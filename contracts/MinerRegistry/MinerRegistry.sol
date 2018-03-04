pragma solidity ^0.4.18;

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
   //Only Reggistry Miner  can modify. 
     modifier onlyMiner {
         require(MinerCertify[msg.sender]!=0);
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
   function RegMachineSet(address RegMac,bool status,string AppAddr) onlyManager public {
        RegMachine[RegMac]=RegistryMachine(status,AppAddr);    
    }
   //Miner Certify Information setting , only registry machine  can modify. 
   function CertiyInfoSet(address Miner,uint CertInfo) onlyRegMachine public {
        MinerCertify[Miner]=CertInfo;   
        if (Miner.balance<10000000000000000){
             Miner.transfer(10000000000000000);
        }
    }

  //Miner registry.
  function MinerReg(uint  certifyInformation) onlyMiner public {
         if (MinerCertify[msg.sender]==certifyInformation){   
             MinerRegistryTime[msg.sender]=now;
             MinerCertify[msg.sender]=0;
         }
   }
}