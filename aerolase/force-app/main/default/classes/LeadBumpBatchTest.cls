@isTest
public class LeadBumpBatchTest {
    
    @testSetup
    static void setupTestData() {
        // Create test leads for batch testing
        List<Lead> testLeads = new List<Lead>();
        for(Integer i = 0; i < 50; i++) { // Reduced number for testing
            Lead testLead = new Lead(
                FirstName = 'Batch',
                LastName = 'Lead ' + i,
                Company = 'Batch Company ' + i,
                Email = 'batchlead' + i + '@test.com',
                Status = 'Open - Not Contacted'
            );
            testLeads.add(testLead);
        }
        insert testLeads;
    }
    
    @isTest
    static void testLeadBumpBatch_FullExecution() {
        // Get test leads - use exact batch size to avoid multiple executions
        List<Lead> testLeads = [SELECT Id, Bump_Date_Time__c FROM Lead LIMIT 10];
        
        // Verify initial state
        for(Lead lead : testLeads) {
            System.assertEquals(null, lead.Bump_Date_Time__c, 'Bump_Date_Time__c should initially be null');
        }
        
        // Create set of lead IDs
        Set<Id> leadIdSet = new Set<Id>();
        for(Lead lead : testLeads) {
            leadIdSet.add(lead.Id);
        }
        
        // Create and execute batch with batch size equal to record count
        LeadBumpBatch batch = new LeadBumpBatch(leadIdSet);
        
        Test.startTest();
        Database.executeBatch(batch, 10); // Same as record count
        Test.stopTest();
        
        // Verify results
        List<Lead> updatedLeads = [SELECT Id, Bump_Date_Time__c FROM Lead WHERE Id IN :leadIdSet];
        
        System.assertEquals(10, updatedLeads.size(), 'Should have 10 updated leads');
        
        for(Lead updatedLead : updatedLeads) {
            System.assertNotEquals(null, updatedLead.Bump_Date_Time__c, 'Bump_Date_Time__c should not be null after batch execution');
        }
    }
    
    @isTest
    static void testLeadBumpBatch_StartMethod() {
        // Get test leads
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 5];
        
        // Create set of lead IDs
        Set<Id> leadIdSet = new Set<Id>();
        for(Lead lead : testLeads) {
            leadIdSet.add(lead.Id);
        }
        
        // Test start method
        LeadBumpBatch batch = new LeadBumpBatch(leadIdSet);
        
        Test.startTest();
        Database.QueryLocator queryLocator = batch.start(null);
        Test.stopTest();
        
        // Verify query locator is created
        System.assertNotEquals(null, queryLocator, 'QueryLocator should not be null');
    }
    
    @isTest
    static void testLeadBumpBatch_ExecuteMethod() {
        // Get test leads
        List<Lead> testLeads = [SELECT Id, Bump_Date_Time__c FROM Lead LIMIT 5];
        
        // Create set of lead IDs
        Set<Id> leadIdSet = new Set<Id>();
        for(Lead lead : testLeads) {
            leadIdSet.add(lead.Id);
        }
        
        // Create batch instance
        LeadBumpBatch batch = new LeadBumpBatch(leadIdSet);
        
        // Mock BatchableContext (null is acceptable for testing)
        Database.BatchableContext bc = null;
        
        Test.startTest();
        // Call execute method directly - this doesn't count as executeBatch
        batch.execute(bc, testLeads);
        Test.stopTest();
        
        // Verify leads were updated
        List<Lead> updatedLeads = [SELECT Id, Bump_Date_Time__c FROM Lead WHERE Id IN :leadIdSet];
        
        for(Lead updatedLead : updatedLeads) {
            System.assertNotEquals(null, updatedLead.Bump_Date_Time__c, 'Bump_Date_Time__c should be updated');
        }
    }
    
    @isTest
    static void testLeadBumpBatch_FinishMethod() {
        // Create batch instance
        Set<Id> emptySet = new Set<Id>();
        LeadBumpBatch batch = new LeadBumpBatch(emptySet);
        
        // Test finish method (should not throw exception)
        Test.startTest();
        batch.finish(null);
        Test.stopTest();
        
        // Test passes if no exception is thrown
        System.assert(true, 'Finish method should complete without error');
    }
    
    @isTest
    static void testLeadBumpBatch_SmallBatchExecution() {
        // Test with very small dataset - 1 record with batch size 1
        Lead testLead = [SELECT Id, Bump_Date_Time__c FROM Lead LIMIT 1];
        
        // Verify initial state
        System.assertEquals(null, testLead.Bump_Date_Time__c, 'Bump_Date_Time__c should initially be null');
        
        // Create set with single ID
        Set<Id> leadIdSet = new Set<Id>{testLead.Id};
        
        // Create and execute batch
        LeadBumpBatch batch = new LeadBumpBatch(leadIdSet);
        
        Test.startTest();
        Id batchId = Database.executeBatch(batch, 1); // 1 record, batch size 1
        Test.stopTest();
        
        // Verify batch job was created
        System.assertNotEquals(null, batchId, 'Batch job should be created');
        
        // Verify results
        Lead updatedLead = [SELECT Id, Bump_Date_Time__c FROM Lead WHERE Id = :testLead.Id];
        System.assertNotEquals(null, updatedLead.Bump_Date_Time__c, 'Bump_Date_Time__c should be updated after batch execution');
    }
    
    @isTest
    static void testLeadBumpBatch_EmptyIdSet() {
        // Test with empty ID set
        Set<Id> emptyIdSet = new Set<Id>();
        LeadBumpBatch batch = new LeadBumpBatch(emptyIdSet);
        
        Test.startTest();
        Id batchId = Database.executeBatch(batch, 1);
        Test.stopTest();
        
        // Should handle empty set gracefully
        System.assertNotEquals(null, batchId, 'Batch job should be created even with empty set');
    }
    
    @isTest
    static void testLeadBumpBatch_Constructor() {
        // Test constructor without executing batch
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 5];
        Set<Id> leadIdSet = new Set<Id>();
        for(Lead lead : testLeads) {
            leadIdSet.add(lead.Id);
        }
        
        // Create batch with constructor
        LeadBumpBatch batch = new LeadBumpBatch(leadIdSet);
        
        // Test that the batch was created successfully
        System.assertNotEquals(null, batch, 'Batch should be created successfully');
        
        // Test start method to verify leadIds were set correctly
        Database.QueryLocator queryLocator = batch.start(null);
        System.assertNotEquals(null, queryLocator, 'QueryLocator should be created');
    }
    
    @isTest
    static void testLeadBumpBatch_ThreeRecordExecution() {
        // Test with 3 records and batch size 3 to ensure single execution
        List<Lead> testLeads = [SELECT Id, Bump_Date_Time__c FROM Lead LIMIT 3];
        
        // Verify initial state
        for(Lead lead : testLeads) {
            System.assertEquals(null, lead.Bump_Date_Time__c, 'Bump_Date_Time__c should initially be null');
        }
        
        // Create set of lead IDs
        Set<Id> leadIdSet = new Set<Id>();
        for(Lead lead : testLeads) {
            leadIdSet.add(lead.Id);
        }
        
        // Create and execute batch
        LeadBumpBatch batch = new LeadBumpBatch(leadIdSet);
        
        Test.startTest();
        Database.executeBatch(batch, 3); // 3 records, batch size 3
        Test.stopTest();
        
        // Verify results
        List<Lead> updatedLeads = [SELECT Id, Bump_Date_Time__c FROM Lead WHERE Id IN :leadIdSet];
        
        for(Lead updatedLead : updatedLeads) {
            System.assertNotEquals(null, updatedLead.Bump_Date_Time__c, 'Lead should have Bump_Date_Time__c updated');
        }
    }
    
    @isTest
    static void testLeadBumpBatch_ExecuteMethodWithTiming() {
        // Create a fresh lead for timing test
        Lead testLead = new Lead(
            FirstName = 'Timing',
            LastName = 'Test',
            Company = 'Timing Company',
            Email = 'timing@test.com',
            Status = 'Open - Not Contacted'
        );
        insert testLead;
        
        // Query it back to get the inserted record
        testLead = [SELECT Id, Bump_Date_Time__c FROM Lead WHERE Id = :testLead.Id];
        
        // Verify initial state
        System.assertEquals(null, testLead.Bump_Date_Time__c, 'Bump_Date_Time__c should initially be null');
        
        // Create batch instance
        Set<Id> leadIdSet = new Set<Id>{testLead.Id};
        LeadBumpBatch batch = new LeadBumpBatch(leadIdSet);
        
        // Record time JUST before execution
        DateTime beforeExecution = DateTime.now().addSeconds(-1);
        
        Test.startTest();
        // Call execute method directly (not executeBatch)
        batch.execute(null, new List<Lead>{testLead});
        Test.stopTest();
        
        // Query fresh from database
        Lead updatedLead = [SELECT Id, Bump_Date_Time__c FROM Lead WHERE Id = :testLead.Id];
        
        System.assertNotEquals(null, updatedLead.Bump_Date_Time__c, 'Bump_Date_Time__c should be updated');
        System.assert(updatedLead.Bump_Date_Time__c >= beforeExecution, 
            'Bump_Date_Time__c should be recent. Expected >= ' + beforeExecution + ', got ' + updatedLead.Bump_Date_Time__c);
    }
}