pragma solidity ^0.4.23;

contract piiszg {
    
    enum PersonType { Student, Profesor, Staff}
    enum UniversityComponenetType { FER, FFZG, FSB}
  
    struct Member {
        //string jmbag;
        PersonType personType;
        UniversityComponenetType universityComponenetType;
        //address membersHashedAddress;
        //public mapping(uint => bool) access;
    }
    struct ControlParameter{
        bool grantAccess;
        address membersHashedAddress;
        //uint timeRequested;
    }
    struct UniversityComponenet {
        //string universityKey;
        UniversityComponenetType universityComponenetType;
        uint32 openingTime;
        uint32 closingTime;
        //address universityComponenetsHashedAddress;
        mapping(uint => ControlParameter) access;
    }

    
    //hashirat će se u 20bajtnu adresu? i neće moći iterirati
    mapping(address => UniversityComponenet) public universityComponenets;
    mapping(address => Member) public members;

    //provjera jesu li dobiveni podatci u ispravnom formatu
    //pure zato što ne vraća ništa iz memorije niti traži po memoriji
    function testNum4(string str) private pure returns (bool){
        bytes memory b = bytes(str);
        if(b.length != 4) return false;
        for(uint i; i<4; i++){
            if(b[i] < 48 || b[i] > 57) return false;

        }
        return true;
    }
    function testNum10(string str) private pure returns (bool){
        bytes memory b = bytes(str);
        if(b.length != 10) return false;
        for(uint i; i<10; i++){
            if(b[i] < 48 || b[i] > 57) return false;
        }
        return true;
    }    
    function testStr20(string str) private pure returns (bool){
        bytes memory b = bytes(str);
        if(b.length != 20) return false;
        for(uint i; i<20; i++){
            if(!((b[i] > 48 && b[i] < 57) || (b[i] > 65 && b[i] < 90) || (b[i] > 97 && b[i] < 122))) return false;

        }
        return true;
    }    
    
    function createMember(address _hValue, PersonType _personType, UniversityComponenetType _uComponenetType) public {
        //require(_personType <= 3 && _uComponenetType <= 3);
        //_member.personType = uint(_personType);
        members[_hValue] = Member(_personType,_uComponenetType);
    }

    function createUniversityComponenet(address _hValue, UniversityComponenetType _uComponenetType,uint32 _openingTime, uint32 _closingTime) public {
        //require(_uComponenetType <= 3);
        universityComponenets[_hValue] = UniversityComponenet(_uComponenetType, _openingTime, _closingTime);
        
    } 
    
    function callTransaction(address addressHashMember, address addressHashUniversityComponenet, uint ttime) public returns(bool){
        //require(testStr20(addressHashMember) && testStr20(addressHashUniversityComponenet) && ttime <= 86400);
        require(ttime <= 86400);
        
        return true;
    }
    
    
    
/*
    address chairperson;
    mapping(address => Voter) voters;
    Proposal[] proposals;

    /// Create a new ballot with $(_numProposals) different proposals.
    function Ballot(uint8 _numProposals) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        proposals.length = _numProposals;
    }

    /// Give $(toVoter) the right to vote on this ballot.
    /// May only be called by $(chairperson).
    function giveRightToVote(address toVoter) public {
        if (msg.sender != chairperson || voters[toVoter].voted) return;
        voters[toVoter].weight = 1;
    }

    /// Delegate your vote to the voter $(to).
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender]; // assigns reference
        if (sender.voted) return;
        while (voters[to].delegate != address(0) && voters[to].delegate != msg.sender)
            to = voters[to].delegate;
        if (to == msg.sender) return;
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegateTo = voters[to];
        if (delegateTo.voted)
            proposals[delegateTo.vote].voteCount += sender.weight;
        else
            delegateTo.weight += sender.weight;
    }

    /// Give a single vote to proposal $(toProposal).
    function vote(uint8 toProposal) public {
        Voter storage sender = voters[msg.sender];
        if (sender.voted || toProposal >= proposals.length) return;
        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
    }

    function winningProposal() public constant returns (uint8 _winningProposal) {
        uint256 winningVoteCount = 0;
        for (uint8 prop = 0; prop < proposals.length; prop++)
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                _winningProposal = prop;
            }
    }*/
}
