pragma solidity ^0.4.18;
//移动用户挖矿合约
contract MobileMine {
    //Define the Manager  定义合约管理员
     address public Manager;
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
         Miners[msg.sender]=now;    //更新移动矿工的支付状态为当前时间
  //Check if the calculating time of active user is lasting one day or not. 检查活跃用户数统计时间是否已到一天
        if(ActiveUsers.LastTime+86400<now){     //如果统计时间已超过一天
                  ActiveUsers.LastTime=now;    //设置活跃用户统计时间为当前时间
                  ActiveUsers.Users=1;    //设置活跃用户数为1
                  Manager.transfer(this.balance/100);     //pay the manager the minerpool reward. 向矿池管理员帐号支付当前合约余额的1%（此值可调整）
          }else{    //如果统计时间未超过一天
                 ActiveUsers.Users+=1;   //累加活跃用户数。
           }
        return true;
  }
} 

pragma solidity ^0.4.18;
//移动矿工能量加注合约
contract MinerRefuel {
  //定义合约管理员
    address public Manager;
    //Only manager can modify. 
   //定义修饰函数：仅合约管理员能修改
     modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }

//EnergyStation Manager Information.
//定义能量站管理员的数据结构
   struct EnergyStation {
         bool status;      //能量站（管理员）状态：使能或去能两种状态，使能TRUE，去能FALSE
         string AppAddr;   //能量丫（管理员）的附加信息，可设为域名/IP地址等。
}
 
 uint public ReceiveFoundation;    //Having received reward foundation.  本合约收到的转款总额
 mapping (address=>EnergyStation) public EnergyStations;     //定义能量站Mapping数组
 mapping (address => uint) public MinerRefuelTime;   //定义移动矿工能量时间Mapping 数组
   //Only EnergyStation manager can modify. 定义修饰函数：仅能量站（管理员）帐号能修改。
     modifier onlyEnergyStation {
         require(EnergyStations[msg.sender].status ==true);    //能量站（管理员）帐号的状态为TRUE时
         _;
      }
    //Construction function, initially define the creator as the manager.  构造函数，初始设置合约创建者为管理员
    function MinerRefuel() public {
            Manager=msg.sender;
    }
//Define the contract can receive mining reward foundation. 定义本合约可接受转入款
   function () payable public {
         ReceiveFoundation+=msg.value;    //转入款数据采用累加，计入ReceiveFoundation公共变量 
   }
//Management power thansfer. 管理权转移，仅能由当前合约管理员操作
  function transferManagement(address newManager) onlyManager public {
               Manager=newManager;
       }
   //EnergyStation manager setting, only manager can modify.  能量站（管理员）设置，仅能由当前管理员操作。
   function EnergyStationSet(address energystation,bool status,string AppAddr) onlyManager public {
        EnergyStations[energystation]=EnergyStation(status,AppAddr);    //对能量站（管理员）数据结构赋值：状态与IP或域名地址
    }
   //Miner refuel time setting , only Energy Station manager  can modify.  //移动矿工能量加注，仅能由能量站（管理员）操作。
   function Refuel(address Miner) onlyEnergyStation public {
        MinerRefuelTime[Miner]=now;      //设置矿工能量时间为当前时间
        if (Miner.balance<10000000000000000){      //如果该移动矿工的帐户余额小于0.01APC
             Miner.transfer(10000000000000000);       //向移动矿工帐户转款0.01APC
        }
    }
}