package main

// =============================================================================
// PCSI – Benchmarks gnark (Groth16 sobre BN254)
//
// Corre com:  go run main.go
// Benchmark:  go test -v -bench=. -benchmem -count=3 | tee results/bench_output.txt
// =============================================================================

import (
	"crypto/sha256"
	"fmt"
	"os"
	"time"

	"github.com/consensys/gnark-crypto/ecc"
	"github.com/consensys/gnark/backend/groth16"
	"github.com/consensys/gnark/frontend"
	"github.com/consensys/gnark/frontend/cs/r1cs"
	"github.com/consensys/gnark/std/hash/sha2"
	"github.com/consensys/gnark/std/math/uints"
)

// ─────────────────────────────────────────────────────────────────────────────
// Circuito 1 – Multiplicação de Matrizes 4×4
//
// Prova: "Conheço A e B tais que A·B = C" sem revelar A nem B.
// C é público; A e B são o witness privado.
// ─────────────────────────────────────────────────────────────────────────────
const N = 4

type MatrixCircuit struct {
	A [N][N]frontend.Variable            // privado
	B [N][N]frontend.Variable            // privado
	C [N][N]frontend.Variable `gnark:",public"` // público
}

func (c *MatrixCircuit) Define(api frontend.API) error {
	for i := 0; i < N; i++ {
		for j := 0; j < N; j++ {
			var sum frontend.Variable = 0
			for k := 0; k < N; k++ {
				sum = api.Add(sum, api.Mul(c.A[i][k], c.B[k][j]))
			}
			api.AssertIsEqual(c.C[i][j], sum)
		}
	}
	return nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Circuito 2 – SHA-256 Preimage
//
// Prova: "Conheço x tal que SHA-256(x) = digest" sem revelar x.
// O digest é público; x (preimage) é o witness privado.
// ─────────────────────────────────────────────────────────────────────────────
const PreimageLen = 64 // 64 bytes (512 bits), igual ao benchmark Circom

type Sha256Circuit struct {
	Input  [PreimageLen]uints.U8           // privado (preimage)
	Output [32]uints.U8 `gnark:",public"` // público (digest)
}

func (c *Sha256Circuit) Define(api frontend.API) error {
	h, err := sha2.New(api)
	if err != nil {
		return fmt.Errorf("new sha2: %w", err)
	}

	for i := 0; i < PreimageLen; i++ {
		h.Write([]uints.U8{c.Input[i]})
	}
	res := h.Sum()

	uapi, err := uints.New[uints.U32](api)
	if err != nil {
		return fmt.Errorf("new uints api: %w", err)
	}
	for i := 0; i < 32; i++ {
		uapi.ByteAssertEq(c.Output[i], res[i])
	}
	return nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Benchmark helper
// ─────────────────────────────────────────────────────────────────────────────
func runBenchmark(name string, circuit frontend.Circuit, assignment frontend.Circuit) {
	fmt.Printf("\n======================================================================\n")
	fmt.Printf(" BENCHMARK: %s\n", name)
	fmt.Printf("======================================================================\n")

	curve := ecc.BN254

	// 1. Compilar circuito → R1CS
	t0 := time.Now()
	ccs, err := frontend.Compile(curve.ScalarField(), r1cs.NewBuilder, circuit)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Compile error: %v\n", err)
		return
	}
	fmt.Printf("Compile:    %v  (%d constraints R1CS)\n", time.Since(t0), ccs.GetNbConstraints())

	// 2. Trusted Setup Groth16
	t0 = time.Now()
	pk, vk, err := groth16.Setup(ccs)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Setup error: %v\n", err)
		return
	}
	fmt.Printf("Setup:      %v\n", time.Since(t0))

	// 3. Calcular witness completo + público
	t0 = time.Now()
	witness, err := frontend.NewWitness(assignment, curve.ScalarField())
	if err != nil {
		fmt.Fprintf(os.Stderr, "Witness error: %v\n", err)
		return
	}
	publicWitness, _ := witness.Public()
	fmt.Printf("Witness:    %v\n", time.Since(t0))

	// 4. Gerar prova
	t0 = time.Now()
	proof, err := groth16.Prove(ccs, pk, witness)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Prove error: %v\n", err)
		return
	}
	fmt.Printf("Prove:      %v\n", time.Since(t0))

	// 5. Verificar prova
	t0 = time.Now()
	err = groth16.Verify(proof, vk, publicWitness)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Verify FAILED: %v\n", err)
		return
	}
	fmt.Printf("Verify:     %v\n", time.Since(t0))
	fmt.Printf("----------------------------------------------------------------------\n")
	_ = pk
}

func main() {
	// ── Benchmark 1: Multiplicação de Matrizes 4×4 ───────────────────────────
	// A = [[1..4],[5..8],[9..12],[13..16]], B = I₄, C = A
	var matCircuit MatrixCircuit
	var matAssign MatrixCircuit
	for i := 0; i < N; i++ {
		for j := 0; j < N; j++ {
			matAssign.A[i][j] = i*N + j + 1
			if i == j {
				matAssign.B[i][j] = 1
			} else {
				matAssign.B[i][j] = 0
			}
			matAssign.C[i][j] = i*N + j + 1 // A·I = A
		}
	}
	runBenchmark(
		"Groth16 – Multiplicação de Matrizes 4×4",
		&matCircuit,
		&matAssign,
	)

	// ── Benchmark 2: SHA-256 Preimage ────────────────────────────────────────
	// preimage = 64 bytes a zero (igual ao benchmark Circom)
	// digest esperado: f5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a92759fb4b
	preimage := make([]byte, PreimageLen)
	digest := sha256.Sum256(preimage)

	var sha256Circuit Sha256Circuit

	var sha256Assign Sha256Circuit
	for i := 0; i < PreimageLen; i++ {
		sha256Assign.Input[i] = uints.NewU8(preimage[i])
	}
	for i := 0; i < 32; i++ {
		sha256Assign.Output[i] = uints.NewU8(digest[i])
	}

	runBenchmark(
		"Groth16 – SHA-256 Preimage (64 bytes)",
		&sha256Circuit,
		&sha256Assign,
	)

	fmt.Println("\nBenchmarks concluídos. Resultados em: results/bench_output.txt")
}