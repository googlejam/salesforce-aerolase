public class LeadBumper {
    
    @InvocableMethod(label='Update Lead Bump Date Time')
    public static void updateLeadBumpDateTime(List<Request> requests) {
        Request req = requests[0];
        
        List<Lead> leadsToUpdate = new List<Lead>();
        DateTime currentDateTime = DateTime.now();
        
        for(Lead leadRecord : req.leadRecords) {
            Lead leadToUpdate = new Lead();
            leadToUpdate.Id = leadRecord.Id;
            leadToUpdate.Bump_Date_Time__c = currentDateTime;
            leadsToUpdate.add(leadToUpdate);
        }
        
        update leadsToUpdate;
    }
    
    public class Request {
        @InvocableVariable(required=true label='Lead Records' description='Collection of Lead records to update')
        public List<Lead> leadRecords;
    }
}