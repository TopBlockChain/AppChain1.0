/*ԭ��1������ѡ�������ʲ��Ĵ��ң��������ܺ�Լ���ʹ����������۸񣻴�������ֱ��ִ�д��ҵ�ת�ʲ���������ת�����ܺ�Լ�ʻ��ϣ���ý��׺ź�ֱ�ӽ����׺ż����۱ҵĺ�Լ�ʺš������������۸��͸�ƽ̨�����ʺ������ƽ̨�����ʺ������֤��ת�ʽ�����ʵ�ԣ�ȷ�Ϻ󣬰��û��������ʲ����������������۸��͵����ܺ�Լ������2����Ҳ�ѯ��������ֱ�Ӷ�������������������ȷ���ļ۸񣬶��������������ܺ�Լ���ͽ��ף����ܺ�Լ�յ��󣬽���Ӧ�����ʲ�ת������ʻ������ʽ��͵������ʻ������������������������ݽ��м����ɾ����3��������Ҫ����������ֱ�ӽ����׺ż��������������ܺ�Լ�����ܺ�Լ��֤��ֱ�ӽ������ʲ�����Ȩת�������ʻ����������������������������*/
pragma solidity ^0.4.18;
//�ƶ��û��ڿ��Լ
//interface MyToken{
 //   function transfer(address _to, uint256 _value) public ;
    //function bananceof(address _to)public;
//}
contract DeExChange{
    //Define the Manager  �����Լ����Ա
     address public Manager;
    //Only manager can modify. �������κ���������Լ����Ա���޸� 
     modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }
//ExChange things' Information. �����������Ʒ���ݽṹ
    struct ExThingInfo {
          address owner; //the owner's account. �������ʺ�
          //MyToken Token;  //the wishing to exchange thing's  token address  ��������Ʒ���Һ�Լ��ַ
          uint256 amount; //the amount of withing to exchange thiing ��������Ʒ����
          uint256 price;  //the price of the things per unit ��Ʒ����
          string AttachInfo; //additional information ��ע�򸽼���Ϣ��
        }
  uint public SalesNum;    //�ҵ�����
  uint256 public LastBalance;  //�ϴ��������
  //ExThingInfo exthing;
  mapping(uint=>ExThingInfo)  public Sales; //����ҵ�����
  //ExThingInfo Mysale; 
  MyToken  ExChToken;   //���ö���Ϊ���Һ�Լ
  //Constuct function��initially define the creator as the manager. ���캯�����������ԱΪ��Լ�����ߣ�
   function DeExChange() public {
            Manager=msg.sender;
             //ExChToken=ThisToken;
             //Amount=ExChToken.balanceOf(msg.sender);
            // Sales[0]=ExThingInfo(msg.sender,Amount,Price, Attachstr);     //���ó�ʼ�ҵ���Ϊ0��
            // LastBalance=this.balance;//��ʼ�����ϴ��������Ϊ��Լ��
          // ExChToken=exchtoken;  
    }
  //Management power transfer. ��Լ����Ȩת�ƣ�������Ա�ܲ�����
  function transferManagement(address newManager) onlyManager public {
               Manager=newManager;
       }
//Define the contract can receive mining reward foundation. ����Լ���յ���ת��������ۼӡ�
   function () payable public {
   }
       
/* Saler send the sale information and transfer the owner power to contract ���ҹҵ������ʲ�����������Ȩת�Ƹ����ܺ�Լ*/
  function SalesThing(uint256 Amount,uint256  Price,string Attachstr)  public returns (bool success){
        // ���Լת������Ȩ�����������еǼǡ�
         //ExChToken=ThisToken;
         //if (ExChToken.balanceOf(this) >= Amount){ //require(ExChToken.balanceOf(msg.sender) >= Amount);
          //     ExChToken.transfer(this,msg.sender,Amount);  //���Լת�ƴ�������������Ȩ
              Sales[SalesNum]=ExThingInfo(msg.sender,Amount,Price, Attachstr);
              //Sales.push(exthing);   //�������йҵ�
               SalesNum+=1;
              LastBalance=this.balance;   //
              return true;
        // }
    }
/* Saler send the sale information and transfer the owner power to contract ���ҹҵ������ʲ�����������Ȩת�Ƹ����ܺ�Լ*/
  function BuyThing(uint SalesIndex,MyToken ThingToken,uint256 Amount) payable public {
        // ���Լת������Ȩ�����������еǼǡ� 
           require(Amount<=Sales[SalesIndex].amount);  
           uint256 BalanceChange=msg.value-Sales[SalesIndex].price*Amount;
           require( BalanceChange>=0);
           ExChToken=ThingToken;
           ExChToken.transfer(msg.sender,Amount);  //�����ת�ƴ�������������Ȩ
           Sales[SalesIndex].owner.transfer(Sales[SalesIndex].price*Amount);  //�����ҷ������յ�����
           Sales[SalesIndex].amount-=Amount;   //�������м�ȥ��������
           if (Sales[SalesIndex].amount==0){                     //�����������Ϊ0������������������ɾ��
                 delete Sales[SalesIndex];
                 SalesNum-=1;
            } 
           if (BalanceChange>0) {                   //�����ʣ�࣬��������㡣
                msg.sender.transfer(BalanceChange);    
           }
         LastBalance=this.balance; //���ó�ֵ


      }
function Withdraw(uint SalesIndex,MyToken Thing) public {
        // ���Լת������Ȩ�����������еǼǡ� 
           require(Sales[SalesIndex].owner==msg.sender);   //ֻ�����������߲��ܳ�����
           ExChToken=Thing;
           ExChToken.transfer(msg.sender,Sales[SalesIndex].amount);  //����Լ�еĴ�����Ʒ���������ߡ�
           delete Sales[SalesIndex]; //������������ɾ��������.
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

