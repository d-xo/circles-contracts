pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract HubLike {
    function give() returns (uint);
    function take() returns (uint);
    function trustable(address usr) returns (bool);
}

contract Token is ERC20 {
    // auth
    address public owner;
    function updateOwner(address usr) public auth { owner = usr; }
    modifier auth() { require(msg.sender == owner); _; }

    // data
    Hublike public hub;  // governance interface & trust graph
    uint    public rate; // demurrage scaling factor
    uint    public then; // last touched

    // init
    constructor(address owner_, uint gift) public {
        hub   = HubLike(msg.sender);
        owner = owner_;

        mint(owner, gift);
        approve(hub, -1);
    }

    // basic income & demurrage
    function collect() public onlyOwner {
        uint period = now - then;

        rate = rate - (period * hub.take());
        balances[address(this)] = period * hub.give();

        then = now;
    }

    // ERC-20
    function balanceOf(address usr) public view {
        return super.balanceOf(usr) * rate;
    }

}
