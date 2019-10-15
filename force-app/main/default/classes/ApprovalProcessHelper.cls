public with sharing class ApprovalProcessHelper {
    @AuraEnabled(cacheable=true)
    public static String getApprovalProcessHistory(Id processInstanceId) {

        List<ApprovalProcessStepInstance__c> historyItems = [
        SELECT Id, Name, Status__c, (SELECT Id, CreatedDate, Comments__c, Status__c, Original_User__c,Original_User__r.Name, Assigned_User__c, Assigned_User__r.Name FROM AP_ApprovalInstanceHistoryItems__r)
        FROM ApprovalProcessStepInstance__c
        WHERE Parent_Approval_Process_Instance__r.ApprovalProcessDefinition__c = :processInstanceId
        ORDER BY Approval_Process_Step_Definition__r.Order__c DESC];

        return JSON.serialize(historyItems);
    }
}