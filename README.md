<h1 align=center>Rate-Limiting Nullifier circuits in Circom</h1>
<p align="center">
    <img src="https://github.com/Rate-Limiting-Nullifier/rln-circuits-v2/workflows/Test/badge.svg" width="110">
</p>

___

## This is a fork of RLN

This fork of RLN makes use of [RC hash function](https://rc-hash.info) as a drop in replacement to poseidon.


### Constraint differences

1. RLN Circuit =>

```diff
circom compiler 2.1.5
-template instances: 216
+template instances: 48
-non-linear constraints: 5820
+non-linear constraints: 957
linear constraints: 0
public inputs: 2
public outputs: 3
private inputs: 43
private outputs: 0
-wires: 5844
+wires: 1053
-labels: 18553
+labels: 24733
```

2. Withdraw Circuit =>

```diff
circom compiler 2.1.5
-template instances: 71
+template instances: 42
-non-linear constraints: 214
+non-linear constraints: 37
linear constraints: 0
public inputs: 1
public outputs: 1
private inputs: 1
private outputs: 0
-wires: 217
+wires: 43
-labels: 585
+labels: 1021
```

## What's RLN?

RLN is a zero-knowledge gadget that enables spam 
prevention in anonymous environments.

The core parts of RLN are:
* zk-circuits in Circom (this repo);
* [registry smart-contract](https://github.com/Rate-Limiting-Nullifier/rln-contract);
* set of libraries to build app with RLN ([rlnjs](https://github.com/Rate-Limiting-Nullifier/rlnjs), [zerokit](https://github.com/vacp2p/zerokit)).

---

To learn more on RLN and how it works - check out [documentation](https://rate-limiting-nullifier.github.io/rln-docs/).
