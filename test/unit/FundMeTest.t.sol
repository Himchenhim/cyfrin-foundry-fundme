// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundMeTest is Test {
    FundMe fundMe;

    uint256 constant TESTING_WEI = 0.1 ether; // 10e18
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    address USER = makeAddr("USER");

    // us -> FundMeTest -> FundMe
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsdt() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // the next line should revert
        fundMe.fund(); // send 0 value // if we want to send value -> fundMe.fund{}();
        // assert(this tx fails/reverts)
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // the next tx will be sent by USER address
        fundMe.fund{value: TESTING_WEI}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, TESTING_WEI);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: TESTING_WEI}();
        _;
    }

    function testWithdrawMoney() public funded {
        vm.expectRevert();
        fundMe.withdraw();

        vm.prank(msg.sender);
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act

        // uint256 gasStart = gasleft(); // UNCOMMENT if you want to test how much gas does it cost
        // vm.txGasPrice(GAS_PRICE); // UNCOMMENT if you want to test how much gas does it cost
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //uint256 gasEnd = gasleft(); // UNCOMMENT if you want to test how much gas does it cost
        //console.log( (gasStart - gasEnd) * tx.gasprice); // UNCOMMENT if you want to test how much gas does it cost

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance,startingFundMeBalance + startingOwnerBalance);
    }

    function testGetters() public {
        vm.prank(USER); // the next tx will be sent by USER address
        fundMe.fund{value: TESTING_WEI}();

        // getAddressToAmountFunded
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, TESTING_WEI);

        // getFunder
        address user = fundMe.getFunder(0);
        assertEq(user, USER);
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; ++i){
            hoax(address(i),TESTING_WEI);
            fundMe.fund{value: TESTING_WEI}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();


        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance  + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testCheaperWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; ++i){
            hoax(address(i),TESTING_WEI);
            fundMe.fund{value: TESTING_WEI}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();


        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance  + startingOwnerBalance == fundMe.getOwner().balance);
    }

    
}
