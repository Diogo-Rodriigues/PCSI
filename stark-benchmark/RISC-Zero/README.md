# Benchmark: RISC Zero zkVM

Utilização da Framework RISC Zero.

## Documentação e API
Para uma compreensão profunda de como otimizar o desempenho, gerir segmentos de execução e utilizar as ferramentas de profiling da framework, consulte a documentação no site:

 **[RISC Zero API Documentation](https://dev.risczero.com/api)**

---

##  Como Executar o Benchmark
Para obter métricas fiáveis, é obrigatório usar o modo **release**. Isto ativa as otimizações do compilador Rust e do acelerador da zkVM.

```bash
cargo run --release
