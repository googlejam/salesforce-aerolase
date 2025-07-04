/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-13-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class LeadTriggerHandler {

    public static void afterInsert(List<Lead> newList,Map<Id,Lead> oldMap){
        assignTerritoryToLead(newList,null);
        shareRecordWithRecOwnerSec(newList,null);
        removeShareRecordWithRecOwnerSec(newList,null);
    }

    public static void afterUpdate(List<Lead> newList,Map<Id,Lead> oldMap){
        assignTerritoryToLead(newList,oldMap);
        shareRecordWithRecOwnerSec(newList,oldMap);
        removeShareRecordWithRecOwnerSec(newList,oldMap);
    }
    
    public static void removeShareRecordWithRecOwnerSec(List<Lead> newList, Map<Id,Lead> oldMap){
        // System.debug('removeShareRecordWithRecOwnerSec');
        List<LeadShare> allExistingLeadShareList = new List<LeadShare>();
        List<LeadShare> deleteList = new List<LeadShare>();
        Set<String> userIdSet = new Set<String>();
        Set<String> leadRecIdSet = new Set<String>();
        Set<String> keySet = new Set<String>();

        for(Lead obj : newList){
            if( obj.Secondary_Lead_Owner__c == null && (oldMap != null && oldMap.get(obj.Id).Secondary_Lead_Owner__c != null )  ){
                userIdSet.add(oldMap.get(obj.Id).Secondary_Lead_Owner__c);
                leadRecIdSet.add(obj.Id);
                keySet.add(oldMap.get(obj.Id).Secondary_Lead_Owner__c+'-'+obj.Id);
            }
        }
        // System.debug('userIdSet'+userIdSet);
        // System.debug('leadRecIdSet'+leadRecIdSet);
        // System.debug('keySet'+keySet);
        
        allExistingLeadShareList = [SELECT Id,LeadId,LeadAccessLevel,UserOrGroupId FROM LeadShare WHERE UserOrGroupId IN:userIdSet AND LeadId IN:leadRecIdSet AND RowCause = 'Manual' ];

        for(LeadShare shareRec : allExistingLeadShareList){
            String key = shareRec.UserOrGroupId+'-'+shareRec.LeadId;
            if(keySet.contains(key)){
                deleteList.add(shareRec);
            }
        }
        
        delete deleteList;
		
    }
    
    public static void shareRecordWithRecOwnerSec(List<Lead> newList, Map<Id,Lead> oldMap){
        // System.debug('shareRecordWithRecOwnerSec');
        List<LeadShare> allExistingAccountShareList = new List<LeadShare>();
        Map<String,List<String>> userIdToAccIdList = new  Map<String,List<String>>();
        Map<String,List<LeadShare>> userIdToAllShareRecList = new Map<String,List<LeadShare>>();
        List<SObject> shareRecInsertList = new List<SObject>();

        for(Lead obj : newList){
            if(obj.Secondary_Lead_Owner__c != null && ( (oldMap == null) || (oldMap != null && oldMap.get(obj.Id).Secondary_Lead_Owner__c != obj.Secondary_Lead_Owner__c) ) ){
                String key = obj.Secondary_Lead_Owner__c;
                if( ( !userIdToAccIdList.isEmpty() && userIdToAccIdList.containsKey(key)) ){
                    List<String> tempAccIdsList = userIdToAccIdList.get(key);
                    tempAccIdsList.add(obj.Id);
                    userIdToAccIdList.put(key,tempAccIdsList);

                }else{
                    userIdToAccIdList.put(key,new List<String>{obj.Id});
                }
            }
        }
        
		// System.debug('userIdToAccIdList'+userIdToAccIdList);
        
        allExistingAccountShareList = [SELECT Id,LeadId,LeadAccessLevel,UserOrGroupId FROM LeadShare WHERE UserOrGroupId IN:userIdToAccIdList.keySet() ];
        
        // System.debug('allExistingAccountShareList'+allExistingAccountShareList);
        
        for(LeadShare shareRec : allExistingAccountShareList){
            String key = shareRec.UserOrGroupId;
            if(( !userIdToAllShareRecList.isEmpty() && userIdToAllShareRecList.containsKey(key)) ){
                List<LeadShare> tempShareList = userIdToAllShareRecList.get(key);
                tempShareList.add(shareRec);
                userIdToAllShareRecList.put(key,tempShareList);

            }else{
                userIdToAllShareRecList.put(key,new List<LeadShare>{shareRec});
            }
        }
        
        // System.debug('userIdToAllShareRecList'+userIdToAllShareRecList);

        for(String userId : userIdToAccIdList.keySet()){
            List<LeadShare> existingAccountShareList = new List<LeadShare>();
            Map<String,LeadShare> accIdToexistingAccountShareMap = new Map<String,LeadShare>();
            if(!userIdToAllShareRecList.isEmpty() && userIdToAllShareRecList.containsKey(userId)){
                existingAccountShareList = userIdToAllShareRecList.get(userId);
            }
            //Populating  Map to store existing share records with parentRecordId as key - start
            for(LeadShare shareRec : existingAccountShareList){
                String key = shareRec.LeadId+'-'+shareRec.UserOrGroupId;
                accIdToexistingAccountShareMap.put(key,shareRec);
            }
            for(String accId : userIdToAccIdList.get(userId)){
                String key = accId+'-'+userId;
                //Populating List of AccountShare if no share record exists or accessLevel needs to updated
                if( (accIdToexistingAccountShareMap.isEmpty()) || (!accIdToexistingAccountShareMap.isEmpty() && ( (!accIdToexistingAccountShareMap.containsKey(key)) || (accIdToexistingAccountShareMap.containsKey(key) && accIdToexistingAccountShareMap.get(key).LeadAccessLevel == 'Read' ) ) ) ){
                    Id shareRecId = !accIdToexistingAccountShareMap.isEmpty() && accIdToexistingAccountShareMap.containsKey(key) ? accIdToexistingAccountShareMap.get(key).Id : null ;
                    // System.debug('shareRecId '+shareRecId);
                    // System.debug('userId '+userId);
                    // System.debug('accId '+accId);
                    shareRecInsertList.add(SharingHelper.createShareRecord(shareRecId,userId,'LeadShare',accId,'Edit','Manual'));
                }
            }
        }
       
        //System.debug('shareRecInsertList'+shareRecInsertList);
        
        upsert shareRecInsertList;
    }

    public static void assignTerritoryToLead(List<Lead> newList,Map<Id,Lead> oldMap){
        //System.debug('assignTerritoryToLead ');
        CustomTerritoryController.fetchRulesData();
        for(Lead leadObj : newList){
            //System.debug('22 leadObj '+leadObj);
            if( (oldMap == null) || (oldMap != null && ( oldMap.get(leadObj.Id).State != leadObj.State ||  oldMap.get(leadObj.Id).Country != leadObj.Country ||  oldMap.get(leadObj.Id).PostalCode != leadObj.PostalCode ||  oldMap.get(leadObj.Id).Name != leadObj.Name ||  oldMap.get(leadObj.Id).Second_Lead_Source__c != leadObj.Second_Lead_Source__c ||  oldMap.get(leadObj.Id).City != leadObj.City ) )){
                //System.debug('24 leadObj '+leadObj);
                CustomTerritoryController.assignLead(leadObj);
                CustomTerritoryController.customTerritoryCalculation();
                CustomTerritoryController.assigneInsertTerritoryRec();
            }
            
        }
        CustomTerritoryController.deleteCheck = true;
        CustomTerritoryController.insertAssignedTerritory();
        CustomTerritoryController.deleteCheck = false;
    }
    
    public static void getduplicateDeletedLead(list<lead> leadList){
         // system.debug('leadList='+leadList);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string[] to = new string[] {System.Label.email}; 
            email.setToAddresses(to);
        email.setSubject('Duplicate lead deleted from salesforce');
        string body1 = System.Label.emailBody +', <br/><br/>This email confirms the merge of Lead in Salesforce.<br/>For your reference here are the details to the deleted records during the process<br/><br/> ';
        string body2 = '';
        for(lead l : leadList){
            body2 = body2 +'<br/>'+l.Firstname+' '+l.Lastname +'&nbsp;'+':'+'&nbsp;'+System.Label.baseUrl+'Lead/'+l.id+'/view';
        }
        string body3 = '<br/> <br/> This is a system generated email.';
        string completeBody = body1+body2+body3;
        //system.debug('completeEmail='+email);
        email.setHtmlBody(completeBody);
        try{
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {email};	
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            // system.debug('@@@results='+results);
            if (results[0].success) {
                //System.debug('The email was sent successfully.');
            } else {
                //System.debug('The email failed to send: '
                    //  + results[0].errors[0].message);
            }
        }catch(exception e){
            //system.debug('Error='+e.getMessage());
            
        }
        
    }
    public static void deleteValidation(list<lead> leadList){
        //system.debug('leadList='+leadList);
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        for(lead l: leadList){  
            //system.debug(l);
            if(l.MasterRecordId == null && profileName !='System Administrator'){
                l.adderror(System.Label.Lead_Error_Message );
            }
        }
        
    }
    
}