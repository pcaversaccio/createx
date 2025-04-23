# Createx

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Createx is a factory smart contract designed to simplify and secure the usage of the `CREATE`, `CREATE2`, and `CREATE3` EVM opcodes. It enables efficient and flexible contract creation without relying on an initcode factor.

## Features

- **Easier Contract Creation**: Simplifies the deployment process using EVM opcodes.
- **Enhanced Safety**: Provides safeguards for secure contract creation.
- **CREATE3 Support**: Adds support for contract creation without requiring an initcode factor.

## Installation

To integrate Createx into your project, clone the repository and include the relevant contracts in your Solidity project:

```bash
git clone https://github.com/nodoubtz/createx.git
```

## Usage

1. Import the Createx factory contract into your Solidity project.
2. Use the provided functions to deploy contracts using the `CREATE`, `CREATE2`, or `CREATE3` opcode.

```solidity
// Example usage of Createx Factory
import "./CreatexFactory.sol";

contract MyContract {
    // Your implementation here
}
```

## Documentation

Detailed documentation is available on the [Createx Homepage](https://createx.rocks).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please fork this repository, create a new branch for your feature or fix, and submit a pull request.

---

### Acknowledgments

This repository is a fork of [pcaversaccio/createx](https://github.com/pcaversaccio/createx).
