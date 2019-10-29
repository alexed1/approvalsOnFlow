public with sharing class FlowFormulaEvaluator {
    @InvocableMethod
    public static List <Results> execute(List<Requests> requestList) {
        String contextObjectId = requestList[0].contextObjectId;
        String formula = requestList[0].formula;

        List<Results> responseWrapper = new List<Results>();
        List<FormulaEvaluator.ContextWrapper> context = new List<FormulaEvaluator.ContextWrapper>();

        context.add(new FormulaEvaluator.ContextWrapper('$Record', contextObjectId));
        String stringContext = JSON.serialize(context);
        responseWrapper.add(new Results(FormulaEvaluator.parseFormula(formula, stringContext)));

        return responseWrapper;
    }
    public class Requests {
        @InvocableVariable(required=true)
        public String contextObjectId;

        @InvocableVariable(required=true)
        public String formula;

    }

    public class Results {
        @InvocableVariable
        public String formulaValue;
        @InvocableVariable
        public Boolean isSuccess;
        @InvocableVariable
        public String errors;
        public Results(String formulaValue) {
            this.isSuccess = formulaValue != null;
            if (!this.isSuccess) {
                this.errors = Label.UnableToParseFormulaMessage;
            }
            this.formulaValue = formulaValue;
        }
    }
}