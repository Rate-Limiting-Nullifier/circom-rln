pragma circom 2.1.0;

include "./utils.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

template RLN(DEPTH, LIMIT_BIT_SIZE) {
    // Private signals
    signal input identitySecret;
    signal input userMessageLimit;
    signal input messageId;
    signal input pathElements[DEPTH];
    signal input identityPathIndex[DEPTH];

    // Public signals
    signal input x;
    signal input externalNullifier;

    // Outputs
    signal output y;
    signal output root;
    signal output nullifier;

    signal identityCommitment <== Poseidon(1)([identitySecret]);
    signal rateCommitment <== Poseidon(2)([identityCommitment, userMessageLimit]);

    root <== MerkleTreeInclusionProof(DEPTH)(rateCommitment, identityPathIndex, pathElements);

    signal checkInterval <== IsInInterval(LIMIT_BIT_SIZE)([1, messageId, userMessageLimit]);
    checkInterval === 1;

    signal a1 <== Poseidon(3)([identitySecret, externalNullifier, messageId]);
    y <== identitySecret + a1 * x;

    nullifier <== Poseidon(1)([a1]);
}

component main { public [x, externalNullifier] } = RLN(20, 16);