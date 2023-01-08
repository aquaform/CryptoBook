// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract Granny {
    //кол-во внуков
    uint8 public counter;

    //денег в банке
    uint256 public bank;

    //адрес кошелька бабушки
    address public owner;

    struct Grandchild {
        string name;
        uint256 birthday;
        bool alreadyGotMoney;
        bool exist;
    }

    address[] public arrGrandchilds;

    mapping(address => Grandchild) public grandchilds;

    constructor() {
        owner = msg.sender;
        counter = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not owner!");
        _;
    }

    function addGrandchild(
        address walletAdress, 
        string memory name, 
        uint256 birthday
    ) public onlyOwner {
        require(birthday > 0, "This date is fucking shit");
        require(grandchilds[walletAdress].exist == false,
            "There is alredy such a grandchild!");
        grandchilds[walletAdress] = Grandchild(name, birthday, false, true);
        arrGrandchilds.push(walletAdress);
        counter++;        
        emit NewGrandchild(walletAdress, name, birthday);
    }

    function balanceOf() public view returns (uint256){
        return address(this).balance;
    }

    function withdraw() public {
        address payable walletAdress = payable(msg.sender);
        
        require(grandchilds[walletAdress].exist == true, "You are not fucking grandchild!");
        require(block.timestamp > grandchilds[walletAdress].birthday, "Birthday hasn't arrived yet!");
        require(grandchilds[walletAdress].alreadyGotMoney == false, "You have already received money!");

        uint256 amount = bank / counter;
        grandchilds[walletAdress].alreadyGotMoney = true;

        (bool success, ) = walletAdress.call{value: amount}("");
        require(success);

        emit GotMoney(walletAdress);
    }

    function readGrandchildsArray(uint cursor, uint length) public view returns (address[] memory) {
        address[] memory array = new address[](length);
        uint counter2 = 0;

        for(uint i = cursor; i < cursor+length; i++) {
            array[counter2] = arrGrandchilds[i];
            counter2++;
        }

        return array;
    }

    receive() external payable {
        bank += msg.value;
    }

    event NewGrandchild(address indexed walletAdress, string name, uint256 birthday);
    event GotMoney(address indexed walletAdress);

}