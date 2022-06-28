## How to implement EIP-165: Standard Interface Detection in smart Contracts
### Background
EIP-165 standardizes the following issues:
1. How interfaces are identified
2. How a contract will publish the interfaces it implements
3. How to detect if a contract implements ERC-165
4. How to detect if a contract implements any given interface  

Full background cf. [EIP-165: Standard Interface Detection](https://eips.ethereum.org/EIPS/eip-165)

### How to get the interfaceId in a smart contract
The interface id is a bytes4 value calculated as the XOR of all function selectors of the interface. <br>
How to get the interface id for the following interface:<br>

```
pragma solidity ^0.4.20;

interface Solidity101 {
    function hello() external pure;
    function world(int) external pure;
}
```
a) Via type(i).interfaceId
```
contract IID {
    function calculateTypeID() public pure returns (bytes4) {
        Solidity101 i;
        return type(i).interfaceId
    }
}
```

b) Via XOR
 function selectors
```
pragma solidity ^0.4.20;

contract viaSelector {
    function calculateSelector() public pure returns (bytes4) {
        Solidity101 i;
        return i.hello.selector ^ i.world.selector;
    }
}
```

c) Via keccak
```
pragma solidity ^0.4.20;

contract viaKeccak {
    function calculateKeccak() public pure returns (bytes4) {
        Solidity101 i;
        return bytes4(keccak256('hello()')) ^ bytes4(keccak256('world(int)'));
    }
}
```

### How to integrate EIP-165 in your smart contract
1. Copy ERC165 from openzeppelin on github
2. Copy IERC165 from openzeppelin on github
3. Import ERC165
4. Inherit from ERC165
5. Override - cf. Example
```
/**
 * @dev See {ERC165-supportsInterface}.
 */
 function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
   return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId ||
   super.supportsInterface(interfaceId);
    }
```
