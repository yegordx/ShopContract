// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentContract {
    struct Payment {
        uint amount;
        address buyer;
        address seller;
        bool isCompleted;
    }

    mapping(uint => Payment) public payments;        
    mapping(bytes32 => uint) public transactions;     
    uint public nextPaymentId;                        


    function createPayment(address seller) public payable returns (uint) {
        payments[nextPaymentId] = Payment({
            amount: msg.value,
            buyer: msg.sender,
            seller: seller,
            isCompleted: false
        });
        nextPaymentId++;
        return nextPaymentId - 1; 
    }


    function storeTransactionHash(bytes32 txHash, uint paymentId) public {
        require(transactions[txHash] == 0, "Transaction hash already exists"); 
        require(payments[paymentId].buyer == msg.sender, "Not authorized");    
        transactions[txHash] = paymentId;                                       
    }


    function confirmPayment(bytes32 txHash) public {
        uint paymentId = transactions[txHash];                               
        Payment storage payment = payments[paymentId];                       

        require(payment.seller != address(0), "Payment does not exist");     
        require(payment.buyer == msg.sender, "Not authorized");              
        require(!payment.isCompleted, "Payment already completed");          

        payment.isCompleted = true;                                          
        payable(payment.seller).transfer(payment.amount);                    
    }
}