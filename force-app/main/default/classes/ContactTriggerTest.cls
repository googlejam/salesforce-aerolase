@istest
public class ContactTriggerTest {
     @istest
    public static void testmethod_01(){
        contact l = new contact ();
        l.LastName = 'test';
        l.email = 'test@gmail.com';
        l.Secondary_Contact_Owner__c = UserInfo.getUserId();
        insert l;
        l.Secondary_Contact_Owner__c = null;
        update l;
        
        contact l2 = new contact ();
        l2.LastName = 'test';
        l2.email = 'test2@gmail.com';  
        
        insert l2;
        
        contact l3 = new contact ();
        l3.LastName = 'test';
        l3.email = 'test3@gmail.com';
        l3.Secondary_Contact_Owner__c = UserInfo.getUserId();
          
        contact l4 = new contact ();
        l4.LastName = 'test';
        l4.email = 'test4@gmail.com';  
        l4.Secondary_Contact_Owner__c = UserInfo.getUserId();
        
        insert new List<contact>{l3,l4};
        
        Database.merge(l, l2, false);
    }

}