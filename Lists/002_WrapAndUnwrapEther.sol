//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IWETH {
  function deposit() external payable;

  function withdraw(uint256) external;

  function approve(address guy, uint256 wad) external returns (bool);

  function transferFrom(
    address src,
    address dst,
    uint256 wad
  ) external returns (bool);
}

import {Ownable} from 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol';

contract EthWrapper is Ownable {

  // rinkebyWETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab; // WETH on Rinkeby Testnet
  // mainWETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH on Mainnet


  IWETH internal immutable WETH;

  /**
   * @dev Sets the WETH address
   * @param weth - address of the Wrapped Ether contract
   **/
  constructor(address weth) {
    WETH = IWETH(weth);
  }

  /**
   * @dev approves this contract once for the highest possible amount
   **/
  function authorize() external onlyOwner {
    WETH.approve(address(this), type(uint256).max);
  }

  /**
   * @dev deposits ETH and receives WETH
   **/
  function depositETH(
  ) external payable {
    WETH.deposit{value: msg.value}();
  }

  /**
   * @dev withdraws the ETH for the WETH in this contract and sends it to specified address
   * @param amount - WETH to withdraw and receive native ETH
   * @param to - address of the user who will receive native ETH
   */
  function withdrawETH(
    uint256 amount,
    address to
  ) external {

    WETH.withdraw(amount);
    _safeTransferETH(to, amount);
  }

  /**
   * @dev transfer ETH to an address, revert if it fails.
   * @param to - recipient of the transfer
   * @param value - the amount to send
   */
  function _safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, 'ETH_TRANSFER_FAILED');
  }

  /**
   * @dev Get WETH address used by WETHWrapper
   */
  function getWETHAddress() external view returns (address) {
    return address(WETH);
  }

  /**
   * @dev Only WETH contract is allowed to transfer ETH here. Prevent other addresses to send Ether to this contract.
   * Other addresses will have to use the depositEth function
   */
  receive() external payable {
    require(msg.sender == address(WETH), 'Receive not allowed');
  }

  /**
   * @dev Revert fallback calls
   */
  fallback() external payable {
    revert('Fallback not allowed');
  }
}
