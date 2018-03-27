pragma solidity ^0.4.18;

interface MinerRefuel{
      function MinerRefuelTime(address Miner) public;
} 
//�ƶ��û��ڿ��Լ
contract MobileMine {
    //Define the Manager  �����Լ����Ա
     address public Manager;
     //����ת���¼�
     event Transfer(address indexed from, address indexed to, uint256 value);
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
         Transfer(this, msg.sender, MineAmount); //ת���¼����档
         Miners[msg.sender]=now;    //�����ƶ��󹤵�֧��״̬Ϊ��ǰʱ��
  //Check if the calculating time of active user is lasting one day or not. ����Ծ�û���ͳ��ʱ���Ƿ��ѵ�һ��
        if(ActiveUsers.LastTime+86400<now){     //���ͳ��ʱ���ѳ���һ��
                  ActiveUsers.LastTime=now;    //���û�Ծ�û�ͳ��ʱ��Ϊ��ǰʱ��
                  ActiveUsers.Users=1;    //���û�Ծ�û���Ϊ1
                  Manager.transfer(this.balance/100);     //pay the manager the minerpool reward. ���ع���Ա�ʺ�֧����ǰ��Լ����1%����ֵ�ɵ�����
                  Transfer(this, Manager, this.balance/100); //ת���¼����档
          }else{    //���ͳ��ʱ��δ����һ��
                 ActiveUsers.Users+=1;   //�ۼӻ�Ծ�û�����
           }
        return true;
  }
} 

