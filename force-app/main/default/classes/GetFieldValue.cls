public with sharing class GetFieldValue {

    @InvocableMethod
    public static List <Results> getFieldValue(List<Requests> requestList) {

        Id recordId = requestList[0].recordId;
        String filterValue = requestList[0].filterValue;
        String filterField = requestList[0].filterField;
        String fieldName = requestList[0].fieldName;
        String objectType = requestList[0].objectType;
        //Create a Results object to hold the return values
        Results response = new Results();
        try {
            if (recordId != null && objectType == null) {
                objectType = recordId.getSobjectType().getDescribe().getName();
            }

            String query = 'SELECT ' + fieldName + ' FROM ' + objectType + ' WHERE ' + filterField + '=:filterValue LIMIT 1';
            List<sObject> objects = Database.query(query);
            if (!objects.isEmpty()) {
                String fieldValue = (String) objects[0].get(fieldName);
                response.fieldValue = fieldValue;
            }else{
                response.errors = 'Query returned no results';
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
        @InvocableVariable
        public String recordId;
        @InvocableVariable
        public String objectType;
        @InvocableVariable(required=true)
        public String fieldName;
        @InvocableVariable(required=true)
        public String filterField;
        @InvocableVariable(required=true)
        public String filterValue;
    }

    public class Results {

        @InvocableVariable
        public String fieldValue;
        @InvocableVariable
        public String errors;
    }
}