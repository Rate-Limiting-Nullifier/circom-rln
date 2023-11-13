pragma circom 2.1.0;

include "./utils.circom";
include "../lib/rc-impls/rc-circom/circuits/reinforcedConcrete.circom";

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

    signal identityCommitment <== ReinforcedConcreteHash()([identitySecret, 0]);
    signal rateCommitment <== ReinforcedConcreteHash()([identityCommitment, userMessageLimit]);

    // Membership check
    root <== MerkleTreeInclusionProof(DEPTH)(rateCommitment, identityPathIndex, pathElements);

    // messageId range check
    RangeCheck(LIMIT_BIT_SIZE)(messageId, userMessageLimit);

    // SSS share calculations
    component rcPermutation = ReinforcedConcretePermutation();
    signal a1;
    rcPermutation.state <== [identitySecret, externalNullifier, messageId];
    a1 <== rcPermutation.hash[0];
    y <== identitySecret + a1 * x;

    // nullifier calculation
    nullifier <== ReinforcedConcreteHash()([a1, 0]);
}

component main { public [x, externalNullifier] } = RLN(20, 16);