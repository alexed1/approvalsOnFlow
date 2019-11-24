public with sharing class CountFieldValues {
    @InvocableMethod
    public static List <Results> countFieldValues(List<Requests> requestList) {

        List<Approval_Process_Step_Task__c> records = requestList[0].records;
        String fieldName = requestList[0].fieldName;
        String fieldValue = requestList[0].fieldValue;

        //Create a Results object to hold the return values
        Results response = new Results();
        try {
            for (Approval_Process_Step_Task__c record : records) {
                if (record.get(fieldName) == fieldValue) {
                    response.matchedNumber++;
                }
                response.totalNumber++;
            }
        } catch (Exception ex) {
            response.errors = ex.getMessage();
        }

//Wrap the Results object in a List container (an extra step added to allow this interface to also support bulkification)
        List<Results> responseWrapper = new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;

    }

    public class Requests {
        @InvocableVariable(required=true)
        public List<Approval_Process_Step_Task__c> records;
        @InvocableVariable(required=true)
        public String fieldName;
        @InvocableVariable(required=true)
        public String fieldValue;
    }

    public class Results {
        public Results() {
            this.errors = '';
            this.matchedNumber = 0;
            this.totalNumber = 0;
        }
        @InvocableVariable
        public Integer matchedNumber;
        @InvocableVariable
        public Integer totalNumber;
        @InvocableVariable
        public String errors;
    }
}