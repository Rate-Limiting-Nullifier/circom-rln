pragma circom 2.1.0;

include "../../node_modules/circomlib/circuits/poseidon.circom";

template Withdraw() {
    signal input identitySecret;
    signal input userMessageLimit;
    signal input addressHash;

    signal identityCommitment <== Poseidon(1)([identitySecret]);
    signal output rateCommitment <== Poseidon(2)([identityCommitment, userMessageLimit]);
}

component main { public [addressHash] } = Withdraw();