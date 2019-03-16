pragma solidity ^0.5.0;

import "ds-token/token.sol";
import "ds-test/test.sol";

contract HubLike {
    function give() public returns (uint);
    function take() public returns (uint);
    function trustable(address usr) public view returns (bool);
}

contract Token is DSTokenBase(0), DSTest {
    // data
    HubLike public hub;   // governance interface & trust graph
    uint    public rate;  // demurrage scaling factor
    uint    public then;  // last touched
    address public owner; // owner

    // init
    constructor(address owner_, uint gift) public {
        hub   = HubLike(msg.sender);
        owner = owner_;

        rate = 1;
        then = now;

        _balances[owner] = gift;
        _approvals[owner][address(hub)] = uint(-1);
    }

    // basic income & demurrage
    function collect() public {
        uint period = now - then;

        rate = rate - (period * hub.take());
        _balances[owner] = period * hub.give();

        then = now;
    }

    // ERC-20
    function balanceOf(address usr) public view returns (uint) {
        return super.balanceOf(usr) * rate;
    }

}
