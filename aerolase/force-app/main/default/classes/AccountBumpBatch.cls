public class AccountBumpBatch implements Database.Batchable<sObject> {
    private Set<Id> accountIds;
    
    public AccountBumpBatch(Set<Id> accountIds) {
        this.accountIds = accountIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Account WHERE Id IN :accountIds]);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Account> accountsToUpdate = new List<Account>();
        DateTime currentDateTime = DateTime.now();
        
        for(Account account : scope) {
            account.Bump_Date_Time__c = currentDateTime;
            accountsToUpdate.add(account);
        }
        
        update accountsToUpdate;
    }
    
    public void finish(Database.BatchableContext bc) {
        // Optional: Add completion logic here
    }
}