pragma circom 2.1.0;

include "./incrementalMerkleTree.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template IsInInterval(n) {
    signal input in[3];

    signal output out;

    signal let <== LessEqThan(n)([in[1], in[2]]);
    signal get <== GreaterEqThan(n)([in[1], in[0]]);

    out <== let * get;
}

template RLN(depth) {
    // Private signals
    signal input identity_secret;
    signal input user_message_limit;
    signal input message_id;
    signal input path_elements[depth][1];
    signal input identity_path_index[depth];

    // Public signals
    signal input x;
    signal input external_nullifier;

    // Outputs
    signal output y;
    signal output root;
    signal output nullifier;

    signal pubkey <-- Poseidon(1)([identity_secret]);
    signal leaf <== Poseidon(2)([pubkey, user_message_limit]);

    root <== MerkleTreeInclusionProof(depth)(leaf, identity_path_index, path_elements);

    signal checkInterval <== IsInInterval(16)([1, message_id, user_message_limit]);
    checkInterval === 1;

    signal a_1 <== Poseidon(3)([identity_secret, external_nullifier, message_id]);
    y <== identity_secret + a_1 * x;

    nullifier <== Poseidon(1)([a_1]);
}

component main { public [x, external_nullifier] } = RLN(20);