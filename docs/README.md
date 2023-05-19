# Formal description of the circuits

*[RFC for RLN-V2](https://rfc.vac.dev/spec/58/)*

- [Utils](#utils-templates)
    - [MerkleTreeInclusionProof](#merkletreeinclusionproof)
    - [IsInInterval](#isininterval)
- [RLN-same](#rln-same-templates)
- [RLN-diff](#rln-diff-templates)
- [Withdrawal](#withdrawal)

___

## Utils

[utils.circom](../circuits/utils.circom) is a set of templates/gadgets that the RLN circuits uses.

These are: 
* MerkleTreeInclusionProof - Merkle Tree inclusion check, used like set membership check;
* IsInInterval - used for range check.

Their description is given below.

### MerkleTreeInclusionProof

`MerkleTreeInclusionProof(DEPTH)` template used for verification of inclusion in full binary incremental merkle tree. The implementation is a fork of https://github.com/privacy-scaling-explorations/incrementalquintree, and changed to *binary* tree and refactored to *Circom 2.1.0*.

**Parameters**:
* `DEPTH` - depth of the Merkle Tree.

**Inputs**:
* `leaf` - `Poseidon(elem)`, where `elem` is the element that's checked for inclusion;
* `pathIndex[DEPTH]` - array of length = `DEPTH`, consists of `0 | 1`, represents Merkle proof path. 
Basically, it says how to calculate Poseidon hash, e.g. for two inputs `input1`, `input2`, if the `pathIndex[i] = 0` it shoud be calculated as `Poseidon(input1, input2)`, otherwise `Poseidon(input2, input1)`;
* `pathElements[DEPTH]` - array of length = `DEPTH`, represents elements of the Merkle proof.

**Outputs**:
* `root` - Root of the merkle tree.

**Templates used**:
* [mux1.circom](https://github.com/iden3/circomlib/blob/master/circuits/mux1.circom) from circomlib;
* [poseidon.circom](https://github.com/iden3/circomlib/blob/master/circuits/poseidon.circom) from circomlib.

### IsInInterval

`IsInInterval(LIMIT_BIT_SIZE)` template used for range check, e.g. (x <= y <= z).

**Parameters**:
* `LIMIT_BIT_SIZE` - maximum bit size of numbers that are used in range check, f.e. for the `LIMIT_BIT_SIZE` = 16, input numbers allowed to be in the interval `[0, 65536)`.

**Inputs**:
* `in[3]` - array of 3 elements.

**Outputs**:
* `out` - bool value (`0 | 1`). Outputs 1 when the circuit is satisfied, otherwise - 0.

**Templates used**:
* [`LessEqThan(n)`](https://github.com/iden3/circomlib/blob/master/circuits/comparators.circom#L105) from circomlib.

**Logic/Constraints**:
Checked that `in[0] <= in[1] <= in[2]`. That's done by combining two `LessEqThan` checks. 
`out` value is calculated as a multiplication of two `LessEqThan` outputs.

___

## RLN-same

[rln-same.circom](../circuits/rln-same/rln-same.circom) is a template that's used for [RLN-same protocol](https://rfc.vac.dev/spec/58/#rln-same-flow). 

**Parameters**:
* `DEPTH` - depth of a Merkle Tree. Described [here](#merkletreeinclusionproof);
* `LIMIT_BIT_SIZE` - maximum bit size of numbers that are used in range check. Described [here](#isininterval).

**Private inputs**:
* `identitySecret` - randomly generated number in `F_p`, used as private key;
* `messageId` - id of the message;
* `pathElements[DEPTH]` - pathElements[DEPTH], described [here](#merkletreeinclusionproof);
* `identityPathIndex[DEPTH]` - pathIndex[DEPTH], described [here](#merkletreeinclusionproof).

**Public inputs**:
* `x` - `Hash(signal)`, where `signal` is for example message, that was sent by user;
* `externalNullifier` - `Hash(epoch, rln_identifier)`;
* `messageLimit` - message limit of an RLN app.

**Outputs**:
* `y` - calculated first-degree linear polynomial (y = kx + b);
* `root` - root of the Merkle Tree;
* `nullifier` - internal nullifier/pseudonym of the user in anonyomus environment.

**Logic/Constraints**:
1. Merkle tree membership check:
    * `identityCommitment` = `Poseidon(identitySecret)` calculation;
    * [Merkle tree inclusion check](#merkletreeinclusionproof) for the `identityCommitment`.
2. Range check:
    * [Range check](#isininterval) that `1 <= messageId <= messageLimit`.
3. Polynomial share calculation:
    * `a1` = `Poseidon(identitySecret, externalNullifier, messageId)`;
    * `y` = `identitySecret + a1 * x`.
4. Output of calculated `root`, `share` and `nullifier` = `Poseidon(a_1)` values.

___

## RLN-diff

[rln-diff.circom](../circuits/rln-diff/rln-diff.circom) is a template that's used for [RLN-diff protocol](https://rfc.vac.dev/spec/58/#rln-diff-flow). 

**Parameters**:
* `DEPTH` - depth of a Merkle Tree. Described [here](#merkletreeinclusionproof);
* `LIMIT_BIT_SIZE` - maximum bit size of numbers that are used in range check. Described [here](#isininterval).

**Private inputs**:
* `identitySecret` - randomly generated number in `F_p`, used as a private key;
* `userMessageLimit` - message limit of the user;
* `messageId` - id of the message;
* `pathElements[DEPTH]` - pathElements[DEPTH], described [here](#merkletreeinclusionproof);
* `identityPathIndex[DEPTH]` - pathIndex[DEPTH], described [here](#merkletreeinclusionproof).

**Public inputs**:
* `x` - `Hash(signal)`, where `signal` is for example message, that was sent by user;
* `externalNullifier` - `Hash(epoch, rln_identifier)`.

**Outputs**:
* `y` - calculated first-degree linear polynomial (y = kx + b);
* `root` - root of the Merkle Tree;
* `nullifier` - internal nullifier/pseudonym of the user in anonyomus environment.

**Logic/Constraints**:
1. Merkle tree membership check:
    * `identityCommitment` = `Poseidon(identitySecret, )` calculation;
    * `rateCommitment` = `Poseidon(identityCommitment, userMessageLimit)` calculation;
    * [Merkle tree inclusion check](#merkletreeinclusionproof) for the `rateCommitment`.
2. Range check:
    * [Range check](#isininterval) that `1 <= messageId <= userMessageLimit`.
3. Polynomial share calculation:
    * `a1` = `Poseidon(identitySecret, externalNullifier, messageId)`;
    * `y` = `identitySecret + a1 * x`.
4. Output of calculated `root`, `share` and `nullifier` = `Poseidon(a_1)` values.

___

### Withdrawal

[withdraw.circom](../circuits/withdraw.circom) is a template that's used for the withdrawal/slashing and is needed to prevent front run while withdrawing the stake from the smart-contract/registry. 

**Private inputs**:
* `identitySecret` - randomly generated number in `F_p`, used as private key.

**Public inputs**:
* `address` - `F_p` scalar field element. ETH address that'll receive stake. 

**Outputs**:
* `identityCommitment` = `Poseidon(identitySecret)`.