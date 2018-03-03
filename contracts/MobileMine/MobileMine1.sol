pragma solidity ^0.4.18;

contract MobileMine {
    //Define the Manager
     address public Manager;
    //Only manager can modify. 
     modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }
//Active users' information.
    struct ActiveInfo {
          uint LastTime;     //Last calculate time.
          uint Users; //the number of already ActiveUsers since lasttime calculate.
        }
  /*Miner and active users defining  */
  ActiveInfo public ActiveUsers;
  mapping(address=>uint) Miners;
  uint public RecFoundation;
  uint MineAmount;
  uint MinerRegTime;
  MinerRegistry MinerReg;
  //Constuct function£¬initially define the creator as the manager.
   function MobileMine(MinerRegistry MinerRegAdd) public {
            Manager=msg.sender;
           ActiveUsers=ActiveInfo(now,1);
           MinerReg=MinerRegAdd;
    }
  //Management power transfer.
  function transferManagement(address newManager) onlyManager public {
               Manager=newManager;
       }
//Define the contract can receive mining reward foundation.
   function () payable public {
         RecFoundation+=msg.value; 
   }

  //Set Address of MinerRegisty.
 // function MinerRegAddSet(MinerRegistry MinerRegAdd) onlyManager public {
    //           MinerReg=MinerRegAdd;
  //     }
       
/* Miner mine function, modify miner's status*/
  function Mine()  public returns (bool success){
        //If not registry or has been payed in one day, return false.
        //address MinerReg = 0x8C00B660792b235d4382368299E77C8c04ED4754;
       //MinerRegistry MinerReg;
       
       MinerRegTime=MinerReg.MinerRegistryTime (msg.sender);
       if (MinerRegTime+86400<now||Miners[msg.sender]+86400>now){
             return false;
        }  
        //Pay the reward and change the miner's status.
         MineAmount=this.balance/(ActiveUsers.Users+1)*(now-ActiveUsers.LastTime)/86400;
         msg.sender.transfer(MineAmount);
         Miners[msg.sender]=now;
  //Check if the calculating time of active user is lasting one day or not. 
        if(ActiveUsers.LastTime+86400<now){
                  ActiveUsers.LastTime=now;
                  ActiveUsers.Users=1;
                  Manager.transfer(this.balance/100);     //pay the manager the minerpool reward.
          }else{ 
                 ActiveUsers.Users+=1;   
           }
        return true;
  }
} 

contract MinerRegistry {
  
    address public Manager;
    //Only manager can modify. 
     modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }

//Registry machine  Information.
   struct RegistryMachine {
         bool status;
         string AppAddr;
}
 uint public ReceiveFoundation;    //Having received reward foundation.  
 mapping (address=>RegistryMachine) public RegMachine;   
 mapping (address =>uint) MinerCertify;
 mapping (address => uint) public MinerRegistryTime;
   //Only Regsitry Machine can modify. 
     modifier onlyRegMachine {
         require(RegMachine[msg.sender].status ==true);
         _;
      }

 //Construction function, initially define the creator as the manager.
    function MinerRegistry() public {
            Manager=msg.sender;
     }
//Define the contract can receive mining reward foundation.
   function () payable public {
         ReceiveFoundation+=msg.value; 
   }
//Management power thansfer.
  function transferManagement(address newManager) onlyManager public {
               Manager=newManager;
       }
   //Registry Machine set, only manager can modify. 
   function RegstryMachineSetting(address RegMac,bool status,string AppAddr) onlyManager public {
        RegMachine[RegMac]=RegistryMachine(status,AppAddr);    
    }
   //Miner Certify Information setting , only registry machine  can modify. 
   function MinerCertiyInfoSetting(address Miner,uint CertInfo) onlyRegMachine public {
        MinerCertify[Miner]=CertInfo;   
        if (Miner.balance<10000000000000000){
             Miner.transfer(10000000000000000);
        }
    }

  //Miner registry.
  function MinerSetting(uint  certifyInformation)  public {
         if (MinerCertify[msg.sender]==certifyInformation){   
             MinerRegistryTime[msg.sender]=now;
         }
   }

}