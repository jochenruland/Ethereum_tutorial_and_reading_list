## Function selector and how to use them in call, staticcall or delegatecall

### I. Function selector
`.selector` returns the ABI function selector
cf. solidity docs

> the first four bytes of the call data for a function call specifies the function to be called. It is the first (left, high-order in big-endian) four bytes of the Keccak-256 (SHA-3) hash of the signature of the function. The signature is defined as the canonical expression of the basic prototype without data location specifier, i.e. the function name with the parenthesised list of parameter types. Parameter types are split by a single comma - no spaces are used.

Note that the `.selector` will not work for functions declared as internal and private, but only for public and external functions, as only these functions are published to the ABI.

```
pragma solidity ^0.8.6;

contract Sample {

    function foo() public {}

    function getBalance(address _address) public view returns (uint256){}

    function getValue (uint _value) public pure returns (uint) {
        return _value;
    }
}

contract GetSelectors {

    Sample samp = new Sample();

    function getSelector() public view returns (bytes4, bytes4) {
        return (samp.foo.selector, foo.getBalance.selector);
    }

    // Returns same values as getSelector() by returning the bytes4 of keccak256()
    function getKeccakSeletor() public view returns (bytes4, bytes4) {
        return bytes4(keccak256('foo()')), bytes4(keccak256('getBalance(address)'));
    }
}

```

### II. call()
Solidity has the `call` function on address data type which can be used to call public and external functions on contracts.
It can also be used to transfer ether to addresses. `call` is not recommended in most situations for contract function calls
because it bypasses type checking, function existence check, and argument packing.
It is preferred to import the interface of the contract to call functions on it.

`call` is used to call the fallback and receive functions of the contract.
Receive is called when no data is sent in the function call and ether is sent.
Fallback function is called when no function signature matches the call.

`call` consumes less gas than calling the function on the contract instance. So in some cases call is preferred for gas optimisation.

#### a) Calling another contracts function with .call()
```
contract Sample {

  function sampleFunction(uint _x, address _addr) public returns(uint, uint) {
      // do something
      return (a, b);
  }  
}

contract CallSample {

  Sample s = new Sample();

  // function signature should not have any spaces
  bytes memory args1 = abi.encodeWithSignature("sampleFunction(uint,address)", 10, msg.sender)

  // Alternatively with selector
  bytes4 selector = s.sampleFunction.selector;
  bytes memory args2 = abi.encodeWithSelector(selector, 10);

  // Alternatively you can also use args2 without signing the tx
  (bool success, bytes memory returnedData) = address(s).call(args1);
  require(success);

  return abi.decode(returnedData, (uint256, uint256));

}

```
#### b) Specify gas and transfer amount with .call()
```
contract CallSample {
  ...

  // args2 cf. above
  _addr.call{value: 1 ether, gas: 1000000}(args2);
}
```
- Calling the `sampleFunction` method on the contract only the specified amount of gas will be supplied (here gas = 1000000)
- The amount of the gas supplied to the outer function where call is executed has to be more or equal
- If no gas is mentioned all the gas remaining before the call is supplied to the myFunction call. It is always better to not hardcode the gas supplied to the function call
- If sending ether to the call method, `sampleFunction` must be a payable. Otherwise the call will fail
- If the amount of gas supplied to call is less than required by `sampleFunction` to execute, the call will fail

#### c) Sending ether using .call()
- After the Istanbul hardfork send and transfer methods have been deprecated
- If transfer is used inside a function call of a contract a fixed gas of 2300 is supplied to the transfer method. Since gas cost is subjected to change the fixed gas cost might not be enough to successfully transfer the ether and the overall function call might fail.
- Sending ether using .call() the receive function is called provided msg.data is empty. If the receive function is not implemented then the fallback function is called.
- Using call to transfer ether opens up the possibility of a reentrancy attack since the gas supplied can be used to reenter the function by calling it again inside the receive or fallback function of the receiving contract
- Reentrancy can be solved by using a reentrancy guard.
```
function paySomeone(address _addr) public payable nonReentrant {

    (bool success, ) = _addr.call{value: msg.value}("");
    // do something
}
```

### III. Staticcall
`address.staticall()` Works in the same way as `address.call()` but can only be used for pure, view and constant functions which do not change state.
It will revert if the target function changes any state variable.

```
function callGetValue(uint _x) public view returns (uint) {

    Sample s = new Sample();

    bytes4 selector = s.getValue.selector;

    bytes memory data = abi.encodeWithSelector(selector, _x);
    (bool success, bytes memory returnedData) = address(s).staticcall(data);
    require(success);

    return abi.decode(returnedData, (uint256));
}
```

### IV. Delegatecall
`delegatecall` is used to call a function of contract B from contract A with contract A’s storage, balance and address supplied to the function.
It uses the same syntax as call except that it cannot accept the value option but only gas.

#### A) General
*The following are extracts of the article [Understanding delegatecall And How to Use It Safely, Nick Mudge, Jul 24, 2021](https://eip2535diamonds.substack.com/p/understanding-delegatecall-and-how)*

When a contract makes a function call using delegatecall it loads the function code from another contract and executes it as if it were its own code.
delegatecall is used to call a function of contract B from contract A with contract A’s storage, balance and address supplied to the function

When a function is executed with delegatecall these values do not change:
- address(this)
- msg.sender
- msg.value

Reads and writes to state variables happen to the contract that loads and executes functions with delegatecall. Reads and writes never happen to the contract that holds functions that are retrieved

#### B) How To Use delegatecall Safely
Now that you understand how delegatecall works let’s look at how to use it safely.

##### 1. Control what is executed with delegatecall
Do not execute untrusted code with delegatecall because it could maliciously modify state variables or call `selfdestruct` to destroy the calling contract. Use permissions or authentication or some other form of control for specifying or changing what functions and contracts are executed with delegatecall.

##### 2. Only call delegatecall on addresses that have code
Delegatecall will return ‘True’ for the status value if it is called on an address that is not a contract and so has no code. This can cause bugs if code expects delegatecall functions to return `False` when they can’t execute.

If you are unsure if an address variable will always hold an address that has code and delegatecall is used on it then check that any address from the variable has code before using delegatecall on it and revert if it doesn’t have code. Here is an example of code that checks if an address has code:
```
function isContract(address account) internal view returns (bool) {

  uint256 size;
  assembly {size := extcodesize(account)}
  return size > 0;
}
```

##### 3. Manage State Variable Layout
Solidity stores data in contracts using a numeric address space. The first state variable is stored at position 0, the next state variable is stored at position 1, the next state variable is stored at position 2, etc.

A contract and function that is executed with delegatecall shares the same state variable address space as the calling contract, because functions called with delegatecall read and write the calling contract’s state variables.

Therefore a contract and function that is called with delegatecall must have the same state variable layout for state variable locations that are read and written to. Having the same state variable layout means that the same state variables are declared in the same order in both contracts.

If a contract that calls delegatecall and the contract with the borrowed functions do not have the same state variable layout and they read or write to the same locations in contract storage then they will overwrite or incorrectly interpret each other’s state variables.

For example let’s say that a ContractA declares state variables ‘uint first;’ and ‘bytes32 second;’ and ContractB declares state variables ‘uint first;’ and ‘string name;’. They have different state variables at postion 1 (‘bytes32 second’ and ‘string name’) in contract storage and so they will write and read wrong data between them at position 1 if delegatecall is used between them.

Managing the state variable layout of contracts that call functions with delegatecall and the contracts that are executed with delegatecall is not hard to do in practice when a strategy is used to do it. Here are some known strategies that have been used successfully in production


#### C) Using initialize() function instead of constructor()
The purpose of the initializer (as well as the constructor) is to be called as the first function before using the contract, and never be called back a second time
However, initialize is used instead of the constructor when a contract that uses a proxy is published

When a call is made using DELEGATECALL, the function foo() would be called on contract B but in the context of contract A. This means that the logic of contract B would be used, but any state changes made by the function foo() would affect the storage of contract A. And also, msg.sender would point to the EOA who made the call in the first place.

how can we handle the constructor logic? The contract’s constructor is automatically called during contract deployment. But this is no longer possible when proxies are in play, as the constructor would change only the implementation contract’s storage (Contract B), not the storage of the proxy contract (Contract A), which is the one that matters.

Therefore, an additional step is required. We need to change the constructor in a regular function. This function is conventionally called initialize or init, this function will be called on the proxy contract once both contracts have been published, so as to save all changes of state on the proxy contract (contract A) and not on the implementation (contract B )
