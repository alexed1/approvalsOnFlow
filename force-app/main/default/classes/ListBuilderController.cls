global with sharing class ListBuilderController {
    @AuraEnabled
    global static String handleButtonAction(String buttonName, String managerName, String paramsString) {
        Map<String, String> params = (Map<String, String>) JSON.deserialize(paramsString, Map<String, String>.class);
        if (managerName == 'ManageStepApprovers') {
            if (buttonName == 'Add') {
                return ManageStepApprovers.addStepApprover(
                        params.get('userOrGroupID'),
                        params.get('approvalStepDefinitionId'),
                        params.get('type'));
            } else if (buttonName == 'Remove'){
                return ManageStepApprovers.removeStepApprover(
                        params.get('userOrGroupID'),
                        params.get('approvalStepDefinitionId'));
            }
        }
        throw new AuraHandledException('Manager "' + managerName + '" is not found');
    }
    @AuraEnabled
    global static String getExistingShares(String managerName, String approvalStepDefinitionId) {
        if (managerName == 'ManageStepApprovers') {
            return ManageStepApprovers.getExistingShares(approvalStepDefinitionId);
        }
        throw new AuraHandledException('Manager "' + managerName + '" is not found');
    }
}