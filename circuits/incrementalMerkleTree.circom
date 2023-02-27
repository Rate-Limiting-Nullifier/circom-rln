pragma circom 2.1.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template MerkleTreeInclusionProof(depth) {
    signal input leaf;
    signal input path_index[depth];
    signal input path_elements[depth];

    signal output root;

    signal mux[depth][2];
    signal levelHashes[depth + 1];
    
    levelHashes[0] <== leaf;
    for (var i = 0; i < depth; i++) {
        path_index[i] * (path_index[i] - 1) === 0;

        mux[i] <== MultiMux1(2)(
            [
                [levelHashes[i], path_elements[i]], 
                [path_elements[i], levelHashes[i]]
            ], 
            path_index[i]
        );

        levelHashes[i + 1] <== Poseidon(2)([mux[i][0], mux[i][1]]);
    }

    root <== levelHashes[depth];
}