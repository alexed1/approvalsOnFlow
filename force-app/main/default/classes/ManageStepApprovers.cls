global with sharing class ManageStepApprovers {
    @AuraEnabled
    global static String addStepApprover(Id UserOrGroupID, Id approvalStepDefinitionId, String type) {
        AP_Approver__c newApprover = new AP_Approver__c(
                Name = UserOrGroupID,
                Approval_Process_Step_Definition__c = approvalStepDefinitionId,
                Type__c = type);
        try {
            insert newApprover;
            return JSON.serialize(newApprover);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }


    }
}