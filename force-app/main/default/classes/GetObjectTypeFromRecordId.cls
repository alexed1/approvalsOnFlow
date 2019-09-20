public with sharing class GetObjectTypeFromRecordId {
  
    @InvocableMethod
    public static List <Results> GetName (List<Requests> requestList) {
        System.debug('entering GetName');
        String  recordId = requestList[0].recordId;
       
        //insert the https://help.salesforce.com/articleView?language=en_US&type=1&mode=1&id=000340200 functionality here.






        //Create a Results object to hold the return values
        Results response = new Results();

        //add the return values to the Results object
         

        //Wrap the Results object in a List container (an extra step added to allow this interface to also support bulkification)
        List<Results> responseWrapper= new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;
    
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
