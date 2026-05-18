# Workload: Verificação de Hash SHA-256

Este módulo implementa a validação de integridade de dados através do algoritmo SHA-256 executado de forma privada dentro da máquina virtual.

## O "Impedance Mismatch"
Este benchmark inverte por completo o perfil computacional dos testes anteriores. O SHA-256 não utiliza matemática de campos finitos; baseia-se puramente em **operações bitwise** (XOR, AND, NOT, SHIFT e rotações de bits). 

Este workload expõe o impacto de emular circuitos lógicos de bits em cima de uma arquitetura nativamente algébrica. Cada rotação de bits força a zkVM a gerar milhares de ciclos de CPU emulados, resultando num tempo de prova substancialmente mais elevado por bloco de dados processado.

## Métricas Capturadas
Os resultados são anexados de forma automatizada em `results/benchmarks_sha256.txt`:
* **Workload:** Identificação do algoritmo (SHA-256).
* **Proof_Time (s):** Tempo total gasto pelo Prover para processar os blocos de bits e gerar a prova.
* **Proof_Size (B):** Tamanho final do Journal público (que neste caso contém apenas o veredito booleano).
* **Verify_Time (s):** Tempo gasto pelo Verifier para validar o recibo.

## Como Executar
Navega até à pasta deste projeto e executa:
```bash
cargo run --release
