// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract TokenHost is ERC20 {
    IERC20 immutable token0;
    IERC20 immutable token1;
    address hook;

    constructor(IERC20 _token0, IERC20 _token1) ERC20("Host", "HOST") {
        token0 = _token0;
        token1 = _token1;
    }

    modifier onlyHook() {
        require(msg.sender == hook);
        _;
    }

    function setHook(address _hook) external {
        require(hook == address(0), "Hook already defined");
        hook = _hook;
    }

    function totalSupply() public view override returns (uint256) {
        // todo normalize decimals
        uint256 supply0 = token0.balanceOf(address(this));
        uint256 supply1 = token1.balanceOf(address(this));

        return supply0 + supply1;
    }

    function deposit(uint256 amount0, uint256 amount1) external onlyHook {
        token0.transferFrom(msg.sender, address(this), amount0);
        token1.transferFrom(msg.sender, address(this), amount1);
    }

    function withdraw(address receiver, uint256 amount0, uint256 amount1) external onlyHook {
        token0.transfer(receiver, amount0);
        token1.transfer(receiver, amount1);
    }
}
