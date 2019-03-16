pragma solidity ^0.5.0;

import "ds-test/test.sol";
import "../hub.sol";

contract User {
    function join(Hub hub) public {
        hub.join();
    }
}

contract Test is DSTest {

    uint gift = 1 ether;
    uint give = 2 wei;
    uint take = 3 wei;

    function test_constructor() public {
        Hub hub = new Hub(gift, give, take);

        assertEq(hub.gift(), gift);
        assertEq(hub.give(), give);
        assertEq(hub.take(), take);
    }

    function test_file() public {
        Hub hub = new Hub(0, 0, 0);

        hub.file("gift", gift);
        hub.file("give", give);
        hub.file("take", take);

        assertEq(hub.gift(), gift);
        assertEq(hub.give(), give);
        assertEq(hub.take(), take);
    }

    function test_join() public {
        Hub hub = new Hub(gift, give, take);
        User user = new User();

        user.join(hub);
        Token token = hub.tokens(address(user));

        // user stored
        assertTrue(address(token) != address(0x0));
        assertEq(hub.people(address(token)), address(user));

        // hub can manage users tokens
        assertEq(token.allowance(address(user), address(hub)), uint(-1));

        // user has correct inital balance
        assertEq(token.balanceOf(address(user)), gift);
    }
}

