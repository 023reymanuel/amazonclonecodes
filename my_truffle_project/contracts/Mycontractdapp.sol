// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {
    address public owner;

    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
        uint256 time;
        Item item;
    }
    
    mapping (uint256 => Item) public items;
    mapping (address => uint256) public orderCount;
    mapping (address => mapping (uint256 => Order)) public orders;

    event ItemListing(string name, uint256 cost, uint256 quantity);
    event Buy(address buyer, uint256 orderID, uint256 cost, uint256 quantity);

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {
        Item memory newItem = Item(_id, _name, _category, _image, _cost, _rating, _stock);
        items[_id] = newItem;

        emit ItemListing(_name, _cost, _stock);
    } 

    function buy(uint256 _id) public payable {
        require(items[_id].stock > 0, "Items out of stock");
        require(msg.value >= items[_id].cost, "Insufficient funds");

        Item memory item = items[_id];
        Order memory order = Order(block.timestamp, item);
        orderCount[msg.sender]++;
        orders[msg.sender][orderCount[msg.sender]] = order;

        // Calculate the quantity based on the stock of the item
        uint256 quantity = item.stock;

        emit Buy(msg.sender, orderCount[msg.sender], item.cost, quantity);

        // Withdraw funds  
        withdraw();
    }

    function withdraw() public onlyOwner {
        (bool success,) = owner.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }
}
