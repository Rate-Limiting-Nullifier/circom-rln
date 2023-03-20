pragma circom 2.1.0;

template IsInInterval(n) {
    signal input in[3];

    signal output out;

    signal let <== LessEqThan(n)([in[1], in[2]]);
    signal get <== GreaterEqThan(n)([in[1], in[0]]);

    out <== let * get;
}