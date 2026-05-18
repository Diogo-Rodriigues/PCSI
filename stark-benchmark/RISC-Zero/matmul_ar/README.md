# Workload: Multiplicação de Matrizes Aritméticas

Este módulo implementa um benchmark de multiplicação de matrizes quadradas ($N \times N$).

## Objetivo do Teste
Isolar e medir a performance da framework em **Arithmetic Workloads**.

## Métricas Capturadas
O script do Host executa o teste e regista de forma automatizada em `results/benchmarks.txt`:
* **Matrix_Size ($N$):** Dimensão da matriz testada (ex: 16, 32).
* **Proof_Time (s):** Tempo total gasto pelo Prover para gerar os polinómios e o *Seal*.
* **Proof_Size (B):** Tamanho em bytes do Journal público gerado.
* **Verify_Time (s):** Tempo gasto pelo Verifier para validar matematicamente o recibo.

## Como Executar
Navega até à pasta deste projeto e executa:
```bash
cargo run --release
