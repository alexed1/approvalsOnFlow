global with sharing class ManageApprovalStepApprovers implements RoleManagerProvider {

    static List<RoleManagerController.ButtonSetting> supportedButtonSettings;

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

    public static List<RoleManagerController.MemberInfo> getExisting(String recordId) {
        return getAllApprovers(recordId);
    }

    private static List<RoleManagerController.MemberInfo> getAllApprovers(String recordId) {
        List<RoleManagerController.MemberInfo> results = new List<RoleManagerController.MemberInfo>();
        List<AP_Approver__c> approvers = [SELECT Id, Name, Type__c FROM AP_Approver__c WHERE Approval_Process_Step_Definition__c = :recordId];
        Map<String, Set<String>> objectTypeToIdMap = getObjectTypeToIdMap(approvers);
        Map<String, String> approverIdToName = SearchUtils.getMembersByTypeAndId(objectTypeToIdMap);
        for (AP_Approver__c app : approvers) {
            results.add(new RoleManagerController.MemberInfo(app.Id, app.Name, approverIdToName.get(app.Name), approverIdToName.get(app.Name) + ' (' + app.Type__c + ')', app));
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

    public ManageApprovalStepApprovers() {
        supportedButtonSettings = new List<RoleManagerController.ButtonSetting>();
        supportedButtonSettings.add(new RoleManagerController.ButtonSetting('Add', new RoleManagerController.ButtonMatchingRule(RoleManagerController.MatchingAction.EXISTS)));
        supportedButtonSettings.add(new RoleManagerController.ButtonSetting('Remove', new RoleManagerController.ButtonMatchingRule(RoleManagerController.MatchingAction.NOTEXISTS)));
        //Sample if Queue or Group sharing is added it can not be removed.
//        supportedButtonSettings.add(new RoleManagerController.ButtonSetting(
//                'Remove',
//                new RoleManagerController.ButtonMatchingRule(RoleManagerController.MatchingAction.VALUEEQUALS, new Map<String, List<String>>{
//                        'Type__c' => (new List<String>{
//                                'Queue', 'Group'
//                        })
//                })
//        ));
    }

    public static List<RoleManagerController.ButtonSetting> getSupportedButtons() {
        return supportedButtonSettings;
    }
}