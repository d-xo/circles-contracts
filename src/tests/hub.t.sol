pragma solidity ^0.5.0;

import "ds-test/test.sol";
import "../hub.sol";

contract User {
    function join(Hub hub) public { hub.join(); }
}

contract Test is DSTest {
    uint gift = 1 ether;
    uint give = 2 wei;
    uint take = 3 wei;

    Hub hub = new Hub(gift, give, take);

    address me    = address(this);
    address alice = address(new User());
    address bob   = address(new User());

    address validator = address(0xdeadbeef);

    function setUp() public {
        User(alice).join(hub);
        User(bob).join(hub);
    }
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
        hub = new Hub(0, 0, 0);

        hub.file("gift", gift);
        hub.file("give", give);
        hub.file("take", take);

        assertEq(hub.gift(), gift);
        assertEq(hub.give(), give);
        assertEq(hub.take(), take);
    }
}


contract Entry is Test {
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

contract Join is Test {
    function test_trust() public {
        assertEq(hub.limits(me, alice), 0);

        hub.trust(alice, 10 ether);
        assertEq(hub.limits(me, alice), 10 ether);

        hub.trust(alice, 3 wei);
        assertEq(hub.limits(me, alice), 3 wei);
    }

    function test_trustable_join() public {
        Hub hub = new Hub(gift, give, take);
        assertTrue(!hub.trustable(me));

        hub.join();

        assertTrue(hub.trustable(me));
    }

    function test_trustable_register() public {
        Hub hub = new Hub(gift, give, take);
        assertTrue(!hub.trustable(me));

        hub.register(me);

        assertTrue(hub.trustable(me));
    }
}

