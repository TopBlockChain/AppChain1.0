/*ԭ��1������ѡ�������ʲ��Ĵ��ң��ڽ������ܺ�Լ�ǼǴ����������۸񣬹ҵ������ܺ�Լ����save���뺯�����ʲ�ת�����ܺ�Լ�ʻ��ϣ�2����Ҳ�ѯ��������ֱ�Ӷ�������������������ȷ���ļ۸񣬶��������������ܺ�Լ���ͽ��ף����ܺ�Լ�յ��󣬽���Ӧ�����ʲ�ת������ʻ������ʽ��͵������ʻ������������������������ݽ��м����ɾ����3��������Ҫ����������ֱ�ӽ����׺ż��������������ܺ�Լ�����ܺ�Լ��֤��ֱ�ӽ������ʲ�����Ȩת�������ʻ����������������������������*/
pragma solidity ^0.4.18;

interface TokenERC20{
      function transfer(address _to,uint256 _value) public;
      function save(address _to,uint256 _value) public;
} 

contract DeExChange{
    //ExChange things' Information. �����������Ʒ���ݽṹ
    struct ExThingInfo {
          address owner; //the owner's account. �������ʺ�
          TokenERC20 Token;  //the wishing to exchange thing's  token address  ��������Ʒ���Һ�Լ��ַ
          uint256 amount; //the amount of withing to exchange thiing ��������Ʒ����
          uint256 price;  //the price of the things per unit ��Ʒ����
          string AttachInfo; //additional information ��ע�򸽼���Ϣ��
        }
  uint public SalesNum;    //�ҵ�����
  address public Manager; //�������Ա  
  mapping(uint=>ExThingInfo)  public Sales; //����ҵ�����
  TokenERC20  ExChToken;   //���ö���Ϊ���Һ�Լ
 
//���캯�����������Ա
function DeExChange(
         ) public {
        manager=msg.sender;    
}

/* Saler send the sale information and transfer the owner power to contract ���ҹҵ������ʲ�����������Ȩת�Ƹ����ܺ�Լ*/
  function Sale(address ThisToken,uint256 Amount,uint256 Price,string Attachstr)  public returns (bool success){
        // ���Լת������Ȩ�����������еǼǡ�
             ExChToken=TokenERC20(ThisToken);
             ExChToken.save(this,Amount);  //���Լת�ƴ�������������Ȩ
             Sales[SalesNum]=ExThingInfo(msg.sender,ExChToken,Amount,Price, Attachstr);
              SalesNum+=1;
             return true;
     }
/* Buyer send money to the contract and get the Token. ��ҷ����ʽ�����ܺ�Լ���������Ӧ�����ʲ�����*/
  function Buy(uint SalesIndex,uint256 Amount) payable public {
        // ���Լ�����ʽ𣬲���ô�������Ȩ�� 
           require(Amount<=Sales[SalesIndex].amount);    //���������Ƿ�С�ڻ������������
           uint256 BalanceChange=msg.value-Sales[SalesIndex].price*Amount;  //��������
           require( BalanceChange>=0);   //����Ӧ���ڻ���0
           ExChToken=Sales[SalesIndex].Token;  //������Һ�ԼΪ��ǰ���۴��ҡ�
           ExChToken.transfer(msg.sender,Amount);  //�����ת�ƴ�������������Ȩ
           Sales[SalesIndex].owner.transfer(Sales[SalesIndex].price*Amount*99/100);  //�����ҷ������յ������99%
           manager.transfer(Sales[SalesIndex].price*Amount*1/100);  //�����������ʺ�֧��1%���׷�
           Sales[SalesIndex].amount-=Amount;   //�������м�ȥ��������
           if (Sales[SalesIndex].amount==0){                     //�����������Ϊ0������������������ɾ��
                 delete Sales[SalesIndex];
                 SalesNum-=1;
            } 
           if (BalanceChange>0) {                   //�����ʣ�࣬��������㡣
                msg.sender.transfer(BalanceChange);    
           }
      }
function Withdraw(uint SalesIndex) public {
        // ָ�������ţ������ҳ��ء� 
           require(Sales[SalesIndex].owner==msg.sender);   //ֻ�����������߲��ܳ�����
           ExChToken=Sales[SalesIndex].Token;
           ExChToken.transfer(msg.sender,Sales[SalesIndex].amount);  //����Լ�еĴ�����Ʒ���������ߡ�
           delete Sales[SalesIndex]; //������������ɾ��������.
           SalesNum-=1;
      } 
}
