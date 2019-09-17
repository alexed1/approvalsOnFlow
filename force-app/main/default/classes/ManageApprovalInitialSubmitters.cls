global with sharing class ManageApprovalInitialSubmitters implements RoleManagerProvider {

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
        AP_AllowedSubmitter__c newSubmitter = new AP_AllowedSubmitter__c(
                Name = userOrGroupID,
                Allowed_Submitters__c = recordId,
                Type__c = type);
        try {
            insert newSubmitter;
            return JSON.serialize(newSubmitter);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static String remove(Id userOrGroupID, Id recordId) {
        try {
            delete [SELECT Id FROM AP_AllowedSubmitter__c WHERE Name = :userOrGroupID AND Allowed_Submitters__c = :recordId];
            return 'SUCCESS';
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static List<RoleManagerController.MemberInfo> getExisting(String recordId) {
        return getAllInitialSubmitters(recordId);
    }

    private static List<RoleManagerController.MemberInfo> getAllInitialSubmitters(String recordId) {
        List<RoleManagerController.MemberInfo> results = new List<RoleManagerController.MemberInfo>();
        List<AP_AllowedSubmitter__c> initialSubmitters = [SELECT Id, Name, Type__c FROM AP_AllowedSubmitter__c WHERE Allowed_Submitters__c = :recordId];
        Map<String, Set<String>> objectTypeToIdMap = getObjectTypeToIdMap(initialSubmitters);
        Map<String, String> initialSubmitterIdToName = SearchUtils.getMembersByTypeAndId(objectTypeToIdMap);
        for (AP_AllowedSubmitter__c app : initialSubmitters) {
            results.add(new RoleManagerController.MemberInfo(app.Id, app.Name, initialSubmitterIdToName.get(app.Name), initialSubmitterIdToName.get(app.Name) + ' (' + app.Type__c + ')', app));
        }
        return results;
    }

    private static Map<String, Set<String>> getObjectTypeToIdMap(List<AP_AllowedSubmitter__c> initialSubmitters) {
        Map<String, Set<String>> resultMap = new Map<String, Set<String>>();
        for (AP_AllowedSubmitter__c app : initialSubmitters) {
            if (!resultMap.containsKey(app.Type__c)) {
                resultMap.put(app.Type__c, new Set<String>());
            }
            resultMap.get(app.Type__c).add(app.Name);
        }
        return resultMap;
    }

    public ManageApprovalInitialSubmitters() {
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