// host/src/main.rs
use std::time::Instant;
use methods::{METHOD_ELF, METHOD_ID};
use risc0_zkvm::{default_prover, ExecutorEnv};
use std::fs;
use std::io::Write;

fn main() {
    let n: usize = 32;
    let a: Vec<u32> = vec![1; n * n];
    let b: Vec<u32> = vec![2; n * n];

    let env = ExecutorEnv::builder()
        .write(&(a, b, n))
        .unwrap()
        .build()
        .unwrap();

    let prover = default_prover();

    println!("A iniciar a geração da prova (Aritmética)...");
    
    let start_time = Instant::now();
    let prove_info = prover.prove(env, METHOD_ELF).unwrap();
    let receipt = prove_info.receipt;
    let proof_duration = start_time.elapsed();

    let start_verify = Instant::now();
    receipt.verify(METHOD_ID).unwrap();
    let verify_duration = start_verify.elapsed();

    let result: Vec<u32> = receipt.journal.decode().unwrap();

    println!("Sucesso! Prova gerada e verificada.");
    println!("Tempo de prova: {:.6} s", proof_duration.as_secs_f64());
    println!("Tempo de verificação: {:.6} s", verify_duration.as_secs_f64());
    println!("Primeiro elemento do resultado: {}", result[0]);
    
    std::fs::create_dir_all("results").expect("Não foi possível criar a pasta results");
    
    let journal_bytes_len = receipt.journal.bytes.len();

    let receipt_cbor = risc0_zkvm::serde::to_vec(&receipt).unwrap();
    let total_bytes_len = receipt_cbor.len() * 4;
    let seal_bytes_len = total_bytes_len - journal_bytes_len;

    let proof_size = (journal_bytes_len + seal_bytes_len) as f64 / 1024.0;

    let log_entry = format!(
        "Matrix_Size: {}, Proof_Time: {:.6} s, Proof_Size: {:.2} KB, Verify_Time: {:.6} s\n",
        n, 
        proof_duration.as_secs_f64(), 
        proof_size,
        verify_duration.as_secs_f64()
    );

    let mut file = std::fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open("results/benchmarks.txt")
        .expect("Não foi possível abrir o ficheiro de resultados");

    file.write_all(log_entry.as_bytes()).expect("Erro ao escrever no ficheiro");

    println!(">>> Resultados salvos com sucesso em: results/benchmarks.txt");
}
