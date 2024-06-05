// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Governable.sol";

contract Prop is Governable, ERC1155 {
    using Strings for uint256;

    string private baseURI;
    uint256 private _nonce;
    uint256 private _kinds;
    mapping(address => bool) private _minter;

    modifier onlyMinter() {
        require(_minter[msg.sender] || msg.sender == governor, "only minter");
        _;
    }

    event Mint(address indexed owner, uint256 _id);

    constructor(string memory baseURI_, uint256 kinds_) ERC1155(baseURI_) {
        baseURI = baseURI_;
        _kinds = kinds_;
        super.initialize(msg.sender);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    function speedUp() public returns (bool) {
        _burn(msg.sender, 1, 1);
        return true;
    }

    function mint(address to_) public onlyMinter returns (uint256) {
        uint256 id = rand();
        _mint(to_, id, 1, "");
        emit Mint(to_, id);
        return id;
    }

    function rand() internal returns (uint256) {
        uint256 random = (uint256(
            keccak256(
                abi.encodePacked(block.difficulty, block.timestamp, _nonce)
            )
        ) % _kinds) + 1;
        _nonce++;
        return random;
    }

    function setKinds(uint256 kinds_) external governance {
        _kinds = kinds_;
    }

    function setURI(string memory baseURI_) external governance {
        baseURI = baseURI_;
        _setURI(baseURI_);
    }

    function setMinter(address minter_, bool state) external governance {
        _minter[minter_] = state;
    }
}
