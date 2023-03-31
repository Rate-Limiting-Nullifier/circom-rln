pragma circom 2.1.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template Withdraw() {
    signal input identitySecret;
    signal input addressHash;

    signal output identityCommitment <== Poseidon(1)([identitySecret]);
}

component main { public [addressHash] } = Withdraw();