// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract chipLottery is Ownable,VRFConsumerBaseV2,ERC721{
    VRFCoordinatorV2Interface public immutable COORDINATOR;
    address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 4;
    uint32 numWords =  1;
    uint64 s_subscriptionId;
    uint256[] public s_randomWords;
    uint256 public s_requestId;
    uint256 public winningNumber;
    address s_owner;
    address public owners;
    uint256 chipsPrice = 0.001 ether;
    uint256 rouletteChips;
    uint256 maxChipChecker;
    bool startRound;
    mapping (address => uint256) public walletChecker;
    address payable[] public players;
    uint public betID;
    mapping (uint => address payable) public betHistory;

    constructor(uint64 subscriptionId) payable VRFConsumerBaseV2(vrfCoordinator) ERC721('Roulette Game','RG'){
      maxChipChecker = 4;
      betID = 1;
      owners = msg.sender;
      COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
      s_owner = msg.sender;
      s_subscriptionId = subscriptionId;
    }
    //VRF
    function requestRandomWords() external onlyOwner {
      s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
  }
    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override{
      winningNumber = (randomWords[0] % 4) + 1;
  }
    //Starting the round
    function RoundStarter() public onlyOwner{
        startRound = true;
    }
    // Clearing round
    function RoundCloser() public onlyOwner{
        startRound = false;
        players = new address payable[](0);
    }
    //You can set the supply with that
    function roundChipSetter(uint256 _maxChipChecker) public onlyOwner {
        maxChipChecker = _maxChipChecker;
    }
    // Minting roulette chips
    function buyChips() public payable{
        require(msg.value < chipsPrice,'Insufficient ballance');
        require(maxChipChecker > rouletteChips,'All chips sold');

        uint256 tokenId = rouletteChips;
        _safeMint(msg.sender,tokenId);
        walletChecker[msg.sender]++;
        rouletteChips++;
    }
    //Winner history
    function getWinner(uint bet) public view returns (address payable) {
        return betHistory[bet];
    }
    // asking balance
    function askBalance() public view returns (uint) {
        return walletChecker[msg.sender];
    }
    // asking players
    function askPlayers() public view returns (address payable[] memory) {
        return players;
    }
    // joining the lottery
    function enterthelottery() public payable {
        require(walletChecker[msg.sender] > 0,'Insufficient balance sry!');
        require(startRound, 'Round not started');
    // players adress entering the lottery
        players.push(payable(msg.sender));
    }
    //Old random number function
    /*function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owners,block.timestamp)));
    }*/
    // Picking winner
    function checkWinner() public onlyOwner {
        uint index = winningNumber;
        walletChecker[players[index]]++;
        betHistory[betID] = players[index];
        betID++;
    }
}
 
 
