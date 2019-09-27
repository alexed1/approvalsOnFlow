public with sharing class ApprovalLockActions {

    @InvocableMethod
    public static void execute(List<Requests> requests) {
        if (requests == null || requests.size() == 0 || (requests[0].objectId == null && requests[0].objectsIds == null)) {
            throw new LockErrorException('You need to populate either objectId or objectsIds in order to perform this action.');
        }

        if (requests[0].lockingAction == null) {
            throw new LockErrorException('lockingAction can not be empty.');
        }

        String lockingAction = requests[0].lockingAction.toLowerCase();
        Map<String, List<Id>> sobjectTypeToIds = new Map<String, List<Id>>();
        if (requests[0].objectId != null) {
            sobjectTypeToIds.put(requests[0].objectId.getSobjectType().getDescribe().getName(), new List<Id>{
                    requests[0].objectId
            });
        }

        if (requests[0].objectsIds != null) {
            for (Id curObjectId : requests[0].objectsIds) {
                String objectApiName = curObjectId.getSobjectType().getDescribe().getName();
                if (!sobjectTypeToIds.containsKey(objectApiName)) {
                    sobjectTypeToIds.put(objectApiName, new List<Id>());
                }
                sobjectTypeToIds.get(objectApiName).add(curObjectId);
            }
        }

        List<Approval.LockResult> lockResults = new List<Approval.LockResult>();
        List<Approval.UnlockResult> unlockResults = new List<Approval.UnlockResult>();
        for (String objectType : sobjectTypeToIds.keySet()) {
            List<Id> ids = sobjectTypeToIds.get(objectType);
            try {
                List<SObject> objResult = Database.query('SELECT Id FROM ' + objectType + ' WHERE Id IN: ids');
                if (lockingAction == 'lock') {
                    lockResults.addAll(Approval.lock(objResult, true));
                } else if (lockingAction == 'unlock') {
                    unlockResults.addAll(Approval.unlock(objResult, true));
                }

            } catch (Exception ex) {
                throw new LockErrorException('error locking a row: ' + ex.getMessage());
            }
        }

        List<String> errors = new List<String>();

        for (Approval.LockResult lr : lockResults) {
            if (!lr.isSuccess()) {
                for (Database.Error err : lr.getErrors()) {
                    errors.add('Error performing ' + lockingAction + ' action: ' + err.getStatusCode() + ': ' + err.getMessage() + ', Fields: ' + err.getFields());
                }
            }
        }

        for (Approval.UnlockResult lr : unlockResults) {
            if (!lr.isSuccess()) {
                for (Database.Error err : lr.getErrors()) {
                    errors.add('Error performing ' + lockingAction + ' action: ' + err.getStatusCode() + ': ' + err.getMessage() + ', Fields: ' + err.getFields());
                }
            }
        }
        if (!errors.isEmpty()) {
            throw new LockErrorException('Following errors appeared while performing ' + lockingAction + 'action :' + String.join(errors, ', '));
        }
    }

    public class LockErrorException extends Exception {
    }


    public class Requests {
        @InvocableVariable
        public String lockingAction;
        @InvocableVariable
        public List<Id> objectsIds;
        @InvocableVariable
        public Id objectId;
    }

    public class Results {
        @InvocableVariable
        public String response;
    }

}