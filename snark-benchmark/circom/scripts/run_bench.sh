#!/bin/bash
set -e

RESULTS="results"
BUILD="build"
mkdir -p "$RESULTS" "$BUILD"

[ ! -d node_modules ] && npm install

run_benchmark() {
    local NAME=$1
    local INPUT=$2
    local POT_SIZE=$3
    local PTAU="$BUILD/pot_final_${POT_SIZE}.ptau"

    echo ""
    echo "======================================================================"
    echo " BENCHMARK: $NAME"
    echo "======================================================================"

    # 1. Compilar circuito
    echo "[1/6] A compilar circuito..."
    circom "circuits/${NAME}.circom" --r1cs --wasm --sym -o "$BUILD"

    # 2. Descarregar ptau pré-gerado (uma vez por tamanho)
    if [ ! -f "$PTAU" ]; then
        echo "[2/6] A descarregar Powers of Tau (pot${POT_SIZE})..."
        curl -L -o "$PTAU" \
    "https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_${POT_SIZE}.ptau"
    else
        echo "[2/6] Powers of Tau (pot${POT_SIZE}) já existe, a saltar..."
    fi

    # 3. Setup Groth16
    echo "[3/6] Setup Groth16..."
    START_SETUP=$(date +%s%N)
    snarkjs groth16 setup "$BUILD/${NAME}.r1cs" "$PTAU" "$BUILD/${NAME}_0.zkey"
    snarkjs zkey contribute "$BUILD/${NAME}_0.zkey" "$BUILD/${NAME}_final.zkey" \
        --name="PCSI" -e="pcsi-entropy-$(date +%s)"
    snarkjs zkey export verificationkey "$BUILD/${NAME}_final.zkey" \
        "$RESULTS/${NAME}_vkey.json"
    END_SETUP=$(date +%s%N)
    DIFF_SETUP=$(( (END_SETUP - START_SETUP) / 1000000 ))

    echo "--- $NAME: SETUP ---" >> "$RESULTS/bench_output.txt"
    echo "Setup Time: ${DIFF_SETUP} ms" | tee -a "$RESULTS/bench_output.txt"

    # 4. Calcular witness
    echo "[4/6] A calcular witness..."
    node "$BUILD/${NAME}_js/generate_witness.js" \
        "$BUILD/${NAME}_js/${NAME}.wasm" \
        "$INPUT" \
        "$BUILD/${NAME}_witness.wtns"

    # 5. Gerar prova
    echo "[5/6] A gerar prova..."
    echo "--- $NAME: PROVE ---" >> "$RESULTS/bench_output.txt"
    { time snarkjs groth16 prove \
        "$BUILD/${NAME}_final.zkey" \
        "$BUILD/${NAME}_witness.wtns" \
        "$RESULTS/${NAME}_proof.json" \
        "$RESULTS/${NAME}_public.json"; } 2>&1 | tee -a "$RESULTS/bench_output.txt"

    # 6. Verificar prova
    echo "[6/6] A verificar prova..."
    echo "--- $NAME: VERIFY ---" >> "$RESULTS/bench_output.txt"
    { time snarkjs groth16 verify \
        "$RESULTS/${NAME}_vkey.json" \
        "$RESULTS/${NAME}_public.json" \
        "$RESULTS/${NAME}_proof.json"; } 2>&1 | tee -a "$RESULTS/bench_output.txt"

    PROOF_SIZE=$(wc -c < "$RESULTS/${NAME}_proof.json")
    echo "Tamanho da prova: $PROOF_SIZE bytes" | tee -a "$RESULTS/bench_output.txt"
    echo "----------------------------------------------------------------------"
}

run_benchmark "sha256_preimage"  "input/sha256_input.json"  16
run_benchmark "matrix_mul"       "input/matrix_input.json"  17

echo ""
echo "Resultados guardados em: $RESULTS/"