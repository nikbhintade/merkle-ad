// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2 as console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagelToken} from "src/BagelToken.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    DeployMerkleAirdrop deployer;

    MerkleAirdrop public airdrop;
    BagelToken public token;

    bytes32 public constant ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    uint256 public constant AMOUNT_TO_CLAIM = 25e18;
    uint256 public constant AMOUNT_TO_MINT = 1000e18;

    bytes32[] public PROOF = [
        bytes32(0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a),
        bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)
    ];


    address gasPayer;
    address user;
    uint256 userPrivateKey;

    function setUp() external {
        deployer = new DeployMerkleAirdrop();
        (airdrop, token) = deployer.run();

        (user, userPrivateKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testGasPayerCanPayForClaimingAirdropWithUserSignature() public {
        uint256 startingBalance = token.balanceOf(user);
        console.log("Starting Balance of USER: ", startingBalance);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending Balance of USER: ", endingBalance);

        vm.assertEq(AMOUNT_TO_CLAIM, endingBalance - startingBalance);
    }
}
