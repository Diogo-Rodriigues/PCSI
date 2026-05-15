#!/bin/bash
# =============================================================================
# Benchmark: Picnic
#
# Picnic prova conhecimento de uma chave privada (preimage de LowMC)
# usando MPC-in-the-Head. É uma assinatura, não uma ZKP genérica.
#
# Parâmetros testados (segurança pós-quântica NIST):
#   picnic3_L1 → 128 bits de segurança (menor/mais rápido)
#   picnic3_L3 → 192 bits de segurança
#   picnic3_L5 → 256 bits de segurança (maior/mais lento)
#
# Corre DENTRO do Docker:
#   docker build -t picnic-bench . && docker run --rm picnic-bench
#
# Ou localmente se tiveres o Picnic compilado:
#   bash scripts/run_bench.sh
# =============================================================================
set -e

RESULTS_DIR="results"
mkdir -p "$RESULTS_DIR"
OUTPUT="$RESULTS_DIR/bench_output.txt"
> "$OUTPUT"

# Localizar o executável (dentro do Docker ou local)
if [ -f "/picnic/example" ]; then
    PICNIC_BIN="/picnic/example"
elif [ -f "./example" ]; then
    PICNIC_BIN="./example"
else
    echo "ERRO: executável 'example' não encontrado." | tee -a "$OUTPUT"
    echo "Compila o Picnic primeiro: cmake . && make" | tee -a "$OUTPUT"
    exit 1
fi

PARAMS=("picnic3_L1" "picnic3_L3" "picnic3_L5")
ITERATIONS=10

echo "================================================================" | tee -a "$OUTPUT"
echo " BENCHMARK: Picnic (MPC-in-the-Head)" | tee -a "$OUTPUT"
echo " Iterações por parâmetro: $ITERATIONS" | tee -a "$OUTPUT"
echo "================================================================" | tee -a "$OUTPUT"

for PARAM in "${PARAMS[@]}"; do
    echo "" | tee -a "$OUTPUT"
    echo "--- $PARAM ---" | tee -a "$OUTPUT"

    # KeyGen + Sign + Verify (o executável 'example' faz os 3)
    echo "KeyGen + Sign + Verify ($ITERATIONS iterações):" | tee -a "$OUTPUT"
    { time (for i in $(seq 1 $ITERATIONS); do $PICNIC_BIN $PARAM; done); } \
        2>&1 | tee -a "$OUTPUT"

    # Gerar uma assinatura real e medir o tamanho
    echo "Tamanho da assinatura:" | tee -a "$OUTPUT"
    $PICNIC_BIN $PARAM 2>/dev/null | grep -i "signature\|size\|bytes" | tee -a "$OUTPUT" || true
done

echo "" | tee -a "$OUTPUT"
echo "Resultados guardados em: $OUTPUT"
