use std::time;
use std::fs;
use std::io::Write;

use matmul_methods::{MATMUL_ELF, MATMUL_ID};
use risc0_zkvm::{default_prover, ExecutorEnv};

const MATRIX_SIZE: usize = 32;

fn main() {
    let a: Vec<u8> = vec![0; MATRIX_SIZE * MATRIX_SIZE];
    let b: Vec<u8> = vec![0; MATRIX_SIZE * MATRIX_SIZE];
    let threshold: u8 = 100;

    let env = ExecutorEnv::builder()
        .write(&(a, b, MATRIX_SIZE, threshold)).unwrap()
        .build()
        .unwrap();

    let prover = default_prover();

    println!("A iniciar o teste para Matriz {}x{}...", MATRIX_SIZE, MATRIX_SIZE);

    let start_proof = time::Instant::now();
    let info = prover.prove(env, MATMUL_ELF).unwrap();
    let proof_time_secs = start_proof.elapsed().as_secs_f64();

    let proof_size = info.receipt.journal.bytes.len();

    let start_verify = time::Instant::now();
    info.receipt.verify(MATMUL_ID).unwrap();
    let verify_time_secs = start_verify.elapsed().as_secs_f64();

    let c: Vec<u8> = info.receipt.journal.decode().unwrap();
    println!("Janela de verificação concluída com sucesso.");

    println!("\n--- RESULTADOS DO TESTE ---");
    println!("Proof time: {:.6} s", proof_time_secs);
    println!("Proof size: {} B", proof_size);
    println!("Verify time: {:.6} s", verify_time_secs);

    fs::create_dir_all("results").expect("Não foi possível criar a pasta results");

    let log_entry = format!(
        "Matrix_Size: {}, Proof_Time: {:.6} s, Proof_Size: {} B, Verify_Time: {:.6} s\n",
        MATRIX_SIZE, proof_time_secs, proof_size, verify_time_secs
    );

    let mut file = fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open("results/benchmarks_bool.txt")
        .expect("Não foi possível abrir o ficheiro de resultados");

    file.write_all(log_entry.as_bytes()).expect("Erro ao escrever no ficheiro");

    println!(">>> Guardado em: results/benchmarks_bool.txt\n");
}
