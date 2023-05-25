#!/bin/bash
set -e

cd "$(dirname "$0")"
mkdir -p ../build/contracts
mkdir -p ../build/setup

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

circuit_dir="../circuits"
circuit_path=""
circuit_type=""
zkeydir="../zkeyFiles"

if [ "$1" = "rln" ]; then
    echo -e "\033[32mUsing RLN circuit\033[0m"
    circuit_name="rln"
elif [ "$1" = "withdraw" ]; then
    echo -e "\033[32mUsing Withdraw circuit\033[0m"
    circuit_name="withdraw"
else
    echo -e "\033[33mUnrecognized argument"
    exit 1
fi
circuit_path="$circuit_dir/$circuit_name.circom"
zkeypath="$zkeydir/$circuit_name"

if ! [ -x "$(command -v circom)" ]; then
    echo -e '\033[31mError: circom is not installed.\033[0m' >&2
    echo -e '\033[31mError: please install circom: https://docs.circom.io/getting-started/installation/.\033[0m' >&2
    exit 1
fi

echo -e "Circuit path: $circuit_path"
echo -e "\033[36m-----------------\033[0m"
echo -e "\033[36mCOMPILING CIRCUIT\033[0m"
echo -e "\033[36m-----------------\033[0m"

echo -e "\033[36mBuild Path: $PWD\033[0m"

circom --version
circom $circuit_path --r1cs --wasm --sym

npx snarkjs r1cs export json $circuit_name.r1cs $circuit_name.r1cs.json

echo -e "\033[36mRunning groth16 trusted setup\033[0m"

npx snarkjs groth16 setup $circuit_name.r1cs powersOfTau28_hez_final_14.ptau setup/circuit_00000.zkey

npx snarkjs zkey contribute setup/circuit_00000.zkey setup/circuit_00001.zkey --name="First contribution" -v -e="Random entropy"
npx snarkjs zkey contribute setup/circuit_00001.zkey setup/circuit_00002.zkey --name="Second contribution" -v -e="Another random entropy"
npx snarkjs zkey beacon setup/circuit_00002.zkey setup/final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"

echo -e "Exporting artifacts to zkeyFiles and contracts directory"

mkdir -p $zkeypath
npx snarkjs zkey export verificationkey setup/final.zkey $zkeypath/verification_key.json
npx snarkjs zkey export solidityverifier setup/final.zkey contracts/verifier.sol

cp $circuit_name\_js/$circuit_name.wasm $zkeypath/circuit.wasm
cp setup/final.zkey $zkeypath/final.zkey

shasumcmd="shasum -a 256"

config_path="$zkeypath/circuit.config.toml"
echo -e "[Circuit_Version]" > $config_path
echo -e "RLN_Version = 2" >> $config_path
echo -e "RLN_Type = \"$circuit_name\"" >> $config_path

echo -e "" >> $config_path

echo -e "[Circuit_Build]" >> $config_path
echo -e "Circom_Version = \"$(circom --version)\"" >> $config_path
echo -e "GitHub_URL = \"$(git config --get remote.origin.url)\""  >> $config_path
echo -e "Git_Commit = \"$(git describe --always)\"" >> $config_path
echo -e "Compilation_Time = $(date +%s)" >> $config_path

echo -e "" >> $config_path
echo -e "[Files]" >> $config_path
echo -e "Wasm = \"circuit.wasm\"" >> $config_path
wasm_sha256=$($shasumcmd $zkeypath/circuit.wasm | awk '{print $1}')
echo -e "Wasm_SHA256SUM = \"$wasm_sha256\"" >> $config_path
echo -e "Zkey = \"final.zkey\"" >> $config_path
zkey_sha256=$($shasumcmd $zkeypath/final.zkey | awk '{print $1}')
echo -e "Zkey_SHA256SUM = \"$zkey_sha256\"" >> $config_path
echo -e "Verification_Key = \"verification_key.json\"" >> $config_path
vkey_sha256=$($shasumcmd $zkeypath/verification_key.json | awk '{print $1}')
echo -e "Verification_Key_SHA256SUM = \"$vkey_sha256\"" >> $config_path