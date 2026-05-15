# Projeto em Criptografia e Segurança de Informação (PCSI)

Este repositório contém o código e os benchmarks desenvolvidos no âmbito da disciplina de Projeto em Criptografia e Segurança de Informação (PCSI). O objetivo central do projeto é estudar, avaliar e comparar diferentes paradigmas de **Zero-Knowledge Proofs (ZKP)**, aferindo a sua performance, escalabilidade e casos de uso adequados.

Os benchmarks focam-se na execução de operações variadas (como multiplicações de matrizes e funções hash SHA-256) através de diversas abordagens modernas da criptografia.

## Estrutura do Projeto

O repositório está dividido em quatro áreas principais de estudo de ZKPs, cada uma explorando bibliotecas e protocolos específicos:

* **`mpc-in-the-head/`**: Explora os protocolos baseados no paradigma *MPC-in-the-Head* (Multi-Party Computation in the Head).
  * Inclui implementações e benchmarks testando **Ligero** e **Picnic**.

* **`snark-benchmark/`**: Focado nos sistemas **SNARKs** (Zero-Knowledge Succinct Non-Interactive Arguments of Knowledge).
  * Inclui avaliações usando ecossistemas de referência como **Circom** e **Gnark**.

* **`stark-benchmark/`**: Estudo centrado em **STARKs** (Zero-Knowledge Scalable Transparent Arguments of Knowledge).
  * Inclui implementações focadas em provas usando as máquinas virtuais de ZK da **RISC-Zero**.

* **`zkp-vole-benchmarks/`**: Focado nos protocolos altamente escaláveis da família **Vector OLE (VOLE)**.
  * Inclui benchmarks para a biblioteca **emp-zk** . 
  * **Caso de Uso Avançado:** Esta pasta também abriga testes com a framework **Rosetta**, demonstrando a capacidade do *emp-zk* no backend para provar em Zero-Knowledge a inferência de modelos pesados de Machine Learning, como uma rede neuronal ResNet101.

## Como Executar os Benchmarks

Dado que o projeto cobre vários paradigmas que assentam em linguagens e frameworks completamente distintas (C++, Rust, Go, Python, etc.), **cada subpasta contém o seu próprio ficheiro `README.md`**. Esses ficheiros incluem as instruções específicas sobre pré-requisitos, compilação e execução dos testes para essa categoria em particular.

Sempre que possível, fornecemos configurações **Docker / Docker Compose** (como é o caso na pasta `zkp-vole-benchmarks`) para garantir que podes replicar e testar tudo num ambiente completamente isolado e sem complicações de dependências locais.
