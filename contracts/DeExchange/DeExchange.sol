/*原理：1、卖家选定数字资产的代币，向交易智能合约发送待售数量、价格；待售数量直接执行代币的转帐操作将代币转到智能合约帐户上，获得交易号后，直接将交易号及待售币的合约帐号、待售数量、价格发送给平台管理帐号软件，平台管理帐号软件验证该转帐交易真实性，确认后，把用户、待售资产名、待售数量、价格发送到智能合约公布。2、买家查询到卖单后，直接对卖单操作，按照卖单确定的价格，定义数量，向智能合约发送交易，智能合约收到后，将相应数量资产转到买家帐户，将资金发送到卖家帐户，根据所售数量对卖单数据进行减额或删除。3、卖家若要撤回卖单，直接将交易号及代币名发给智能合约，智能合约验证后，直接将卖单资产所有权转回卖家帐户，并在卖单数组中清除该卖单。*/
pragma solidity ^0.4.18;
//移动用户挖矿合约
//interface MyToken{
 //   function transfer(address _to, uint256 _value) public ;
    //function bananceof(address _to)public;
//}
contract DeExChange{
    //Define the Manager  定义合约管理员
     address public Manager;
    //Only manager can modify. 定义修饰函数，仅合约管理员能修改 
     modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }
//ExChange things' Information. 定义待交换物品数据结构
    struct ExThingInfo {
          address owner; //the owner's account. 所有者帐号
          //MyToken Token;  //the wishing to exchange thing's  token address  待交易物品代币合约地址
          uint256 amount; //the amount of withing to exchange thiing 待交换物品数量
          uint256 price;  //the price of the things per unit 物品单价
          string AttachInfo; //additional information 备注或附加信息。
        }
  uint public SalesNum;    //挂单数量
  uint256 public LastBalance;  //上次余额数量
  //ExThingInfo exthing;
  mapping(uint=>ExThingInfo)  public Sales; //定义挂单数组
  //ExThingInfo Mysale; 
  MyToken  ExChToken;   //设置对象为代币合约
  //Constuct function，initially define the creator as the manager. 构造函数：定义管理员为合约创建者；
   function DeExChange() public {
            Manager=msg.sender;
             //ExChToken=ThisToken;
             //Amount=ExChToken.balanceOf(msg.sender);
            // Sales[0]=ExThingInfo(msg.sender,Amount,Price, Attachstr);     //设置初始挂单量为0。
            // LastBalance=this.balance;//初始设置上次余额数量为合约余额。
          // ExChToken=exchtoken;  
    }
  //Management power transfer. 合约管理权转移，仅管理员能操作。
  function transferManagement(address newManager) onlyManager public {
               Manager=newManager;
       }
//Define the contract can receive mining reward foundation. 本合约所收到的转入款数据累加。
   function () payable public {
   }
       
/* Saler send the sale information and transfer the owner power to contract 卖家挂单待售资产，并将所有权转移给智能合约*/
  function SalesThing(uint256 Amount,uint256  Price,string Attachstr)  public returns (bool success){
        // 向合约转移所有权，并在数组中登记。
         //ExChToken=ThisToken;
         //if (ExChToken.balanceOf(this) >= Amount){ //require(ExChToken.balanceOf(msg.sender) >= Amount);
          //     ExChToken.transfer(this,msg.sender,Amount);  //向合约转移待交换代币所有权
              Sales[SalesNum]=ExThingInfo(msg.sender,Amount,Price, Attachstr);
              //Sales.push(exthing);   //在数组中挂单
               SalesNum+=1;
              LastBalance=this.balance;   //
              return true;
        // }
    }
/* Saler send the sale information and transfer the owner power to contract 卖家挂单待售资产，并将所有权转移给智能合约*/
  function BuyThing(uint SalesIndex,MyToken ThingToken,uint256 Amount) payable public {
        // 向合约转移所有权，并在数组中登记。 
           require(Amount<=Sales[SalesIndex].amount);  
           uint256 BalanceChange=msg.value-Sales[SalesIndex].price*Amount;
           require( BalanceChange>=0);
           ExChToken=ThingToken;
           ExChToken.transfer(msg.sender,Amount);  //向买家转移待交换代币所有权
           Sales[SalesIndex].owner.transfer(Sales[SalesIndex].price*Amount);  //向卖家发送已收到货款
           Sales[SalesIndex].amount-=Amount;   //从卖单中减去已售数量
           if (Sales[SalesIndex].amount==0){                     //如果卖单数量为0，将该卖单从数组中删除
                 delete Sales[SalesIndex];
                 SalesNum-=1;
            } 
           if (BalanceChange>0) {                   //如果有剩余，向买家找零。
                msg.sender.transfer(BalanceChange);    
           }
         LastBalance=this.balance; //重置初值


      }
function Withdraw(uint SalesIndex,MyToken Thing) public {
        // 向合约转移所有权，并在数组中登记。 
           require(Sales[SalesIndex].owner==msg.sender);   //只有卖单所有者才能撤单。
           ExChToken=Thing;
           ExChToken.transfer(msg.sender,Sales[SalesIndex].amount);  //将合约中的待售物品还回所有者。
           delete Sales[SalesIndex]; //从卖单数组中删除该卖单.
           SalesNum-=1;
      } 
}

pragma solidity ^0.4.18;

contract MyToken {
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    event Transfer(address _from,address _to, uint256 value);
    /* Initializes contract with initial supply tokens to the creator of the contract */
    function  MyToken(
        uint256 initialSupply
        ) public{
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
    }

    /* Send coins */
    function transfer(address _to,uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);           // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
        balanceOf[msg.sender]-= _value;                    // Subtract from the sender
        balanceOf[_to]+= _value;                           // Add the same to the recipient
       Transfer(msg.sender,_to,_value);
    }
 /* SaveCoin */
//    function save(address _to, uint256 _value) public {
 //       require(balanceOf[msg.sender] >= _value);           // Check if the sender has enough
  //      require(balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
  //      balanceOf[msg.sender]-= _value;                    // Subtract from the sender
   //     balanceOf[_to]+= _value;                           // Add the same to the recipient
  //  }
/* WithdrawCoin */
  //  function withdraw(address _from, uint256 _value) public {
   //     require(balanceOf[_from] >= _value);           // Check if the sender has enough
   //     require(balanceOf[msg.sender] + _value >= balanceOf[_from]); // Check for overflows
    //    balanceOf[_from]-= _value;                    // Subtract from the sender
    //    balanceOf[msg.sender]+= _value;                           // Add the same to the recipient
  //  }

}

