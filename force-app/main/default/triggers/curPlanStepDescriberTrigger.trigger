/****************
 Purpose: Create and Update curPlanStep and its values for plan step 
 Handler: PicklistDescriber
 ****************/
trigger curPlanStepDescriberTrigger on Plan_Step__c (after insert, before insert, after update) {
    Set<Id> curPlanStepIdSet = new Set<Id>();
    Map<String, Plan_Step__c> curPlanStepIdOldValueMap = new Map<String, Plan_Step__c>();
    if(Trigger.isAfter && Trigger.isInsert) {
        for(Plan_Step__c curPlanStep : Trigger.New) {
            curPlanStepIdSet.add(curPlanStep.Id);
        }
        if(!curPlanStepIdSet.isEmpty()){
            If(!test.isRunningTest()){
                Database.executeBatch(new PicklistDescriber(curPlanStepIdSet, curPlanStepIdOldValueMap));
            }
        }
    }

    if(Trigger.isBefore && Trigger.isInsert) {
        Set<String> curPlanStepDescriberNameSet = new Set<String>();
        Set<String> curPlanStepDescriberUniqueNameSet = new Set<String>();
        for(Plan_Step__c curPlanStep : Trigger.New) {
            curPlanStepDescriberNameSet.add(curPlanStep.Object_API_Name__c + '' + curPlanStep.Picklist_Field_API_Name__c + '' + curPlanStep.Name);
        }
        for(Plan_Step__c curPlanStep : [SELECT Id, Unique_Name__c FROM Plan_Step__c WHERE Unique_Name__c IN :curPlanStepDescriberNameSet]) {
            curPlanStepDescriberUniqueNameSet.add(curPlanStep.Unique_Name__c);
        }
        for(Plan_Step__c curPlanStep : Trigger.New) {
            if(curPlanStepDescriberUniqueNameSet.contains(curPlanStep.Object_API_Name__c + '' + curPlanStep.Picklist_Field_API_Name__c + '' + curPlanStep.Name)) {
                curPlanStep.addError('Picklist value "' + curPlanStep.Name + '"' + ' for "' + curPlanStep.Picklist_Field_API_Name__c + '" picklist already exists on ' + curPlanStep.Object_API_Name__c + ' object.');
            }
        }
    }

    if(Trigger.IsAfter && Trigger.isUpdate) {
        for(Plan_Step__c curPlanStep : Trigger.New) {
            if(Trigger.oldMap.get(curPlanStep.Id).Object_API_Name__c != curPlanStep.Object_API_Name__c
                    || Trigger.oldMap.get(curPlanStep.Id).Name != curPlanStep.Name
                    || Trigger.oldMap.get(curPlanStep.Id).Picklist_Field_API_Name__c != curPlanStep.Picklist_Field_API_Name__c
                    || Trigger.oldMap.get(curPlanStep.Id).Picklist_Field_API_Name__c != curPlanStep.Picklist_Field_API_Name__c) {
                curPlanStepIdOldValueMap.put(curPlanStep.Id, Trigger.oldMap.get(curPlanStep.Id));
                curPlanStepIdSet.add(curPlanStep.Id);
            }
        }
        if(!curPlanStepIdSet.isEmpty()){
            If(!test.isRunningTest()){
                Database.executeBatch(new PicklistDescriber(curPlanStepIdSet, curPlanStepIdOldValueMap));
            }
        }
    }


}