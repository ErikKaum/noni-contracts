pragma circom 2.0.3;

template Main(m, n) {
    signal input A[m][n]; // This is the final layer of the nn, aka secret
    signal input x[n]; // This is the input to the final layer. aka the embedded input for now and the board state in the future
    signal output out[m]; // This is the output, the q values for each board position.

    signal s[m][n + 1];        
    for (var i = 0; i < m; i++) {
        s[i][0] <== 0;
        for (var j = 1; j <= n; j++) {
            s[i][j] <== s[i][j-1] + A[i][j-1] * x[j-1];
        }
        out[i] <== s[i][n] + 1000000000;
        log(out[i]);
    }
}

component main = Main(9,32);

