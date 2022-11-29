// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract SimpleNFT is ERC721Enumerable, Ownable  {
  
  using Strings for uint256;

  string public baseExtension = ".json";
  uint256 public cost = 0.01 ether;
  uint256 public daiMintPrice = 1 ether;  // $1
  uint256 public maxSupply = 1000000;
  uint256 public maxMintAmount = 10;
  bool public paused = false;
  string private constant NAME ="Soulbound" ;
  string private constant SYMBOL= "pies" ;  
  string private s_baseURI="ipfs://QmRvpdsMzdp5CnRjsWbDDkCqgu3SJ1UR5K8WmxnrofqyRU/";
  address private daiAddress = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;  // polygon dai address
  address private mumbaiDaiAddress =  0x1B2278e4f8e9D7786ed305B0204db3107Efa3396;

  IERC20 paytoken  = IERC20(mumbaiDaiAddress); 
  event LogEvent (address indexed _minter, uint _tokenID);

  constructor( ) ERC721(NAME, SYMBOL) {
    
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return s_baseURI;
  }

  // public
  function mint(uint256 _mintAmount) public payable {
      console.log (" ______________", msg.value);
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmount);
    require(supply + _mintAmount <= maxSupply);

   // if (msg.sender != owner()) {
   //   require(msg.value >= cost * _mintAmount);

   require(msg.value >= cost * _mintAmount);
    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
      emit LogEvent(msg.sender,supply + i);
    }
    
  }

  // public
  function mintWithDAI() public payable {
    console.log (" ______________", msg.value);
    uint256 supply = totalSupply();
    require(!paused);
    require(supply + 1 <= maxSupply);

    require(paytoken.balanceOf(msg.sender ) >= daiMintPrice, "Not enough dai");
    paytoken.transferFrom(msg.sender, address(this), daiMintPrice);
      _safeMint(msg.sender, supply + 1);
    emit LogEvent(msg.sender,supply + 1);  
  }

  function walletOfOwner(address _owner) public view returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId) public view virtual override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }
  

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    s_baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
         // withdraws the erc20 token provided
   function withdrawERC20s() public payable onlyOwner() {
        paytoken.transfer(msg.sender, paytoken.balanceOf(address(this)));
        }

  function withdraw() public payable onlyOwner {
    // This will payout the owner 100% of the contract balance.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }
    /**
    * @notice contract can receive Ether.
    */
     receive() external payable {}
 
}
