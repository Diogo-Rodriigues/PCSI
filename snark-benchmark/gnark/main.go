package main

// =============================================================================
// PCSI – Benchmarks gnark (Groth16 sobre BN254)
//
// Dois circuitos, análogos ao que o colega fez com emp-zk:
//   1. MatrixCircuit  – Multiplicação de Matrizes 4×4 (aritmético)
//   2. CubicCircuit   – x³+x+5=y (baseline aritmético simples)
//
// Corre com:  go run main.go
// Benchmark:  go test -v -bench=. -benchmem -count=3 | tee results/bench_output.txt
// =============================================================================

import (
	"fmt"
	"os"
	"time"

	"github.com/consensys/gnark-crypto/ecc"
	"github.com/consensys/gnark/backend/groth16"
	"github.com/consensys/gnark/frontend"
	"github.com/consensys/gnark/frontend/cs/r1cs"
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
// Circuito 2 – Polinómio Cúbico (baseline)
//
// Prova: "Conheço x tal que x³ + x + 5 = y"
// y é público; x é o witness privado.
// ─────────────────────────────────────────────────────────────────────────────
type CubicCircuit struct {
	X frontend.Variable
	Y frontend.Variable `gnark:",public"`
}

func (c *CubicCircuit) Define(api frontend.API) error {
	x3 := api.Mul(c.X, c.X, c.X)
	api.AssertIsEqual(c.Y, api.Add(x3, c.X, 5))
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
	compileTime := time.Since(t0)
	fmt.Printf("Compile:    %v  (%d constraints R1CS)\n", compileTime, ccs.GetNbConstraints())

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
	proveTime := time.Since(t0)
	fmt.Printf("Prove:      %v\n", proveTime)

	// 5. Verificar prova
	t0 = time.Now()
	err = groth16.Verify(proof, vk, publicWitness)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Verify FAILED: %v\n", err)
		return
	}
	verifyTime := time.Since(t0)
	fmt.Printf("Verify:     %v\n", verifyTime)
	fmt.Printf("----------------------------------------------------------------------\n")
	_ = pk
}

func main() {
	// ── Benchmark 1: Cúbico (baseline) ───────────────────────────────────────
	// x=3 → 3³+3+5 = 35
	runBenchmark(
		"Groth16 – Cúbico (x³+x+5=y)",
		&CubicCircuit{},
		&CubicCircuit{X: 3, Y: 35},
	)

	// ── Benchmark 2: Multiplicação de Matrizes 4×4 ───────────────────────────
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

	fmt.Println("\nBenchmarks concluídos. Resultados em: results/bench_output.txt")
}
