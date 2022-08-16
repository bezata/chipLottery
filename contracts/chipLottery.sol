// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract chipLottery is ERC721,Ownable{
    address public owners;
    uint256 chipsPrice = 0.001 ether;
    uint256 rouletteChips;
    uint256 maxChipChecker;
    bool startRound;
    mapping (address => uint256) public walletChecker;
    address payable[] public players;
    uint public betID;
    mapping (uint => address payable) public betHistory;

    constructor() payable ERC721('Roulette Game','RG'){
      maxChipChecker = 0;
      betID = 1;
      owners = msg.sender;
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
        require(msg.value != chipsPrice,'Insufficient balance');
        require(maxChipChecker > rouletteChips,'All chips sold');
        require(walletChecker[msg.sender] < 1 ,'You can only buy one chip');

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
        walletChecker[msg.sender]--;
        require(startRound, 'Round not started');
    // players adress entering the lottery
        players.push(payable(msg.sender));
    }
    //Random number function
    function getRandomNumber() internal view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,players.length,betHistory[betID])));
    }
    // Picking winner
    function checkWinner() public onlyOwner {
        uint index = getRandomNumber() % players.length;
        walletChecker[players[index]]++;
        betHistory[betID] = players[index];
        betID++;
    }

}
