trigger UpdateTerritoryName on Territory__c (before insert, before update) {
    for(Territory__c record : Trigger.new) {
        if(Trigger.isInsert) {
            // Set the Name field is created
            record.Name = record.Territory_Name_Formula__c;
        } else if(Trigger.isUpdate) {
            // Set the Name field when the record is updated
            record.Name = record.Territory_Name_Formula__c;
        }
    }
}