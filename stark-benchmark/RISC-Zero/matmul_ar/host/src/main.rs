// host/src/main.rs
use std::time::Instant;
use methods::{METHOD_ELF, METHOD_ID};
use risc0_zkvm::{default_prover, ExecutorEnv};

fn main() {
    // Configuração das Matrizes (Exemplo 8x8)
    let n: usize = 8;
    let a: Vec<u32> = vec![1; n * n]; // Preenchido com 1s para teste
    let b: Vec<u32> = vec![2; n * n]; // Preenchido com 2s para teste

    // Preparar o ambiente do Executor
    // Enviamos (a, b, n) como uma tupla, tal como o Guest espera ler
    let env = ExecutorEnv::builder()
        .write(&(a, b, n))
        .unwrap()
        .build()
        .unwrap();

    // Inicializar o Prover
    let prover = default_prover();

    println!("A iniciar a geração da prova (Aritmética)...");
    let start_time = Instant::now();

    // Gerar a prova (Prove)
    // O Prover executa o Guest e gera a prova STARK
    let prove_info = prover.prove(env, METHOD_ELF).unwrap();
    let receipt = prove_info.receipt;

    let duration = start_time.elapsed();

    // Verificar a prova
    // Qualquer pessoa com o ID do método e o Receipt pode verificar a integridade
    receipt.verify(METHOD_ID).unwrap();

    //Extrair o resultado do Journal
    let result: Vec<u32> = receipt.journal.decode().unwrap();

    println!("Sucesso! Prova gerada e verificada.");
    println!("Tempo de execução: {:?}", duration);
    println!("Primeiro elemento do resultado: {}", result[0]);
    // Numa matriz 8x8 de 1s por 2s, o resultado deve ser 1*2 * 8 = 16
}
