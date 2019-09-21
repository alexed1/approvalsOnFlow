public with sharing class GetObjectTypeFromRecordId {
  
    @InvocableMethod
    public static List <Results> GetName (List<Requests> requestList) {
        System.debug('entering GetName');
        String  recordId = requestList[0].recordId;
       
        String objectType = findObjectNameFromRecordIdPrefix(recordId);




        //Create a Results object to hold the return values
        Results response = new Results();

        //add the return values to the Results object
        response.objectType = objectType;

        //Wrap the Results object in a List container (an extra step added to allow this interface to also support bulkification)
        List<Results> responseWrapper= new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;
    
    }
    //from   https://help.salesforce.com/articleView?language=en_US&type=1&mode=1&id=000340200 functionality here.
    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){

                //if (!sObj.contains('__')) to exclude managed package objects

                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                System.debug('Prefix is ' + prefix);
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }

    public class Requests {
      @InvocableVariable(required=true)
      public String recordId; 
    }
    
    public class Results {
     
      @InvocableVariable
      public String objectType;

    }

}
