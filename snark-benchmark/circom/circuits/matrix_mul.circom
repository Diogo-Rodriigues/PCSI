pragma circom 2.0.0;

// ─────────────────────────────────────────────────────────────────────────────
// Circuito: Multiplicação de Matrizes N×N
//
// Prova: "Conheço matrizes A e B tais que A·B = C"
//
// Público  → c[N][N]       : resultado da multiplicação
// Privado  → a[N][N], b[N][N] : as matrizes (witness)
//
// N=32 → 32^3 = 32768 multiplicações → 32768 constraints R1CS
// ─────────────────────────────────────────────────────────────────────────────
template MatrixMul(N) {
    signal input a[N][N];    // privado
    signal input b[N][N];    // privado
    signal input c[N][N];    // público

    signal partial[N][N][N];
    signal acc[N][N][N+1];

    for (var i = 0; i < N; i++) {
        for (var j = 0; j < N; j++) {
            acc[i][j][0] <== 0;
            for (var k = 0; k < N; k++) {
                partial[i][j][k] <== a[i][k] * b[k][j];
                acc[i][j][k+1] <== acc[i][j][k] + partial[i][j][k];
            }
            c[i][j] === acc[i][j][N];
        }
    }
}

component main { public [c] } = MatrixMul(32);
