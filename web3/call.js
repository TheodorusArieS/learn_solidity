
const solc = require("solc");
const fs = require("fs");
const Web3 = require("web3");

let web3 = new Web3(new Web3.providers.HttpProvider("HTTP://127.0.0.1:7545"));

let fileContent = fs.readFileSync("Add.sol").toString();
// console.log("File Content:", fileContent);

// input structure

let input = {
    language: "Solidity",
    sources: {
        "Add.sol": {
            content: fileContent,
        },
    },
    settings: {
        outputSelection: {
            "*": {
                "*": ["*"],
            },
        },
    },
};

let output = JSON.parse(solc.compile(JSON.stringify(input)));

console.log("Output:", output);
let ABI = output.contracts["Add.sol"]["Add"].abi;
let bytecode = output.contracts["Add.sol"]["Add"].evm.bytecode.object;

console.log("ABI:", ABI);
console.log("Byte Code:", bytecode);

let contract = new web3.eth.Contract(ABI);
let owner;

web3.eth.getAccounts().then((accounts) => {
    console.log("ACCOUNTS:", accounts);
    owner = accounts[0];
    console
        .log("owner:", owner);

    contract
        .deploy({ data: bytecode })
        .send({ from: owner, gas: 470000 })
        .on("receipt", (receipt) => {
            console.log("Contract Address :", receipt.contractAddress);
        })
        .then((addContract) => {
            addContract.methods.getSum().call((err, sum) => {
                console.log("Initial Sum:", sum);

            });

            addContract.methods.Sum(2, 10).send({ from: owner }, () => {
                addContract.methods.getSum().call((err, sum) => {
                    console.log("Final Sum:", sum);

                })
            })

        });
});