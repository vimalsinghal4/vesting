// SPDX-License-Identifier: MIT
pragma solidity^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract vesting{
    address public admin;
    address[] public adr;
    mapping(address=>uint256) public totalAmount;
    mapping(address=>uint256) public amountWithdrawn;
    mapping(address=>bool)benefactors;
    uint256 public start=0;
    uint256 public startTime;
    address public token;
    constructor(address[] memory _adr,address _token){
        admin=msg.sender;
        adr=_adr;
        token=_token;
    }
    function startVesting(uint256 amount) public onlyadmin{
    require(start==0,"Process already initialized");
    IERC20 paymentToken = IERC20(token);
    require(paymentToken.allowance(msg.sender, address(this)) >= amount,"Insuficient Allowance");
    require(paymentToken.transferFrom(msg.sender,address(this),amount),"transfer Failed");
    uint256 x=adr.length;
    uint256 balance=paymentToken.balanceOf(address(this));
    require(balance>=x);
    start=1;
    uint i;
    uint256 y=balance/x;
    for(i=0;i<x;i++){
         benefactors[adr[i]]=true;
         totalAmount[adr[i]]=y;
    }
    startTime=block.timestamp;
    }
    function withdrawableAmount(address _address) public view returns(uint256 amount){
         uint256 time=block.timestamp;
         uint256 x=(375)*(24)*(60);
         uint256 y=(time-startTime)/60;
         amount=(totalAmount[_address])*(y/x)-amountWithdrawn[_address];
    }
    function withdraw(uint256 _amount) public onlybenefactors{
        uint256 amount=withdrawableAmount(msg.sender);
        require(amount>=_amount);
        require(IERC20(token).transfer(msg.sender,_amount));
        amountWithdrawn[msg.sender]+=_amount;
    }
    modifier onlyadmin{
        require(msg.sender==admin,"Only admin can call this function");
        _;
          }
    modifier onlybenefactors{
        require(benefactors[msg.sender]==true,"Only admin can call this function");
        _;
          }

}
