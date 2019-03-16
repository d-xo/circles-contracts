pragma solidity ^0.5.0;

import "ds-test/test.sol";
import "../hub.sol";

contract Validator {
    Hub hub;
    constructor(Hub hub_) public {
        hub = hub_;
    }

    function trust(address usr, uint limit) public { hub.trust(usr, limit); }
}

contract User {
    Hub hub;
    constructor(Hub hub_) public {
        hub = hub_;
    }

    function join() public { hub.join(); }
    function trust(address usr, uint limit) public { hub.trust(usr, limit); }
}

contract Init is DSTest {
    function test_constructor() public {
        Hub hub = new Hub(1, 2, 3);

        assertEq(hub.gift(), 1);
        assertEq(hub.give(), 2);
        assertEq(hub.take(), 3);
    }
}


contract Admin is DSTest {
    uint gift = 1 ether;
    uint give = 2 wei;
    uint take = 3 wei;

    function test_file() public {
        Hub hub = new Hub(0, 0, 0);

        hub.file("gift", gift);
        hub.file("give", give);
        hub.file("take", take);

        assertEq(hub.gift(), gift);
        assertEq(hub.give(), give);
        assertEq(hub.take(), take);
    }
}


contract Entry is DSTest {
    uint gift = 1 ether;
    uint give = 2 wei;
    uint take = 3 wei;

    Hub hub = new Hub(gift, give, take);
    address me = address(this);

    function test_join() public {
        assertTrue(address(hub.tokens(me)) == address(0x0));

        hub.join();

        // token created
        Token token = hub.tokens(me);
        assertTrue(address(token) != address(0x0));

        // reverse lookup populated
        assertEq(hub.people(address(token)), me);

        // hub can manage tokens
        assertEq(token.allowance(me, address(hub)), uint(-1));

        // initial balance is correct
        assertEq(token.balanceOf(me), gift);
    }

    function test_register() public {
        assertTrue(!hub.isValidator(me));

        hub.register(me);

        assertTrue(hub.isValidator(me));
    }
}

contract Trust is DSTest {
    uint gift = 1 ether;
    uint give = 2 wei;
    uint take = 3 wei;

    Hub hub = new Hub(gift, give, take);

    address me    = address(this);
    address alice = address(new User(hub));

    function setUp() public {
        User(alice).join();
    }

    function test_trust() public {
        assertEq(hub.limits(me, alice), 0);

        hub.trust(alice, 10 ether);
        assertEq(hub.limits(me, alice), 10 ether);

        hub.trust(alice, 3 wei);
        assertEq(hub.limits(me, alice), 3 wei);
    }

    function test_trustable_join() public {
        assertTrue(!hub.trustable(me));

        hub.join();

        assertTrue(hub.trustable(me));
    }

    function test_trustable_register() public {
        assertTrue(!hub.trustable(me));

        hub.register(me);

        assertTrue(hub.trustable(me));
    }
}

contract Transfer is DSTest {
    uint gift = 1 ether;
    uint give = 2 wei;
    uint take = 3 wei;

    Hub hub = new Hub(gift, give, take);

    address me   = address(this);
    address alex = address(new User(hub));
    address beth = address(new User(hub));
    address carl = address(new User(hub));
    address dani = address(new User(hub));

    address validator = address(new Validator(hub));

    function setUp() public {
        User(alex).join();
        User(beth).join();
        User(carl).join();
        User(dani).join();
        hub.register(validator);

        User(alex).trust(beth, uint(-1));
        User(alex).trust(carl, uint(-1));
        User(alex).trust(dani, uint(-1));
        User(alex).trust(validator, uint(-1));

        User(beth).trust(alex, uint(-1));
        User(beth).trust(carl, uint(-1));
        User(beth).trust(dani, uint(-1));
        User(beth).trust(validator, uint(-1));

        User(carl).trust(alex, uint(-1));
        User(carl).trust(beth, uint(-1));
        User(carl).trust(dani, uint(-1));
        User(carl).trust(validator, uint(-1));

        User(dani).trust(alex, uint(-1));
        User(dani).trust(beth, uint(-1));
        User(dani).trust(carl, uint(-1));
        User(dani).trust(validator, uint(-1));

        Validator(validator).trust(alex, uint(-1));
        Validator(validator).trust(beth, uint(-1));
        Validator(validator).trust(carl, uint(-1));
        Validator(validator).trust(dani, uint(-1));
    }

    function test_through_user() public {
        address[] memory route = new address[](2);
        route[0] = alex;
        route[1] = beth;

        hub.join();
        User(alex).trust(me, uint(-1));

        hub.transferThrough(route, gift);

        assertEq(hub.tokens(me).balanceOf(me), 0);
        assertEq(hub.tokens(me).balanceOf(alex), gift);

        assertEq(hub.tokens(alex).balanceOf(alex), 0);
        assertEq(hub.tokens(alex).balanceOf(beth), gift);
    }

    function test_through_validator() public {
        address[] memory route = new address[](2);
        route[0] = validator;
        route[1] = beth;

        hub.join();
        Validator(validator).trust(me, uint(-1));

        hub.transferThrough(route, gift);

        assertEq(hub.tokens(me).balanceOf(me), 0);
        assertEq(hub.tokens(me).balanceOf(beth), gift);
    }

    function test_long_route() public {
        address[] memory route = new address[](5);
        route[0] = alex;
        route[1] = beth;
        route[2] = validator;
        route[3] = carl;
        route[4] = dani;

        hub.join();
        User(alex).trust(me, uint(-1));

        hub.transferThrough(route, gift);

        assertEq(hub.tokens(me).balanceOf(me), 0);
        assertEq(hub.tokens(me).balanceOf(alex), gift);

        assertEq(hub.tokens(alex).balanceOf(alex), 0);
        assertEq(hub.tokens(alex).balanceOf(beth), gift);

        assertEq(hub.tokens(beth).balanceOf(beth), 0);
        assertEq(hub.tokens(beth).balanceOf(carl), gift);

        assertEq(hub.tokens(carl).balanceOf(carl), 0);
        assertEq(hub.tokens(carl).balanceOf(dani), gift);
    }

    function testFail_route_too_long() public {
        address[] memory route = new address[](6);

        route[0] = alex;
        route[1] = beth;
        route[2] = validator;
        route[3] = carl;
        route[4] = dani;
        route[5] = me;

        hub.join();
        User(alex).trust(me, gift);

        hub.transferThrough(route, gift);
    }

    function testFail_transfer_through_non_trustable() public {
        address[] memory route = new address[](2);

        route[0] = address(0xdeadbeef);
        route[1] = alex;

        hub.join();
        User(alex).trust(me, gift);

        hub.transferThrough(route, gift);
    }
}
