global with sharing class ManageApprovalAutomatedApprover implements RoleManagerProvider {
    static List<RoleManagerController.ButtonSetting> supportedButtonSettings;

    public static String execute(String buttonName, String paramsString) {
        Map<String, String> params = (Map<String, String>) JSON.deserialize(paramsString, Map<String, String>.class);

        if (buttonName == 'Add') {
            return add(
                    params.get('userOrGroupID'),
                    params.get('recordId'));
        } else if (buttonName == 'Remove') {
            return remove(params.get('recordId'));
        }

        throw new AuraHandledException('Button "' + buttonName + '" is not supported');
    }

    private static String add(String userOrGroupID, Id recordId) {
        List<ApprovalProcessDefinition__c> existingApprovalProcess = [
                SELECT Id,Name, Automated_Approver_Role__c
                FROM ApprovalProcessDefinition__c
                WHERE Id = :recordId
        ];
        if (!existingApprovalProcess.isEmpty() && existingApprovalProcess[0].Automated_Approver_Role__c == userOrGroupID) {
            return JSON.serialize(existingApprovalProcess[0]);
        }
        existingApprovalProcess[0].Automated_Approver_Role__c = userOrGroupID;
        try {
            update existingApprovalProcess;
            return JSON.serialize(existingApprovalProcess);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static String remove(Id recordId) {
       return add(null, recordId);
    }

    public static List<RoleManagerController.MemberInfo> getExisting(String recordId) {
        return getAllInitialSubmitters(recordId);
    }

    private static List<RoleManagerController.MemberInfo> getAllInitialSubmitters(String recordId) {
        List<RoleManagerController.MemberInfo> results = new List<RoleManagerController.MemberInfo>();
        List<ApprovalProcessDefinition__c> existingApprovalProcess = [
                SELECT Id,Name, Automated_Approver_Role__c
                FROM ApprovalProcessDefinition__c
                WHERE Id = :recordId AND Automated_Approver_Role__c != null
        ];
        if (!existingApprovalProcess.isEmpty()) {
            String automatedApprover = existingApprovalProcess[0].Automated_Approver_Role__c;
            results.add(new RoleManagerController.MemberInfo(existingApprovalProcess[0].Id, automatedApprover, automatedApprover, automatedApprover + ' (Related User)', existingApprovalProcess[0]));
        }

        return results;
    }

    private static void generateButtonSettings() {
        supportedButtonSettings = new List<RoleManagerController.ButtonSetting>();
        supportedButtonSettings.add(new RoleManagerController.ButtonSetting('Add', new RoleManagerController.ButtonMatchingRule(RoleManagerController.MatchingAction.EXISTS)));
        supportedButtonSettings.add(new RoleManagerController.ButtonSetting('Remove', new RoleManagerController.ButtonMatchingRule(RoleManagerController.MatchingAction.NOTEXISTS)));
    }

    public static List<RoleManagerController.ButtonSetting> getSupportedButtons(String recordId) {
        if (supportedButtonSettings == null) {
            generateButtonSettings();
        }
        return supportedButtonSettings;
    }
}