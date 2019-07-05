/**
  Handler class for generateCaseSteps apex trigger
  when new case is created or existing one updated it will add
  and update the case with new or existing case step
*/

public with sharing class generateCaseStepsHandler {


    public static void beforeInsertAndUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        updateCasePlanWhenInsertAndUpdate(newList, oldMap);
    }
    public static void afterInsertAndUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        updateCaseSteps(newList, oldMap);
    }
    public static void updateCaseSteps(List<Case> newList, Map<Id, Case> oldMap) {
        Set<Id> casePlanIdSet = new Set<Id>();
        Map<Id, List<Plan_Step__c>> mapOfCasePlanIdWithPlanSteps = new Map<Id, List<Plan_Step__c>>();
        List<Case_Step__c> listOfCaseSteptoBeCreated = new List<Case_Step__c>();
        Set<Id> CaseIdSet = new Set<Id>();
        Case_Step__c caseStepObj;
        List<Case> newListCase = new List<Case>();
        List<Case_Step__c> caseStepToBeDeleted = new List<Case_Step__c>();

        for (Case caseObj : newList) {
            if(oldMap == null){
                casePlanIdSet.add(caseObj.Case_Plan__c);
                newListCase.add(caseObj);
            }else{
                if(oldMap.get(caseObj.Id).RecordTypeId != caseObj.RecordTypeId){
                    casePlanIdSet.add(caseObj.Case_Plan__c);
                    newListCase.add(caseObj);
                    CaseIdSet.add(caseObj.Id);
                }
            }
        }

        for(Case_Step__c caseStepLoopObj : [Select Id from Case_Step__c Where Case__c IN : CaseIdSet]){
            caseStepToBeDeleted.add(caseStepLoopObj);
        }

        if(caseStepToBeDeleted.size() > 0){
            delete caseStepToBeDeleted;
        }

        for (Plan_Step__c planStep : [Select Id, Name,Case_Plan__c, Associate_Case_Status__c,CreatedDate from Plan_Step__c Where Case_Plan__c IN :casePlanIdSet]) {
            if (mapOfCasePlanIdWithPlanSteps.containsKey(planStep.Case_Plan__c)) {
                mapOfCasePlanIdWithPlanSteps.get(planStep.Case_Plan__c).add(planStep);
            } else {
                mapOfCasePlanIdWithPlanSteps.put(planStep.Case_Plan__c, new List<Plan_Step__c>{
                        planStep
                });
            }
        }

        for (Case caseobj : newListCase){
            for(Id casePlanId : mapOfCasePlanIdWithPlanSteps.keySet()){
                if(casePlanId == caseobj.Case_Plan__c){
                    for(Plan_Step__c planStep : mapOfCasePlanIdWithPlanSteps.get(casePlanId)){
                        caseStepObj = new Case_Step__c();
                        caseStepObj.Name = planStep.Name;
                        caseStepObj.Case__c = caseobj.Id;
                        caseStepObj.Plan_Step__c = planStep.Id;
                        caseStepObj.PlanStepOrder__c = planStep.CreatedDate;
                        caseStepObj.Associated_Status__c = planStep.Associate_Case_Status__c;
                        listOfCaseSteptoBeCreated.add(caseStepObj);
                    }
                }
            }
        }

        if(listOfCaseSteptoBeCreated.size() > 0){
            insert listOfCaseSteptoBeCreated;
        }



    }
    public static void updateCasePlanWhenInsertAndUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        Map<String, String> mapOfActiveCasePlanWithRecordType = new Map<String, String>();
        List<RecordType> recordTypelist = new List<RecordType>();
        Map<String, String> mapOfCasePlanNameWithId = new Map<String, String>();
        for (Case_Plan_Record_Type__c casePlanSupportProcess : [Select Id, Case_Plan__c, Record_Type__c From Case_Plan_Record_Type__c]) {
            mapOfActiveCasePlanWithRecordType.put(casePlanSupportProcess.Record_Type__c, casePlanSupportProcess.Case_Plan__c);
        }
        for (RecordType recordTypeRec : [Select Id, DeveloperName from RecordType where SobjectType = 'Case']) {
            recordTypelist.add(recordTypeRec);
        }
        for (Case_Plan__c casePlan : [Select Id, Name from Case_Plan__c Where Name IN :mapOfActiveCasePlanWithRecordType.values()]) {
            mapOfCasePlanNameWithId.put(casePlan.Name, casePlan.Id);
        }
        if (oldMap == null) {
            for (case casObj : newList) {
                if (casObj.RecordTypeId != null) {
                    for (RecordType recObj : recordTypelist) {
                        if (casObj.RecordTypeId == recObj.Id) {
                            casObj.Case_Plan__c = mapOfCasePlanNameWithId.get(mapOfActiveCasePlanWithRecordType.get(recObj.DeveloperName));
                        }
                    }

                }
            }
        } else {
            for (Id oldCaseid : oldMap.keySet()) {
                for (Case caseObj : newList) {
                    if (caseObj.RecordTypeId != oldMap.get(oldCaseid).RecordTypeId) {
                        for (RecordType recObj : recordTypelist) {
                            if (caseObj.RecordTypeId == recObj.Id) {
                                caseObj.Case_Plan__c = mapOfCasePlanNameWithId.get(mapOfActiveCasePlanWithRecordType.get(recObj.DeveloperName));
                            }
                        }
                    }
                }
            }

        }
    }


}