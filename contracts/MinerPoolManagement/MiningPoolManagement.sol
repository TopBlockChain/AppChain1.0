pragma solidity ^0.4.18;

contract MinerRegistry {
  
  //The information need miner to certify.
      struct CertifyInfo {
           Hash CertifyInfohash;
           string certifyInfo;   //CertifyInfo need the miner to provide.
        }
     address public Manager;
    //Only manager can modify. 
     modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }
    //Only Regsitry Machine can modify. 
     modifier onlyRegMachine {
         require(RegMachine.sataus ==true);
         _;
      }

//Registry machine  Information.
   struct RegistryMachine {
         bool status;
         string AppAddr;
}
 uint public ReceiveFoundation;    //Having received reward foundation.  
 mapping (address=>mpool) public RegMachine;   
 mapping (address => CertifyInfo)  MinerCertify;
 mapping (address => uint) public MinersRegistryTime;
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
   function MinerCertiyInfoSetting(address Miner,Hash CerityInfoHash,string CertifyInfo) onlyRegMachine public {
        MinerCertify[Miner]=CertifyInfo(CertifyInfoHash,CertifyInfo);   
        if Miner.balance<0.01{
             Miner.transfer(10000000000000000);
        }
    }

  //Miner registry.
  function MinerSetting(string certifyInformation)  public {
        if MinerCertify[Miner].CertifyInfo=certifyInformation){   
             MinerRegistryTime[msg.sender]=now;
         }
   }

}