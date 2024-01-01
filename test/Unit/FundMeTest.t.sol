// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // this cheatcode sets the user balance to starting balance
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }



    //What can we do to work with our addresses outside our system?
    // 1. Unit test
    //   - Testing a specific part of our code
    // 2. Integration test
    //   -Testing how our code works with other parts of our code
    // 3. Forked test
    //   - testing our code on a simulated rel environment
    // 4. Staging
    //   - Testing our code in a real environment that is not prod

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailWithoutEnoughETH() public{
        vm.expectRevert(); //hey the next line should revert which is equivalent to saying 
        // assert(this txn fails/reverts)
        fundMe.fund(); //send 0 value
    }

    modifier funded(){
        vm.prank(USER); //The next txn will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }


    function testAddsFunderToArrayOfFunders() public funded{
       address funder = fundMe.getFunder(0);
       assertEq(funder,USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
       vm.expectRevert();
       fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
       uint256 startingOwnerbalance = fundMe.getOwner().balance;
       uint256 startingFundMeBalance = address(fundMe).balance;

       //Act
       vm.prank(fundMe.getOwner());
       fundMe.withdraw();

       // Assert
       uint256 endingOwnerBalance = fundMe.getOwner().balance;
       uint256 endingFundMeBalance = address(fundMe).balance;
       assertEq(endingOwnerBalance, startingOwnerbalance + startingFundMeBalance);
       assertEq(endingFundMeBalance,0);
    }

     function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex =1;
        for(uint160 i = startingFunderIndex;i< numberOfFunders; i++){
            //vm.prank new address
            //vm.deal new address
            hoax(address(i),SEND_VALUE); // hoax does both prank and deal together

            //fund the fundme
            fundMe.fund{value: SEND_VALUE}();
        }

         // Arrange
       uint256 startingOwnerbalance = fundMe.getOwner().balance;
       uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
       vm.startPrank(fundMe.getOwner());
       fundMe.cheaperWithdraw();
       vm.stopPrank();

       // Assert
       uint256 endingOwnerBalance = fundMe.getOwner().balance;
       uint256 endingFundMeBalance = address(fundMe).balance;
       assertEq(endingOwnerBalance, startingOwnerbalance + startingFundMeBalance);
       assertEq(endingFundMeBalance,0);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex =1;
        for(uint160 i = startingFunderIndex;i< numberOfFunders; i++){
            //vm.prank new address
            //vm.deal new address
            hoax(address(i),SEND_VALUE); // hoax does both prank and deal together

            //fund the fundme
            fundMe.fund{value: SEND_VALUE}();
        }

         // Arrange
       uint256 startingOwnerbalance = fundMe.getOwner().balance;
       uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
       vm.startPrank(fundMe.getOwner());
       fundMe.withdraw();
       vm.stopPrank();

       // Assert
       uint256 endingOwnerBalance = fundMe.getOwner().balance;
       uint256 endingFundMeBalance = address(fundMe).balance;
       assertEq(endingOwnerBalance, startingOwnerbalance + startingFundMeBalance);
       assertEq(endingFundMeBalance,0);
    }
}
