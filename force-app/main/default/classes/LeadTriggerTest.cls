@istest
public class LeadTriggerTest {
    @testSetup
    public static void testSetup(){
        
        
        Territory2Model t2m = new Territory2Model();
        t2m.Name = 'TEST';
        t2m.DeveloperName = 'TEST';
        insert t2m;
        
    }
    @istest
    public static void testmethod_01(){
        lead l = new Lead ();
        l.LastName = 'test';
        l.email = 'test@gmail.com';
        l.Company = 'test';
        l.Secondary_Lead_Owner__c = UserInfo.getUserId();
        insert l;
        
        lead l2 = new Lead ();
        l2.LastName = 'test';
        l2.email = 'test2@gmail.com';  
        l2.Company = 'test2';
        l2.Secondary_Lead_Owner__c = UserInfo.getUserId();
        insert l2;
        
        
        lead l4 = new Lead ();
        l4.LastName = 'test';
        l4.email = 'test4@gmail.com';
        l4.Company = 'test4';
        l4.Secondary_Lead_Owner__c = UserInfo.getUserId();
        
        lead l3 = new Lead ();
        l3.LastName = 'test';
        l3.email = 'test3@gmail.com';  
        l3.Company = 'test3';
        l3.Secondary_Lead_Owner__c = UserInfo.getUserId();
        
		insert new List<lead>{l3,l4};        
        
        
        Database.merge(l, l2, false);
    }
    
}