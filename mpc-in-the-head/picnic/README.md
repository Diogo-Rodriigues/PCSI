# Picnic - Benchmarks MPC-in-the-Head

Picnic e um esquema de assinatura pos-quantica baseado em MPC-in-the-Head. Usa o cifrador de bloco LowMC como one-way function e prova conhecimento da chave privada sem a revelar.

## Ambiente de Teste

- **Maquina:** Windows 11 (via Docker, imagem `debian:bullseye`)
- **Implementacao:** IAIK/Picnic (repositorio oficial NIST Round 3)
- **Mensagem assinada:** 500 bytes
- **Iteracoes:** 10 por parametro

## Resultados

### Tempos (10 iteracoes, KeyGen + Sign + Verify)

| Parametro | Tempo total (10x) | Media por iteracao |
|---|---|---|
| picnic3_L1 | 4.4 s | ~440 ms |
| picnic3_L3 | 4.7 s | ~470 ms |
| picnic3_L5 | 4.2 s | ~420 ms |

### Tamanhos de assinatura (mensagem de 500 bytes)

| Parametro | Seguranca | Tamanho max | Tamanho real (aprox) |
|---|---|---|---|
| Picnic3_L1 | 128 bits | 14 608 bytes | ~12 400 bytes |
| Picnic3_L3 | 192 bits | 35 024 bytes | ~27 500 bytes |
| Picnic3_L5 | 256 bits | 61 024 bytes | ~48 500 bytes |
| Picnic_L1_FS | 128 bits | 34 032 bytes | ~32 800 bytes |
| Picnic_L1_UR | 128 bits | 53 961 bytes | 53 961 bytes (fixo) |
| Picnic_L3_FS | 192 bits | 76 772 bytes | ~74 200 bytes |
| Picnic_L3_UR | 192 bits | 121 845 bytes | 121 845 bytes (fixo) |
| Picnic_L5_FS | 256 bits | 132 856 bytes | ~128 200 bytes |
| Picnic_L5_UR | 256 bits | 209 506 bytes | 209 506 bytes (fixo) |
| Picnic_L1_full | 128 bits | 32 061 bytes | ~30 800 bytes |
| Picnic_L3_full | 192 bits | 71 179 bytes | ~68 500 bytes |
| Picnic_L5_full | 256 bits | 126 286 bytes | ~121 700 bytes |

## Observacoes

- O **Picnic3 e claramente o melhor**: assinaturas ~2.5x mais pequenas que o Picnic_FS
  ao mesmo nivel de seguranca (ex: L1: ~12 400 vs ~32 800 bytes).
- O **tamanho da assinatura varia entre runs** porque o Picnic usa aleatoriedade
  interna no processo de sign -- e comportamento esperado e correto.
- O **Picnic_UR tem tamanho fixo** (nao varia entre runs) porque o transform de
  Unruh produz provas de tamanho deterministico.
- Comparando com os SNARKs (gnark/circom): as assinaturas Picnic sao muito maiores
  (~12-200 KB vs ~800 bytes no Groth16), mas o Picnic nao precisa de trusted setup
  e e resistente a computadores quanticos.
- Todos os testes passaram: KeyGen, Sign, Verify, serializacao de chave publica
  e privada para todos os parametros.

## Como Correr

```powershell
# Dentro da pasta mpc-in-the-head\picnic
docker-compose up --build

# Para guardar resultados
docker-compose up 2>&1 | Set-Content -Encoding utf8 results\bench_output.txt
```