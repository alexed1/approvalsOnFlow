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
    @AuraEnabled(cacheable=true)
    global static String getExistingShares(String managerName, String approvalStepDefinitionId) {
        if (managerName == 'ManageStepApprovers') {
            return ManageStepApprovers.getExistingShares(approvalStepDefinitionId);
        }
        throw new AuraHandledException('Manager "' + managerName + '" is not found');
    }
    @AuraEnabled(cacheable=true)
    global static String getSupportedButtons(String managerName) {
        if (managerName == 'ManageStepApprovers') {
            return JSON.serialize(ManageStepApprovers.getSupportedButtons());
        }
        throw new AuraHandledException('Manager "' + managerName + '" is not found');
    }
    global class ButtonSetting {
        @AuraEnabled global String name;
        @AuraEnabled global ButtonMatchingRule matchingRule;
        public ButtonSetting(String name, ButtonMatchingRule matchingRule){
            this.name = name;
            this.matchingRule = matchingRule;
        }

    }
    global enum MatchingAction {EXISTS, NOTEXISTS, VALUEEQUALS}
    global class ButtonMatchingRule {
        @AuraEnabled global MatchingAction matchingAction;
        //{fieldName => FieldValue} when button in disabled; used only when matchingAction == VALUEEQUALS
        @AuraEnabled global Map<String, String> disabledValues;
        public ButtonMatchingRule(MatchingAction matchingAction, Map<String, String> disabledValues){
            this.matchingAction = matchingAction;
            this.disabledValues = disabledValues;
        }
        public ButtonMatchingRule(MatchingAction matchingAction){
            this.matchingAction = matchingAction;
        }
    }
}