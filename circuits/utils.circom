pragma circom 2.1.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template MerkleTreeInclusionProof(DEPTH) {
    signal input leaf;
    signal input pathIndex[DEPTH];
    signal input pathElements[DEPTH];

    signal output root;

    signal mux[DEPTH][2];
    signal levelHashes[DEPTH + 1];
    
    levelHashes[0] <== leaf;
    for (var i = 0; i < DEPTH; i++) {
        pathIndex[i] * (pathIndex[i] - 1) === 0;

        mux[i] <== MultiMux1(2)(
            [
                [levelHashes[i], pathElements[i]], 
                [pathElements[i], levelHashes[i]]
            ], 
            pathIndex[i]
        );

        levelHashes[i + 1] <== Poseidon(2)([mux[i][0], mux[i][1]]);
    }

    root <== levelHashes[DEPTH];
}

template IsInInterval(LIMIT_BIT_SIZE) {
    signal input in[3];

    signal output out;

    signal firstCmp <== LessEqThan(LIMIT_BIT_SIZE)([in[0], in[1]]);
    signal secondCmp <== LessEqThan(LIMIT_BIT_SIZE)([in[1], in[2]]);

    out <== firstCmp * secondCmp;
}