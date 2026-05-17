#![no_main]
#![no_std]
extern crate alloc;

use alloc::vec::Vec;
use risc0_zkvm::guest::env;
use sha2::{Digest, Sha256};

risc0_zkvm::guest::entry!(main);

pub fn main() {

    let (message, expected_hash): (Vec<u8>, [u8; 32]) = env::read();

    let mut hasher = Sha256::new();
    hasher.update(&message);
    let result = hasher.finalize();

    let is_valid = result.as_slice() == expected_hash;

    env::commit(&is_valid);
}
