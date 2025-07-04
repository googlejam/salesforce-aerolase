@isTest
public class AccountBumpUpdaterTest {
    
    @testSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 250; i++) {
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
    static void testBatchAccountBumpDateTime_Success() {
        // Get test accounts
        List<Account> testAccounts = [SELECT Id, Bump_Date_Time__c FROM Account LIMIT 50];
        
        // Verify Bump_Date_Time__c is initially null
        for(Account account : testAccounts) {
            System.assertEquals(null, account.Bump_Date_Time__c, 'Bump_Date_Time__c should initially be null');
        }
        
        // Create request
        AccountBumpUpdater.Request request = new AccountBumpUpdater.Request();
        request.accountRecords = testAccounts;
        List<AccountBumpUpdater.Request> requests = new List<AccountBumpUpdater.Request>{request};
        
        Test.startTest();
        // Call the method
        List<String> results = AccountBumpUpdater.batchAccountBumpDateTime(requests);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result message');
        System.assert(results[0].contains('Started batch job for 50 accounts'), 'Should confirm batch job started: ' + results[0]);
        
        // Verify accounts were updated by the batch job
        List<Account> updatedAccounts = [SELECT Id, Bump_Date_Time__c FROM Account WHERE Id IN :testAccounts];
        
        for(Account updatedAccount : updatedAccounts) {
            System.assertNotEquals(null, updatedAccount.Bump_Date_Time__c, 'Bump_Date_Time__c should not be null after batch update');
        }
    }
    
    @isTest
    static void testBatchAccountBumpDateTime_SingleAccount() {
        // Get single test account
        Account testAccount = [SELECT Id, Bump_Date_Time__c FROM Account LIMIT 1];
        
        // Create request with single account
        AccountBumpUpdater.Request request = new AccountBumpUpdater.Request();
        request.accountRecords = new List<Account>{testAccount};
        List<AccountBumpUpdater.Request> requests = new List<AccountBumpUpdater.Request>{request};
        
        Test.startTest();
        List<String> results = AccountBumpUpdater.batchAccountBumpDateTime(requests);
        Test.stopTest();
        
        // Verify batch job was started
        System.assertEquals(1, results.size(), 'Should return one result message');
        System.assert(results[0].contains('Started batch job for 1 accounts'), 'Should confirm batch job started for single account: ' + results[0]);
        
        // Verify single account was updated
        Account updatedAccount = [SELECT Id, Bump_Date_Time__c FROM Account WHERE Id = :testAccount.Id];
        System.assertNotEquals(null, updatedAccount.Bump_Date_Time__c, 'Single account should have Bump_Date_Time__c updated');
    }
    
    @isTest
    static void testBatchAccountBumpDateTime_EmptyList() {
        // Create request with empty list
        AccountBumpUpdater.Request request = new AccountBumpUpdater.Request();
        request.accountRecords = new List<Account>();
        List<AccountBumpUpdater.Request> requests = new List<AccountBumpUpdater.Request>{request};
        
        Test.startTest();
        List<String> results = AccountBumpUpdater.batchAccountBumpDateTime(requests);
        Test.stopTest();
        
        // Should handle empty list gracefully
        System.assertEquals(1, results.size(), 'Should return one result message');
        System.assert(results[0].contains('Started batch job for 0 accounts'), 'Should handle empty list: ' + results[0]);
    }
    
    @isTest
    static void testBatchAccountBumpDateTime_LargeVolume() {
        // Get larger number of accounts
        List<Account> testAccounts = [SELECT Id, Bump_Date_Time__c FROM Account LIMIT 200];
        
        // Create request
        AccountBumpUpdater.Request request = new AccountBumpUpdater.Request();
        request.accountRecords = testAccounts;
        List<AccountBumpUpdater.Request> requests = new List<AccountBumpUpdater.Request>{request};
        
        Test.startTest();
        List<String> results = AccountBumpUpdater.batchAccountBumpDateTime(requests);
        Test.stopTest();
        
        // Verify batch job handles large volume
        System.assertEquals(1, results.size(), 'Should return one result message');
        System.assert(results[0].contains('Started batch job for 200 accounts'), 'Should handle large volume: ' + results[0]);
        
        // Verify all accounts were updated
        List<Account> updatedAccounts = [SELECT Id, Bump_Date_Time__c FROM Account WHERE Id IN :testAccounts];
        System.assertEquals(200, updatedAccounts.size(), 'Should have 200 updated accounts');
        
        for(Account updatedAccount : updatedAccounts) {
            System.assertNotEquals(null, updatedAccount.Bump_Date_Time__c, 'Each account should have Bump_Date_Time__c updated');
        }
    }
    
    @isTest
    static void testRequest_ClassCoverage() {
        // Test the inner Request class for complete coverage
        AccountBumpUpdater.Request request = new AccountBumpUpdater.Request();
        
        // Create a test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Website = 'www.website.com',
            Description = 'Apex Test Class'
        );
        insert testAccount;
        
        // Set the accountRecords property
        request.accountRecords = new List<Account>{testAccount};
        
        // Verify the property was set
        System.assertEquals(1, request.accountRecords.size(), 'Request should contain one account record');
        System.assertEquals(testAccount.Id, request.accountRecords[0].Id, 'Request should contain the correct account');
    }
}