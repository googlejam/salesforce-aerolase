/**
 * @description Main Invocable Apex Class Lead Record Bumper - Flow Integration
 * @author Glenn Goodman | 678-557-7562 | salesforce@procetra.com
 * @date 2025
 */
public class LeadBumpUpdater {
    
    @InvocableMethod(label='Batch Lead Bump Date Time Update')
    public static List<String> batchLeadBumpDateTime(List<Request> requests) {
        Request req = requests[0];
        List<String> results = new List<String>();
        
        try {
            // Extract lead IDs
            Set<Id> leadIdSet = new Set<Id>();
            for(Lead leadRecord : req.leadRecords) {
                leadIdSet.add(leadRecord.Id);
            }
            
            // Start batch job
            LeadBumpBatch batchJob = new LeadBumpBatch(leadIdSet);
            Database.executeBatch(batchJob, 200);
            
            results.add('Started batch job for ' + leadIdSet.size() + ' leads');
            return results;
            
        } catch(Exception e) {
            results.add('Error starting batch: ' + e.getMessage());
            return results;
        }
    }
    
    public class Request {
        @InvocableVariable(required=true label='Lead Records')
        public List<Lead> leadRecords;
    }
}