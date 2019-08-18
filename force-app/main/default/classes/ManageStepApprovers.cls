global with sharing class ManageStepApprovers implements SharingManager {

    static List<ListBuilderController.ButtonSetting> supportedButtonSettings;

    public static String execute(String buttonName, String paramsString) {
        Map<String, String> params = (Map<String, String>) JSON.deserialize(paramsString, Map<String, String>.class);

        if (buttonName == 'Add') {
            return add(
                    params.get('userOrGroupID'),
                    params.get('approvalStepDefinitionId'),
                    params.get('type'));
        } else if (buttonName == 'Remove') {
            return remove(
                    params.get('userOrGroupID'),
                    params.get('approvalStepDefinitionId'));
        }

        throw new AuraHandledException('Button "' + buttonName + '" is not supported');
    }
    public ManageStepApprovers initialize(String managerName){
        return new ManageStepApprovers();
    }

    private static String add(Id userOrGroupID, Id approvalStepDefinitionId, String type) {
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

    private static String remove(Id userOrGroupID, Id approvalStepDefinitionId) {
        try {
            delete [SELECT Id FROM AP_Approver__c WHERE Name = :userOrGroupID AND Approval_Process_Step_Definition__c = :approvalStepDefinitionId];
            return 'SUCCESS';
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static String getExisting(String approvalStepDefinitionId) {
        return JSON.serialize([SELECT Id, Name, Type__c FROM AP_Approver__c WHERE Approval_Process_Step_Definition__c = :approvalStepDefinitionId]);
    }

    public ManageStepApprovers() {
        supportedButtonSettings = new List<ListBuilderController.ButtonSetting>();
        supportedButtonSettings.add(new ListBuilderController.ButtonSetting('Add', new ListBuilderController.ButtonMatchingRule(ListBuilderController.MatchingAction.EXISTS)));
        supportedButtonSettings.add(new ListBuilderController.ButtonSetting('Remove', new ListBuilderController.ButtonMatchingRule(ListBuilderController.MatchingAction.NOTEXISTS)));
        //Sample if Queue or Group sharing is added it can not be removed.
//        supportedButtonSettings.add(new ListBuilderController.ButtonSetting(
//                'Remove',
//                new ListBuilderController.ButtonMatchingRule(ListBuilderController.MatchingAction.VALUEEQUALS, new Map<String, List<String>>{
//                        'Type__c' => (new List<String>{
//                                'Queue', 'Group'
//                        })
//                })
//        ));
    }

    public static String getSupportedButtons() {
        return JSON.serialize(supportedButtonSettings);
    }


    private static boolean isButtonSupported(String buttonName) {
        for (ListBuilderController.ButtonSetting bs : supportedButtonSettings) {
            if (bs.name == buttonName) {
                return true;
            }
        }
        return false;
    }

}