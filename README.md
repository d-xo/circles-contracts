# Circles Contracts [![Chat Server](https://chat.joincircles.net/api/v1/shield.svg?type=online&name=circles%20chat)](https://chat.joincircles.net) [![Backers](https://opencollective.com/circles/supporters/badge.svg)](https://opencollective.com/circles) [![Follow Circles](https://img.shields.io/twitter/follow/circlesubi.svg?label=follow+circles)](https://twitter.com/CirclesUBI) [![Circles License](https://img.shields.io/badge/license-APGLv3-orange.svg)](https://github.com/CirclesUBI/circles-contracts/blob/master/LICENSE) [![Build Status](https://travis-ci.org/CirclesUBI/circles-contracts.svg?branch=master)](https://travis-ci.org/CirclesUBI/circles-contracts)

This is the initial smart contract implementation for the Circles universal basic income platform.

**Note:** This is not yet intended for deployment in a production system.

Circles is a blockchain-based Universal Basic Income implementation.

[Website](http://www.joincircles.net) // [Whitepaper](https://github.com/CirclesUBI/docs/blob/master/Circles.md) // [Chat](https://chat.joincircles.net)

## Basic design

In general the design philosophy here was to favor restriction of outside interference in token
state. The separation of individual token logics into discrete contracts allows stakeholders to
migrate their token to different circles-like systems.

There are several components:

### Token

This is derived from standard ERC20 implementations, with two main differences: The balance for the
"owner" (UBI reciever) is calculated based on the time elapsed since the contract was created, and
there is an "hubTransfer" function that allows trusted transitive exchanges. Tokens belong to only
one hub at a time, and can only transact transitively with tokens from the same hub. `Owner` can
migrate their token to a new hub, but doing so will require rebuilding the trust graph.

### Hub

This is the location of system-wide variables, and the trust graph. It has special permissions on
all tokens that have authorized it to perform transitive exchanges. Hub has an owner, which should
at least be a multisig, but can easily be another contract.

### Organization

This is a wallet that transacts in the circles system but does not receive a universal basic income.

### TxRelay

A meta-transaction relayer to pay users' gas fees for the purposes of the circles pilot. Eventually,
this functionality will be opened to other entities in the circles system.

## Development

first install [`dapptools`](https://dapp.tools/) (`curl https://dapp.tools/install | sh`)

then:

- `dapp build` to build
- `dapp test` to test
- `dapp debug` to debug unit tests


