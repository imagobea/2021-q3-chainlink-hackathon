# What's the weather LINK?

Get the average current temperature at a given location from [Accuweather](http://apidev.accuweather.com/developers/) and [Openweather](https://openweathermap.org/current).

## Setup

To complete the following steps, setup a Metamask wallet and get some ETH and LINK in Kovan.

### Step 1. Run a Chainlink node

Visit the Chainlink docs for instructions about [running a node](https://docs.chain.link/docs/running-a-chainlink-node/). For the purposes of this demo, [Chainlink version 1.0.0](https://github.com/smartcontractkit/chainlink/releases/tag/v1.0.0) was used.

### Step 2. Deploy an oracle contract

Open [Remix](https://remix.ethereum.org/) and deploy a version of the `Operator.sol` contract. The source code is available at [chainlink/contracts/src](https://github.com/smartcontractkit/chainlink/tree/develop/contracts/src) (v0.7 at the time of the hackathon).

To deploy, pass an `owner` address and the `link` token address in Kovan, i.e. 0xa36085F69e2889c224210F603D836748e7dC0088.

Associate your node address (Node Operator GUI Keys > Account addresses) to the oracle contract. Do this on Remix, calling `setAuthorizedSenders`.

E.g. Operator contract in Kovan: [0xffcb560a05183a9a0ee04ba93b624656ad61fd7b](https://kovan.etherscan.io/address/0xffcb560a05183a9a0ee04ba93b624656ad61fd7b)

### Step 3. Run the Accuweather external adapter

Clone and start the Accuweather external adapter as per the [external-adapters-js](https://github.com/smartcontractkit/external-adapters-js) and [accuweather](https://github.com/smartcontractkit/external-adapters-js/tree/develop/packages/sources/accuweather) README files.

Note that you will have to request an API Key for development purposes. This key is only valid for the `dataservice` Accuweather URLs, and they just allow a handful of requests per key at a time.

Run the adapater:

```
# Add your API_KEY
docker-compose -f docker-compose.generated.yaml run -p 8080:8080 -e "API_ENDPOINT=http://dataservice.accuweather.com" -e "API_KEY=" accuweather-adapter
```

Test the adapter:

```
curl -X POST -H "Content-Type: application/json" "http://localhost:8080" --data '{"id":"1","data":{"endpoint":"location-current-conditions","lat": 41.406909471885754, "lon": 2.1758906926877977, "units":"metric", "encodeResult": true}}'
```

*Response example in external-adapter-templates/response-examples*.

### Step 4. Run the Openweather external adapter

Clone and start the [external-adapters-template](https://github.com/thodges-gh/CL-EA-NodeJS-Template) repository and replace the `index.js` file with the content in external-adapter-templates/openweather.js.

Note that you will have to request an API Key for development purposes.

Run the adapater:

```
yarn start
```

Test the adapter:

```
curl -X POST -H "Content-Type: application/json" "http://localhost:8081" --data '{ "id":0, "data": { "lat": "41.406909471885754", "lon": "2.1758906926877977", "units": "metric"}}'
```

*Response example in external-adapter-templates/response-examples*.
*Read the full tutorial at [Building and Using External Adapters](https://blog.chain.link/build-and-use-external-adapters/?_ga=2.265889231.1547695959.1637401718-1284471972.1628164264), by Patrick Collins*.

### Step 5. Further node configurations

1. Add a bridge for Accuweather (name `accuweather`)
2. Add a bridge for Openweather (name `openweather`)
3. Create a job (jobs/get-mean-temperature) - mind `contractAddress`

### Step 6. Deploy a consumer contract

Code in contracts/TemperatureConsumer.sol.

E.g. [0x92Fa7e523fdD4677Adb8e5168486981A59A452fC](https://kovan.etherscan.io/address/0x92Fa7e523fdD4677Adb8e5168486981A59A452fC) - contract validation on Etherscan fails, but can be tested on Remix: `requestIdMeanTemp` > paste [0x45198a5b5d3f297c097f8986a3e702a9a98a8b84a10e9b04fbfa71e292b217b9](https://kovan.etherscan.io/tx/0xdefeb951d58e3a25dcac20cd0e5dce0f3ecf2d535b612a79828a2e329469d21c#eventlog)

E.g. [0x4238e4ec58dc817d569f83b02820acf28f9e117b#readContract](https://kovan.etherscan.io/address/0x4238e4ec58dc817d569f83b02820acf28f9e117b) - validated but with no transactions due to node failure

### Step 7. Send Funds

1. Fund your node address with ETH
2. Fund the consumer contract with LINK

### Final thoughts

TBC
