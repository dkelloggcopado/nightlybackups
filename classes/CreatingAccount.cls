public Class CreatingAccount {
public Account createAccount(String name) { //method to create account
//Adding a new comment for CLI test
Account acc = new Account();
acc.Name = name;
return acc;
}
}