/**
 * Purpose : Trigger will be fired when new case is created or existing one updated
 * generates the Case Step records for the case in accordance with the Plan Steps defined for the active Case Plan
 * Handler Name: caseToAddCaseStepsTriggerHandler
 */

trigger generateCaseStepsTrigger on Case (after insert, after update, before insert, before update) {

    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        generateCaseStepsHandler.beforeInsertAndUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        generateCaseStepsHandler.afterInsertAndUpdate(trigger.new, trigger.oldMap);
    }
}