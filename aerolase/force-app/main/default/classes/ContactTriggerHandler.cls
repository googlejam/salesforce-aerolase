public class ContactTriggerHandler {
    public static void getduplicateDeletedContact(list<contact> conList){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string[] to = new string[] {System.Label.email}; 
            email.setToAddresses(to);
        email.setSubject('Duplicate contact deleted from salesforce');
        string body1 = System.Label.emailBody+', <br/><br/>This email confirms the merge of contact in Salesforce.<br/>For your reference here are the details to the deleted records during the process<br/><br/> ';
        string body2 = '';
        for(contact  con : conList){
            body2 = body2 +'<br/>'+con.Firstname+' '+con.Lastname +'&nbsp;'+':'+'&nbsp;'+System.Label.baseUrl+'Contact/'+con.id+'/view';
        }
        string body3 = '<br/> <br/> This is a system generated email.';
        string completeBody = body1+body2+body3;
        system.debug('completeBody='+completeBody);
        email.setHtmlBody(completeBody);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            system.debug('Error='+e.getMessage());
            
        }
        
    }
     public static void deleteValidation(list<contact> contactList){
        system.debug('leadList='+contactList);
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        for(contact l: contactList){  
            system.debug(l);
            if(l.MasterRecordId == null && profileName !='System Administrator'){
                l.adderror(System.Label.contact_error_message);
            }
        }
        
    }
    
     public static void afterInsert(List<Contact> newList, Map<Id,Contact> oldMap){
      shareRecordWithRecOwnerSec(newList,null);
      removeShareRecordWithRecOwnerSec(newList,null);
    }

    public static void afterUpdate(List<Contact> newList, Map<Id,Contact> oldMap){
      shareRecordWithRecOwnerSec(newList,oldMap);
      removeShareRecordWithRecOwnerSec(newList,oldMap);
    }
    
    public static void removeShareRecordWithRecOwnerSec(List<Contact> newList, Map<Id,Contact> oldMap){
        System.debug('removeShareRecordWithRecOwnerSec');
        List<ContactShare> allExistingConShareList = new List<ContactShare>();
        List<ContactShare> deleteList = new List<ContactShare>();
        Set<String> userIdSet = new Set<String>();
        Set<String> conRecIdSet = new Set<String>();
        Set<String> keySet = new Set<String>();

        for(Contact obj : newList){
            if( obj.Secondary_Contact_Owner__c == null && (oldMap != null && oldMap.get(obj.Id).Secondary_Contact_Owner__c != null )  ){
                userIdSet.add(oldMap.get(obj.Id).Secondary_Contact_Owner__c);
                conRecIdSet.add(obj.Id);
                keySet.add(oldMap.get(obj.Id).Secondary_Contact_Owner__c+'-'+obj.Id);
            }
        }
        
        allExistingConShareList = [SELECT Id,ContactId,ContactAccessLevel,UserOrGroupId FROM ContactShare WHERE UserOrGroupId IN:userIdSet AND ContactId IN:conRecIdSet AND RowCause = 'Manual' ];

        for(ContactShare shareRec : allExistingConShareList){
            String key = shareRec.UserOrGroupId+'-'+shareRec.ContactId;
            if(keySet.contains(key)){
                deleteList.add(shareRec);
            }
        }
        
		delete deleteList;
    }
    
    public static void shareRecordWithRecOwnerSec(List<Contact> newList, Map<Id,Contact> oldMap){
        System.debug('shareRecordWithRecOwnerSec');
        List<ContactShare> allExistingAccountShareList = new List<ContactShare>();
        Map<String,List<String>> userIdToAccIdList = new  Map<String,List<String>>();
        Map<String,List<ContactShare>> userIdToAllShareRecList = new Map<String,List<ContactShare>>();
        List<SObject> shareRecInsertList = new List<SObject>();

        for(Contact obj : newList){
            if(obj.Secondary_Contact_Owner__c != null && ( (oldMap == null) || (oldMap != null && oldMap.get(obj.Id).Secondary_Contact_Owner__c != obj.Secondary_Contact_Owner__c) ) ){
                String key = obj.Secondary_Contact_Owner__c;
                if( ( !userIdToAccIdList.isEmpty() && userIdToAccIdList.containsKey(key)) ){
                    List<String> tempAccIdsList = userIdToAccIdList.get(key);
                    tempAccIdsList.add(obj.Id);
                    userIdToAccIdList.put(key,tempAccIdsList);

                }else{
                    userIdToAccIdList.put(key,new List<String>{obj.Id});
                }
            }
        }
        
		System.debug('userIdToAccIdList'+userIdToAccIdList);
        
        allExistingAccountShareList = [SELECT Id,ContactId,ContactAccessLevel,UserOrGroupId FROM ContactShare WHERE UserOrGroupId IN:userIdToAccIdList.keySet() ];
        
        System.debug('allExistingAccountShareList'+allExistingAccountShareList);
        
        for(ContactShare shareRec : allExistingAccountShareList){
            String key = shareRec.UserOrGroupId;
            if(( !userIdToAllShareRecList.isEmpty() && userIdToAllShareRecList.containsKey(key)) ){
                List<ContactShare> tempShareList = userIdToAllShareRecList.get(key);
                tempShareList.add(shareRec);
                userIdToAllShareRecList.put(key,tempShareList);

            }else{
                userIdToAllShareRecList.put(key,new List<ContactShare>{shareRec});
            }
        }
        
        System.debug('userIdToAllShareRecList'+userIdToAllShareRecList);

        for(String userId : userIdToAccIdList.keySet()){
            List<ContactShare> existingAccountShareList = new List<ContactShare>();
            Map<String,ContactShare> accIdToexistingAccountShareMap = new Map<String,ContactShare>();
            if(!userIdToAllShareRecList.isEmpty() && userIdToAllShareRecList.containsKey(userId)){
                existingAccountShareList = userIdToAllShareRecList.get(userId);
            }
            //Populating  Map to store existing share records with parentRecordId as key - start
            for(ContactShare shareRec : existingAccountShareList){
                String key = shareRec.ContactId+'-'+shareRec.UserOrGroupId;
                accIdToexistingAccountShareMap.put(key,shareRec);
            }
            for(String accId : userIdToAccIdList.get(userId)){
                String key = accId+'-'+userId;
                //Populating List of AccountShare if no share record exists or accessLevel needs to updated
                if( (accIdToexistingAccountShareMap.isEmpty()) || (!accIdToexistingAccountShareMap.isEmpty() && ( (!accIdToexistingAccountShareMap.containsKey(key)) || (accIdToexistingAccountShareMap.containsKey(key) && accIdToexistingAccountShareMap.get(key).ContactAccessLevel == 'Read' ) ) ) ){
                    Id shareRecId = !accIdToexistingAccountShareMap.isEmpty() && accIdToexistingAccountShareMap.containsKey(key) ? accIdToexistingAccountShareMap.get(key).Id : null ;
                    System.debug('shareRecId '+shareRecId);
                    System.debug('userId '+userId);
                    System.debug('accId '+accId);
                    shareRecInsertList.add(SharingHelper.createShareRecord(shareRecId,userId,'ContactShare',accId,'Edit','Manual'));
                }
            }
        }
       
        System.debug('shareRecInsertList'+shareRecInsertList);
        
        upsert shareRecInsertList;
    }

    
}