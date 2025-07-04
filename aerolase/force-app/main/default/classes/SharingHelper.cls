/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-14-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class SharingHelper {

    public static SObject createShareRecord(String shareRecId,String userId, String objectName, String recordId, String accessLevel, String reason)
    {
        Schema.SObjectType shareType = Schema.getGlobalDescribe().get(objectName);
        SObject shareObj = shareType.newSObject();
        if(objectName == 'AccountShare'){
            shareObj.put('AccountId', recordId);
            shareObj.put('AccountAccessLevel', accessLevel);
            shareObj.put('OpportunityAccessLevel', 'Read');
            shareObj.put('CaseAccessLevel', 'Read');
        }else if(objectName == 'LeadShare'){
            shareObj.put('LeadId', recordId);
            shareObj.put('LeadAccessLevel', accessLevel);
        }else if(objectName == 'ContactShare'){
            shareObj.put('ContactId', recordId);
            shareObj.put('ContactAccessLevel', accessLevel);
        }/*else{
            shareObj.put('ParentId', recordId);
            shareObj.put('AccessLevel', accessLevel);
        }*/
        shareObj.put('UserOrGroupId', userId);
        shareObj.put('RowCause', reason);

        if(shareRecId != null && !String.isEmpty(shareRecId)){
        shareObj.put('Id', shareRecId);
        }
        return shareObj;         
        
    }
}