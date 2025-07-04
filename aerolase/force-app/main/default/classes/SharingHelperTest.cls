@istest
public class SharingHelperTest {
     @istest
    public static void testmethod_01(){
        contact l = new contact ();
        l.LastName = 'test';
        l.email = 'test@gmail.com';
        l.Secondary_Contact_Owner__c = UserInfo.getUserId();
        insert l;
        SharingHelper.createShareRecord(null,UserInfo.getUserId(),'ContactShare',l.Id,'Edit','Manual');
        SharingHelper.createShareRecord(null,UserInfo.getUserId(),'AccountShare',l.Id,'Edit','Manual');
        SharingHelper.createShareRecord(null,UserInfo.getUserId(),'LeadShare',l.Id,'Edit','Manual');

    }

}