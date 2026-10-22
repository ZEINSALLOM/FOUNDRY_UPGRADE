//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradBox} from "../script/UpgradBox.s.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {BoxV1} from "../src/BoxV1.sol";

contract DeployAndUpgradeTset is Test {
    DeployBox deployBox;
    UpgradBox upgradBox;
    address public owner = makeAddr("owner");
    address public proxy;
    function setUp() public {
        deployBox = new DeployBox();
        upgradBox = new UpgradBox();
        proxy= deployBox.run();

    }
    function testProxyStartAsBoxV1() public {
        uint256 expectedVersion = 1;
        assertEq(BoxV1(proxy).version(), expectedVersion, "Version mismatch");
        vm.expectRevert();
        BoxV2(proxy).setNumber(42);

    }
    function testUpgrade () public {
      BoxV2 boxV2 = new BoxV2();
      upgradBox.upgradeBox(proxy, address(boxV2));
      uint256 expectedVersion = 2;
      assertEq(BoxV2(proxy).version(), expectedVersion, "Version mismatch after upgrade");
      BoxV2(proxy).setNumber(42);
      assertEq(BoxV2(proxy).getNumber(), 42, "Number mismatch after upgrade");
    }
}