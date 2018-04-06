pragma solidity ^0.4.18;

import "./CappedCrowdsale.sol";
import "./TimedCrowdsale.sol";
import "./MintedCrowdsale.sol";
import "./MintableToken.sol";
import "./Pausable.sol";


/**
 * @title PibbleCrowdsaleToken
 * @dev Very simple ERC20 Token that can be minted.
 * It is meant to be used in a crowdsale contract.
 */
contract PibbleToken is MintableToken  {

  string public constant name = "Pibble Token"; // solium-disable-line uppercase
  string public constant symbol = "PIB"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase

  uint256 public constant INITIAL_SUPPLY = (10*1000*1000*1000) * (10 ** uint256(decimals)); // 10 billion coin

  event Burn(address indexed burner, uint256 value);


  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function PibbleToken() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }


  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(burner, _value);
  }
  
  

}


/**
 * @title Pibble1stPresale
 * @dev This is an example of a fully fledged crowdsale.
 * The way to add new features to a base crowdsale is by multiple inheritance.
 * In this example we are providing following extensions:
 * CappedCrowdsale - sets a max boundary for raised funds
 * RefundableCrowdsale - set a min goal to be reached and returns funds if it's not met
 *
 * After adding multiple features it's good practice to run integration tests
 * to ensure that subcontracts works together as intended.
 */
contract Pibble1stPresale is CappedCrowdsale, TimedCrowdsale, Pausable {

  uint256 public minValue;

/**
 * rate 200,000 PIB per 1 eth  
 *  
 */
  function Pibble1stPresale(uint256 _openingTime, uint256 _closingTime, uint256 _rate, address _wallet, uint256 _cap, MintableToken _token, uint256 _minValue) public
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap)
    TimedCrowdsale(_openingTime, _closingTime)
    {
        require(_minValue >= 0);
        minValue =_minValue;
    }


  /**
   * @dev Allows the "TOKEN owner" to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferTokenOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    MintableToken(token).transferOwnership(newOwner);
  }


  function buyTokens(address _beneficiary) public payable whenNotPaused {

    require(msg.value >= minValue);
    super.buyTokens(_beneficiary);
    
  }

  function _forwardFunds() internal whenNotPaused {
    
    super._forwardFunds();
    
  }

  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal whenNotPaused {

//    do nothing at thistime.
//    super._deliverTokens(_beneficiary, _tokenAmount) 

  }

  function saleEnded() public view returns (bool) {
    return (weiRaised >= cap || now > closingTime);
  }
 
  function saleStatus() public view returns (uint, uint) {
    return (cap, weiRaised);
  } 
  
}
