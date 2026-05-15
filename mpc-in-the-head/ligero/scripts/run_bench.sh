#!/bin/bash
set -e

RESULTS_DIR="/results"
mkdir -p "$RESULTS_DIR"
OUTPUT="$RESULTS_DIR/bench_output.txt"
> "$OUTPUT"

# O binário de profiling real
INSTRUMENT_BIN="/libiop/build/libiop/instrument_ligero_snark"
# O teste unitário (alternativa)
TEST_BIN="/libiop/build/libiop/test_ligero_snark"

echo "================================================================" | tee -a "$OUTPUT"
echo " BENCHMARK: Ligero (IOP sobre R1CS)"                              | tee -a "$OUTPUT"
echo " $(date)"                                                          | tee -a "$OUTPUT"
echo "================================================================" | tee -a "$OUTPUT"

if [ -x "$INSTRUMENT_BIN" ]; then
    echo "A usar instrument_ligero_snark..." | tee -a "$OUTPUT"
    # Este binário aceita parâmetros, verifica a ajuda
    "$INSTRUMENT_BIN" --help 2>&1 | head -20 | tee -a "$OUTPUT" || true
    echo "" | tee -a "$OUTPUT"
    # Corre com defaults (o binário define os seus próprios tamanhos)
    { time "$INSTRUMENT_BIN"; } 2>&1 | tee -a "$OUTPUT"
else
    echo "instrument_ligero_snark não encontrado, a usar test..." | tee -a "$OUTPUT"
    if [ -x "$TEST_BIN" ]; then
        { time "$TEST_BIN"; } 2>&1 | tee -a "$OUTPUT"
    else
        echo "ERRO: nenhum binário ligero encontrado." | tee -a "$OUTPUT"
        echo "Binários disponíveis:" | tee -a "$OUTPUT"
        find /libiop/build -type f -executable | tee -a "$OUTPUT"
        exit 1
    fi
fi

echo "" | tee -a "$OUTPUT"
echo "Resultados guardados em: $OUTPUT"