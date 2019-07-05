@isTest(SeeAllData=true)
private class caseMgmt_CasePlanControllerTest {
    public static testMethod void testf0rCallout(){
        Test.setMock(HTTPCalloutMock.class, new MockHttpResponseGenrator());
        
        Id caseID = [Select Id from Case Limit 1].Id;
        CaseMgmt_CasePlanController.CaseManager caseManagerData = CaseMgmt_CasePlanController.manageCase(caseID);
        List<RecordType> rcType = new List<RecordType>();
        rcType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Case'];
        List<Case_Plan__c> casePlanList = [Select Id from Case_Plan__c];
        Plan_Step__c ps = new Plan_Step__c();
        ps.Name = 'Test Plan';
        ps.Case_Plan__c = casePlanList[0].Id;
        insert ps;
        Case caseInsertObj = new Case();
        caseInsertObj.Subject = 'Test';
        caseInsertObj.Case_Plan__c = casePlanList[0].Id;
        caseInsertObj.RecordTypeId = rcType[0].Id;
        insert caseInsertObj;
        List<String> listOfArgument= new List<String>();
        System.debug('SD : ' + rcType[0].Id);
        listOfArgument.add(rcType[0].Id);
        List<String> cm = CaseMgmt_CasePlanController.fetchRecordTypePicklistValue(listOfArgument);
    }
}