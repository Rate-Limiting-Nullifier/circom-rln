pragma circom 2.1.0;

include "./utils.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

template RLN(DEPTH, LIMIT_BIT_SIZE, NULLIFIERS) {
    // Private signals
    signal input identitySecret;
    signal input userMessageLimitMultiplier;
    signal input messageIds[NULLIFIERS];
    signal input pathElements[DEPTH];
    signal input identityPathIndex[DEPTH];

    // Public signals
    signal input x;
    signal input externalNullifiers[NULLIFIERS];
    signal input messageLimits[NULLIFIERS];

    // Outputs
    signal output y[NULLIFIERS];
    signal output root;
    signal output nullifiers[NULLIFIERS];

    signal identityCommitment <== Poseidon(1)([identitySecret]);
    signal rateCommitment <== Poseidon(2)([identityCommitment, userMessageLimitMultiplier]);

    root <== MerkleTreeInclusionProof(DEPTH)(rateCommitment, identityPathIndex, pathElements);

    signal userMessageLimits[NULLIFIERS];
    signal checkIntervals[NULLIFIERS];
    signal a1[NULLIFIERS];

    for (var i = 0; i < NULLIFIERS; i++) {
        userMessageLimits[i] <== messageLimits[i] * userMessageLimitMultiplier;
        checkIntervals[i] <== IsInInterval(LIMIT_BIT_SIZE)([1, messageIds[i], userMessageLimits[i]]);
        checkIntervals[i] === 1;
        a1[i] <== Poseidon(4)([identitySecret, externalNullifiers[i], messageIds[i], i]);
        y[i] <== identitySecret + a1[i] * x;
        nullifiers[i] <== Poseidon(1)([a1[i]]);
    }
}

component main { public [x, externalNullifiers, messageLimits] } = RLN(20, 16, 2);
