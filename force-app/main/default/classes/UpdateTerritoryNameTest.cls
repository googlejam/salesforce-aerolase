@isTest
public class UpdateTerritoryNameTest {
    
    @isTest
    static void testInsertTrigger() {
        // Test the 'before insert' logic
        Territory__c newTerritory = new Territory__c(Name = 'Test Territory');
        
        Test.startTest();
        insert newTerritory;
        Test.stopTest();
        
        // Fetch the inserted Territory__c record
        Territory__c insertedTerritory = [SELECT Name, Territory_Name_Formula__c FROM Territory__c WHERE Id = :newTerritory.Id LIMIT 1];
        
        // Assert that the Name field was set correctly during insert
        System.assertEquals(insertedTerritory.Territory_Name_Formula__c , insertedTerritory.Name, 'The Name field should match the Territory_Name_Formula__c field on insert.');
    }
    
    @isTest
    static void testUpdateTrigger() {
        // Create a Territory__c record for the 'before update' logic
        Territory__c territoryToUpdate = new Territory__c(Name = 'Original Territory');
        insert territoryToUpdate;
        
        // Update the Territory_Name_Formula__c field
        territoryToUpdate.Name = 'Updated Territory';
        
        Test.startTest();
        update territoryToUpdate;
        Test.stopTest();
        
        // Fetch the updated Territory__c record
        Territory__c updatedTerritory = [SELECT Name, Territory_Name_Formula__c FROM Territory__c WHERE Id = :territoryToUpdate.Id LIMIT 1];
        
        // Assert that the Name field was updated correctly
        System.assertEquals(updatedTerritory.Territory_Name_Formula__c, updatedTerritory.Name, 'The Name field should match the updated Territory_Name_Formula__c field.');
    }
}