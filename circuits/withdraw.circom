pragma circom 2.1.0;

include "../lib/rc-impls/rc-circom/circuits/reinforcedConcrete.circom";

template Withdraw() {
    signal input identitySecret;
    signal input address;

    signal output identityCommitment <== ReinforcedConcreteHash()([identitySecret, 0]);

    // Dummy constraint to prevent compiler optimizing it
    signal addressSquared <== address * address;
}

component main { public [address] } = Withdraw();
