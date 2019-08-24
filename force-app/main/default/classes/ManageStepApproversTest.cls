@IsTest
private class ManageStepApproversTest {
    static final String TEST_NAME = 'testrecordname@test.te';
    static final String MANAGER_NAME = 'ManageStepApprovers';
    static final String OBJECT_TYPE = 'User';
    static final Set<String> EXPECTED_ACTION_BUTTONS = new Set<String>{
            'Add', 'Remove'
    };

    @testSetup
    static void setup() {
        ApprovalProcessDefinition__c apd = new ApprovalProcessDefinition__c(Name = TEST_NAME);
        insert apd;
        ApprovalProcessStepDefinition__c apsd = new ApprovalProcessStepDefinition__c(Name = TEST_NAME, ApprovalProcessDefinition__c = apd.Id);
        insert apsd;
        List<Profile> adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(Alias = 'test1', Email = 'testuser1@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = adminProfile[0].Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = TEST_NAME);
        insert testUser;
    }

    @IsTest
    static void testHandleButtonAction() {
        ApprovalProcessDefinition__c apd = [SELECT Id FROM ApprovalProcessDefinition__c WHERE Name = :TEST_NAME];
        ApprovalProcessStepDefinition__c apsd = [SELECT Id FROM ApprovalProcessStepDefinition__c WHERE Name = :TEST_NAME];
        User testUser = [SELECT Id FROM User WHERE Username = :TEST_NAME];

        //Checking if supported buttons are added
        List<ListBuilderController.ButtonSetting> supportedButtons = (List<ListBuilderController.ButtonSetting>) JSON.deserialize(ListBuilderController.getSupportedButtons(MANAGER_NAME), List<ListBuilderController.ButtonSetting>.class);
        Set<String> actualButtonNames = new Set<String>();
        for (ListBuilderController.ButtonSetting bs : supportedButtons) {
            actualButtonNames.add(bs.name);
            System.assertEquals(true, EXPECTED_ACTION_BUTTONS.contains(bs.name));
        }
        System.assertEquals(EXPECTED_ACTION_BUTTONS.size(), actualButtonNames.size());

        //Checking number of shares before clicking buttons
        List<ListBuilderController.ShareInfo> existingShares = ListBuilderController.getExistingMembers(MANAGER_NAME, apsd.Id);
        Integer numberOfExistingShares = existingShares.size();

        //Adding new share
        ListBuilderController.handleButtonAction('Add', MANAGER_NAME, JSON.serialize(generateParamString(testUser.Id, apsd.Id, OBJECT_TYPE)));

        //Checking list of shares after we added one
        existingShares = ListBuilderController.getExistingMembers(MANAGER_NAME, apsd.Id);
        System.assertEquals(numberOfExistingShares + 1, existingShares.size());

        //Removing share
        ListBuilderController.handleButtonAction('Remove', MANAGER_NAME, JSON.serialize(generateParamString(testUser.Id, apsd.Id, OBJECT_TYPE)));

        //Checking if share is actually removed
        existingShares = ListBuilderController.getExistingMembers(MANAGER_NAME, apsd.Id);
        System.assertEquals(numberOfExistingShares, existingShares.size());
    }

    @IsTest
    static void testMissingManager() {
        String wrongManagerName = MANAGER_NAME+'test';
        try{
            List<ListBuilderController.ButtonSetting> supportedButtons = (List<ListBuilderController.ButtonSetting>) JSON.deserialize(ListBuilderController.getSupportedButtons(wrongManagerName), List<ListBuilderController.ButtonSetting>.class);
        }catch (Exception ex){
            System.assertEquals(true, ex.getMessage().contains('Manager "' + wrongManagerName + '" is not found'));
        }
    }

    private static Map<String, String> generateParamString(String userOrGroupID, String recordId, String type) {
        Map<String, String> result = new Map<String, String>();
        if (userOrGroupID != null) {
            result.put('userOrGroupID', userOrGroupID);
        }
        if (recordId != null) {
            result.put('recordId', recordId);
        }
        if (type != null) {
            result.put('type', type);
        }

        return result;
    }
}