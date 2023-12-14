# What I have learn during doing the pet Project "FundMe"?

// "private" variables are more efficient than the "publics" one

1. every function runs standalone right after setUp() -> setup + testMinimumUsdt, setup + testOwnerIsMsgSender, ...
2. methodology for the testing:
   1) Arrange
   2) Act
   3) Assert


3. vm.prank() + vm.deal() == hoax (ADDRESS, VALUE_IN_WEI)

// uint16 custom_address = address(1)

4. gasleft() - how much our transaction has gas so far 
HINT: whenever we sent transaction, we send a little bit more gas than expected to use


5. obvious gas optimization technique -> write to memory, not in storage

6. constant/immutable variables - part of byte code -> don't cost so many gas as variables in storage

7. Explore contract layout -- 
```bash
forge inspect FundMe storageLayout
``` 
--- every time we see "s_**", we say: "OMG! I am reading from storage -> let's change it to memory!"

8. how to know what is the information is stored int the storage: -> everybody can see `private information` in the blocks -> there is no 'private', just not indexed
   1) run 'anvil'
   2) send there 'contract'
   3) run this comman in console: 
```bash
   cast storage <address of contract(account)> 1
```
9. Foundry can run bash script directly on the machine, but we need to add this allowing to the .toml configuration file:
```toml
...
ffi = true
...
```
10. There are different type of testing:
    1.  <b>Unit test</b> == testing specific part of code
    2.  <b>Integration test</b> == testing how our codes test with other parts of code
    3.  <b>Forked test</b> == testing our code in real simulated env (test network)
    4.  <b>Staging test</b> == testing in acceptance env