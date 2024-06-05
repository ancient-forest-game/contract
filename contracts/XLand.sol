// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./XLandToken.sol";
import "./Governable.sol";

contract XLand is Governable {
    address private _XCoinAddress;
    uint256 private _rate;
    mapping(address => uint256) public userScore;
    mapping(address => bytes) public userSave;
    address[10] public rankingList;

    constructor(address XCoinAddress, uint256 rate) {
        _XCoinAddress = XCoinAddress;
        _rate = rate;
        super.initialize(msg.sender);
    }

    function saveInfo(uint256 score, bytes calldata info, address user) public {
        userScore[user] = score;
        userSave[user] = info;

        address tem1;
        address tem2;
        for (uint256 i = 0; i < 10; i++) {
            if (rankingList[i] != address(0)) {
                if (tem1 != address(0)) {
                    tem2 = rankingList[i];
                    rankingList[i] = tem1;
                    tem1 = tem2;
                } else if (score >= userScore[rankingList[i]]) {
                    tem1 = rankingList[i];
                    rankingList[i] = user;
                }
            } else {
                if (tem1 != address(0)) {
                    rankingList[i] = tem1;
                } else {
                    rankingList[i] = user;
                }
                break;
            }
        }
    }

    function exchange(uint256 score, address user) external returns (bool) {
        userScore[user] = 0;
        userSave[user] = "";
        XLandToken(_XCoinAddress).mint(user, score * _rate);
        return true;
    }

    function setXCoinAddress(address XCoinAddress_) external governance {
        _XCoinAddress = XCoinAddress_;
    }

    function setRate(uint256 rate_) external governance {
        _rate = rate_;
    }

    function getUserScore(address user) external view returns (uint256) {
        return userScore[user];
    }

    function getUserSave(address user) external view returns (bytes memory) {
        return userSave[user];
    }

    function getRankingList() external view returns (address[10] memory) {
        return rankingList;
    }
}
