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
    signal input messageId;
    signal input pathElements[DEPTH];
    signal input identityPathIndex[DEPTH];

    // Public signals
    signal input x;
    signal input externalNullifierMultiMessage; // Nullifier that can be reused with different message IDs
    signal input messageLimit;

    signal input externalNullifierSingleMessage; // Nullifier that must be unique

    // Outputs
    signal output root;
    // Multiple message ID related
    signal output y_mm;
    signal output nullifierMultiMessage;
    // Single message ID related
    signal output y_sm;
    signal output nullifierSingleMessage;

    signal identityCommitment <== Poseidon(1)([identitySecret]);

    root <== MerkleTreeInclusionProof(DEPTH)(identityCommitment, identityPathIndex, pathElements);

    signal checkInterval <== IsInInterval(LIMIT_BIT_SIZE)([1, messageId, messageLimit]);
    checkInterval === 1;

    signal a1_mm <== Poseidon(3)([identitySecret, externalNullifierMultiMessage, messageId]);
    y_mm <== identitySecret + a1_mm * x;

    nullifierMultiMessage <== Poseidon(1)([a1_mm]);

    signal a1_sm <== Poseidon(2)([identitySecret, externalNullifierSingleMessage]);
    y_sm <== identitySecret + a1_sm * x;

    nullifierSingleMessage <== Poseidon(1)([a1_sm]);
}

component main { public [x, externalNullifierMultiMessage, messageLimit, externalNullifierSingleMessage] } = RLN(20, 16);
