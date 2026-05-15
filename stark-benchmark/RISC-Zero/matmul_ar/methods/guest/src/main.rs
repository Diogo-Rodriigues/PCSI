#![no_main]
#![no_std]
extern crate alloc;

use alloc::vec::Vec;
use risc0_zkvm::guest::env;

risc0_zkvm::guest::entry!(main);

pub fn main() {
    //Ler as matrizes enviadas pelo Host
    let (a, b, n): (Vec<u32>, Vec<u32>, usize) = env::read();

    //Inicializar a matriz resultado (Aritmética em Campo Finito)
    let mut product = Vec::with_capacity(n * n);

    // 3. Processar a Multiplicação (O que gera o rasto de execução)
    for i in 0..n {
        for j in 0..n {
            let mut sum: u32 = 0;
            for k in 0..n {
                // Multiplicação e Soma Aritmética
                let val_a = a[i * n + k];
                let val_b = b[k * n + j];
                sum = sum.wrapping_add(val_a.wrapping_mul(val_b));
            }
            product.push(sum);
        }
    }

    // 4. Comprometer o resultado (Commit)
    // O resultado vai para o Journal público
    env::commit(&product);
}
