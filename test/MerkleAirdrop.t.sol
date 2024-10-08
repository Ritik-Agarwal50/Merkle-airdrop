//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/MerkleAirdrop.sol";
import {Test, console} from "forge-std/Test.sol";
import "../src/BiganToken..sol";
import "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirDrop.s.sol";

contract MerkleAirDropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop private airdrop;
    BiganToken private token;
    uint256 public AMOUNT = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT * 4;
    bytes32 ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32 proofOne =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];
    address user;
    uint256 userPrivateKey;
    address public gasPayer;

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BiganToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }
        (user, userPrivateKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUserCanClaim() external {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHashed(user, AMOUNT);
        //sign message
        (uint8 v,bytes32 r,bytes32 s) = vm.sign(userPrivateKey, digest);
        //gasplayer calls and sign message
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT, PROOF, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance: ", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT);
    }
}
