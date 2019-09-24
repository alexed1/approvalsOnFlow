
public with sharing class GenerateTestRecords {
  
    @InvocableMethod
    public static List<Results> generate(List<Requests> requestList) {
        ApprovalProcessDefinition__c curAPD = generateApprovalProcessDefinition1();
        ApprovalProcessStepDefinition__c curAPStep = generateApprovalProcessStepDefinition(curAPD.Id, 'Step 1');
         generateApprover(curAPStep.Id, 'mikeManager@aof.org', 'User');

        curAPStep = generateApprovalProcessStepDefinition(curAPD.Id, 'Step 2');
        generateApprover(curAPStep.Id, 'dianneDirector@aof.org', 'User');


        //Create a Results object to hold the return values
        Results response = new Results();

        //add the return values to the Results object
 
        
        //Wrap the Results object in a List container (an extra step added to allow this interface to also support bulkification)
        List<Results> responseWrapper= new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;
    }

    public static ApprovalProcessDefinition__c generateApprovalProcessDefinition1() {
        ApprovalProcessDefinition__c curAPD = new ApprovalProcessDefinition__c();
        curAPD.Label__c = 'testDef1';
        insert curAPD;

        //ApprovalProcessStepDefinition__c[] APsteps = new ApprovalProcessStepDefinition__c();
        curAPD = [SELECT Id FROM ApprovalProcessDefinition__c WHERE Label__c='testDef1'];
        generateApprovalSubmitter(curAPD.Id);
        
        return curAPD;
    }

    public static void generateApprovalSubmitter (String curAPD_Id) {
        AP_AllowedSubmitter__c curSubmitter = new AP_AllowedSubmitter__c();
        curSubmitter.Parent_Approval_Process_Definition__c = curAPD_Id;
        curSubmitter.Type__c = 'User';
        curSubmitter.Name = UserInfo.getUserId();
        insert curSubmitter;
    }
     


    public static ApprovalProcessStepDefinition__c generateApprovalProcessStepDefinition(String APD_Id, String Label) {
        ApprovalProcessStepDefinition__c step = new ApprovalProcessStepDefinition__c();
        step.ApprovalProcessDefinition__c = APD_Id;
        step.Label__c = Label;
        insert step;

        step = [SELECT Id FROM ApprovalProcessStepDefinition__c WHERE Label__c = :Label];
        return step;
    }

     public static void generateApprover (String curAPStepId, String Name, String Type) {
        Approver__c approver = new Approver__c();
        approver.Approval_Process_Step_Definition__c = curAPStepId;
        approver.Name = Name;
        approver.Type__c = Type;
        insert approver;
    } 

    public class Requests {

      @InvocableVariable
      public String input; //unused so far
        
    }
    
    public class Results {
     
      @InvocableVariable
      public String output; //unused so far

    }
}
