const hre = require("hardhat");


async function main() {
    let requests = []; // Oracle Requests Queue

    const [deployer] = await ethers.getSigners();

    const DecipherOracle = await hre.ethers.getContractFactory("DecipherOracle");
    const oracle = await DecipherOracle.deploy();
    await oracle.deployed();
    console.log("DecipherOracle contract deployed at: " + oracle.address);

    const DecipherManager = await hre.ethers.getContractFactory("DecipherManager");
    const manager = await DecipherManager.deploy(oracle.address);
    await manager.deployed();
    console.log("DecipherManager contract deployed at: " + manager.address);

    oracle.on("GetPOC", (managerAddress, id, name, event) => {
        console.log(`Event:GetPOC Name:${name}`);
        requests.push({managerAddress, id, name});
    });

    oracle.on("SetPOC", (managerAddress, id, name, poc, event) => {
        console.log(`Event:SetPOC Name:${name} POC:${poc}`);
    });

    await manager.getPOC("ansuchan.eth");
    await manager.getPOC("Pangyoalto");

    let poc = getPOC(await getDecipherPosts(), "Pangyoalto");

    setInterval(async() => {
        console.log("Watch requests. Current requests.length is: " + requests.length);
        if (requests.length > 0) {
            const request = requests.shift();
            const poc = await getPOC(request.name);
            console.log(`POC of ${request.name} is ${poc}.`);

            await oracle.setPOC(
                request.id,
                request.name,
                poc,
                request.managerAddress,
            );
        }
    }, 2000);
}


async function getDecipherPosts() {
    // TODO: Should parse multiple RSS pages.
    const Parser = require('rss-parser');
    const parser = new Parser();

    const feed = await parser.parseURL('https://medium.com/feed/decipher-media');
    const posts = feed.items;
    return posts;
}


async function getDecipherPostsOfAuthor(name) {
    const posts = await getDecipherPosts();
    return posts.filter(post => post["dc:creator"] == name);
}


async function getPOC(name) {
    let postsOfAuthor = await getDecipherPostsOfAuthor(name);
    return postsOfAuthor.length;
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
