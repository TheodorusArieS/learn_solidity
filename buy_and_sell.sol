// SPDX-License-Identifier: GPL-3.0


pragma solidity 0.8.0;

contract Amazon {
    uint private _productId = 1; 
    Product[] public products;

    struct Product{
        string title;
        string desc;
        address payable seller;
        uint prodId;
        uint price;
        address buyer;
        bool delivered;
    }
    event Registered(string title,uint prodId,address seller,uint price);
    event Bought(uint prodId,address buyer);
    event Delivered(uint prodId);

    // product registration
    function productRegistration(string memory _title,string memory _desc,uint _price) public {
        Product memory tempProduct;
        tempProduct.title = _title;
        tempProduct.desc = _desc;
        tempProduct.price = _price; // price in ether
        tempProduct.seller = payable(msg.sender);
        tempProduct.prodId = _productId;
        _productId++;
        products.push(tempProduct);

        emit Registered(tempProduct.title,tempProduct.prodId,tempProduct.seller,tempProduct.price);
    }

    // buyers pay for the product
    function buy(uint _prodId) payable public{
        require(products[_prodId -1].price == msg.value,"You are not paying enough");
        products[_prodId -1].buyer = msg.sender;
        emit Bought(_prodId,msg.sender);
    }

    // buyers confirm delivery

    function delivery(uint _prodId) public{
        require(products[_prodId -1].buyer == msg.sender);
        products[_prodId -1].delivered = true;
        products[_prodId - 1].seller.transfer(products[_prodId - 1].price);
        emit Delivered(_prodId);
    }

}