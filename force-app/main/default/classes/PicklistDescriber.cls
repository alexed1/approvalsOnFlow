/**
 * Purpose: Create and Update picklist field and its values for plan step 
   Called from Trigger: PicklistDescriberTrigger 
 */

public class PicklistDescriber implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public final Set<Id> picklistDescriberSet;
    public final Map<String, Plan_Step__c> picklistIdOldValueMap;

    public PicklistDescriber(set<Id> picklistSet, Map<String, Plan_Step__c> picklistIdValueMap){
        picklistDescriberSet = picklistSet;
        picklistIdOldValueMap = picklistIdValueMap;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Name, Start_When__c, Object_API_Name__c, Picklist_Field_API_Name__c, Error_Message__c, Id FROM Plan_Step__c WHERE Id IN :picklistDescriberSet';
        return Database.getQueryLocator(query);
    }



    public void execute(Database.BatchableContext BC, List<Plan_Step__c> scope) {
        List<MetadataService.Metadata> metadataCreateList = new List<MetadataService.Metadata>();
        List<MetadataService.Metadata> metadataUpdateList = new List<MetadataService.Metadata>();
        List<MetadataService.Metadata> metadataUpdateTempList = new List<MetadataService.Metadata>();
        List<MetadataService.Metadata> metadataUpdateProfileList = new List<MetadataService.Metadata>();
        List<Plan_Step__c> createPicklistMetadataList = new List<Plan_Step__c>();
        List<Plan_Step__c> updatePicklistMetadataList = new List<Plan_Step__c>();
        MetadataService.MetadataPort service = createService();
        String picklistApiName = '';
        for(Plan_Step__c sob : scope) {
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(String.escapeSingleQuotes(sob.Object_API_Name__c)).getDescribe().fields.getMap();
            MetadataService.CustomField customField = new MetadataService.CustomField();
            picklistApiName = 'Start_When__c';
            picklistApiName = picklistApiName.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '_');
            if(fieldMap.containsKey(picklistApiName.toLowerCase())) {
                if(picklistIdOldValueMap.containsKey(sob.Id)) {
                    MetadataService.CustomField customField1 = new MetadataService.CustomField();
                    picklistApiName = picklistIdOldValueMap.get(sob.Id).Picklist_Field_API_Name__c.replaceAll(' ','_');
                    picklistApiName = picklistApiName.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '_');
                    customField1.fullName = picklistIdOldValueMap.get(sob.Id).Object_API_Name__c + '.' + picklistApiName;
                    customField1.label = picklistIdOldValueMap.get(sob.Id).Picklist_Field_API_Name__c;
                    customField1.type_x = 'Picklist';
                    MetadataService.Picklist picklist1 = new MetadataService.Picklist();
                    picklist1.sorted = false;
                    MetadataService.PicklistValue firstValue1 = new MetadataService.PicklistValue();
                    firstValue1.fullName = picklistIdOldValueMap.get(sob.Id).Name;
                    firstValue1.isActive = false;
                    firstValue1.default_x = false ;
                    /*if(picklistIdOldValueMap.get(sob.Id).Plan_Step__c != null){
                        picklistApiName = sob.Case_Step__r.Picklist_Field_API_Name__c.replaceAll(' ','_');
                        picklistApiName = picklistApiName.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '_');
                        picklist1.controllingField = picklistApiName + '__c';
                        //firstValue1.controllingFieldValues = new String[] {picklistIdOldValueMap.get(sob.Id).Name};
                    }*/
                    picklist1.picklistValues = new List<MetadataService.PicklistValue>{firstValue1};
                    customField1.picklist = picklist1 ;
                    metadataUpdateTempList.add(customField1);

                    picklistApiName = sob.Picklist_Field_API_Name__c.replaceAll(' ','_');
                    picklistApiName = picklistApiName.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '_');
                    customField.fullName = sob.Object_API_Name__c + '.' + picklistApiName;
                    customField.label = sob.Picklist_Field_API_Name__c;
                    customField.type_x = 'Picklist';
                    MetadataService.Picklist picklist = new MetadataService.Picklist();
                    picklist.sorted = false;
                    MetadataService.PicklistValue firstValue = new MetadataService.PicklistValue();
                    firstValue.fullName = sob.Name;
                    firstValue.default_x = false ;
                    /*if(sob.Plan_Step__c != null){
                        picklistApiName = sob.Case_Step__r.Picklist_Field_API_Name__c.replaceAll(' ','_');
                        picklistApiName = picklistApiName.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '_');
                        picklist.controllingField = picklistApiName + '__c';
                        firstValue.controllingFieldValues = new String[] {sob.Case_Step__r.Name};
                    }*/
                    picklist.picklistValues = new List<MetadataService.PicklistValue>{firstValue};
                    customField.picklist = picklist ;
                    metadataUpdateList.add(customField);
                    updatePicklistMetadataList.add(sob);
                    MetadataService.Profile systemAdmin = new MetadataService.Profile();
                    systemAdmin.fullName = 'Admin';
                    systemAdmin.custom = false;

                    MetadataService.ProfileFieldLevelSecurity fieldSecurity = new MetadataService.ProfileFieldLevelSecurity();
                    picklistApiName = sob.Picklist_Field_API_Name__c.replaceAll(' ','_');
                    picklistApiName = picklistApiName.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '_');
                    fieldSecurity.field = sob.Object_API_Name__c + '.' + picklistApiName;
                    fieldSecurity.editable = true;
                    systemAdmin.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSecurity} ;
                    metadataUpdateProfileList.add(systemAdmin);
                } else {
                    system.debug(' nirwal ');
                    picklistApiName = sob.Picklist_Field_API_Name__c.replaceAll(' ','_');
                    picklistApiName = picklistApiName.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '_');
                    customField.fullName = sob.Object_API_Name__c + '.' + picklistApiName;
                    customField.label = sob.Picklist_Field_API_Name__c;
                    customField.type_x = 'Picklist';
                    MetadataService.Picklist picklist = new MetadataService.Picklist();
                    picklist.sorted = false;
                    MetadataService.PicklistValue firstValue = new MetadataService.PicklistValue();
                    firstValue.fullName = sob.Name;
                    firstValue.default_x = false ;
                    /*if(sob.Plan_Step__c != null){
                        picklistApiName = sob.Case_Step__r.Picklist_Field_API_Name__c.replaceAll(' ','_');
                        picklistApiName = picklistApiName.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '_');
                        picklist.controllingField = picklistApiName + '__c';
                        firstValue.controllingFieldValues = new String[] {sob.Case_Step__r.Name};
                    }*/
                    picklist.picklistValues = new List<MetadataService.PicklistValue>{firstValue};
                    customField.picklist = picklist ;
                    metadataUpdateList.add(customField);
                    updatePicklistMetadataList.add(sob);
                    MetadataService.Profile systemAdmin = new MetadataService.Profile();
                    systemAdmin.fullName = 'Admin';
                    systemAdmin.custom = false;

                    MetadataService.ProfileFieldLevelSecurity fieldSecurity = new MetadataService.ProfileFieldLevelSecurity();
                    picklistApiName = sob.Picklist_Field_API_Name__c.replaceAll(' ','_');
                    picklistApiName = picklistApiName.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '_');
                    fieldSecurity.field = sob.Object_API_Name__c + '.' + picklistApiName;
                    fieldSecurity.editable = true;
                    systemAdmin.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSecurity} ;
                    metadataUpdateProfileList.add(systemAdmin);
                }
            } else {
                system.debug(' saurav ');
                picklistApiName = sob.Picklist_Field_API_Name__c.replaceAll(' ','_');
                picklistApiName = picklistApiName.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '_');
                customField.fullName = sob.Object_API_Name__c + '.' + picklistApiName;
                customField.label = sob.Picklist_Field_API_Name__c;
                customField.type_x = 'Picklist';
                MetadataService.Picklist picklist = new MetadataService.Picklist();
                picklist.sorted = false;
                MetadataService.PicklistValue firstValue = new MetadataService.PicklistValue();
                firstValue.fullName = sob.Name;
                firstValue.default_x = false ;
                /*if(sob.Plan_Step__c != null){
                    picklistApiName = sob.Case_Step__r.Picklist_Field_API_Name__c.replaceAll(' ','_');
                    picklistApiName = picklistApiName.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '_');
                    picklist.controllingField = picklistApiName + '__c';
                    firstValue.controllingFieldValues = new String[] {sob.Case_Step__r.Name};
                }*/
                picklist.picklistValues = new List<MetadataService.PicklistValue>{firstValue};
                customField.picklist = picklist ;
                metadataCreateList.add(customField);
                createPicklistMetadataList.add(sob);

                MetadataService.Profile systemAdmin = new MetadataService.Profile();
                systemAdmin.fullName = 'Admin';
                systemAdmin.custom = false;
                MetadataService.ProfileFieldLevelSecurity fieldSecurity = new MetadataService.ProfileFieldLevelSecurity();
                picklistApiName = sob.Picklist_Field_API_Name__c.replaceAll(' ','_');
                picklistApiName = picklistApiName.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '_');
                fieldSecurity.field = sob.Object_API_Name__c + '.' + picklistApiName;
                fieldSecurity.editable = true;
                systemAdmin.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSecurity} ;
                metadataUpdateProfileList.add(systemAdmin);
            }
        }
        if(!metadataCreateList.isEmpty()) {
            List<MetadataService.SaveResult> createResults = service.createMetadata( metadataCreateList );
            if(!createResults.isEmpty() && !createPicklistMetadataList.isEmpty() && createResults.size() == createPicklistMetadataList.size()) {
                for(Integer i=0; i<createResults.size(); i++) {
                    createPicklistMetadataList[i].Error_Message__c = handleSaveResults(createResults[i]);
                }
            }
        }
        if(!metadataUpdateList.isEmpty()) {
            List<MetadataService.SaveResult> updateResults = service.updateMetadata( metadataUpdateList );
            if(!updateResults.isEmpty() && !updatePicklistMetadataList.isEmpty() && updateResults.size() == updatePicklistMetadataList.size()) {
                for(Integer i=0; i<updateResults.size(); i++) {
                    updatePicklistMetadataList[i].Error_Message__c = handleSaveResults(updateResults[i]);
                }
            }
        }
        if(!metadataUpdateTempList.isEmpty()) {
            List<MetadataService.SaveResult> updateTempResults = service.updateMetadata( metadataUpdateTempList );
            for(MetadataService.SaveResult result : updateTempResults) {
                system.debug(' Handle Temp Results '+ handleSaveResults(result));
            }
        }
        if(!metadataUpdateProfileList.isEmpty()) {
            List<MetadataService.SaveResult> updateProfileResults = service.updateMetadata( metadataUpdateProfileList );
            for(MetadataService.SaveResult result : updateProfileResults) {
                system.debug(' Handle Profile Results '+ handleSaveResults(result));
            }
        }
        if(!createPicklistMetadataList.isEmpty()) {
            update createPicklistMetadataList;
        }
        if(!updatePicklistMetadataList.isEmpty()) {
            update updatePicklistMetadataList;
        }
    }

    public void finish(Database.BatchableContext BC){

    }

    public static String handleSaveResults(MetadataService.SaveResult saveResult) {
        if(saveResult == null || saveResult.success) {
            return 'Record has been created successfully.';
        }
        // Construct error message and throw an exception
        if(saveResult.errors != null) {
            List<String> messages = new List<String>();
            messages.add((saveResult.errors.size() == 1 ? 'Error ' : 'Errors ') + 'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors) {
                messages.add( error.message + ' (' + error.statusCode + ').' + ( error.fields != null && error.fields.size() > 0 ? ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            }
            if(!messages.isEmpty()) {
                return String.join(messages, ' ');
            }
        }
        if(!saveResult.success) {
            return 'Request failed with no specified error.';
        }
        return null;
    }

    public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

}