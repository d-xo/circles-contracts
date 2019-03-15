// Adapted from https://github.com/uport-project/uport-identity/blob/develop/contracts/TxRelay.sol

pragma solidity ^0.5.0;

contract Relay {
    // auth
    address public owner;
    function updateOwner(address usr) public auth { owner = usr; }
    modifier auth() { require (msg.sender == owner); _; }

    // data
    mapping(address => uint) nonce;

    /*
     * @dev Relays meta transactions
     * @param sigV, sigR, sigS ECDSA signature on some data to be forwarded
     * @param destination Location the meta-tx should be forwarded to
     * @param data The bytes necessary to call the function in the destination contract.
     * Note: The first encoded argument in data must be address of the signer. This means
     * that all functions called from this relay must take an address as the first parameter.
     */
    function relayMetaTx(
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        address destination,
        bytes memory data
    )
        public
        auth
        returns (bytes memory)
    {

        address claimedSender = getAddress(data);

        // use EIP 191
        // 0x19 :: version :: relay :: nonce :: destination :: data
        bytes32 h = keccak256(
            abi.encodePacked(
                byte(0x19),
                byte(0),
                this,
                nonce[claimedSender],
                destination,
                data
            )
        );
        address addressFromSig = ecrecover(h, sigV, sigR, sigS);

        require(claimedSender == addressFromSig);

        nonce[claimedSender]++; //if we are going to do tx, update nonce

        (bool success, bytes memory callData) = destination.call(data);
        require(success);
        return callData;
    }

    /*
     * @dev Gets an address encoded as the first argument in transaction data
     * @param b The byte array that should have an address as first argument
     * @returns a The address retrieved from the array
     (Optimization based on work by tjade273)
     */
    function getAddress(bytes memory b) public pure returns (address a) {
        if (b.length < 36) return address(0);
        assembly {
            let mask := 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            a := and(mask, mload(add(b, 36)))
            // 36 is the offset of the first parameter of the data, if encoded properly.
            // 32 bytes for the length of the bytes array, and 4 bytes for the function signature.
        }
    }

    /*
     * @dev Returns the local nonce of an account.
     * @param add The address to return the nonce for.
     * @return The specific-to-this-contract nonce of the address provided
     */
    function getNonce(address add) public view returns (uint) {
        return nonce[add];
    }
}
