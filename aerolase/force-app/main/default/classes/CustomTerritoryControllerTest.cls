@isTest
public class CustomTerritoryControllerTest {
    
    @testSetup
    public static void testSetup(){
        
        
        Territory2Model t2m = new Territory2Model();
        t2m.Name = 'TEST';
        t2m.DeveloperName = 'TEST';
        insert t2m;
        
    }
    
    @istest
    public static void testmethod_01(){
        Test.startTest();
        lead l = new Lead ();
        l.LastName = 'test';
        l.email = 'test@gmail.com';
        l.Company = 'test';
        l.Country = 'United States';
        l.CountryCode = 'US';
        l.PostalCode = 	'93204';
        insert l;
        CustomTerritoryController.fetchRulesData();
        CustomTerritoryController.assignLead(l);
        CustomTerritoryController.customTerritoryCalculation();
        CustomTerritoryController.assigneInsertTerritoryRec();
        CustomTerritoryController.insertAssignedTerritory();
        Test.stopTest();
    }

}