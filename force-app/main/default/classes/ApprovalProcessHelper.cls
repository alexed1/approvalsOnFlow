global with sharing class ApprovalProcessHelper {

    static final String NULL_KEY = 'null';

    @AuraEnabled(cacheable=true)
    public static String getApprovalProcessHistory(Id processInstanceId) {

        Map<Id, ApprovalProcessStepInstance__c> stepInstances = new Map<Id, ApprovalProcessStepInstance__c>([
                SELECT Id, Name, Status__c,Approval_Process_Step_Definition__r.Order__c,Approval_Process_Step_Definition__r.Name
                FROM ApprovalProcessStepInstance__c
                WHERE Parent_Approval_Process_Instance__c = :processInstanceId
                ORDER BY Approval_Process_Step_Definition__r.Order__c DESC
        ]);
        Map<String, ApprovalHistoryWrapper> stepInstanceWrappers = new Map<String, ApprovalHistoryWrapper>();
        for (Id siId : stepInstances.keySet()) {
            ApprovalProcessStepInstance__c si = stepInstances.get(siId);
            stepInstanceWrappers.put(siId, new ApprovalHistoryWrapper(si.Id, si.Approval_Process_Step_Definition__r.Name, si.Status__c, si.Approval_Process_Step_Definition__r.Order__c, new List<ApprovalInstanceHistory__c>()));
        }

        List<ApprovalInstanceHistory__c> historyItems = [SELECT Id,Approval_Process_Instance__c, ApprovalProcessStepInstance__c, CreatedDate, Comments__c, Status__c, Original_User__c,Original_User__r.Name, Assigned_User__c, Assigned_User__r.Name FROM ApprovalInstanceHistory__c WHERE Approval_Process_Instance__c = :processInstanceId];

        for (ApprovalInstanceHistory__c hi : historyItems) {
            if (hi.ApprovalProcessStepInstance__c != null && stepInstanceWrappers.containsKey(hi.ApprovalProcessStepInstance__c)) {
                stepInstanceWrappers.get(hi.ApprovalProcessStepInstance__c).items.add(hi);
            } else {
                if (!stepInstanceWrappers.containsKey(NULL_KEY)) {
                    stepInstanceWrappers.put(NULL_KEY, new ApprovalHistoryWrapper(NULL_KEY, '', '', -1, new List<ApprovalInstanceHistory__c>()));
                }
                stepInstanceWrappers.get(NULL_KEY).items.add(hi);
            }
        }

        return JSON.serialize(stepInstanceWrappers.values());
    }

    global class ApprovalHistoryWrapper {
        @AuraEnabled global String id;
        @AuraEnabled global String name;
        @AuraEnabled global String status;
        @AuraEnabled global Decimal order;
        global List<ApprovalInstanceHistory__c> items;
        public ApprovalHistoryWrapper() {
            items = new List<ApprovalInstanceHistory__c>();
        }
        public ApprovalHistoryWrapper(String id, String name, String status, Decimal order, List<ApprovalInstanceHistory__c> items) {
            this.id = id;
            this.name = name;
            this.status = status;
            this.order = order;
            this.items = items;
        }
    }
}