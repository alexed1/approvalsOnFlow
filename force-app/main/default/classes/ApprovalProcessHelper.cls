public with sharing class ApprovalProcessHelper {
    @AuraEnabled(cacheable=true)
    public static String getApprovalProcessHistory(Id processInstanceId) {
        System.debug('querying for approval process history');
        List<ApprovalInstanceHistory__c> historyItems = [
                SELECT Id, CreatedDate, Comments__c, Status__c, Original_User__c,Original_User__r.Name, Assigned_User__c, Assigned_User__r.Name
                FROM ApprovalInstanceHistory__c
                WHERE Approval_Process_Instance__c = :processInstanceId
        ];


      
        return JSON.serialize(historyItems);
    }
}