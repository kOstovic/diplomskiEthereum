pragma solidity ^0.4.23;

contract piiSZG {
    
    //enums za lakšu provjeru tipova sastavnica sveučilišta i osoba
    enum PersonType { Student, Profesor, Staff}
    enum UniversityComponenetType { FER, FFZG, FSB}
    
    event ControlEvent(
        bool controlEvent
    );
    
    uint timeInDay = 86400;
    uint8 numOfPersonType = 3;
    uint8 numOfUniversityComponenetType = 3;
  
  
    //struktura za zapis kontrole ulaza sadrži bool 
    //jeli dopušten ulaz te hash osobe koja je zatražila pristup
    struct ControlParameter{
        bool grantAccess;
        address hashedAddress;

    }

    //struktura Member/Osoba, sadrži enums tipOsobe i 
    //tipFakulteta te bool set za provjeru postoji li 
    struct Member {
        //string jmbag;
        PersonType personType;
        UniversityComponenetType universityComponenetType;
        bool set;
        string tid;
        //address membersHashedAddress;
        mapping(uint => ControlParameter) accessM;
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
        address universityComponenetAccount;
        bool set;
        mapping(uint => ControlParameter) access;

    }
    
    //hashirat će se u 20bajtnu adresu? i neće moći iterirati?
    //mapa svih komponenti sveučilišta i svih osoba preko hasha jmbaga/universityKeya
    mapping(address => UniversityComponenet) public universityComponenets;
    mapping(address => Member) public members;
    
    //getteri za osobu, zakomentirani getteri se trenutno ne koriste i samo troše gas
    function getPersonType(address _hValue) public view returns (uint){
        require(members[_hValue].set == true);
        return uint(members[_hValue].personType);
    }
    function getUniversityComponenetTypeMem(address _hValue) public view returns (uint){
        require(members[_hValue].set == true);
        return uint(members[_hValue].universityComponenetType);
    }
    function getMemberSet(address _hValue) public view returns (bool){
        require(members[_hValue].set == true);
        return members[_hValue].set;
    }

    //getteri za sveučilišnu komponentu
    function getUniversityComponenetTypeUC(address _hValue) public view returns (uint){
        require(universityComponenets[_hValue].set == true);
        return uint(universityComponenets[_hValue].universityComponenetType);
    }  
    function getOpeningTime(address _hValue) public view returns (uint32){
        require(universityComponenets[_hValue].set == true);
        return universityComponenets[_hValue].openingTime;
    }
    function getClosingTime(address _hValue) public view returns (uint32){
        require(universityComponenets[_hValue].set == true);
        return universityComponenets[_hValue].closingTime;
    }
    function getUniversityComponenetSet(address _hValue) public view returns (bool ){
        require(universityComponenets[_hValue].set == true);
        return universityComponenets[_hValue].set;
    }
    function getAccessFromUC(address _hValue, uint time) public view returns (bool, address){
        require(universityComponenets[_hValue].set == true);
        return (universityComponenets[_hValue].access[time].grantAccess, universityComponenets[_hValue].access[time].hashedAddress);
    }
    function getAccessFromMem(address _hValue, uint time) public view returns (bool, address){
        require(members[_hValue].set == true);
        return (members[_hValue].accessM[time].grantAccess, members[_hValue].accessM[time].hashedAddress);
    }
    

    //pomoćne funckije
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
    function testStr24(string str) internal pure returns (bool){
        bytes memory b = bytes(str);
        if(b.length != 24) return false;
        for(uint i; i<24; i++){
            if(!((b[i] >= 48 && b[i] <= 57) || (b[i] >= 65 && b[i] <= 90) || (b[i] >= 97 && b[i] <= 122))) return false;

        }
        return true;
    }    

    //kreiranje nove osobe na temelju unosa hashedValue jmbaga
    function createMember(address _hValue, PersonType _personType, UniversityComponenetType _uComponenetType, string _tid) public returns(bool){
        require(uint(_personType) < numOfPersonType && uint(_uComponenetType) < numOfUniversityComponenetType);
        require(members[_hValue].set != true);
        require(testStr24(_tid) == true);
        //svejedno koji način, oba su ispravna, prvi je kraći-1liner
        members[_hValue] = Member(_personType,_uComponenetType,true,_tid);
        //members[_hValue].personType = _personType;
        //members[_hValue].universityComponenetType = _uComponenetType;
        //members[_hValue].set = true;
        emit ControlEvent(true);
        return true;
    }


    //kreiranje nove komponente sveučilišta na temelju unosa hashedValue universityKeya
    function createUniversityComponenet(address _hValue, UniversityComponenetType _uComponenetType,uint32 _openingTime, uint32 _closingTime) public returns(bool){
        require(uint(_uComponenetType) < numOfUniversityComponenetType && _openingTime <= timeInDay && _closingTime <= timeInDay);
        //_hValue = msg.sender;
        require(universityComponenets[_hValue].set != true);
        //registerUC(_hValue);
        universityComponenets[_hValue] = UniversityComponenet(_uComponenetType, _openingTime, _closingTime,msg.sender,true);
        emit ControlEvent(true);
        return true;
    } 
    
    //funkcija za provjeru i kreiranje transakcije te zove interne funkcije koje provjeravaju logičke cijeline te na temelju toga radi transakciju
    function callAccessTransaction(address addressHashMember, address addressHashUniversityComponenet, uint ttime, uint transactionDateTime, string tid) public returns(bool){
        //require(testStr20(addressHashMember) && testStr20(addressHashUniversityComponenet) && ttime <= timeInDay);
        require(msg.sender == universityComponenets[addressHashUniversityComponenet].universityComponenetAccount);
        require(ttime <= timeInDay && members[addressHashMember].set == true && universityComponenets[addressHashUniversityComponenet].set == true);
        require(testStr24(tid) == true);
        bool _access = false;
        
        //provjera jeli dostavljeni tid jednak onome zapisanom u memberu preko hasha, troši puno manje gasa
        if(keccak256(tid) != keccak256(members[addressHashMember].tid)){
            emit ControlEvent(false);
            return false;
        }
        
        //addressHashUniversityComponenet = msg.sender;
        _access = checkSameUniversityOpenedOrPrivileged(addressHashMember,addressHashUniversityComponenet,ttime);
        if(_access == true){
            universityComponenets[addressHashUniversityComponenet].access[transactionDateTime] = ControlParameter(_access,addressHashMember);
            members[addressHashMember].accessM[transactionDateTime] = ControlParameter(_access,addressHashUniversityComponenet);
            emit ControlEvent(true);
            return true;
        }
        _access = checkNotSameUniversityOpenedStudentProfesor(addressHashMember,addressHashUniversityComponenet,ttime);    
        if(_access == true){
            universityComponenets[addressHashUniversityComponenet].access[transactionDateTime] = ControlParameter(_access,addressHashMember);
            members[addressHashMember].accessM[transactionDateTime] = ControlParameter(_access,addressHashUniversityComponenet);
            emit ControlEvent(true);
            return true;
        }
        _access = checkNotSameUniversityOpenedFER(addressHashMember,addressHashUniversityComponenet,ttime);    
        if(_access == true){
            universityComponenets[addressHashUniversityComponenet].access[transactionDateTime] = ControlParameter(_access,addressHashMember);
            members[addressHashMember].accessM[transactionDateTime] = ControlParameter(_access,addressHashUniversityComponenet);
            emit ControlEvent(true);
            return true;
        }
        universityComponenets[addressHashUniversityComponenet].access[transactionDateTime] = ControlParameter(_access,addressHashMember);
        members[addressHashMember].accessM[transactionDateTime] = ControlParameter(_access,addressHashUniversityComponenet);
        emit ControlEvent(false);
        return false;    
    }
    
    //funkcije za reguliranje ulaza podijeljenje prema logičkim komponentama
    function checkSameUniversityOpenedOrPrivileged(address addressHashMember, address addressHashUniversityComponenet, uint ttime) internal view returns(bool){
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
    function checkNotSameUniversityOpenedStudentProfesor(address addressHashMember, address addressHashUniversityComponenet, uint ttime) internal view returns(bool){
        UniversityComponenet memory _universityComponenet = universityComponenets[addressHashUniversityComponenet];
        Member memory _member = members[addressHashMember]; 
        if(uint(_member.personType) == 0 || uint(_member.personType) == 1){
            if(ttime >= _universityComponenet.openingTime && ttime <= _universityComponenet.closingTime)
                return true;
        }
        return false;
    }
    function checkNotSameUniversityOpenedFER(address addressHashMember, address addressHashUniversityComponenet, uint ttime) internal view returns(bool){
        UniversityComponenet memory _universityComponenet = universityComponenets[addressHashUniversityComponenet];
        //Member memory  _member = members[addressHashMember]; 
        if(uint(_universityComponenet.universityComponenetType) == 0){
            if(ttime >= _universityComponenet.openingTime && ttime <= _universityComponenet.closingTime)
                return true;
        }
        return false;
    }
}

