pragma solidity ^0.5.4;

import "ds-test/test.sol";

import "./CirclesContracts.sol";

contract CirclesContractsTest is DSTest {
    CirclesContracts contracts;

    function setUp() public {
        contracts = new CirclesContracts();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
