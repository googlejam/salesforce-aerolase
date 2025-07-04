@isTest
public class LeadBumpUpdaterTest {
    
    @testSetup
    static void setupTestData() {
        // Create test leads
        List<Lead> testLeads = new List<Lead>();
        for(Integer i = 0; i < 250; i++) {
            Lead testLead = new Lead(
                FirstName = 'Test',
                LastName = 'Lead ' + i,
                Company = 'Test Company ' + i,
                Email = 'testlead' + i + '@test.com',
                Status = 'Open - Not Contacted'
            );
            testLeads.add(testLead);
        }
        insert testLeads;
    }
    
    @isTest
    static void testBatchLeadBumpDateTime_Success() {
        // Get test leads
        List<Lead> testLeads = [SELECT Id, Bump_Date_Time__c FROM Lead LIMIT 50];
        
        // Verify Bump_Date_Time__c is initially null
        for(Lead lead : testLeads) {
            System.assertEquals(null, lead.Bump_Date_Time__c, 'Bump_Date_Time__c should initially be null');
        }
        
        // Create request
        LeadBumpUpdater.Request request = new LeadBumpUpdater.Request();
        request.leadRecords = testLeads;
        List<LeadBumpUpdater.Request> requests = new List<LeadBumpUpdater.Request>{request};
        
        Test.startTest();
        // Call the method
        List<String> results = LeadBumpUpdater.batchLeadBumpDateTime(requests);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result message');
        System.assert(results[0].contains('Started batch job for 50 leads'), 'Should confirm batch job started: ' + results[0]);
        
        // Verify leads were updated by the batch job
        List<Lead> updatedLeads = [SELECT Id, Bump_Date_Time__c FROM Lead WHERE Id IN :testLeads];
        
        for(Lead updatedLead : updatedLeads) {
            System.assertNotEquals(null, updatedLead.Bump_Date_Time__c, 'Bump_Date_Time__c should not be null after batch update');
        }
    }
    
    @isTest
    static void testBatchLeadBumpDateTime_SingleLead() {
        // Get single test lead
        Lead testLead = [SELECT Id, Bump_Date_Time__c FROM Lead LIMIT 1];
        
        // Create request with single lead
        LeadBumpUpdater.Request request = new LeadBumpUpdater.Request();
        request.leadRecords = new List<Lead>{testLead};
        List<LeadBumpUpdater.Request> requests = new List<LeadBumpUpdater.Request>{request};
        
        Test.startTest();
        List<String> results = LeadBumpUpdater.batchLeadBumpDateTime(requests);
        Test.stopTest();
        
        // Verify batch job was started
        System.assertEquals(1, results.size(), 'Should return one result message');
        System.assert(results[0].contains('Started batch job for 1 leads'), 'Should confirm batch job started for single lead: ' + results[0]);
        
        // Verify single lead was updated
        Lead updatedLead = [SELECT Id, Bump_Date_Time__c FROM Lead WHERE Id = :testLead.Id];
        System.assertNotEquals(null, updatedLead.Bump_Date_Time__c, 'Single lead should have Bump_Date_Time__c updated');
    }
    
    @isTest
    static void testBatchLeadBumpDateTime_EmptyList() {
        // Create request with empty list
        LeadBumpUpdater.Request request = new LeadBumpUpdater.Request();
        request.leadRecords = new List<Lead>();
        List<LeadBumpUpdater.Request> requests = new List<LeadBumpUpdater.Request>{request};
        
        Test.startTest();
        List<String> results = LeadBumpUpdater.batchLeadBumpDateTime(requests);
        Test.stopTest();
        
        // Should handle empty list gracefully
        System.assertEquals(1, results.size(), 'Should return one result message');
        System.assert(results[0].contains('Started batch job for 0 leads'), 'Should handle empty list: ' + results[0]);
    }
    
    @isTest
    static void testBatchLeadBumpDateTime_LargeVolume() {
        // Get larger number of leads
        List<Lead> testLeads = [SELECT Id, Bump_Date_Time__c FROM Lead LIMIT 200];
        
        // Create request
        LeadBumpUpdater.Request request = new LeadBumpUpdater.Request();
        request.leadRecords = testLeads;
        List<LeadBumpUpdater.Request> requests = new List<LeadBumpUpdater.Request>{request};
        
        Test.startTest();
        List<String> results = LeadBumpUpdater.batchLeadBumpDateTime(requests);
        Test.stopTest();
        
        // Verify batch job handles large volume
        System.assertEquals(1, results.size(), 'Should return one result message');
        System.assert(results[0].contains('Started batch job for 200 leads'), 'Should handle large volume: ' + results[0]);
        
        // Verify all leads were updated
        List<Lead> updatedLeads = [SELECT Id, Bump_Date_Time__c FROM Lead WHERE Id IN :testLeads];
        System.assertEquals(200, updatedLeads.size(), 'Should have 200 updated leads');
        
        for(Lead updatedLead : updatedLeads) {
            System.assertNotEquals(null, updatedLead.Bump_Date_Time__c, 'Each lead should have Bump_Date_Time__c updated');
        }
    }
    
    @isTest
    static void testRequest_ClassCoverage() {
        // Test the inner Request class for complete coverage
        LeadBumpUpdater.Request request = new LeadBumpUpdater.Request();
        
        // Create a test lead
        Lead testLead = new Lead(
            FirstName = 'Coverage',
            LastName = 'Test',
            Company = 'Coverage Company',
            Email = 'coverage@test.com',
            Status = 'Open - Not Contacted'
        );
        insert testLead;
        
        // Set the leadRecords property
        request.leadRecords = new List<Lead>{testLead};
        
        // Verify the property was set
        System.assertEquals(1, request.leadRecords.size(), 'Request should contain one lead record');
        System.assertEquals(testLead.Id, request.leadRecords[0].Id, 'Request should contain the correct lead');
    }
}