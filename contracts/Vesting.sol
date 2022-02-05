
pragma solidity 0.8.10;

import "./bbKRL.sol";
import "../lib/dappsys/auth.sol";
import "../lib/dappsys/math.sol";
import "../lib/dappsys/erc20.sol";


contract VestingSimple is DSMath, DSAuth {

  event GrantSet(address recipient, uint256 amount);
  event GrantClaimed(address recipient, uint256 claimed);

  KRL public token; // The token being distributed

  uint256 constant public INITIAL_CLAIMABLE;
  uint256 constant public VESTING_DURATION = (365 days * 2)-1; // The period of time (in seconds) over which the vesting occurs
  uint256 public startTime; // The timestamp of activation, when vesting begins
  
 
  
  function getBMCamout() public returns(uint){
    require(listedusers.whitelistCheck(msg.sender) == true,"you are not white listed");
    Wuser storage wuser = wusers[block.timestamp];
    listedusers.KRLbalance(msg.sender)/40;
    wuser.DeservingBMC= listedusers.KRLbalance(msg.sender);
    wuser.BMCamount = wuser.DeservingBMC/730 days;
    wuser.maturity = block.timestamp;
    wuser.userAddress = msg.sender;
    wuser.BMCamount = DeservingBMC/63072000;
    BMCflow = true;
    return DeservingBMC;
  }

  uint256 public totalAmount; // Sum of all grant amounts
  uint256 public totalClaimed; // Sum of all claimed tokens

  struct Grant {
    uint256 amount;
    uint256 claimed;
  }

  mapping (address => Grant) public grants;

  constructor(address _token) {
    require(_token != address(0x0), "vesting-simple-invalid-token");

    token = Token(_token);
  }

  function withdraw(uint256 _amount) external auth {
    require(token.transfer(msg.sender, _amount), "vesting-simple-transfer-failed");
  }

  function activate() external auth {
    require(startTime == 0, "vesting-simple-already-active");
    startTime = block.timestamp;
  }

  function setGrant(address _recipient, uint256 _amount) public auth {
    Grant storage grant = grants[_recipient];
    require(grant.claimed <= _amount, "vesting-simple-bad-amount");

    totalAmount = add(_amount, sub(totalAmount, grant.amount));
    grant.amount = _amount;

    emit GrantSet(_recipient, _amount);
  }

  function setGrants(address[] calldata _recipients, uint256[] calldata _amounts) external auth {
    require(_recipients.length == _amounts.length, "vesting-simple-bad-inputs");

    for (uint256 i; i < _recipients.length; i++) {
      setGrant(_recipients[i], _amounts[i]);
    }
  }

  function claimGrant() external {
    Grant storage grant = grants[msg.sender];
    uint256 claimable = sub(getClaimable(grant.amount), grant.claimed);
    require(claimable > 0, "vesting-simple-nothing-to-claim");

    grant.claimed = add(grant.claimed, claimable);
    totalClaimed = add(totalClaimed, claimable);

    assert(grant.amount >= grant.claimed);
    assert(totalAmount >= totalClaimed);

    require(token.transfer(msg.sender, claimable), "vesting-simple-transfer-failed");

    emit GrantClaimed(msg.sender, claimable);
  }

  function getClaimable(uint256 _amount) public view returns (uint256) {
    if (startTime == 0) { return 0; }
    uint256 fractionUnlocked = min(WAD, wdiv((block.timestamp - startTime), VESTING_DURATION)); // Max 1
    uint256 remainder = sub(max(INITIAL_CLAIMABLE, _amount), INITIAL_CLAIMABLE); // Avoid underflows for small grants
    return min(_amount, add(INITIAL_CLAIMABLE, wmul(fractionUnlocked, remainder)));
  }
}
