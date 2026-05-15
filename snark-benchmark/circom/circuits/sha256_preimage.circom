pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/sha256/sha256.circom";

// ─────────────────────────────────────────────────────────────────────────────
// Circuito: SHA-256 Preimage
//
// Prova: "Conheço um preimage P (512 bits) tal que SHA256(P) = H"
//
// Público  → hash[256]     : os 256 bits do digest esperado
// Privado  → preimage[512] : os 512 bits do input (witness)
// ─────────────────────────────────────────────────────────────────────────────
template SHA256Preimage() {
    signal input  preimage[512];   // privado
    signal input  hash[256];       // público

    component sha = Sha256(512);

    for (var i = 0; i < 512; i++) {
        sha.in[i] <== preimage[i];
    }

    // Garante que o output do circuito bate com o hash declarado
    for (var i = 0; i < 256; i++) {
        sha.out[i] === hash[i];
    }
}

component main { public [hash] } = SHA256Preimage();
