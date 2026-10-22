# UUPS Upgradeable Smart Contracts

A Solidity project demonstrating **UUPS proxy-based smart contract upgrades** using OpenZeppelin, ERC1967Proxy, and Foundry.

The project implements an initial `BoxV1` contract, deploys it behind an `ERC1967Proxy`, and upgrades the proxy to a new implementation, `BoxV2`, while preserving the contract's storage.

## Overview

Smart contract upgradeability allows developers to introduce new functionality without changing the address through which users interact with a deployed contract.

This project demonstrates the UUPS (Universal Upgradeable Proxy Standard) pattern, where upgrade authorization is implemented in the logic contract rather than directly in the proxy.

The proxy delegates function calls to its current implementation and maintains the application state in proxy storage. When the implementation changes, the proxy address remains the same.

## Features

- **UUPS Upgradeability:** Implements an upgrade mechanism using OpenZeppelin's UUPS upgrade contract.
- **ERC1967 Proxy:** Deploys a proxy that delegates calls to an implementation contract.
- **Upgradeable Initialization:** Initializes the V1 implementation through the proxy.
- **Version Tracking:** Uses a `version()` function to distinguish between implementation versions.
- **Storage Preservation:** Demonstrates retaining stored state across implementation upgrades.
- **Deployment Scripts:** Uses Foundry scripts to deploy the proxy and upgrade its implementation.
- **Automated Testing:** Verifies implementation versions, access restrictions, and functionality after upgrading.

## Project Structure

The following structure is based on the provided files. Adjust the test filename if necessary.

```text
.
├── src/
│   ├── BoxV1.sol
│   └── BoxV2.sol
├── script/
│   ├── DeployBox.s.sol
│   └── UpgradBox.s.sol
├── test/
│   └── DeployAndUpgradeTest.t.sol
├── lib/
│   ├── forge-std/
│   ├── openzeppelin-contracts/
│   ├── openzeppelin-contracts-upgradeable/
│   └── foundry-devops/
├── foundry.toml
└── README.md
```

## Smart Contracts

### 1. BoxV1.sol

The initial implementation of the upgradeable Box contract.

**Key components:**

- `Initializable`: Provides initializer-based setup for proxy deployments.
- `OwnableUpgradeable`: Provides ownership functionality for upgrade authorization.
- `UUPSUpgradeable`: Provides the UUPS upgrade mechanism.
- `initialize()`: Initializes the contract through the proxy.
- `getNumber()`: Returns the stored number.
- `version()`: Returns implementation version `1`.
- `_authorizeUpgrade()`: Restricts upgrades to the owner through `onlyOwner`.

The implementation constructor calls `_disableInitializers()` to prevent the implementation contract itself from being initialized directly.

### 2. BoxV2.sol

The second implementation introduces the next version of the Box contract.

**Key functions:**

- `setNumber(uint256 num)`: Updates the stored number.
- `getNumber()`: Reads the stored number.
- `version()`: Returns implementation version `2`.
- `_authorizeUpgrade()`: Defines the authorization hook for further upgrades.

The purpose of this version is to demonstrate how new functionality can be introduced while continuing to interact with the existing proxy.

## Deployment and Upgrade Scripts

### DeployBox.s.sol

The deployment script performs the following steps:

1. Deploys the `BoxV1` implementation.
2. Encodes the `initialize()` function call.
3. Deploys an `ERC1967Proxy` pointing to the implementation.
4. Initializes the proxy during deployment.
5. Returns the proxy address.

Users should interact with the proxy address rather than directly with the implementation contract.

### UpgradBox.s.sol

The upgrade script:

1. Retrieves the most recent `ERC1967Proxy` deployment for the current chain using `DevOpsTools`.
2. Deploys the `BoxV2` implementation.
3. Calls `upgradeToAndCall()` through the proxy.
4. Returns the proxy address.

The proxy address remains unchanged; only its implementation is updated.

The deployment lookup requires the relevant deployment records to be available to Foundry DevOps Tools.

## Upgrade Workflow

```text
Deploy BoxV1
     |
     v
Deploy ERC1967Proxy
     |
     v
Initialize Proxy
     |
     v
Interact with BoxV1
     |
     v
Deploy BoxV2
     |
     v
Authorize and Execute Upgrade
     |
     v
Interact with BoxV2
     |
     v
Verify Version and Storage
```

## Installation and Setup

### Prerequisites

- [Git](https://git-scm.com/)
- [Foundry](https://getfoundry.sh/)
- A compatible Solidity compiler
- OpenZeppelin Contracts and OpenZeppelin Contracts Upgradeable
- Foundry DevOps Tools

### Clone the Repository

```bash
git clone https://github.com/ZEINSALLOM/FOUNDRY_UPGRADE.git
cd FOUNDRY_UPGRADE
```

### Install Dependencies

Install the required dependencies if they are not already configured:

```bash
forge install foundry-rs/forge-std
forge install OpenZeppelin/openzeppelin-contracts
forge install OpenZeppelin/openzeppelin-contracts-upgradeable
```

Install and configure Foundry DevOps Tools according to its repository instructions.

Ensure `foundry.toml` contains the necessary remappings for all imported dependencies.

## Build

Compile the project:

```bash
forge build
```

## Run Tests

For detailed execution traces:

```bash
forge test -vvvv
```

### Included Tests

The provided test contract demonstrates the following scenarios:

**1. Initial Implementation**

- Deploys the proxy through the deployment script.
- Verifies that `version()` returns `1`.
- Checks that `BoxV2.setNumber()` is unavailable before the upgrade.

**2. Upgrade to V2**

- Deploys a `BoxV2` implementation.
- Upgrades the proxy to the new implementation.
- Verifies that `version()` returns `2`.
- Calls `setNumber(42)`.
- Checks that `getNumber()` returns `42`.

These tests illustrate the basic upgrade lifecycle. Additional tests are recommended to verify storage preservation and upgrade authorization.

## Deployment

The deployment scripts require a configured network and appropriate deployment credentials.

A typical Foundry script command has the following structure:

```bash
forge script script/DeployBox.s.sol:DeployBox \
  --rpc-url <RPC_URL> \
  --broadcast
```

For an upgrade, configure the correct chain and deployment records before running:

```bash
forge script script/UpgradBox.s.sol:UpgradBox \
  --rpc-url <RPC_URL> \
  --broadcast
```

Replace `<RPC_URL>` with your target network's RPC endpoint.

**Important:** These commands describe the intended workflow. Verify the script behavior, broadcaster configuration, and deployment lookup before executing against a live network. Never commit private keys or other deployment secrets to the repository.

## Security Considerations

Upgradeable contracts require special care because a faulty implementation can compromise the state and functionality managed by a proxy.

Before using this project beyond local development:

- Enforce access control in every upgrade authorization hook.
- Restrict sensitive state-changing functions such as `setNumber()`.
- Use compatible upgradeable components and initializer patterns.
- Verify storage-layout compatibility between implementation versions.
- Test that existing state survives an upgrade.
- Prevent unauthorized initialization and reinitialization.
- Validate the deployment and upgrade scripts on a local network or testnet.
- Review and audit the contracts before managing real assets.

**Important:** The provided `BoxV2` implementation intentionally lacks effective access restrictions. The current code should be treated as an educational demonstration, not a production-ready upgradeable contract.

## Future Improvements

Potential improvements include:

- Implementing secure ownership or role-based access control in V2.
- Adding tests that verify storage preservation across upgrades.
- Adding negative tests for unauthorized upgrades.
- Adding automated storage-layout compatibility checks.
- Improving deployment scripts and network configuration.
- Supporting additional implementation versions.
- Integrating continuous integration for automated builds and tests.

## License

The provided Solidity files declare the **MIT License**. Add a repository-level `LICENSE` file containing the appropriate MIT license text.

---

**Disclaimer:** This project is intended for educational and development purposes. Upgradeable smart contracts should undergo comprehensive testing and independent security review before production use.
