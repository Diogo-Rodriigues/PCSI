use std::time::Instant;
use methods::{METHOD_ELF, METHOD_ID};
use risc0_zkvm::{default_prover, ExecutorEnv};
use sha2::{Digest, Sha256};
use std::fs;
use std::io::Write;

fn main() {

    let message = vec![5u8; 2*1024];
    
    let mut hasher = Sha256::new();
    hasher.update(&message);
    let expected_hash: [u8; 32] = hasher.finalize().into();

    let env = ExecutorEnv::builder()
        .write(&(message, expected_hash))
        .unwrap()
        .build()
        .unwrap();

    let prover = default_prover();

    println!("A iniciar a geração da prova (SHA-256 Booleano)...");
    
    let start_proof = Instant::now();
    let prove_info = prover.prove(env, METHOD_ELF).unwrap();
    let receipt = prove_info.receipt;
    let proof_duration = start_proof.elapsed();

    let start_verify = Instant::now();
    receipt.verify(METHOD_ID).unwrap();
    let verify_duration = start_verify.elapsed();

    let is_valid: bool = receipt.journal.decode().unwrap();
    println!("Sucesso! O Guest provou que o Hash é válido? -> {}", is_valid);

    fs::create_dir_all("results").expect("Não foi possível criar a pasta results");
    let receipt_bytes_len = receipt.journal.bytes.len();

    let log_entry = format!(
        "Workload: SHA-256, Proof_Time: {:.6} s, Proof_Size: {} B, Verify_Time: {:.6} s\n",
        proof_duration.as_secs_f64(), 
        receipt_bytes_len,
        verify_duration.as_secs_f64()
    );

    let mut file = fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open("results/benchmarks_sha256.txt")
        .expect("Não foi possível abrir o ficheiro de resultados");

    file.write_all(log_entry.as_bytes()).expect("Erro ao escrever no ficheiro");

    println!(">>> Resultados salvos em: results/benchmarks_sha256.txt");
}
