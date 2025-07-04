public class AccountBumpUpdater {
    
    @InvocableMethod(label='Batch Account Bump Date Time Update')
    public static List<String> batchAccountBumpDateTime(List<Request> requests) {
        Request req = requests[0];
        List<String> results = new List<String>();
        
        try {
            // Extract account IDs
            Set<Id> accountIdSet = new Set<Id>();
            for(Account accountRecord : req.accountRecords) {
                accountIdSet.add(accountRecord.Id);
            }
            
            // Start batch job
            AccountBumpBatch batchJob = new AccountBumpBatch(accountIdSet);
            Database.executeBatch(batchJob, 200);
            
            results.add('Started batch job for ' + accountIdSet.size() + ' accounts');
            return results;
            
        } catch(Exception e) {
            results.add('Error starting batch: ' + e.getMessage());
            return results;
        }
    }
    
    public class Request {
        @InvocableVariable(required=true label='Account Records')
        public List<Account> accountRecords;
    }
}