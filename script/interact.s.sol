//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "lib/foundry-devops/src/DevOpsTools.sol";

import "../src/MerkleAirdrop.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ClaimAirDrop is Script {
    address CLAIMINIG_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 PROOF_ONE =
        0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_TWO =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [PROOF_ONE, PROOF_TWO];
    bytes private SIGN =
        hex"1fabe6bce5a0b52e2f0c22db537866e2e7ea6d4e2dcc3ae57c975af39b11656873871bfbdf5067eda988e71114b875bfe9d492ce0911fd39273870a79873b28e1c";

    function claimAirDrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSig(SIGN);
        MerkleAirdrop airdropContract = MerkleAirdrop(airdrop);
        airdropContract.claim(
            CLAIMINIG_ADDRESS,
            CLAIMING_AMOUNT,
            proof,
            v,
            r,
            s
        );
        vm.stopBroadcast();
    }

    function splitSig(
        bytes memory sign
    ) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sign.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sign, 32))
            s := mload(add(sign, 64))
            v := byte(0, mload(add(sign, 96)))
        }
    }

    function run() external {
        address mostRecentAirdrop = DevOpsTools.get_most_recent_deployment(
            "MerkleAirdrop",
            block.chainid
        );
        claimAirDrop(mostRecentAirdrop);
    }
}
