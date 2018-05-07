pragma solidity ^0.4.23;

contract piiSZGNetwork {
    
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
    
    
    //hashirat će se u 20bajtnu adresu? i neće moći iterirati?
    //mapa svih komponenti sveučilišta i svih osoba preko hasha jmbaga/universityKeya
    mapping(address => UniversityComponenet) public universityComponenets;
    mapping(address => Member) public members;

    //provjera jesu li dobiveni podatci u ispravnom formatu
    //pure zato što ne vraća ništa iz memorije niti traži po memoriji
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
    function createMember(address _hValue, PersonType _personType, UniversityComponenetType _uComponenetType) public returns(bool){
        require(uint(_personType) < 3 && uint(_uComponenetType) < 3);
        //registerMember(_hValue);
        members[_hValue] = Member(_personType,_uComponenetType,true);
        return true;
    }

    //kreiranje nove komponente sveučilišta na temelju unosa hashedValue universityKeya
    function createUniversityComponenet(address _hValue, UniversityComponenetType _uComponenetType,uint32 _openingTime, uint32 _closingTime) public returns(bool){
        require(uint(_uComponenetType) < 3);
        //_hValue = msg.sender;
        //registerUC(_hValue);
        universityComponenets[_hValue] = UniversityComponenet(_uComponenetType, _openingTime, _closingTime,true);
        return true;
    } 
    
    //funkcija za provjeru i kreiranje transakcije te zove interne funkcije koje provjeravaju logičke cijeline te na temelju toga radi transakciju
    function callAccessTransaction(address addressHashMember, address addressHashUniversityComponenet, uint ttime, uint CurrentTransactionTime) public returns(bool){
        //require(testStr20(addressHashMember) && testStr20(addressHashUniversityComponenet) && ttime <= 86400);
        require(ttime <= 86400 && members[addressHashMember].set == true && universityComponenets[addressHashUniversityComponenet].set == true);
        bool _access = false;
        //addressHashUniversityComponenet = msg.sender;
        _access = checkFirstCondition(addressHashMember,addressHashUniversityComponenet,ttime);
        if(_access == true){
            universityComponenets[addressHashUniversityComponenet].access[CurrentTransactionTime] = ControlParameter(_access,addressHashMember);
            return true;
        }
        _access = checkSecondCondition(addressHashMember,addressHashUniversityComponenet,ttime);    
        if(_access == true){
            universityComponenets[addressHashUniversityComponenet].access[CurrentTransactionTime] = ControlParameter(_access,addressHashMember);
            return true;
        }
        _access = checkThirdCondition(addressHashMember,addressHashUniversityComponenet,ttime);    
        if(_access == true){
            universityComponenets[addressHashUniversityComponenet].access[CurrentTransactionTime] = ControlParameter(_access,addressHashMember);
            return true;
        }
        universityComponenets[addressHashUniversityComponenet].access[CurrentTransactionTime] = ControlParameter(_access,addressHashMember);
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

