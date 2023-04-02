import * as path from "path";
import assert from "assert";
const tester = require("circom_tester").wasm;
import poseidon from "poseidon-lite";
import { calculateOutput, genFieldElement, genMerkleProof, getSignal }  from "./utils";

const circuitPath = path.join(__dirname, "..", "circuits", "rln-same.circom");

// ffjavascript has no types so leave circuit with untyped
type CircuitT = any;


describe("Test rln-diff.circom", function () {
    let circuit: CircuitT;

    this.timeout(30000);

    before(async function () {
        circuit = await tester(circuitPath);
    });

    it("Should generate witness with correct outputs", async () => {
        // Public inputs
        const x = genFieldElement();
        const externalNullifier = genFieldElement();
        // Private inputs
        const identitySecret = genFieldElement();
        const identitySecretCommitment = poseidon([identitySecret]);
        const merkleProof = genMerkleProof([identitySecretCommitment], 0)
        const merkleRoot = merkleProof.root
        const messageLimit = BigInt(10)
        const messageId = BigInt(1)

        const inputs = {
            // Private inputs
            identitySecret,
            messageId,
            pathElements: merkleProof.siblings,
            identityPathIndex: merkleProof.pathIndices,
            // Public inputs
            x,
            externalNullifier,
            messageLimit,
        }

        // Test: should generate proof if inputs are correct
        const witness: bigint[] = await circuit.calculateWitness(inputs, true);
        await circuit.checkConstraints(witness);

        const {y, nullifier} = calculateOutput(identitySecret, x, externalNullifier, messageId)

        const outputRoot = await getSignal(circuit, witness, "root")
        const outputY = await getSignal(circuit, witness, "y")
        const outputNullifier = await getSignal(circuit, witness, "nullifier")

        assert.equal(outputY, y)
        assert.equal(outputRoot, merkleRoot)
        assert.equal(outputNullifier, nullifier)
    });

    it("should fail to generate witness if messageId is not in range [1, messageLimit]", async function () {
        // Public inputs
        const x = genFieldElement();
        const externalNullifier = genFieldElement();
        // Private inputs
        const identitySecret = genFieldElement();
        const identitySecretCommitment = poseidon([identitySecret]);
        const merkleProof = genMerkleProof([identitySecretCommitment], 0)
        const messageLimit = BigInt(10)
        // valid message id is in the range [1, messageLimit]
        const invalidMessageIds = [BigInt(0), messageLimit + BigInt(1)]

        for (const invalidMessageId of invalidMessageIds) {
            const inputs = {
                // Private inputs
                identitySecret,
                messageId: invalidMessageId,
                pathElements: merkleProof.siblings,
                identityPathIndex: merkleProof.pathIndices,
                // Public inputs
                x,
                externalNullifier,
                messageLimit,
            }
            await assert.rejects(async () => {
                await circuit.calculateWitness(inputs, true);
            }, /Error: Assert Failed/);
        }
    });

});