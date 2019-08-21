global with sharing class ManageObjectSharing implements SharingManager {

    static List<ListBuilderController.ButtonSetting> supportedButtonSettings;
    static Map<String, String> BUTTON_TO_ACCESS_TYPE = new Map<String, String>{
            'Read' => 'Read', 'Read/Write' => 'Edit'
    };

    public static String execute(String buttonName, String paramsString) {

        Map<String, String> params = (Map<String, String>) JSON.deserialize(paramsString, Map<String, String>.class);

        if (buttonName == 'Read' || buttonName == 'Read/Write') {
            return add(
                    params.get('userOrGroupID'),
                    params.get('recordId'),
                    BUTTON_TO_ACCESS_TYPE.get(buttonName));
        } else if (buttonName == 'None') {
            return remove(
                    params.get('userOrGroupID'),
                    params.get('recordId'));
        }

        throw new AuraHandledException('Button "' + buttonName + '" is not supported');
    }


    private static String add(Id userOrGroupID, Id recordId, String level) {
        System.debug('entering upsertPerm');
        Schema.DescribeSObjectResult describe = getSharingDescribe(recordId);
        level = String.escapeSingleQuotes(level);

        if (!canIEditPerms(recordId)) {
            throw new AuraHandledException(Label.OwnerAdminModify);
        }
        System.debug('doing perm upsert');

        // special handling for role => groups
        if (UserOrGroupID.getSobjectType() == Schema.UserRole.SObjectType) {
            //it's a role...find the matching group?
            list<group> matchingGroups = [select id, name, type from group where RelatedId = :UserOrGroupID and type = 'Role'];
            if (matchingGroups.size() > 1) {
                throw new AuraHandledException(Label.MultipleGroupsForRole);
            }
            UserOrGroupID = matchingGroups[0].Id;
        }
        String query = buildQuery(recordId);
        query = query + ' and UserOrGroupID =\'' + String.escapeSingleQuotes(String.valueOf(UserOrGroupID)) + '\'';
        System.debug(query);

        list<sObject> existing = database.query(query);
        String sobj = AdminTools.objectTypeFromId(recordId);

        if (existing.size() > 0) {
            System.debug('already existing. will update');
            //can I update this thing?

            if (!describe.isUpdateable() ||
                    !describe.fields.getMap().get(AdminTools.getAccessLevelField(sobj)).getDescribe().isUpdateable()
                    ) {
                throw new AuraHandledException(Label.OwnerAdminModify);
            }

            existing[0].put(AdminTools.getAccessLevelField(sobj), level);

            try {
                update existing;
            } catch (exception e) {
                throw new AuraHandledException(e.getMessage());
            }

            return JSON.serialize(existing);
        } else {
            System.debug('not already existing. will create');
            //are we even allowed to insert this?  for these specific fields that we'll set?
            if (!describe.isCreateable() ||
                    !describe.fields.getMap().get(AdminTools.getAccessLevelField(sobj)).getDescribe().isCreateable() ||
                    !describe.fields.getMap().get(AdminTools.getLookupField(sobj)).getDescribe().isCreateable() ||
                    !describe.fields.getMap().get('UserOrGroupId').getDescribe().isCreateable()
                    ) {
                throw new AuraHandledException(Label.OwnerAdminModify);
            }
            //create a new SObject dynamically and insert
            Schema.SObjectType newObj = Schema.getGlobalDescribe().get(getSharingTableName(sobj));
            sobject share = newObj.newSObject();

            share.put(AdminTools.getAccessLevelField(sobj), level);
            share.put(AdminTools.getLookupField(sobj), recordId);
            share.put('UserOrGroupId', String.escapeSingleQuotes(String.valueOf(UserOrGroupID)));

            if (AdminTools.objectTypeFromId(recordId) == 'Account') {
                //share.put('ContactAccessLevel', level);
                share.put('CaseAccessLevel', level);
                share.put('OpportunityAccessLevel', level);
            }
            try {
                insert share;
            } catch (exception e) {
                throw new AuraHandledException(e.getMessage());
            }
            return JSON.serialize(share);
        }
    }

    private static String remove(Id userOrGroupID, Id recordId) {

        //access check
        Schema.DescribeSObjectResult describe = getSharingDescribe(recordId);

        //can I delete the sharing objects?
        if (!describe.isDeletable() || !describe.isAccessible()) {
            throw new AuraHandledException(Label.LackingPermissions);
        }

        // special handling for role => groups
        if (UserOrGroupID.getSobjectType() == Schema.UserRole.SObjectType) {
            //it's a role...find the matching group?
            list<group> matchingGroups = [select id, name, type from group where RelatedId = :UserOrGroupID and type = 'Role'];
            if (matchingGroups.size() > 1) {
                throw new AuraHandledException(Label.MultipleGroupsForRole);
            }
            UserOrGroupID = matchingGroups[0].Id;
        }

        String query = buildQuery(recordId);
        query = query + ' and UserOrGroupID =\'' + String.escapeSingleQuotes(UserOrGroupID) + '\'';
        System.debug(query);

        list<sObject> existing = database.query(query);
        System.debug(existing);
        try {
            delete existing;
            return 'SUCCESS';//TODO: fix
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static List<ListBuilderController.ShareInfo> getExisting(String recordId) {
        return getAllObjectShares(recordId);
    }

    private static List<ListBuilderController.ShareInfo> getAllObjectShares(String recordId) {
        if (!sharingExists(AdminTools.objectTypeFromId(recordId))) {
            throw new AuraHandledException(Label.OWDReadWrite);
        }

        List<ListBuilderController.ShareInfo> results = new List<ListBuilderController.ShareInfo>();
        list<sObject> shares = database.query(buildQuery(recordId));
        Map<Id, String> idToObjectType = new Map<Id, String>();

        for (sObject share : shares) {
            Id curRecId = (Id) share.get('UserOrGroupId');
            idToObjectType.put(curRecId, AdminTools.objectTypeFromId(curRecId));
        }

        Map<String, SObject> recordData = getRecordData(idToObjectType.keySet());

        for (sObject app : shares) {
            String recordName = (String) recordData.get((Id) app.get('UserOrGroupId')).get('Name');
            results.add(new ListBuilderController.ShareInfo(
                    (Id) app.get('Id'),
                    (Id) app.get('UserOrGroupId'),
                    recordName,
                    recordName + ' (' + idToObjectType.get((Id) app.get('UserOrGroupId')) + ')',
                    app)
            );
        }
        return results;
    }

    static Map<String, SObject> getRecordData(Set<Id> recordIds) {
        Map<String, List<Id>> typeToRecordIds = new Map<String, List<Id>>();
        Map<String, SObject> recordIdToRecord = new Map<String, SObject>();
        for (Id curId : recordIds) {
            String objectName = AdminTools.objectTypeFromId(curId);
            if (!typeToRecordIds.containsKey(objectName)) {
                typeToRecordIds.put(objectName, new List<String>());
            }
            typeToRecordIds.get(objectName).add(curId);
        }
        for (String curType : typeToRecordIds.keySet()) {
            list<SObject> shares = database.query('SELECT Id, Name FROM ' + curType);
            for (SObject share : shares) {
                recordIdToRecord.put((String) share.get('Id'), share);
            }
        }
        return recordIdToRecord;
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

    public ManageObjectSharing() {
        supportedButtonSettings = new List<ListBuilderController.ButtonSetting>();

        supportedButtonSettings.add(new ListBuilderController.ButtonSetting('None', new ListBuilderController.ButtonMatchingRule(ListBuilderController.MatchingAction.NOTEXISTS)));

        supportedButtonSettings.add(new ListBuilderController.ButtonSetting(
                'None',
                new ListBuilderController.ButtonMatchingRule(ListBuilderController.MatchingAction.VALUEEQUALS, new Map<String, List<String>>{
                        'RowCause' => (new List<String>{
                                'Owner', 'ImplicitChild', 'ImplicitParent'
                        })
                })
        ));

        supportedButtonSettings.add(new ListBuilderController.ButtonSetting(
                'Read/Write',
                new ListBuilderController.ButtonMatchingRule(ListBuilderController.MatchingAction.VALUEEQUALS, new Map<String, List<String>>{
                        'AccountAccessLevel' => (new List<String>{
                                'Edit', 'All'
                        }),
                        'RowCause' => (new List<String>{
                                'Owner'
                        })
                })
        ));

        supportedButtonSettings.add(new ListBuilderController.ButtonSetting(
                'Read',
                new ListBuilderController.ButtonMatchingRule(ListBuilderController.MatchingAction.VALUEEQUALS, new Map<String, List<String>>{
                        'RowCause' => (new List<String>{
                                'Owner'
                        }),
                        'AccountAccessLevel' => (new List<String>{
                                'Read'
                        })
                }
                )));
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

    @TestVisible
    private static String getSharingTableName(String sobj) {
        if (sobj.contains('__c')) {
            return sobj.replace('__c', '__Share');
        } else {
            return sobj + 'Share';
        }
    }

    @TestVisible
    private static boolean sharingExists(String sobj) {
        //custom objects
        if (sobj.contains('__c')) {
            Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
            if (tokens.containsKey(getSharingTableName(sobj).toLowerCase()) || tokens.containsKey('ltngsharing__' + getSharingTableName(sobj).toLowerCase())) {
                return true;
            }
        } else {
            String tableName = getSharingTableName(sobj);
            String query = 'select count() from ' + tableName;
            try {
                integer count = database.countQuery(query);
                if (count > 0) {
                    return true;
                } else {
                    return false;
                }
            } catch (exception e) {
                System.debug(e);
            }
            return false;
        }

        return false;
    }

    @TestVisible
    private static schema.DescribeSObjectResult getSharingDescribe(Id recordId) {
        try {
            String sharingName = getSharingTableName(AdminTools.objectTypeFromId(recordId));
            System.debug('sharingName in getSharingDescribe is: ' + sharingName);
            schema.DescribeSObjectResult curResult = Schema.getGlobalDescribe().get(sharingName).getDescribe();
            System.debug('global describe in getSharingDescribe is: ' + curResult);
            return curResult;
        } catch (exception e) {
            //probably means they don't have sharing turned on for this object
            throw new AuraHandledException(Label.OWDReadWrite);
        }
    }

    @TestVisible private static String buildQuery(Id recordId) {
        String sobj = AdminTools.objectTypeFromId(recordId);

        schema.DescribeSObjectResult describe = getSharingDescribe (recordId);

        if (!describe.isAccessible() ||
                !describe.fields.getMap().get('Id').getDescribe().isAccessible() ||
                !describe.fields.getMap().get('RowCause').getDescribe().isAccessible() ||
                !describe.fields.getMap().get('UserOrGroupId').getDescribe().isAccessible() ||
                !describe.fields.getMap().get(AdminTools.getAccessLevelField(sobj)).getDescribe().isAccessible() ||
                !describe.fields.getMap().get(AdminTools.getLookupField(sobj)).getDescribe().isAccessible()
                ) {
            throw new AuraHandledException(Label.LackingPermissions);
        }

        String query = 'select Id, RowCause, UserOrGroupId, ' + AdminTools.getAccessLevelField(sobj) + ' from ' + getSharingTableName(sobj) + ' where ' + AdminTools.getLookupField(sobj) + ' = \'' + String.escapeSingleQuotes(String.valueOf(recordId)) + '\'';
        System.debug(query);
        return query;
    }

    @AuraEnabled
    global static boolean canIEditPerms(Id recordId) {
        try {
            String query = 'SELECT RecordId, HasDeleteAccess, HasAllAccess FROM UserRecordAccess WHERE RecordId = \'' + String.escapeSingleQuotes(String.valueOf(recordId)) + '\' AND UserId = \'' + UserInfo.getUserId() + '\'';
            sObject o = Database.query(query);
            if ((Boolean) o.get('HasDeleteAccess') || (Boolean) o.get('HasAllAccess')) {
                System.Debug('edit allowed because user has full acesss or modify all permissions');
                return true;
            }
        } catch (System.queryException e) {
            //it's possible you can't even see that record and the queries are null!
            return false;
        }
        return false;
    }


}