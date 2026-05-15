# ZKP VOLE Benchmarks

Este repositório contém benchmarks para protocolos Zero-Knowledge Proofs (ZKP) baseados em Vector OLE (VOLE), focando-se em uma biblioteca: **emp-zk**.

Os benchmarks testam duas operações principais:
1. Multiplicação de Matrizes
2. Função Hash SHA-256

Os testes podem ser facilmente executados utilizando o Docker Compose, que simula a execução entre dois participantes (Alice e Bob).

## Estrutura

A pasta `zkp-vole-benchmarks` está organizada da seguinte forma:

* **`docker/`**: Contém os ficheiros `Dockerfile` necessários para construir as imagens dos ambientes de teste para o `emp-zk`.
* **`emp-zk/`**: Contém o código fonte dos benchmarks e testes implementados para a biblioteca `emp-zk`.
* **`results/`**: Pasta mapeada no Docker para armazenar e consultar ficheiros gerados durante os testes (como resultados ou relatórios de output).
* **`docker-compose.yml`**: Ficheiro que define e orquestra todos os serviços Docker, permitindo lançar a Alice e o Bob de forma rápida e conectada na mesma rede.

### O Caso de Uso Avançado: `rosetta_ml`

Dentro da pasta **`advanced_use_cases/rosetta_ml/`**, exploramos um cenário muito mais complexo para demonstrar a escalabilidade massiva dos protocolos da família VOLE.

Enquanto a maioria dos sistemas Zero-Knowledge tradicionais (como SNARKs) teria extrema dificuldade, a framework **Rosetta** (apoiada no `emp-zk` no seu backend) permite-nos provar em Zero-Knowledge a inferência de uma enorme rede neuronal (ResNet101) com milhões de parâmetros!
A pasta contém o necessário para treinar a rede no dataset CIFAR-10 e realizar previsões (classificar imagens) completamente em Zero-Knowledge.

## Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Como Correr os Testes

Para correr qualquer um dos testes, utiliza o comando `docker compose up` seguido dos nomes dos serviços que representam o provador (Alice) e o verificador (Bob).

### Benchmarks do emp-zk

**1. Multiplicação de Matrizes:**
```bash
docker compose up alice-matrix bob-matrix
```

**2. SHA-256:**
```bash
docker compose up alice-sha256 bob-sha256
```

---

**Nota:** Para recompilar as imagens baseadas nos Dockerfiles mais recentes, podes adicionar a flag `--build` ao comando. Exemplo:
```bash
docker compose up --build alice-matrix bob-matrix
```
Para garantires que limpas os containers após a execução, podes usar a flag `--rm` ou correr `docker compose down` no final.
