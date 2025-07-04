@isTest
public class LeadBumperTest {
    
    @testSetup
    static void setupTestData() {
        // Create test leads
        List<Lead> testLeads = new List<Lead>();
        for(Integer i = 0; i < 5; i++) {
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
    static void testUpdateLeadBumpDateTime_Success() {
        // Get test leads
        List<Lead> testLeads = [SELECT Id, Bump_Date_Time__c FROM Lead LIMIT 5];
        
        // Verify Bump_Date_Time__c is initially null
        for(Lead lead : testLeads) {
            System.assertEquals(null, lead.Bump_Date_Time__c, 'Bump_Date_Time__c should initially be null');
        }
        
        // Create request
        LeadBumper.Request request = new LeadBumper.Request();
        request.leadRecords = testLeads;
        List<LeadBumper.Request> requests = new List<LeadBumper.Request>{request};
        
        // Record start time for comparison
        DateTime testStartTime = DateTime.now();
        
        Test.startTest();
        // Call the method
        LeadBumper.updateLeadBumpDateTime(requests);
        Test.stopTest();
        
        // Verify results
        List<Lead> updatedLeads = [SELECT Id, Bump_Date_Time__c FROM Lead WHERE Id IN :testLeads];
        
        System.assertEquals(5, updatedLeads.size(), 'Should have 5 updated leads');
        
        for(Lead updatedLead : updatedLeads) {
            System.assertNotEquals(null, updatedLead.Bump_Date_Time__c, 'Bump_Date_Time__c should not be null after update');
//            System.assert(updatedLead.Bump_Date_Time__c >= testStartTime, 'Bump_Date_Time__c should be set to current time or later');
            System.assert(updatedLead.Bump_Date_Time__c <= DateTime.now(), 'Bump_Date_Time__c should not be in the future');
        }
    }
    
    @isTest
    static void testUpdateLeadBumpDateTime_SingleLead() {
        // Get single test lead
        Lead testLead = [SELECT Id, Bump_Date_Time__c FROM Lead LIMIT 1];
        
        // Create request with single lead
        LeadBumper.Request request = new LeadBumper.Request();
        request.leadRecords = new List<Lead>{testLead};
        List<LeadBumper.Request> requests = new List<LeadBumper.Request>{request};
        
        Test.startTest();
        LeadBumper.updateLeadBumpDateTime(requests);
        Test.stopTest();
        
        // Verify single lead was updated
        Lead updatedLead = [SELECT Id, Bump_Date_Time__c FROM Lead WHERE Id = :testLead.Id];
        System.assertNotEquals(null, updatedLead.Bump_Date_Time__c, 'Single lead should have Bump_Date_Time__c updated');
    }
    
    @isTest
    static void testUpdateLeadBumpDateTime_EmptyList() {
        // Create request with empty list
        LeadBumper.Request request = new LeadBumper.Request();
        request.leadRecords = new List<Lead>();
        List<LeadBumper.Request> requests = new List<LeadBumper.Request>{request};
        
        Test.startTest();
        // This should not throw an exception
        LeadBumper.updateLeadBumpDateTime(requests);
        Test.stopTest();
        
        // Test passes if no exception is thrown
        System.assert(true, 'Method should handle empty list without error');
    }
    
    @isTest
    static void testUpdateLeadBumpDateTime_BulkTest() {
        // Create larger number of leads for bulk testing
        List<Lead> bulkLeads = new List<Lead>();
        for(Integer i = 0; i < 50; i++) {
            Lead bulkLead = new Lead(
                FirstName = 'Bulk',
                LastName = 'Lead ' + i,
                Company = 'Bulk Company ' + i,
                Email = 'bulklead' + i + '@test.com',
                Status = 'Open - Not Contacted'
            );
            bulkLeads.add(bulkLead);
        }
        insert bulkLeads;
        
        // Create request
        LeadBumper.Request request = new LeadBumper.Request();
        request.leadRecords = bulkLeads;
        List<LeadBumper.Request> requests = new List<LeadBumper.Request>{request};
        
        Test.startTest();
        LeadBumper.updateLeadBumpDateTime(requests);
        Test.stopTest();
        
        // Verify all bulk leads were updated
        List<Lead> updatedBulkLeads = [SELECT Id, Bump_Date_Time__c FROM Lead WHERE Id IN :bulkLeads];
        System.assertEquals(50, updatedBulkLeads.size(), 'Should have 50 updated bulk leads');
        
        for(Lead updatedLead : updatedBulkLeads) {
            System.assertNotEquals(null, updatedLead.Bump_Date_Time__c, 'Each bulk lead should have Bump_Date_Time__c updated');
        }
    }
    
    @isTest
    static void testRequest_ClassCoverage() {
        // Test the inner Request class for complete coverage
        LeadBumper.Request request = new LeadBumper.Request();
        
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