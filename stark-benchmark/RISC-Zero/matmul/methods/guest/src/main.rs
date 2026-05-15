#![no_main]
#![no_std] // Ativa o modo no_std para evitar o erro de panic_impl

extern crate alloc; // Necessário para usar memória dinâmica sem std
use alloc::vec::Vec;
use alloc::vec;
use risc0_zkvm::guest::env;

risc0_zkvm::guest::entry!(main);

const MATRIX_SIZE: usize = 8;

pub fn main() {
    let a: Vec<u8> = env::read();
    let b: Vec<u8> = env::read();

    if MATRIX_SIZE * MATRIX_SIZE != a.len() {
        // No modo no_std, o panic funciona mas é mais básico
        panic!("Tamanho incorreto");
    }

    let n: usize = MATRIX_SIZE;
    let mut product: Vec<u8> = vec![0; n * n];
    
    for i in 0..n {
        for j in 0..n {
            for k in 0..n {
                // Usamos wrapping_add e mul para evitar overflows que disparam panics complexos
                let index = i * n + j;
                let val_a = a[i * n + k];
                let val_b = b[k * n + j];
                product[index] = product[index].wrapping_add(val_a.wrapping_mul(val_b));
            }
        }
    }

    env::commit(&product);
}


