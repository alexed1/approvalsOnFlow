global with sharing class ListBuilderController {

    @AuraEnabled
    global static String handleButtonAction(String buttonName, String managerName, String paramsString) {

        return getSharingManager(managerName).execute(buttonName, paramsString);
    }

    @AuraEnabled(cacheable=true)
    global static String getExistingShares(String managerName, String approvalStepDefinitionId) {

        return getSharingManager(managerName).getExisting(approvalStepDefinitionId);
    }

    @AuraEnabled(cacheable=true)
    global static String getSupportedButtons(String managerName) {

        return getSharingManager(managerName).getSupportedButtons();
    }

    private static SharingManager getSharingManager(String managerName) {

        try{
            SharingManager sm =  (SharingManager) Type.forName(managerName).newInstance();
            return sm;
        }catch (Exception ex){
            throw new AuraHandledException('Manager "' + managerName + '" is not found');
        }
    }

    global class ButtonSetting {
        @AuraEnabled global String name;
        @AuraEnabled global ButtonMatchingRule matchingRule;
        public ButtonSetting(String name, ButtonMatchingRule matchingRule) {
            this.name = name;
            this.matchingRule = matchingRule;
        }

    }

    global enum MatchingAction {
        EXISTS, NOTEXISTS, VALUEEQUALS
    }

    global class ButtonMatchingRule {
        @AuraEnabled global MatchingAction matchingAction;
        @AuraEnabled global Map<String, List<String>> disabledValues;
        public ButtonMatchingRule(MatchingAction matchingAction, Map<String, List<String>> disabledValues) {
            this.matchingAction = matchingAction;
            this.disabledValues = disabledValues;
        }
        public ButtonMatchingRule(MatchingAction matchingAction) {
            this.matchingAction = matchingAction;
        }
    }
}