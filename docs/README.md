# Formal description of the circuits

- [Utils](#utils-templates)
    - [MerkleTreeInclusionProof](#merkletreeinclusionproofdepth)
    - [IsInInterval](#isininterval)
- [RLN-diff](#rln-diff-templates)
- [RLN-same](#rln-same-templates)

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

## RLN-same



## RLN-diff
