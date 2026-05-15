#!/bin/bash
# =============================================================================
# Benchmark: Circom + SnarkJS (Groth16 sobre BN254)
#
# Dependências: node >= 18, circom >= 2.0, snarkjs >= 0.7
#   npm install -g circom snarkjs
#   npm install          (instala circomlib localmente)
# =============================================================================
set -e

RESULTS="results"
BUILD="build"
mkdir -p "$RESULTS" "$BUILD"

# Instalar circomlib se não estiver presente
[ ! -d node_modules ] && npm install

run_benchmark() {
    local NAME=$1        # ex: sha256_preimage
    local INPUT=$2       # ex: input/sha256_input.json
    local POT_SIZE=$3    # ex: 16 (2^16 constraints máx)

    echo ""
    echo "======================================================================"
    echo " BENCHMARK: $NAME"
    echo "======================================================================"

    # 1. Compilar circuito → R1CS + WASM
    echo "[1/6] A compilar circuito..."
    circom "circuits/${NAME}.circom" --r1cs --wasm --sym -o "$BUILD"

    # 2. Powers of Tau (fase 1 do trusted setup)
    echo "[2/6] Powers of Tau (pot${POT_SIZE})..."
    snarkjs powersoftau new bn128 "$POT_SIZE" "$BUILD/pot_0.ptau" -v
    snarkjs powersoftau contribute "$BUILD/pot_0.ptau" "$BUILD/pot_1.ptau" \
        --name="PCSI" -v -e="pcsi-entropy-$(date +%s)"
    snarkjs powersoftau prepare phase2 "$BUILD/pot_1.ptau" "$BUILD/pot_final.ptau" -v

    # 3. Setup Groth16 (fase 2)
    echo "[3/6] Setup Groth16..."
    snarkjs groth16 setup "$BUILD/${NAME}.r1cs" "$BUILD/pot_final.ptau" "$BUILD/${NAME}_0.zkey"
    snarkjs zkey contribute "$BUILD/${NAME}_0.zkey" "$BUILD/${NAME}_final.zkey" \
        --name="PCSI" -e="pcsi-entropy-$(date +%s)"
    snarkjs zkey export verificationkey "$BUILD/${NAME}_final.zkey" \
        "$RESULTS/${NAME}_vkey.json"

    # 4. Calcular witness
    echo "[4/6] A calcular witness..."
    node "$BUILD/${NAME}_js/generate_witness.js" \
        "$BUILD/${NAME}_js/${NAME}.wasm" \
        "$INPUT" \
        "$BUILD/${NAME}_witness.wtns"

    # 5. Gerar prova e medir tempo
    echo "[5/6] A gerar prova (Groth16 Prove)..."
    echo "--- $NAME: PROVE ---" >> "$RESULTS/bench_output.txt"
    { time snarkjs groth16 prove \
        "$BUILD/${NAME}_final.zkey" \
        "$BUILD/${NAME}_witness.wtns" \
        "$RESULTS/${NAME}_proof.json" \
        "$RESULTS/${NAME}_public.json"; } 2>&1 | tee -a "$RESULTS/bench_output.txt"

    # 6. Verificar prova e medir tempo
    echo "[6/6] A verificar prova (Groth16 Verify)..."
    echo "--- $NAME: VERIFY ---" >> "$RESULTS/bench_output.txt"
    { time snarkjs groth16 verify \
        "$RESULTS/${NAME}_vkey.json" \
        "$RESULTS/${NAME}_public.json" \
        "$RESULTS/${NAME}_proof.json"; } 2>&1 | tee -a "$RESULTS/bench_output.txt"

    # Tamanho da prova
    PROOF_SIZE=$(wc -c < "$RESULTS/${NAME}_proof.json")
    echo "Tamanho da prova: $PROOF_SIZE bytes" | tee -a "$RESULTS/bench_output.txt"
    echo "----------------------------------------------------------------------"
}

# ── Executar os dois benchmarks ───────────────────────────────────────────────
run_benchmark "sha256_preimage"  "input/sha256_input.json"  16
run_benchmark "matrix_mul"       "input/matrix_input.json"  14

echo ""
echo "Resultados guardados em: $RESULTS/"
