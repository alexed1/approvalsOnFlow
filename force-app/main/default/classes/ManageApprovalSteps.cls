global with sharing class ManageApprovalSteps {

    @AuraEnabled(cacheable=true)
    public static List<SearchUtils.Member> getApprovalProcessSteps(Id approvalProcessId) {
        List<ApprovalProcessStepDefinition__c> steps = [SELECT Id, Name FROM ApprovalProcessStepDefinition__c WHERE ApprovalProcessDefinition__c = :approvalProcessId ORDER BY Order__c ASC];
        List<SearchUtils.Member> members = new List<SearchUtils.Member>();
        for (ApprovalProcessStepDefinition__c step : steps) {
            members.add(new SearchUtils.Member(step.Name, step.Id));
        }

        return members;
    }

    @AuraEnabled
    public static void saveApprovalSteps(List<ApprovalProcessStepDefinition__c> appSteps) {
        update appSteps;
    }
}