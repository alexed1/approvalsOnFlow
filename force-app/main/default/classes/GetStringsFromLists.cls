//Given a list of SObjects, return a list of Strings corresponding to a specified fieldname
public with sharing class GetStringsFromLists {

  
    @InvocableMethod
    public static List <Results> getStrings (List<Requests> requestList) {
        System.debug('entering getStrings');
        List<String> outputStrings =  new List<String>();
        
        String targetField = requestList[0].fieldName;
        List<AP_AllowedSubmitter__c>   inputCollection = requestList[0].inputCollection;
        System.debug('before loop');
        if (inputCollection != null) {
            System.debug('entering loop');
            //for each item,
            //get the record
            //get the value of the field
            //add it to outputSTrings
              for(AP_AllowedSubmitter__c curSubmitter : inputCollection) {
                outputStrings.add(String.valueOf(curSubmitter.get(targetField)));
              }
        }
        

        
        //Create a Results object to hold the return values
        Results response = new Results();

        //add the return values to the Results object
        response.stringList = outputStrings;

        //Wrap the Results object in a List container (an extra step added to allow this interface to also support bulkification)
        List<Results> responseWrapper= new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;
    
    }

    public class Requests {

      public Requests () {
        this.inputCollection = new List<AP_AllowedSubmitter__c>();
      }

      @InvocableVariable //don't make required because it blows up if user passes in null
      public List<AP_AllowedSubmitter__c> inputCollection; //for Spring '20 change this to a dynamic

      @InvocableVariable(required=true)
      public String fieldName;
        
    }
    
    public class Results {
     
      @InvocableVariable
      public List<String> stringList;

    }

}