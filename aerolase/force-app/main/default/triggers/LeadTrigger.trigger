/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-15-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger LeadTrigger on Lead (after insert, after update, after delete,before delete) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        LeadTriggerHandler.afterInsert(Trigger.new,Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        LeadTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
    }
    
    if(trigger.isDelete && trigger.isafter){
        list<lead> leadList = new list<lead>();
        for(lead l: trigger.old){
            if(l.MasterRecordId !=null){
                leadList.add(l);
            }
        }
         system.debug('leadList='+leadList);
        if(!leadList.isEmpty()){
            LeadTriggerHandler.getduplicateDeletedLead(leadList);
        }
    }
    if(trigger.isDelete && trigger.isafter){
        
      LeadTriggerHandler.deleteValidation(trigger.old);
        
    }
    
    
}