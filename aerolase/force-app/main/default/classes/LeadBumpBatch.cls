public class LeadBumpBatch implements Database.Batchable<sObject> {
    private Set<Id> leadIds;
    
    public LeadBumpBatch(Set<Id> leadIds) {
        this.leadIds = leadIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Lead WHERE Id IN :leadIds]);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        List<Lead> leadsToUpdate = new List<Lead>();
        DateTime currentDateTime = DateTime.now();
        
        for(Lead lead : scope) {
            lead.Bump_Date_Time__c = currentDateTime;
            leadsToUpdate.add(lead);
        }
        
        update leadsToUpdate;
    }
    
    public void finish(Database.BatchableContext bc) {
        // Optional: Add completion logic here
    }
}