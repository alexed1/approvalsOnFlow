global with sharing class ManageStepApprovers {

    public static String addStepApprover(Id userOrGroupID, Id approvalStepDefinitionId, String type) {
        AP_Approver__c newApprover = new AP_Approver__c(
                Name = userOrGroupID,
                Approval_Process_Step_Definition__c = approvalStepDefinitionId,
                Type__c = type);
        try {
            insert newApprover;
            return JSON.serialize(newApprover);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    public static String removeStepApprover(Id userOrGroupID, Id approvalStepDefinitionId) {
        try {
            delete [SELECT Id FROM AP_Approver__c WHERE Name = :userOrGroupID AND Approval_Process_Step_Definition__c = :approvalStepDefinitionId];
            return 'SUCCESS';
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    public static String getExistingShares(String approvalStepDefinitionId) {
        return JSON.serialize([SELECT Id, Name, Type__c FROM AP_Approver__c WHERE Approval_Process_Step_Definition__c =: approvalStepDefinitionId]);
    }
}