import { IncrementalMerkleTree } from "@zk-kit/incremental-merkle-tree";
import poseidon from "poseidon-lite";
const ffjavascript = require("ffjavascript");

import { MERKLE_TREE_DEPTH, MERKLE_TREE_ZERO_VALUE } from "./configs";


// ffjavascript has no types so leave circuit with untyped
type CircuitT = any;

const SNARK_FIELD_SIZE = BigInt('21888242871839275222246405745257275088548364400416034343698204186575808495617')
const F = new ffjavascript.ZqField(SNARK_FIELD_SIZE);

export function genFieldElement() {
    return F.random()
}

export function genMerkleProof(elements: BigInt[], leafIndex: number) {
    const tree = new IncrementalMerkleTree(poseidon, MERKLE_TREE_DEPTH, MERKLE_TREE_ZERO_VALUE, 2);
    for (let i = 0; i < elements.length; i++) {
        tree.insert(elements[i]);
    }
    const merkleProof = tree.createProof(leafIndex)
    merkleProof.siblings = merkleProof.siblings.map((s) => s[0])
    return merkleProof;
}

export function calculateOutput(identitySecret: bigint, x: bigint, externalNullifier: bigint, messageId: bigint) {
    // signal a1 <== Poseidon(3)([identitySecret, externalNullifier, messageId]);
    const a1 = poseidon([identitySecret, externalNullifier, messageId]);
    // y <== identitySecret + a1 * x;
    const y = F.normalize(identitySecret + a1 * x);
    const nullifier = poseidon([a1]);
    return {y, nullifier}
}


export async function getSignal(circuit: CircuitT, witness: bigint[], name: string) {
    const prefix = "main"
    // E.g. the full name of the signal "root" is "main.root"
    // You can look up the signal names using `circuit.getDecoratedOutput(witness))`
    const signalFullName = `${prefix}.${name}`
    await circuit.loadSymbols()
    // symbols[n] = { labelIdx: 1, varIdx: 1, componentIdx: 142 },
    const signalMeta = circuit.symbols[signalFullName]
    // Assigned value of the signal is located in the `varIdx`th position
    // of the witness array
    const indexInWitness = signalMeta.varIdx
    return BigInt(witness[indexInWitness]);
}
