# Workload: Multiplicação de Matrizes Booleanas 

Este módulo implementa um benchmark de multiplicação de matrizes quadradas ($N \times N$).

## Objetivo do Teste
Isolar e medir a performance da framework para multiplicação de matrizes boleanas

## Métricas Capturadas
Os resultados são anexados de forma automatizada em `results/benchmarks_bool.txt`:
* **Matrix_Size ($N$):** Dimensão da matriz testada (ex: 8, 16, 32).
* **Proof_Time (s):** Tempo gasto para gerar os polinómios e a prova com dados `u8`.
* **Proof_Size (B):** Tamanho final do Journal público.
* **Verify_Time (s):** Tempo de validação do recibo pelo Verifier.

## Como Executar
Navega até à pasta deste projeto e executa:
```bash
cargo run --release
