# Benchmark: RISC Zero zkVM

Utilização da framework RISC Zero para geração e verificação de provas ZK.

---

## Documentação e API

Para uma compreensão profunda de como instalar a zkVM e como utilizá-la, consulte a documentação oficial:

**[RISC Zero API Documentation](https://dev.risczero.com/api)**

---

## Como Executar o Benchmark

Para obter métricas fiáveis, é aconselhado usar o modo `release`. Isto ativa as otimizações do compilador Rust e do acelerador da zkVM, evitando consumos excessivos de memória e pânicos no ambiente de execução.

```bash
cargo run --release
```

---

## Como Criar um Novo Projeto do Zero

A framework disponibiliza um gerador de templates oficial que configura automaticamente o ambiente de workspace necessário para ligar o Host à VM.

Para criar um novo projeto, executa o seguinte comando na raiz do teu espaço de trabalho:

```bash
cargo risczero new nome_do_projeto
```

---

## Estrutura Geral de Pastas do Projeto

Após a criação, o projeto vem organizado como um Cargo Workspace dividido em duas entidades computacionais distintas:

```
nome_do_projeto/
├── Cargo.toml               # Configuração do Workspace (combina o Host e o Guest)
├── rust-toolchain.toml      # Define a versão específica do Rust e da toolchain RISC-V
├── host/                    # O COMPONENTE VERIFICADOR
│   ├── Cargo.toml           # Dependências do Host (ex: risc0-zkvm, serializadores)
│   └── src/
│       └── main.rs          # Código principal que orquestra, cronometra e verifica a prova
└── methods/                 # O COMPONENTE PROVADOR
    ├── Cargo.toml
    ├── guest/               # O CÓDIGO DA MÁQUINA VIRTUAL
    │   ├── Cargo.toml       # Dependências restritas do Guest
    │   └── src/
    │       └── main.rs      # Algoritmo principal executado de forma privada dentro da zkVM
    └── src/
        └── lib.rs           # Gera automaticamente as constantes ELF e ID para o Host
```

### O Papel de Cada Componente no Fluxo ZK

| Componente | Papel |
|---|---|
| `methods/guest/` | **The Black Box** — corre o algoritmo cuja execução queres provar. Compila para uma arquitetura isolada de 32 bits RISC-V. Sem acesso ao exterior (`no_std`). |
| `host/` | **The Brain** — alimenta a VM com dados públicos/privados, aciona a geração da prova matemática (Seal) e valida o recibo final usando o Method ID do Guest. |

---

## Guia de Implementação

Quando quiseres aplicar a framework a um novo problema podes seguir esta ordem de edição:

### 1. Guest — `methods/guest/src/main.rs`

O Guest lê os dados, processa-os e expõe apenas o resultado estrito.

- Usa `env::read()` para receber o que o Host injetar:
  ```rust
  let dados: Tipo = env::read();
  ```
- Desenvolve o algoritmo em Rust puro. Podes adicionar crates externas ao `guest/Cargo.toml`, desde que suportem ambientes `no_std`.
- Usa `env::commit()` para gravar os dados que queres tornar públicos no Journal:
  ```rust
  env::commit(&resultado);
  ```

### 2. Host — `host/src/main.rs`

O Host prepara os inputs e captura os tempos exatos do benchmark.

- Altera as variáveis de input para corresponderem ao tamanho do teste desejado.
- Ajusta a tupla no builder do ambiente para coincidir com a ordem de leitura do Guest:
  ```rust
  ExecutorEnv::builder()
      .write(&(input1, input2)).unwrap()
      .build().unwrap();
  ```

