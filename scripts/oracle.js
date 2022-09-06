const hre = require("hardhat");
const axios = require("axios");


async function main() {
    let requests = []; // Oracle Requests Queue

    const [deployer] = await ethers.getSigners();

    const BtcPriceOracle = await hre.ethers.getContractFactory("BtcPriceOracle");
    const btcPriceOracle = await BtcPriceOracle.deploy();
    await btcPriceOracle.deployed();
    console.log("btcPriceOracle contract deployed at: " + btcPriceOracle.address);

    const Caller = await hre.ethers.getContractFactory("Caller");
    const caller = await Caller.deploy(btcPriceOracle.address);
    await caller.deployed();
    console.log("caller contract deployed at: " + caller.address);

    btcPriceOracle.on("GetBtcPrice", (caller, id, event) => {
        console.log("Event:GetBtcPrice");
        requests.push({caller, id});
    });

    btcPriceOracle.on("SetBtcPrice", (caller, id, btcPrice, event) => {
        console.log("Event:SetBtcPrice");
        console.log(event);
    });

    await caller.getBtcPrice();
    await caller.getBtcPrice();
    await caller.getBtcPrice();

    setInterval(async() => {
        console.log("Watch requests. Current requests.length is: " + requests.length);
        if (requests.length > 0) {
            const request = requests.shift();
            const btcPrice = await getLatestBinanceBtcPrice();
            console.log("caller: " + request.caller);
            console.log("id: " + request.id);
                        
            await btcPriceOracle.setBtcPrice(
                request.id,
                parseInt(btcPrice), // #TODO: Decimal Issue
                request.caller,
            );
        }
    }, 2000);
}


async function getLatestBinanceBtcPrice() {
    const response = await axios({
        method: "GET",
        url: "https://api.binance.com/api/v3/ticker/price",
        params: {
            symbol: "BTCUSDT",
        },
    });
    return response.data.price;
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
