// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * **** Data Conversions ****

 * Decimals to integers (both metric & imperial units)
 * ---------------------------------------------------
 * Condition                    Conversion
 * ---------------------------------------------------
 * temperature                  multiplied by 10
 *
 *
 *
 * Current weather conditions units per system
 * ---------------------------------------------------
 * Condition                    metric      imperial
 * ---------------------------------------------------
 * temperature                  C           F

 */
/**
 * @title A consumer contract to get the mean temperature at the given coordinates.
 * @author imagobea
 * @notice For a given "lat, lon", the job requests temperature data from different providers and returns the average temperature.
 */
contract TemperatureConsumer is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    /* ========== CONSUMER STATE VARIABLES ========== */

    struct RequestParams {
        string lat;
        string lon;
        string units;
    }

    // Maps
    mapping(bytes32 => int256) public requestIdMeanTemp;
    mapping(bytes32 => RequestParams) public requestIdRequestParams;

    /* ========== CONSTRUCTOR ========== */

    /**
     * @param _link the LINK token address.
     * @param _oracle the Operator.sol contract address.
     */
    constructor(address _link, address _oracle) {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
    }

    /* ========== CONSUMER REQUEST FUNCTIONS ========== */

    /**
     * @notice Returns the average temperature at the given coordinates.
     * @param _jobId the node jobID.
     * @param _payment the LINK amount in Juels (10^16 or 0.01 LINK).
     * @param _lat the latitude (WGS84 standard, from -90 to 90).
     * @param _lon the longitude (WGS84 standard, from -180 to 180).
     * @param _units the measurement system ("metric" or "imperial").
     */
    function requestGeoPositionTemperature(
        string calldata _jobId,
        uint256 _payment,
        string calldata _lat,
        string calldata _lon,
        string calldata _units
    ) public {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillGeoPositionTemperature.selector
        );

        req.add("lat", _lat);
        req.add("lon", _lon);
        req.add("units", _units);

        bytes32 requestId = requestOracleData(req, _payment);

        RequestParams memory requestParams;
        requestParams.lat = _lat;
        requestParams.lon = _lon;
        requestParams.units = _units;
        requestIdRequestParams[requestId] = requestParams;
    }

    /* ========== CONSUMER FULFILL FUNCTIONS ========== */

    /**
     * @notice Consumes the data returned by the node job.
     * @param _requestId the request ID to fulfill.
     * @param _meanTemperature the average temperature at the given coordinates multiplied by 10.
     */
    function fulfillGeoPositionTemperature(bytes32 _requestId, int256 _meanTemperature)
        public
        recordChainlinkFulfillment(_requestId)
    {
        requestIdMeanTemp[_requestId] = _meanTemperature;
    }

    /* ========== OTHER FUNCTIONS ========== */

    function getOracleAddress() external view returns (address) {
        return chainlinkOracleAddress();
    }

    function setOracle(address _oracle) external {
        setChainlinkOracle(_oracle);
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }

    function withdrawLink() public {
        LinkTokenInterface linkToken = LinkTokenInterface(chainlinkTokenAddress());
        require(linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))), "Unable to transfer");
    }
}
