//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "../src/MerkleAirdrop.sol";
import "forge-std/Script.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {BiganToken} from "../src/BiganToken..sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToTransfer = 4 * 25 * 1e18;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BiganToken) {
        vm.startBroadcast();
        BiganToken token = new BiganToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(
            s_merkleRoot,
            IERC20(address(token))
        );
        token.mint(token.owner(), s_amountToTransfer);
        token.transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() external returns (MerkleAirdrop, BiganToken) {
        return deployMerkleAirdrop();
    }
}
