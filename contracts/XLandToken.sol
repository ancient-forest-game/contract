// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Governable.sol";

contract XLandToken is ERC20, Governable {
    mapping(address => bool) private _minter;
    modifier onlyMinter() {
        require(_minter[msg.sender] || msg.sender == governor, "only minter");
        _;
    }
    event Mint(address indexed owner, uint256 amount);

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        super.initialize(msg.sender);
    }

    function setMinter(address minter_, bool state) external governance {
        _minter[minter_] = state;
    }

    function mint(address account, uint256 amount) external onlyMinter {
        _mint(account, amount);
        emit Mint(account, amount);
    }
}
