pragma solidity ^0.5.0;

import "ds-test/test.sol";
import "../hub.sol";

contract User {
    function join(Hub hub) public {
        hub.join();
    }
}

contract Validator {}

contract Test is DSTest {

    uint gift = 1 ether;
    uint give = 2 wei;
    uint take = 3 wei;

    Hub hub = new Hub(gift, give, take);
    User user = new User();
    Validator validator = new Validator();

    function test_constructor() public {
        assertEq(hub.gift(), gift);
        assertEq(hub.give(), give);
        assertEq(hub.take(), take);
    }

    function test_file() public {
        hub = new Hub(0, 0, 0);

        hub.file("gift", gift);
        hub.file("give", give);
        hub.file("take", take);

        assertEq(hub.gift(), gift);
        assertEq(hub.give(), give);
        assertEq(hub.take(), take);
    }

    function test_join() public {
        Token token = hub.tokens(address(user));
        assertTrue(address(token) == address(0x0));

        user.join(hub);

        // token created
        token = hub.tokens(address(user));
        assertTrue(address(token) != address(0x0));

        // reverse lookup
        assertEq(hub.people(address(token)), address(user));

        // hub can manage users tokens
        assertEq(token.allowance(address(user), address(hub)), uint(-1));

        // user has correct inital balance
        assertEq(token.balanceOf(address(user)), gift);
    }

    function test_register() public {
        assertTrue(!hub.isValidator(address(validator)));

        hub.register(address(validator));

        assertTrue(hub.isValidator(address(validator)));
    }
}

