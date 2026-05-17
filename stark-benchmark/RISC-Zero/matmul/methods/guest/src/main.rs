#![no_main]
#![no_std]
extern crate alloc;

use alloc::vec::Vec;
use risc0_zkvm::guest::env;

risc0_zkvm::guest::entry!(main);

pub fn main() {

    let (a, b, n, threshold): (Vec<u8>, Vec<u8>, usize, u8) = env::read();

    if a.len() != n * n || b.len() != n * n {
        panic!("Tamanho incorreto");
    }

    let mut first_element: u32 = 0;
    for k in 0..n {
        first_element = first_element.wrapping_add((a[k] as u32).wrapping_mul(b[k * n] as u32));
    }

    let condition_met: bool = first_element > threshold as u32;

    env::commit(&condition_met);
}
