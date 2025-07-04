trigger ContactTrigger on Contact (after insert,after update,after delete) {
    if(trigger.IsDelete){
        list<contact> contactList = new list<contact>();
        for(contact con: trigger.old){
            if(con.MasterRecordId !=null){
                contactList.add(con);
            }
        }
        if(!contactList.isEmpty()){
            ContactTriggerHandler.getduplicateDeletedContact(contactList);
        }
         ContactTriggerHandler.deleteValidation(trigger.old);
    }
    
    
    //After insert
    if(trigger.isAfter && trigger.isInsert){
        System.debug('afterInsert');
        ContactTriggerHandler.afterInsert(Trigger.new,Trigger.oldMap);
    } 

    //After update
    if(trigger.isAfter && trigger.isUpdate){
        System.debug('afterUpdate');
        ContactTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
    } 
}