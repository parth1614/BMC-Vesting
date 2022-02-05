
pragma solidity 0.8.10;

import "../lib/dappsys/auth.sol";


contract TokenAuthority is DSAuthority {
  address public token;
  mapping(address => mapping(bytes4 => bool)) authorizations;

  bytes4 constant BURN_FUNC_SIG = bytes4(keccak256("burn(uint256)"));
  bytes4 constant BURN_OVERLOAD_FUNC_SIG = bytes4(keccak256("burn(address,uint256)"));

  constructor(address _token, address _colony, address[] memory allowedToTransfer) public {
    token = _token;
    bytes4 transferSig = bytes4(keccak256("transfer(address,uint256)"));
    bytes4 transferFromSig = bytes4(keccak256("transferFrom(address,address,uint256)"));
    bytes4 mintSig = bytes4(keccak256("mint(uint256)"));
    bytes4 mintSigOverload = bytes4(keccak256("mint(address,uint256)"));

    authorizations[_colony][transferSig] = true;
    authorizations[_colony][mintSig] = true;
    authorizations[_colony][mintSigOverload] = true;

    for (uint i = 0; i < allowedToTransfer.length; i++) {
      authorizations[allowedToTransfer[i]][transferSig] = true;
      authorizations[allowedToTransfer[i]][transferFromSig] = true;
    }
  }

  function canCall(address src, address dst, bytes4 sig) public override view returns (bool) {
    if (sig == BURN_FUNC_SIG || sig == BURN_OVERLOAD_FUNC_SIG) {
      // anyone can burn their own tokens even when the token is still locked
      return true;
    }

    if (dst != token) {
      return false;
    }

    return authorizations[src][sig];
  }
}
