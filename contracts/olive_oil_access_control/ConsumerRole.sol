// SPDX-License-Identifier: MIT

pragma solidity >=0.6.00;

// Based on openzeppelin-solidity@2.5.0:  openzeppelin-solidity\contracts\access\roles\CapperRole.sol

import "../olive_oil_access_control/Roles.sol";

contract ConsumerRole {
    using Roles for Roles.Role;

    event ConsumerAdded(address indexed account);
    event ConsumerRemoved(address indexed account);

    Roles.Role private _Consumers;

    constructor () public {
        _addConsumer(msg.sender);
    }

    modifier onlyConsumer() {
        require(isConsumer(msg.sender), "ConsumerRole: caller does not have the Consumer role");
        _;
    }

    function isConsumer(address account) public view returns (bool) {
        return _Consumers.has(account);
    }

    function addConsumer(address account) public onlyConsumer {
        _addConsumer(account);
    }

    function renounceConsumer() public {
        _removeConsumer(msg.sender);
    }

    function _addConsumer(address account) internal {
        _Consumers.add(account);
        emit ConsumerAdded(account);
    }

    function _removeConsumer(address account) internal {
        _Consumers.remove(account);
        emit ConsumerRemoved(account);
    }
}

  // Define a function 'renounceConsumer' to renounce this role
  function renounceConsumer() public {

  }

  // Define an internal function '_addConsumer' to add this role, called by 'addConsumer'
  function _addConsumer(address account) internal {

  }

  // Define an internal function '_removeConsumer' to remove this role, called by 'removeConsumer'
  function _removeConsumer(address account) internal {

  }
}
