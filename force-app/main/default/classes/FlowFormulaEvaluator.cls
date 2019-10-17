public with sharing class FlowFormulaEvaluator {
    @InvocableMethod
    public static List <Results> execute(List<Requests> requestList) {
        String contextObjectId = requestList[0].contextObjectId;
        String apDefinitionId = requestList[0].apDefinitionId;
        List<ApprovalProcessDefinition__c> ap = [SELECT Id, EntryCriteria__c FROM ApprovalProcessDefinition__c WHERE Id = :apDefinitionId];
        List<Results> responseWrapper = new List<Results>();
        if (!ap.isEmpty()) {
            List<FormulaEvaluator.ContextWraper> context = new List<FormulaEvaluator.ContextWraper>();
            context.add(new FormulaEvaluator.ContextWraper('$Record', contextObjectId));
            String stringContext = JSON.serialize(context);
            String formula = ap[0].EntryCriteria__c;
            responseWrapper.add(new Results(FormulaEvaluator.parseFormula(formula, stringContext)));
        }

        return responseWrapper;

    }
    public class Requests {
        @InvocableVariable(required=true)
        public String contextObjectId;

        @InvocableVariable(required=true)
        public String apDefinitionId;

    }

    public class Results {
        @InvocableVariable
        public String formulaValue;
        public Results(String formulaValue) {
            this.formulaValue = formulaValue;
        }
    }
}