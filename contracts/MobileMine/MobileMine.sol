pragma solidity ^0.4.18;

interface MinerRefuel{
      function MinerRefuelTime(address Miner) public;
} 
//移动用户挖矿合约
contract MobileMine {
    //Define the Manager  定义合约管理员
     address public Manager;
     //定义转帐事件
     event Transfer(address indexed from, address indexed to, uint256 value);
    //Only manager can modify. 定义修饰函数，仅合约管理员能修改 
     modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }
//Active users' information. 定义活跃用户数据结构
    struct ActiveInfo {
          uint LastTime;     //Last calculate time. 上次活跃用户统计时间
          uint Users; //the number of already ActiveUsers since lasttime calculate. 活跃用户数量
        }
  /*Miner and active users defining  定义活跃用户公共变量ActiveUsers*/
  ActiveInfo public ActiveUsers;
  mapping(address=>uint) Miners;   //定义移动矿工Mapping数组，用于存储最近的奖励支付时间
  uint public RecFoundation;    //定义本合约所收到的直接转入款总额
  uint MineAmount;    //定义临时变量，用于计算矿工的奖励支付金额。
  uint MinerRefTime;    //设置变量:矿工在能量加注合约中的能量时间，需要访问能量加注合约获取
  MinerRefuel MinerRef;   //设置对象为能量加注合约
    //Only not paid miner  can modify. 定义修饰函数仅尚未支付奖励的移动矿工能够操作
     modifier onlyNoPaidMiner {
        MinerRefTime=MinerRef.MinerRefuelTime (msg.sender);   //访问注册合约函数，获取矿工在合约中的注册时间
       require (MinerRefTime+3600>now&&Miners[msg.sender]+86400<now);   //要求满足条件：在能量加注合约中能量时间尚未超过1小时，在本矿池中领取奖金已超过一天。
         _;
      }
  //Constuct function，initially define the creator as the manager. 构造函数：定义管理员为合约创建者；初始设置活跃矿工数组变量的值；设置注册合约的合约地址。
   function MobileMine(MinerRefuel MinerRegAdd) public {
            Manager=msg.sender;
           ActiveUsers=ActiveInfo(now,0);     //定义活跃矿工变量：活跃用户统计时间为当前区块的时间，活跃用户数为1。
           MinerRef=MinerRegAdd;     //登记注册合约的合约地址，供访问注册合约数据所使用
    }
  //Management power transfer. 合约管理权转移，仅管理员能操作。
  function transferManagement(address newManager) onlyManager public {
               Manager=newManager;
       }
//Define the contract can receive mining reward foundation. 本合约所收到的转入款数据累加。
   function () payable public {
         RecFoundation+=msg.value; 
   }
       
/* Miner mine function, modify miner's status 移动矿工挖矿函数，仅符合条件的移动矿工能操作*/
  function Mine() onlyNoPaidMiner public returns (bool success){
        //Pay the reward and change the miner's status. 向矿工支付奖励，并修改矿工的Mapping存储挖矿状态。
         MineAmount=this.balance/(ActiveUsers.Users+1)*(now-ActiveUsers.LastTime)/86400;   //计算矿工的奖励金额：当前合约帐户余额除以当前已登记的活跃用户数，乘以当前时间在一天时间中的比例。
         msg.sender.transfer(MineAmount);   //支付奖励
         Transfer(this, msg.sender, MineAmount); //转帐事件报告。
         Miners[msg.sender]=now;    //更新移动矿工的支付状态为当前时间
  //Check if the calculating time of active user is lasting one day or not. 检查活跃用户数统计时间是否已到一天
        if(ActiveUsers.LastTime+86400<now){     //如果统计时间已超过一天
                  ActiveUsers.LastTime=now;    //设置活跃用户统计时间为当前时间
                  ActiveUsers.Users=1;    //设置活跃用户数为1
                  Manager.transfer(this.balance/100);     //pay the manager the minerpool reward. 向矿池管理员帐号支付当前合约余额的1%（此值可调整）
                  Transfer(this, Manager, this.balance/100); //转帐事件报告。
          }else{    //如果统计时间未超过一天
                 ActiveUsers.Users+=1;   //累加活跃用户数。
           }
        return true;
  }
} 

