
pragma solidity 0.8.10;

import "./bbKRL.sol";


contract TokenTransferBinaryRegulator {
  struct Transfer {
    address from;
    address to;
    uint256 amount;
    bool valid;
  }

  mapping (uint256 => Transfer) public transfers;
  uint public transferCount = 0;
  address public owner;
  ERC20Extended public token;

  event TransferRequested(uint256 id, address from, address to, uint256 amount);
  event TransferRequestExecuted(uint256 id);
  event TransferRequestInvalidated(uint256 id);

  constructor(address _owner, BuyBackKRL _token) public {
    owner = _owner;
    token = _token;
  }

  function requestTransfer(address _from, address _to, uint256 _amount) public {
    require(_from == msg.sender, "colony-token-regulator-not-from-address");
    transferCount += 1;
    transfers[transferCount] = Transfer(_from, _to, _amount, true);

    emit TransferRequested(transferCount, _from, _to, _amount);
  }

  function executeTransfer(uint256 _id) public {
    require(transfers[_id].valid, "token-regulator-transfer-invalid-or-already-executed");
    require(msg.sender == owner, "token-regulator-only-owner-can-execute");
    transfers[_id].valid = false;
    token.transferFrom(transfers[_id].from, transfers[_id].to, transfers[_id].amount);
  
    emit TransferRequestExecuted(_id);
  }

  function invalidateRequest(uint256 _id) public {
    require(transfers[_id].from == msg.sender || msg.sender == owner, "token-regulator-not-from-address");
    transfers[_id].valid = false;

    emit TransferRequestInvalidated(_id);
  }
}
