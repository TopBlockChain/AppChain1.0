pragma solidity ^0.4.18;
//�ƶ��û��ڿ��Լ
contract MobileMine {
    //Define the Manager  �����Լ����Ա
     address public Manager;
    //Only manager can modify. �������κ���������Լ����Ա���޸� 
     modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }
//Active users' information. �����Ծ�û����ݽṹ
    struct ActiveInfo {
          uint LastTime;     //Last calculate time. �ϴλ�Ծ�û�ͳ��ʱ��
          uint Users; //the number of already ActiveUsers since lasttime calculate. ��Ծ�û�����
        }
  /*Miner and active users defining  �����Ծ�û���������ActiveUsers*/
  ActiveInfo public ActiveUsers;
  mapping(address=>uint) Miners;   //�����ƶ���Mapping���飬���ڴ洢����Ľ���֧��ʱ��
  uint public RecFoundation;    //���屾��Լ���յ���ֱ��ת����ܶ�
  uint MineAmount;    //������ʱ���������ڼ���󹤵Ľ���֧����
  uint MinerRefTime;    //���ñ���:����������ע��Լ�е�����ʱ�䣬��Ҫ����������ע��Լ��ȡ
  MinerRefuel MinerRef;   //���ö���Ϊ������ע��Լ
    //Only not paid miner  can modify. �������κ�������δ֧���������ƶ����ܹ�����
     modifier onlyNoPaidMiner {
        MinerRefTime=MinerRef.MinerRefuelTime (msg.sender);   //����ע���Լ��������ȡ���ں�Լ�е�ע��ʱ��
       require (MinerRefTime+3600>now&&Miners[msg.sender]+86400<now);   //Ҫ��������������������ע��Լ������ʱ����δ����1Сʱ���ڱ��������ȡ�����ѳ���һ�졣
         _;
      }
  //Constuct function��initially define the creator as the manager. ���캯�����������ԱΪ��Լ�����ߣ���ʼ���û�Ծ�����������ֵ������ע���Լ�ĺ�Լ��ַ��
   function MobileMine(MinerRefuel MinerRegAdd) public {
            Manager=msg.sender;
           ActiveUsers=ActiveInfo(now,0);     //�����Ծ�󹤱�������Ծ�û�ͳ��ʱ��Ϊ��ǰ�����ʱ�䣬��Ծ�û���Ϊ1��
           MinerRef=MinerRegAdd;     //�Ǽ�ע���Լ�ĺ�Լ��ַ��������ע���Լ������ʹ��
    }
  //Management power transfer. ��Լ����Ȩת�ƣ�������Ա�ܲ�����
  function transferManagement(address newManager) onlyManager public {
               Manager=newManager;
       }
//Define the contract can receive mining reward foundation. ����Լ���յ���ת��������ۼӡ�
   function () payable public {
         RecFoundation+=msg.value; 
   }
       
/* Miner mine function, modify miner's status �ƶ����ڿ������������������ƶ����ܲ���*/
  function Mine() onlyNoPaidMiner public returns (bool success){
        //Pay the reward and change the miner's status. ���֧�����������޸Ŀ󹤵�Mapping�洢�ڿ�״̬��
         MineAmount=this.balance/(ActiveUsers.Users+1)*(now-ActiveUsers.LastTime)/86400;   //����󹤵Ľ�������ǰ��Լ�ʻ������Ե�ǰ�ѵǼǵĻ�Ծ�û��������Ե�ǰʱ����һ��ʱ���еı�����
         msg.sender.transfer(MineAmount);   //֧������
         Miners[msg.sender]=now;    //�����ƶ��󹤵�֧��״̬Ϊ��ǰʱ��
  //Check if the calculating time of active user is lasting one day or not. ����Ծ�û���ͳ��ʱ���Ƿ��ѵ�һ��
        if(ActiveUsers.LastTime+86400<now){     //���ͳ��ʱ���ѳ���һ��
                  ActiveUsers.LastTime=now;    //���û�Ծ�û�ͳ��ʱ��Ϊ��ǰʱ��
                  ActiveUsers.Users=1;    //���û�Ծ�û���Ϊ1
                  Manager.transfer(this.balance/100);     //pay the manager the minerpool reward. ���ع���Ա�ʺ�֧����ǰ��Լ����1%����ֵ�ɵ�����
          }else{    //���ͳ��ʱ��δ����һ��
                 ActiveUsers.Users+=1;   //�ۼӻ�Ծ�û�����
           }
        return true;
  }
} 

pragma solidity ^0.4.18;
//�ƶ���������ע��Լ
contract MinerRefuel {
  //�����Լ����Ա
    address public Manager;
    //Only manager can modify. 
   //�������κ���������Լ����Ա���޸�
     modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }

//EnergyStation Manager Information.
//��������վ����Ա�����ݽṹ
   struct EnergyStation {
         bool status;      //����վ������Ա��״̬��ʹ�ܻ�ȥ������״̬��ʹ��TRUE��ȥ��FALSE
         string AppAddr;   //����Ѿ������Ա���ĸ�����Ϣ������Ϊ����/IP��ַ�ȡ�
}
 
 uint public ReceiveFoundation;    //Having received reward foundation.  ����Լ�յ���ת���ܶ�
 mapping (address=>EnergyStation) public EnergyStations;     //��������վMapping����
 mapping (address => uint) public MinerRefuelTime;   //�����ƶ�������ʱ��Mapping ����
   //Only EnergyStation manager can modify. �������κ�����������վ������Ա���ʺ����޸ġ�
     modifier onlyEnergyStation {
         require(EnergyStations[msg.sender].status ==true);    //����վ������Ա���ʺŵ�״̬ΪTRUEʱ
         _;
      }
    //Construction function, initially define the creator as the manager.  ���캯������ʼ���ú�Լ������Ϊ����Ա
    function MinerRefuel() public {
            Manager=msg.sender;
    }
//Define the contract can receive mining reward foundation. ���屾��Լ�ɽ���ת���
   function () payable public {
         ReceiveFoundation+=msg.value;    //ת������ݲ����ۼӣ�����ReceiveFoundation�������� 
   }
//Management power thansfer. ����Ȩת�ƣ������ɵ�ǰ��Լ����Ա����
  function transferManagement(address newManager) onlyManager public {
               Manager=newManager;
       }
   //EnergyStation manager setting, only manager can modify.  ����վ������Ա�����ã������ɵ�ǰ����Ա������
   function EnergyStationSet(address energystation,bool status,string AppAddr) onlyManager public {
        EnergyStations[energystation]=EnergyStation(status,AppAddr);    //������վ������Ա�����ݽṹ��ֵ��״̬��IP��������ַ
    }
   //Miner refuel time setting , only Energy Station manager  can modify.  //�ƶ���������ע������������վ������Ա��������
   function Refuel(address Miner) onlyEnergyStation public {
        MinerRefuelTime[Miner]=now;      //���ÿ�����ʱ��Ϊ��ǰʱ��
        if (Miner.balance<10000000000000000){      //������ƶ��󹤵��ʻ����С��0.01APC
             Miner.transfer(10000000000000000);       //���ƶ����ʻ�ת��0.01APC
        }
    }
}