global class CaseMgmt_CasePlanController {

/********************************************************
Controller for CaseMgmt_CasePlan lightning component
*********************************************************/
    
    @auraEnabled
    public static CaseManager manageCase(Id recordId){
        
        CaseManager caseManagerRecord = new CaseManager();
        CaseStepDescribe curCaseStepDescribe;
        //Plan Steps are definitions/templates
        List<Plan_Step__c> planStepList = new List<Plan_Step__c>();
        //Case Steps are created for a particular case, based on the plan
        List<Case_Step__c> caseStepList = new List<Case_Step__c>();
        Boolean CaseStepPlanStepMatchFound = false; 
        
        // Fetch Case Plans and Status From Case on the basis of recordId passed from component
        List<Case> caseRecords = new List<Case>([Select Id, Status,Case_Plan__c  From Case where Id =: recordId]);
        if(!caseRecords.isEmpty()){
            caseManagerRecord.CaseStatus = caseRecords[0].Status;
        }
        // Retrieve all Plan_Steps Which have current case status and caseId, to create a wrapper and add fields according to case plan Where Case Plan Not Null and Equals to Case's Associated Case Plan
        // Associated Case Status Should be case's current status
        for(Plan_Step__c curPlanStep : [Select Id, Name, Flow__c, Start_When__c, Associate_Case_Status__c, Is_Required__c From Plan_Step__c Where Case_Plan__c =: caseRecords[0].Case_Plan__c AND Associate_Case_Status__c =: caseRecords[0].Status ORDER BY CreatedDate ASC]){
            planStepList.add(curPlanStep);
        }
        
        // Retrive all Case Steps associated with caseId and Plan Step  to create a wrapper and add fields according to case plan and Plan steps where case plan relate to case
        // Associated Flow can be null for Case Step if admin create it, if user creates it then it should contain flow name
        // Case Plan Shuld be related to Plan Steps which is Associate to Case Plan And Associate Status is Case Current Status,
        for(Case_Step__c curCaseStep : [Select Id, Name,PlanStepOrder__c, IsCompleted__c, Is_Pending__c,Associated_Status__c,Flow_By_User__c, Case__c, Plan_Step__c From Case_Step__c Where Case__c =: recordId AND (Flow_By_User__c != null OR Plan_Step__c IN : planStepList) AND Associated_Status__c =: caseRecords[0].Status  ORDER BY PlanStepOrder__c ASC]){

            caseStepList.add(curCaseStep);
        }
        
        // Check Case Step is Created by user or Admin and update describe according to user and admin.
        // The 'describe' data structures will be added to the case manager object that's returned to the LC
        for(Case_Step__c curCaseStep : caseStepList){
            //comment from the original developer on this variable, which used to be called 'flag':
            //We are using Flag Because Some of the Case Steps are creating from the Component, and when we are fetching them, they don't have any parent but have Case ids. So by Using Flag, we can differentiate and adding them to the wrapper where we can show them at the and of the steps, and all these steps don't have any Plan Step Ids, They are not required Step, No Need Of Depended Steps as well. 
            CaseStepPlanStepMatchFound = false;
            for(Plan_Step__c curPlanStep : planStepList){
                if(curCaseStep.Plan_Step__c == curPlanStep.Id && !CaseStepPlanStepMatchFound){
                    //for each matching Case Step and Plan Step, create a new case Step describe
                    curCaseStepDescribe = new CaseStepDescribe();
                    curCaseStepDescribe.StepName =  curPlanStep.Name;
                    curCaseStepDescribe.AssociateStatus = curPlanStep.Associate_Case_Status__c;
                    curCaseStepDescribe.IsRequired   = curPlanStep.Is_Required__c;
                    curCaseStepDescribe.StepFlow = curPlanStep.Flow__c;
                    curCaseStepDescribe.PlanStepId = curPlanStep.Id;
                    System.debug('curPlanStep.Start_When__c is ' + curPlanStep.Start_When__c);
                    if (curPlanStep.Start_When__c !=  null) {
                        curCaseStepDescribe.StartWhen = curPlanStep.Start_When__c;
                    } else {
                        curCaseStepDescribe.StartWhen = 'None';
                    }
                    
                    curCaseStepDescribe.CaseStepId = curCaseStep.Id;
                    curCaseStepDescribe.IsCompleted = curCaseStep.IsCompleted__c;
                    curCaseStepDescribe.IsPending = curCaseStep.Is_Pending__c;
                    caseManagerRecord.curCaseStepDescribes.add(curCaseStepDescribe);
                    CaseStepPlanStepMatchFound = true;
                }
            }
            //if there were no matches, generate this describe instead ISSUE: what is the purpose of this?
            if(!CaseStepPlanStepMatchFound){
                curCaseStepDescribe = new CaseStepDescribe();
                curCaseStepDescribe.StepName =  curCaseStep.Name;
                curCaseStepDescribe.AssociateStatus = curCaseStep.Associated_Status__c;
                curCaseStepDescribe.IsRequired   = false;
                curCaseStepDescribe.StepFlow = curCaseStep.Flow_By_User__c;
                curCaseStepDescribe.PlanStepId = null;
                curCaseStepDescribe.StartWhen = 'None';
                curCaseStepDescribe.CaseStepId = curCaseStep.Id;
                curCaseStepDescribe.IsCompleted = curCaseStep.IsCompleted__c;
                curCaseStepDescribe.IsPending = curCaseStep.Is_Pending__c;
                caseManagerRecord.curCaseStepDescribes.add(curCaseStepDescribe);
            }

        }
        // Fetch Case Plan Record Where Id of Case plan is Come from Case Associated Case Plan
        for(Case_Plan__c casepl : [SELECT Name, Id, CaseStatusOrdering__c, RecordType_SupportProcess__c, RecordTypeId__c FROM Case_Plan__c WHERE Id =: caseRecords[0].Case_Plan__c]){
            caseManagerRecord.recordCasePlan =casepl;
        }

        return caseManagerRecord;
    }
    
    
    @InvocableMethod
    public static List<String> fetchRecordTypePicklistValue(List<String> RecordIdList){
        List<String> orderStatusStringList = new List<String>();
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String restAPIURL = sfdcURL + '/services/data/v45.0/ui-api/object-info/Case/picklist-values/' +RecordIdList[0];
        caseMgmt_JSON2Apex myWrapper;
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        PageReference pg = new PageReference('/Apex/SessionIdUtilityPage');
        String sessionId ='';
        If(!test.isRunningTest()){
            sessionId = pg.getContent().toString().substringBetween('<div id="apiSeesionID">','</div>').trim();
        }

        httpRequest.setHeader('Authorization', 'OAuth ' + sessionId);
        System.debug('URL >>> ' + restAPIURL);
        httpRequest.setHeader('Authorization', 'Bearer ' + sessionId);
        httpRequest.setEndpoint(restAPIURL);
        String response = '';
        String orderString;
        try {
            If(!test.isRunningTest()){
                Http http = new Http();
                HttpResponse httpResponse = http.send(httpRequest);
                if (httpResponse.getStatusCode() == 200 ) {
                    response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                    caseMgmt_JSON2Apex selectedCse =  caseMgmt_JSON2Apex.parse(httpResponse.getBody());
                    List<caseMgmt_JSON2Apex.values> listOfStatus = selectedCse.picklistFieldValues.Status.Values;
                    for(caseMgmt_JSON2Apex.values value : listOfStatus){
                        if(orderString == null){
                            orderString = String.valueOf(value.value);
                        }else{
                            orderString = orderString + ',' + String.valueOf(value.value);
                        }
                    }
                    orderStatusStringList.add(orderString);
                } else {

                    throw new CalloutException( httpResponse.getBody() );
                }
            }
        } catch( System.Exception e) {
            
            throw e;
        }
        return orderStatusStringList;
    }
    
    public class CaseManager{
        @auraEnabled public List<CaseMgmt_CasePlanController.CaseStepDescribe> curCaseStepDescribes;
        @auraEnabled public String CaseStatus;
        @auraEnabled public Case_Plan__c recordCasePlan;
        public CaseManager(){
            curCaseStepDescribes = new List<CaseMgmt_CasePlanController.CaseStepDescribe>();
            CaseStatus = '';
            recordCasePlan = new Case_Plan__c();
        }
    }
    public class CaseStepDescribe{
        @auraEnabled public String StepName;
        @auraEnabled public String StepFlow;
        @auraEnabled public Boolean IsPending;
        @auraEnabled public Boolean IsCompleted;
        @auraEnabled public Boolean IsRequired;
        @auraEnabled public String AssociateStatus;
        @auraEnabled public String CaseStepId;
        @auraEnabled public String PlanStepId;
        @auraEnabled public String StartWhen;
    }
}