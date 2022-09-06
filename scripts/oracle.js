const hre = require("hardhat");
const axios = require("axios");


async function main() {
    console.log(await getLatestBinanceBtcPrice());
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
