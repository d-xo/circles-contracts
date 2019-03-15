pragma solidity ^0.5.0;

import "./token.sol";

//role of validators
//hubfactory?
//finish update function in token
//what should initial demurrage rate be? And initial issuance?
//more events in Token
//parallel transfer helper
//organization can transfer, and transitively transfer
//abstract ownership utils?
//organization signup

contract Hub {
    // auth
    address public owner;
    function updateOwner(address usr) public auth { owner = usr; }
    modifier auth() { require (msg.sender == owner); _; }

    // monetary policy
    uint public gift;  // initial payout
    uint public give;  // issuance rate
    uint public take;  // demurrage rate

    // money
    mapping (address => Token) public tokens;
    mapping (Token => address) public people;

    // trust
    mapping (address => bool) public isValidator;
    mapping (address => mapping (address => uint)) public limits;

    // logs
    event Signup(address indexed user, address token);
    event Trust(address indexed from, address indexed to, uint256 limit);
    event RegisterValidator(address indexed validator);

    // init
    constructor(uint gift_, uint give_, uint take_) public {
        owner = msg.sender;
        gift = gift_;
        give = give_;
        take = take_;
    }

    // governance
    function file(bytes32 what, uint data) public auth {
        if (what == "gift") gift = data;
        if (what == "give") give = data;
        if (what == "take") take = data;
    }

    // introductions
    function join() external {
        require(!trustable(msg.sender), "validators cannot have a currency")

        Token token = new Token(msg.sender, gift);
        token.approve(this, -1);

        tokens[msg.sender] = token;
        people[address(token)] = sender;

        emit Signup(msg.sender, address(token));
    }

    function register(address usr) public {
        require(!trustable(usr), "currency holders cannot be validators")
        isValidator[usr] = true;
    }

    // relationships
    function trust(address usr, uint limit) public {
        require(trustable(usr));

        limits[msg.sender][usr] = limit;

        emit Trust(msg.sender, usr, limit);
    }

    function trustable(address usr) public returns (bool) {
        return address(tokens[usr]) != address(0) || isValidator[usr];
    }

    // care work
    function transferThrough(address[] memory users, uint wad) public {
        require(users.length <= 5);

        address prev = msg.sender;
        for (uint i = 0; i < users.length; i++) {
            address curr = users[i];

            if (isValidator[curr]) {

                address next = users[i+1];
                require(limits[curr][prev] > 0, "validator does not trust sender");
                require(tokens[prev].balanceOf(next) + wad <= limits[next][curr], "trust limit exceeded");

                tokens[prev].transferFrom(prev, next, wad);
                prev = next;
                i++;

            } else {

                require(tokens[prev].balanceOf(curr) + wad <= limits[curr][prev], "trust limit exceeded");

                tokens[prev].transferFrom(prev, curr, wad);
                prev = curr;

            }
        }
    }
}
