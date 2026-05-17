#![no_main]
#![no_std]
extern crate alloc;

use alloc::vec::Vec;
use risc0_zkvm::guest::env;

risc0_zkvm::guest::entry!(main);

pub fn main() {
    let (a, b, n): (Vec<u32>, Vec<u32>, usize) = env::read();

    let mut product = Vec::with_capacity(n * n);

    for i in 0..n {
        for j in 0..n {
            let mut sum: u32 = 0;
            for k in 0..n {
                let val_a = a[i * n + k];
                let val_b = b[k * n + j];
                sum = sum.wrapping_add(val_a.wrapping_mul(val_b));
            }
            product.push(sum);
        }
    }

    env::commit(&product);
}
