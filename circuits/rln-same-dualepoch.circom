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

template RLN(DEPTH, LIMIT_BIT_SIZE) {
    // Private signals
    signal input identitySecret;
    signal input messageIdA;
    signal input messageIdB;
    signal input pathElements[DEPTH];
    signal input identityPathIndex[DEPTH];

    // Public signals
    signal input x;
    signal input externalNullifierA;
    signal input messageLimitA;
    signal input externalNullifierB;
    signal input messageLimitB;

    // Outputs
    signal output yA;
    signal output yB;
    signal output root;
    signal output nullifierA;
    signal output nullifierB;

    signal identityCommitment <== Poseidon(1)([identitySecret]);

    root <== MerkleTreeInclusionProof(DEPTH)(identityCommitment, identityPathIndex, pathElements);

    signal checkIntervalA <== IsInInterval(LIMIT_BIT_SIZE)([1, messageIdA, messageLimitA]);
    checkIntervalA === 1;

    signal checkIntervalB <== IsInInterval(LIMIT_BIT_SIZE)([1, messageIdB, messageLimitB]);
    checkIntervalB === 1;

    signal a1_A <== Poseidon(4)([identitySecret, externalNullifierA, messageIdA, 1]);
    yA <== identitySecret + a1_A * x;

    nullifierA <== Poseidon(1)([a1_A]);

    signal a1_B <== Poseidon(4)([identitySecret, externalNullifierB, messageIdB, 2]);
    yB <== identitySecret + a1_B * x;

    nullifierB <== Poseidon(1)([a1_B]);
}

component main { public [x, externalNullifierA, messageLimitA, externalNullifierB, messageLimitB] } = RLN(20, 16);
