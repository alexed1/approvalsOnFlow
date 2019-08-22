global with sharing class ListBuilderController {

    @AuraEnabled
    global static String handleButtonAction(String buttonName, String managerName, String paramsString) {

        return getSharingManager(managerName).execute(buttonName, paramsString);
    }

    @AuraEnabled(cacheable=true)
    global static List<ShareInfo> getExistingMembers(String managerName, String recordId) {

        return getSharingManager(managerName).getExisting(recordId);
    }

    @AuraEnabled(cacheable=true)
    global static String getSupportedButtons(String managerName) {

        return JSON.serialize(getSharingManager(managerName).getSupportedButtons());
    }

    private static SharingManager getSharingManager(String managerName) {

        try {
            SharingManager sm = (SharingManager) Type.forName(managerName).newInstance();
            return sm;
        } catch (Exception ex) {
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
    global class ShareInfo {

        @AuraEnabled global Id shareId;
        @AuraEnabled global Id recordId;
        @AuraEnabled global String name;
        @AuraEnabled global String label;
        @AuraEnabled global SObject shareRecord;
        public ShareInfo(Id shareId, Id recordId, String name, String label, SObject shareRecord) {
            this.shareId = shareId;
            this.recordId = recordId;
            this.name = name;
            this.label = label;
            this.shareRecord = shareRecord;
        }
    }

    global enum MatchingAction {
        EXISTS, NOTEXISTS, VALUEEQUALS, SUPPORTED
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