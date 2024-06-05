// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./XLandToken.sol";
import "./Prop.sol";
import "./Governable.sol";
import "./ERC6551Registry.sol";
import "./AccountProxy.sol";

contract RoleNFT is Governable, ERC721 {
    event Mint(address indexed owner, uint256 tokenId, address registry6551);

    uint256 private _maxAmount;
    uint256 private _counter;
    string private _baseURIVal;
    address private _registryAddress;
    address private _implementationProxy;
    address private _implementation;
    uint256 private _chainId;
    uint256 private _XCoinAmount;
    address private _XCoinAddress;
    address private _PropAddress;
    uint256 private _XCoinCost;
    uint256 private _PropCost;
    mapping(address => uint256[]) private _ownerOfAll;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI,
        uint256 chainId,
        uint256 maxAmount,
        uint256 XCoinAmount,
        address XCoinAddress,
        address PropAddress,
        uint256 XCoinCost,
        uint256 PropCost
    ) ERC721(name, symbol) {
        _baseURIVal = baseURI;
        _registryAddress = 0x000000006551c19487814612e58FE06813775758;
        _implementationProxy = 0x55266d75D1a14E4572138116aF39863Ed6596E7F;
        _implementation = 0x41C8f39463A868d3A88af00cd0fe7102F30E44eC;
        _chainId = chainId;
        _maxAmount = maxAmount;
        _XCoinAmount = XCoinAmount;
        _XCoinAddress = XCoinAddress;
        _PropAddress = PropAddress;
        _XCoinCost = XCoinCost;
        _PropCost = PropCost;
        super.initialize(msg.sender);
    }

    function setBaseURI(string memory baseURI) external governance {
        _baseURIVal = baseURI;
    }

    function setRegistryAddress(address registryAddress_) external governance {
        _registryAddress = registryAddress_;
    }

    function setImplementationProxy(
        address implementationProxy_
    ) external governance {
        _implementationProxy = implementationProxy_;
    }

    function setImplementation(address implementation_) external governance {
        _implementation = implementation_;
    }

    function setChainId(uint256 chainId) external governance {
        _chainId = chainId;
    }

    function setXCoinAmount(uint256 XCoinAmount_) external governance {
        _XCoinAmount = XCoinAmount_;
    }

    function setXCoinAddress(address XCoinAddress_) external governance {
        _XCoinAddress = XCoinAddress_;
    }

    function setPropAddress(address PropAddress_) external governance {
        _PropAddress = PropAddress_;
    }

    function setXCoinCost(uint256 XCoinCost_) external governance {
        _XCoinCost = XCoinCost_;
    }

    function setPropCost(uint256 PropCost_) external governance {
        _PropCost = PropCost_;
    }

    function setMaxAmount(uint256 maxAmount_) external governance {
        _maxAmount = maxAmount_;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIVal;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        if (from != address(0)) {
            uint l = _ownerOfAll[from].length;
            for (uint i = 0; i < l; i++) {
                if (_ownerOfAll[from][i] == tokenId) {
                    _ownerOfAll[from][i] = _ownerOfAll[from][l - 1];
                    _ownerOfAll[from].pop();
                    break;
                }
            }
        }
        _ownerOfAll[to].push(tokenId);
    }

    function getOwnerOfAll(
        address owner
    ) public view returns (uint256[] memory) {
        return _ownerOfAll[owner];
    }

    function mintTo(address to) internal returns (address) {
        require(_counter < _maxAmount, "max limit reached");
        _counter += 1;
        _mint(to, _counter);
        address registry6551 = ERC6551Registry(_registryAddress).createAccount(
            _implementationProxy,
            0,
            _chainId,
            address(this),
            _counter
        );
        AccountProxy(registry6551).initialize(_implementation);
        emit Mint(to, _counter, registry6551);
        return registry6551;
    }

    function mint() public {
        mintTo(msg.sender);
    }

    function mintXCoin() public payable {
        require(msg.value >= _XCoinCost, "Insufficient funds.");
        address registry6551 = mintTo(msg.sender);
        XLandToken(_XCoinAddress).mint(registry6551, _XCoinAmount);
    }

    function mintProp() public payable returns (uint256) {
        require(msg.value >= _PropCost, "Insufficient funds.");
        address registry6551 = mintTo(msg.sender);
        uint256 tokenId = Prop(_PropAddress).mint(registry6551);
        return tokenId;
    }

    function emergencyWithdraw(
        address payee,
        uint256 amount
    ) external governance {
        payable(payee).transfer(amount);
    }
}
