pragma solidity ^0.4.23;

contract piiSZG {
    
    //enums za lakšu provjeru tipova sastavnica sveučilišta i osoba
    enum PersonType { Student, Profesor, Staff}
    enum UniversityComponenetType { FER, FFZG, FSB}
  
    //struktura Member/Osoba, sadrži enums tipOsobe i 
    //tipFakulteta te bool set za provjeru postoji li 
    struct Member {
        //string jmbag;
        PersonType personType;
        UniversityComponenetType universityComponenetType;
        bool set;
        //address membersHashedAddress;
        //public mapping(uint => bool) access;
    }
    
    //struktura za zapis kontrole ulaza sadrži bool 
    //jeli dopušten ulaz te hash osobe koja je zatražila pristup
    struct ControlParameter{
        bool grantAccess;
        address membersHashedAddress;
        
        //uint timeRequested;
    }
    /*event ControlAccess(
        bool controlAccess
    );*/
    
    //struktura sastavnica sveučilišta sadrrži enum tipa fakulteta, 
    //radno vrijeme u sekundama te bool set za provjeru postoji li i 
    //zapis kontrole ulaza za tu sastvniu 
    struct UniversityComponenet {
        //string universityKey;
        UniversityComponenetType universityComponenetType;
        uint32 openingTime;
        uint32 closingTime;
        //address universityComponenetsHashedAddress;
        bool set;
        mapping(uint => ControlParameter) access;

    }
    
    //hashirat će se u 20bajtnu adresu? i neće moći iterirati?
    //mapa svih komponenti sveučilišta i svih osoba preko hasha jmbaga/universityKeya
    mapping(address => UniversityComponenet) public universityComponenets;
    mapping(address => Member) public members;
    
    /* Data layer za mapping
    mapping(uint256 => address) public memberSequence;
    uint256 public numberOfMembers = 0;
    address[] listOfAddressesMem;
    mapping(address => bool) registeredMem;

    function registerMember(address _member) public {
        //only unregistered users will be registered
        require(!registeredMem[_member]);
        memberSequence[numberOfMembers++] = _member;
        listOfAddressesMem.push(_member);
        registeredMem[_member] = true;
    }
    
    mapping(uint256 => address) public UCSequence;
    uint256 public numberOfUniversityComponenets = 0;
    address[] listOfAddressesUC;
    mapping(address => bool) registeredUC;

    function registerUC(address _universityComponenet) public {
        //only unregistered users will be registered
        require(!registeredUC[_universityComponenet]);
        UCSequence[numberOfUniversityComponenets++] = _universityComponenet;
        listOfAddressesUC.push(_universityComponenet);
        registeredUC[_universityComponenet] = true;
    }*/
    //getteri za osobu
    function getPersonType(address _hValue) public view returns (uint personType){
        require(members[_hValue].set == true);
        return uint(members[_hValue].personType);
    }
    function getUniversityComponenetTypeMem(address _hValue) public view returns (uint universityComponenetTypeMem){
        require(members[_hValue].set == true);
        return uint(members[_hValue].universityComponenetType);
    }
    function getMemberSet(address _hValue) public view returns (bool memberSet){
        require(members[_hValue].set == true);
        return members[_hValue].set;
    }

    //getteri za sveučilišnu komponentu
    function getUniversityComponenetTypeUC(address _hValue) public view returns (uint universityComponenetTypeUC){
        require(universityComponenets[_hValue].set == true);
        return uint(universityComponenets[_hValue].universityComponenetType);
    }    
    function getOpeningTime(address _hValue) public view returns (uint32 openingTime){
        require(universityComponenets[_hValue].set == true);
        return universityComponenets[_hValue].openingTime;
    }
    function getClosingTime(address _hValue) public view returns (uint32 closingTime){
        require(universityComponenets[_hValue].set == true);
        return universityComponenets[_hValue].closingTime;
    }
    function getUniversityComponenetSet(address _hValue) public view returns (bool universityComponenetSet){
        require(universityComponenets[_hValue].set == true);
        return universityComponenets[_hValue].set;
    }
    function getAccess(address _hValue, uint time) public view returns (bool grantAccess, address membersHashedAddress){
        require(universityComponenets[_hValue].set == true);
        return (universityComponenets[_hValue].access[time].grantAccess, universityComponenets[_hValue].access[time].membersHashedAddress);
        //return extractControlParameterStructToBytes(universityComponenets[_hValue].access[time]);
    }
    

    //pomoćne funckije
    //provjera jesu li dobiveni podatci u ispravnom formatu
    //pure zato što ne vraća ništa iz memorije niti traži po memoriji
    //vraća byteove strukture ControlParameter zato što ne postoji concanate
    function testNum4(string str) internal pure returns (bool){
        bytes memory b = bytes(str);
        if(b.length != 4) return false;
        for(uint i; i<4; i++){
            if(b[i] < 48 || b[i] > 57) return false;

        }
        return true;
    }
    function testNum10(string str) internal pure returns (bool){
        bytes memory b = bytes(str);
        if(b.length != 10) return false;
        for(uint i; i<10; i++){
            if(b[i] < 48 || b[i] > 57) return false;
        }
        return true;
    }    
    function testStr20(string str) internal pure returns (bool){
        bytes memory b = bytes(str);
        if(b.length != 20) return false;
        for(uint i; i<20; i++){
            if(!((b[i] > 48 && b[i] < 57) || (b[i] > 65 && b[i] < 90) || (b[i] > 97 && b[i] < 122))) return false;

        }
        return true;
    }    

    //kreiranje nove osobe na temelju unosa hashedValue jmbaga
    function createMember(address _hValue, PersonType _personType, UniversityComponenetType _uComponenetType) public returns(bool creationSuccessful){
        require(uint(_personType) < 3 && uint(_uComponenetType) < 3);
        require(members[_hValue].set != true);
        //registerMember(_hValue);
        members[_hValue] = Member(_personType,_uComponenetType,true);
        return true;
    }

    //kreiranje nove komponente sveučilišta na temelju unosa hashedValue universityKeya
    function createUniversityComponenet(address _hValue, UniversityComponenetType _uComponenetType,uint32 _openingTime, uint32 _closingTime) public returns(bool creationSuccessful){
        require(uint(_uComponenetType) < 3 && _openingTime <= 86400 && _closingTime <= 86400);
        //_hValue = msg.sender;
        require(universityComponenets[_hValue].set != true);
        //registerUC(_hValue);
        universityComponenets[_hValue] = UniversityComponenet(_uComponenetType, _openingTime, _closingTime,true);
        return true;
    } 
    
    //funkcija za provjeru i kreiranje transakcije te zove interne funkcije koje provjeravaju logičke cijeline te na temelju toga radi transakciju
    function callAccessTransaction(address addressHashMember, address addressHashUniversityComponenet, uint ttime, uint CurrentTransactionTime) public returns(bool creationSuccessful){
        //require(testStr20(addressHashMember) && testStr20(addressHashUniversityComponenet) && ttime <= 86400);
        require(ttime <= 86400 && members[addressHashMember].set == true && universityComponenets[addressHashUniversityComponenet].set == true);
        bool _access = false;
        //addressHashUniversityComponenet = msg.sender;
        _access = checkFirstCondition(addressHashMember,addressHashUniversityComponenet,ttime);
        if(_access == true){
            universityComponenets[addressHashUniversityComponenet].access[CurrentTransactionTime] = ControlParameter(_access,addressHashMember);
            //emit ControlAccess(true);
            return true;
        }
        _access = checkSecondCondition(addressHashMember,addressHashUniversityComponenet,ttime);    
        if(_access == true){
            universityComponenets[addressHashUniversityComponenet].access[CurrentTransactionTime] = ControlParameter(_access,addressHashMember);
            //emit ControlAccess(true);
            return true;
        }
        _access = checkThirdCondition(addressHashMember,addressHashUniversityComponenet,ttime);    
        if(_access == true){
            universityComponenets[addressHashUniversityComponenet].access[CurrentTransactionTime] = ControlParameter(_access,addressHashMember);
            //emit ControlAccess(true);
            return true;
        }
        universityComponenets[addressHashUniversityComponenet].access[CurrentTransactionTime] = ControlParameter(_access,addressHashMember);
        //emit ControlAccess(false);
        return false;    
    }
    
    //funkcije za reguliranje ulaza podijeljenje prema logičkim komponentama
    function checkFirstCondition(address addressHashMember, address addressHashUniversityComponenet, uint ttime) internal view returns(bool){
        UniversityComponenet memory _universityComponenet = universityComponenets[addressHashUniversityComponenet];
        Member memory _member = members[addressHashMember]; 
        if(_universityComponenet.universityComponenetType == _member.universityComponenetType){
            if(ttime >= _universityComponenet.openingTime && ttime <= _universityComponenet.closingTime)
                return true;
            else if(uint(_member.personType) == 1 || uint(_member.personType) == 2)
                return true;
        }
        return false;    
    }
    function checkSecondCondition(address addressHashMember, address addressHashUniversityComponenet, uint ttime) internal view returns(bool){
        UniversityComponenet memory _universityComponenet = universityComponenets[addressHashUniversityComponenet];
        Member memory _member = members[addressHashMember]; 
        if(uint(_member.personType) == 0 || uint(_member.personType) == 1){
            if(ttime >= _universityComponenet.openingTime && ttime <= _universityComponenet.closingTime)
                return true;
        }
        return false;
    }
    function checkThirdCondition(address addressHashMember, address addressHashUniversityComponenet, uint ttime) internal view returns(bool){
        UniversityComponenet memory _universityComponenet = universityComponenets[addressHashUniversityComponenet];
        //Member memory  _member = members[addressHashMember]; 
        if(uint(_universityComponenet.universityComponenetType) == 0){
            if(ttime >= _universityComponenet.openingTime && ttime <= _universityComponenet.closingTime)
                return true;
        }
        return false;
    }
}
