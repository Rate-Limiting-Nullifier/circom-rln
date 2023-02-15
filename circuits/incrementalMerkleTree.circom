pragma circom 2.1.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template MerkleTreeInclusionProof(depth) {
    signal input leaf;
    signal input path_index[depth];
    signal input path_elements[depth][1];

    signal output root;

    component mux[depth];

    signal levelHashes[depth + 1];
    
    levelHashes[0] <== leaf;
    for (var i = 0; i < depth; i++) {
        path_index[i] * (path_index[i] - 1) === 0;

        mux[i] = MultiMux1(2);

        mux[i].c[0][0] <== levelHashes[i];
        mux[i].c[0][1] <== path_elements[i][0];

        mux[i].c[1][0] <== path_elements[i][0];
        mux[i].c[1][1] <== levelHashes[i];

        mux[i].s <== path_index[i];

        levelHashes[i + 1] <== Poseidon(2)([mux[i].out[0], mux[i].out[1]]);
    }

    root <== levelHashes[depth];
}