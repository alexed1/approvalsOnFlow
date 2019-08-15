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
    public static List<ListBuilderController.ButtonSetting> getSupportedButtons() {
        List<ListBuilderController.ButtonSetting> supportedButtonSettings = new List<ListBuilderController.ButtonSetting>();
        supportedButtonSettings.add(new ListBuilderController.ButtonSetting('Add',new ListBuilderController.ButtonMatchingRule(ListBuilderController.MatchingAction.EXISTS)));
        supportedButtonSettings.add(new ListBuilderController.ButtonSetting('Remove',new ListBuilderController.ButtonMatchingRule(ListBuilderController.MatchingAction.NOTEXISTS)));
        return supportedButtonSettings;
    }


}