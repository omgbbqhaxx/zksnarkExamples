pragma solidity ^0.6.3;
interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}
contract ERC20 {
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);


    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
}



contract decentstore {
   address creator;
   address erush = 0x2040FD61e31250D2913c9bfe61510cAC3bF212cB; //0x6EA53dfc58C5cbf68a799EdD208cb3A905db5939;
   mapping (string => uint256 ) public balances;
   uint256 public listprice = 1;
   event NewProduct(address indexed from, string value);
   constructor() public { creator = msg.sender; }

   function uintToString(uint256 v) internal pure returns(string memory str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }

    function nAddrHash() view public returns (uint256) {
        return uint256(msg.sender) % 10000000000;
    }

    function append(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a,"-",b));
    }

    function nMixAddrandBlock()  private view returns(string memory) {
         uint256 _bnum = block.number;
         return append(uintToString(nAddrHash()),uintToString(_bnum));
    }

    function nMixAddrandSpBlock(uint256 bnum)  private view returns(string memory) {
         return append(uintToString(nAddrHash()),uintToString(bnum));
    }

    struct pds {
       uint256 _ltime;
       address _lister;
       string _phead;
       string _pimage;
       uint256 _pprice;
       string _pexplain;
   }
   mapping(uint256 => pds) plist;
   uint256[] private indexList;


    function listproduct(uint256 tokens, string memory _phead, string memory _pimage, uint256 _pprice, string memory _pexplain )  public {
      require(ERC20(erush).balanceOf(msg.sender) >= listprice);
      require(tokens >= listprice);

      ERC20(erush).transferFrom(msg.sender, address(this), tokens);
      plist[indexList.length]._ltime = now;
      plist[indexList.length]._lister = msg.sender;
      plist[indexList.length]._phead = _phead;
      plist[indexList.length]._pimage = _pimage;
      plist[indexList.length]._pprice = _pprice;
      plist[indexList.length]._pexplain = _pexplain;
      indexList.push(indexList.length+1);
      emit NewProduct(msg.sender, _phead);




   }

    function plister(uint256 _index) view public returns(uint256, address, string memory, string memory, uint256, string memory) {
       uint256 _ltimex = plist[_index]._ltime;
       address _lister = plist[_index]._lister;
       string memory _phead = plist[_index]._phead;
       string memory _pimage = plist[_index]._pimage;
       uint256 _pprice = plist[_index]._pprice;
       string memory _pexplain = plist[_index]._pexplain;
       if(plist[_index]._ltime == 0){
            return (0, msg.sender, "0","0", 0, "0");
       }else {
            return (_ltimex, _lister,_phead, _pimage, _pprice, _pexplain);
       }
   }

   function pcount() view public returns (uint256) {
       return indexList.length;
   }

   function changeListingprice(uint256 newprice) public{
        require(msg.sender == creator);   // Check if the sender is manager
        listprice = newprice;

    }

     function transferOwnership(address newOwner) public{
        require(msg.sender == creator);   // Check if the sender is manager
        if (newOwner != address(0)) {
            creator = newOwner;
        }
    }

     function awithdrawal(uint tokens)  public {
          require(msg.sender == creator);
          ERC20(erush).transfer(creator, tokens);
    }





}
