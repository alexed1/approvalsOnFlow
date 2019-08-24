global with sharing class ManageStepApprovers implements SharingManager {

    static List<ListBuilderController.ButtonSetting> supportedButtonSettings;

    public static String execute(String buttonName, String paramsString) {
        Map<String, String> params = (Map<String, String>) JSON.deserialize(paramsString, Map<String, String>.class);

        if (buttonName == 'Add') {
            return add(
                    params.get('userOrGroupID'),
                    params.get('recordId'),
                    params.get('type'));
        } else if (buttonName == 'Remove') {
            return remove(
                    params.get('userOrGroupID'),
                    params.get('recordId'));
        }

        throw new AuraHandledException('Button "' + buttonName + '" is not supported');
    }

    private static String add(Id userOrGroupID, Id recordId, String type) {
        AP_Approver__c newApprover = new AP_Approver__c(
                Name = userOrGroupID,
                Approval_Process_Step_Definition__c = recordId,
                Type__c = type);
        try {
            insert newApprover;
            return JSON.serialize(newApprover);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static String remove(Id userOrGroupID, Id recordId) {
        try {
            delete [SELECT Id FROM AP_Approver__c WHERE Name = :userOrGroupID AND Approval_Process_Step_Definition__c = :recordId];
            return 'SUCCESS';
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static List<ListBuilderController.ShareInfo> getExisting(String recordId) {
        return getAllApprovers(recordId);
    }

    private static List<ListBuilderController.ShareInfo> getAllApprovers(String recordId) {
        List<ListBuilderController.ShareInfo> results = new List<ListBuilderController.ShareInfo>();
        List<AP_Approver__c> approvers = [SELECT Id, Name, Type__c FROM AP_Approver__c WHERE Approval_Process_Step_Definition__c = :recordId];
        Map<String, Set<String>> objectTypeToIdMap = getObjectTypeToIdMap(approvers);
        Map<String, String> approverIdToName = InitialSubmittersSelectController.getSubmittersByTypeAndId(objectTypeToIdMap);
        for (AP_Approver__c app : approvers) {
            results.add(new ListBuilderController.ShareInfo(app.Id, app.Name, approverIdToName.get(app.Name), approverIdToName.get(app.Name) + ' (' + app.Type__c + ')', app));
        }
        return results;
    }

    private static Map<String, Set<String>> getObjectTypeToIdMap(List<AP_Approver__c> approvers) {
        Map<String, Set<String>> resultMap = new Map<String, Set<String>>();
        for (AP_Approver__c app : approvers) {
            if (!resultMap.containsKey(app.Type__c)) {
                resultMap.put(app.Type__c, new Set<String>());
            }
            resultMap.get(app.Type__c).add(app.Name);
        }
        return resultMap;
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

    public static List<ListBuilderController.ButtonSetting> getSupportedButtons() {
        return supportedButtonSettings;
    }
}