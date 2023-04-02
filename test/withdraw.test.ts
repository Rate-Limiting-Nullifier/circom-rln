import * as path from "path";
import assert from "assert";
const tester = require("circom_tester").wasm;
import poseidon from "poseidon-lite";
import { genFieldElement, getSignal }  from "./utils";

const circuitPath = path.join(__dirname, "..", "circuits", "withdraw.circom");

// ffjavascript has no types so leave circuit with untyped
type CircuitT = any;


describe("Test withdraw.circom", function () {
    let circuit: CircuitT;

    this.timeout(30000);

    before(async function () {
        circuit = await tester(circuitPath);
    });

    it("Should generate witness with correct outputs", async () => {
        // Private inputs
        const identitySecret = genFieldElement();
        // Public inputs
        const addressHash = genFieldElement();
        // Test: should generate proof if inputs are correct
        const witness: bigint[] = await circuit.calculateWitness({identitySecret, addressHash}, true);
        await circuit.checkConstraints(witness);
        const expectedIdentityCommitment = poseidon([identitySecret])
        const outputIdentityCommitment = await getSignal(circuit, witness, "identityCommitment")
        assert.equal(outputIdentityCommitment, expectedIdentityCommitment)
    });
});