#!/bin/bash
set -e

cd "$(dirname "$0")"
zkeypath="../zkeyFiles"
mkdir -p ../build/contracts
mkdir -p ../build/setup
mkdir -p $zkeypath

# Build context
cd ../build
echo -e "\033[36m----------------------\033[0m"
echo -e "\033[36mSETTING UP ENVIRONMENT\033[0m"
echo -e "\033[36m----------------------\033[0m"
if [ -f ./powersOfTau28_hez_final_14.ptau ]; then
    echo -e "\033[33mpowersOfTau28_hez_final_14.ptau already exists. Skipping.\033[0m"
else
    echo -e "\033[33mDownloading powersOfTau28_hez_final_14.ptau\033[0m"
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_14.ptau
fi

circuit_path=""
circuit_type=""
if [ "$1" = "diff" ]; then
    echo -e "\033[32mUsing Diff circuit\033[0m"
    circuit_type="diff"
    circuit_path="../circuits/rln-diff.circom"
elif [ "$1" = "same" ]; then
    echo -e "\033[32mUsing Same circuit\033[0m"
    circuit_type="same"
    circuit_path="../circuits/rln-same.circom"
else
    circuit_type="same"
    circuit_path="../circuits/rln-same.circom"
    echo -e "\033[33mUnrecognized argument, using 'same' as default.\033[0m"
fi

if ! [ -x "$(command -v circom)" ]; then
    echo -e '\033[31mError: circom is not installed.\033[0m' >&2
    echo -e '\033[31mError: please install circom: https://docs.circom.io/getting-started/installation/.\033[0m' >&2
    exit 1
fi

echo -e "Circuit path: $circuit_path"
echo -e "\033[36m-----------------\033[0m"
echo -e "\033[36mCOMPILING CIRCUIT\033[0m"
echo -e "\033[36m-----------------\033[0m"

echo -e "\033[36m Build Path: $PWD\033[0m"

circom --version
circom $circuit_path --r1cs --wasm --sym

snarkjs r1cs export json rln-same.r1cs rln-same.r1cs.json

echo -e "\033[36mRunning groth16 trusted setup\033[0m"

snarkjs groth16 setup rln-same.r1cs powersOfTau28_hez_final_14.ptau setup/rln_0000.zkey

snarkjs zkey contribute setup/rln_0000.zkey setup/rln_0001.zkey --name="First contribution" -v -e="Random entropy"
snarkjs zkey contribute setup/rln_0001.zkey setup/rln_0002.zkey --name="Second contribution" -v -e="Another random entropy"
snarkjs zkey beacon setup/rln_0002.zkey setup/rln_final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"

echo -e "Exporting artifacts to zkeyFiles and contracts directory"

snarkjs zkey export verificationkey setup/rln_final.zkey $zkeypath/verification_key.json
snarkjs zkey export solidityverifier setup/rln_final.zkey contracts/verifier.sol

cp rln-same_js/rln-same.wasm $zkeypath/rln-same.wasm
cp setup/rln_final.zkey $zkeypath/rln_final.zkey

echo -e "RLN_Version: V2" > $zkeypath/circuit.config
echo -e "RLN_Type: $circuit_type" >> $zkeypath/circuit.config
echo -e "GitHub_URL: $(git config --get remote.origin.url)"  >> $zkeypath/circuit.config
echo -e "Git_Commit: $(git describe --always)" >> $zkeypath/circuit.config
echo -e "Compilation_Time: $(date +%s)" >> $zkeypath/circuit.config