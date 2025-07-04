@isTest
public class AccountBumpBatchTest {
    
    @testSetup
    static void setupTestData() {
        // Create test accounts for batch testing
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 50; i++) { // Reduced number for testing
            Account testAccount = new Account(
                Name = 'Test Account ' + i,
                Website = 'www.website' + i + '.com',
                Description = 'Apex Test Class'
            );
            testAccounts.add(testAccount);
        }
        insert testAccounts;
    }
    
    @isTest
    static void testAccountBumpBatch_FullExecution() {
        // Get test accounts - use exact batch size to avoid multiple executions
        List<Account> testAccounts = [SELECT Id, Bump_Date_Time__c FROM Account LIMIT 10];
        
        // Verify initial state
        for(Account account : testAccounts) {
            System.assertEquals(null, account.Bump_Date_Time__c, 'Bump_Date_Time__c should initially be null');
        }
        
        // Create set of account IDs
        Set<Id> accountIdSet = new Set<Id>();
        for(Account account : testAccounts) {
            accountIdSet.add(account.Id);
        }
        
        // Create and execute batch with batch size equal to record count
        AccountBumpBatch batch = new AccountBumpBatch(accountIdSet);
        
        Test.startTest();
        Database.executeBatch(batch, 10); // Same as record count
        Test.stopTest();
        
        // Verify results
        List<Account> updatedAccounts = [SELECT Id, Bump_Date_Time__c FROM Account WHERE Id IN :accountIdSet];
        
        System.assertEquals(10, updatedAccounts.size(), 'Should have 10 updated accounts');
        
        for(Account updatedAccount : updatedAccounts) {
            System.assertNotEquals(null, updatedAccount.Bump_Date_Time__c, 'Bump_Date_Time__c should not be null after batch execution');
        }
    }
    
    @isTest
    static void testAccountBumpBatch_StartMethod() {
        // Get test accounts
        List<Account> testAccounts = [SELECT Id FROM Account LIMIT 5];
        
        // Create set of account IDs
        Set<Id> accountIdSet = new Set<Id>();
        for(Account account : testAccounts) {
            accountIdSet.add(account.Id);
        }
        
        // Test start method
        AccountBumpBatch batch = new AccountBumpBatch(accountIdSet);
        
        Test.startTest();
        Database.QueryLocator queryLocator = batch.start(null);
        Test.stopTest();
        
        // Verify query locator is created
        System.assertNotEquals(null, queryLocator, 'QueryLocator should not be null');
    }
    
    @isTest
    static void testAccountBumpBatch_ExecuteMethod() {
        // Get test accounts
        List<Account> testAccounts = [SELECT Id, Bump_Date_Time__c FROM Account LIMIT 5];
        
        // Create set of account IDs
        Set<Id> accountIdSet = new Set<Id>();
        for(Account account : testAccounts) {
            accountIdSet.add(account.Id);
        }
        
        // Create batch instance
        AccountBumpBatch batch = new AccountBumpBatch(accountIdSet);
        
        // Mock BatchableContext (null is acceptable for testing)
        Database.BatchableContext bc = null;
        
        Test.startTest();
        // Call execute method directly - this doesn't count as executeBatch
        batch.execute(bc, testAccounts);
        Test.stopTest();
        
        // Verify accounts were updated
        List<Account> updatedAccounts = [SELECT Id, Bump_Date_Time__c FROM Account WHERE Id IN :accountIdSet];
        
        for(Account updatedAccount : updatedAccounts) {
            System.assertNotEquals(null, updatedAccount.Bump_Date_Time__c, 'Bump_Date_Time__c should be updated');
        }
    }
    
    @isTest
    static void testAccountBumpBatch_FinishMethod() {
        // Create batch instance
        Set<Id> emptySet = new Set<Id>();
        AccountBumpBatch batch = new AccountBumpBatch(emptySet);
        
        // Test finish method (should not throw exception)
        Test.startTest();
        batch.finish(null);
        Test.stopTest();
        
        // Test passes if no exception is thrown
        System.assert(true, 'Finish method should complete without error');
    }
    
    @isTest
    static void testAccountBumpBatch_SmallBatchExecution() {
        // Test with very small dataset - 1 record with batch size 1
        Account testAccount = [SELECT Id, Bump_Date_Time__c FROM Account LIMIT 1];
        
        // Verify initial state
        System.assertEquals(null, testAccount.Bump_Date_Time__c, 'Bump_Date_Time__c should initially be null');
        
        // Create set with single ID
        Set<Id> accountIdSet = new Set<Id>{testAccount.Id};
        
        // Create and execute batch
        AccountBumpBatch batch = new AccountBumpBatch(accountIdSet);
        
        Test.startTest();
        Id batchId = Database.executeBatch(batch, 1); // 1 record, batch size 1
        Test.stopTest();
        
        // Verify batch job was created
        System.assertNotEquals(null, batchId, 'Batch job should be created');
        
        // Verify results
        Account updatedAccount = [SELECT Id, Bump_Date_Time__c FROM Account WHERE Id = :testAccount.Id];
        System.assertNotEquals(null, updatedAccount.Bump_Date_Time__c, 'Bump_Date_Time__c should be updated after batch execution');
    }
    
    @isTest
    static void testAccountBumpBatch_EmptyIdSet() {
        // Test with empty ID set
        Set<Id> emptyIdSet = new Set<Id>();
        AccountBumpBatch batch = new AccountBumpBatch(emptyIdSet);
        
        Test.startTest();
        Id batchId = Database.executeBatch(batch, 1);
        Test.stopTest();
        
        // Should handle empty set gracefully
        System.assertNotEquals(null, batchId, 'Batch job should be created even with empty set');
    }
    
    @isTest
    static void testAccountBumpBatch_Constructor() {
        // Test constructor without executing batch
        List<Account> testAccounts = [SELECT Id FROM Account LIMIT 5];
        Set<Id> accountIdSet = new Set<Id>();
        for(Account account : testAccounts) {
            accountIdSet.add(account.Id);
        }
        
        // Create batch with constructor
        AccountBumpBatch batch = new AccountBumpBatch(accountIdSet);
        
        // Test that the batch was created successfully
        System.assertNotEquals(null, batch, 'Batch should be created successfully');
        
        // Test start method to verify accountIds were set correctly
        Database.QueryLocator queryLocator = batch.start(null);
        System.assertNotEquals(null, queryLocator, 'QueryLocator should be created');
    }
    
    @isTest
    static void testAccountBumpBatch_ThreeRecordExecution() {
        // Test with 3 records and batch size 3 to ensure single execution
        List<Account> testAccounts = [SELECT Id, Bump_Date_Time__c FROM Account LIMIT 3];
        
        // Verify initial state
        for(Account account : testAccounts) {
            System.assertEquals(null, account.Bump_Date_Time__c, 'Bump_Date_Time__c should initially be null');
        }
        
        // Create set of account IDs
        Set<Id> accountIdSet = new Set<Id>();
        for(Account account : testAccounts) {
            accountIdSet.add(account.Id);
        }
        
        // Create and execute batch
        AccountBumpBatch batch = new AccountBumpBatch(accountIdSet);
        
        Test.startTest();
        Database.executeBatch(batch, 3); // 3 records, batch size 3
        Test.stopTest();
        
        // Verify results
        List<Account> updatedAccounts = [SELECT Id, Bump_Date_Time__c FROM Account WHERE Id IN :accountIdSet];
        
        for(Account updatedAccount : updatedAccounts) {
            System.assertNotEquals(null, updatedAccount.Bump_Date_Time__c, 'Account should have Bump_Date_Time__c updated');
        }
    }
    
    @isTest
    static void testAccountBumpBatch_ExecuteMethodWithTiming() {
        // Create a fresh account for timing test
        Account testAccount = new Account(
                Name = 'Test Account',
                Website = 'www.website.com',
                Description = 'Apex Test Class'
        );
        insert testAccount;
        
        // Query it back to get the inserted record
        testAccount = [SELECT Id, Bump_Date_Time__c FROM Account WHERE Id = :testAccount.Id];
        
        // Verify initial state
        System.assertEquals(null, testAccount.Bump_Date_Time__c, 'Bump_Date_Time__c should initially be null');
        
        // Create batch instance
        Set<Id> accountIdSet = new Set<Id>{testAccount.Id};
        AccountBumpBatch batch = new AccountBumpBatch(accountIdSet);
        
        // Record time JUST before execution
        DateTime beforeExecution = DateTime.now().addSeconds(-1);
        
        Test.startTest();
        // Call execute method directly (not executeBatch)
        batch.execute(null, new List<Account>{testAccount});
        Test.stopTest();
        
        // Query fresh from database
        Account updatedAccount = [SELECT Id, Bump_Date_Time__c FROM Account WHERE Id = :testAccount.Id];
        
        System.assertNotEquals(null, updatedAccount.Bump_Date_Time__c, 'Bump_Date_Time__c should be updated');
        System.assert(updatedAccount.Bump_Date_Time__c >= beforeExecution, 
            'Bump_Date_Time__c should be recent. Expected >= ' + beforeExecution + ', got ' + updatedAccount.Bump_Date_Time__c);
    }
}