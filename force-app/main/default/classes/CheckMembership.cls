public with sharing class CheckMembership {

  
    @InvocableMethod
    public static List <Results> ExecuteMembershipCheck (List<Requests> requestList) {
        System.debug('entering ExecuteMembershipCheck');
        String  targetUsername = requestList[0].targetUsername;
        List<String>  memberUsernames = requestList[0].memberUsernames;
        Boolean isMember = false;
        System.debug ('memberUsernames is: ' + memberUsernames);
        System.debug ('targetUsername is ' + targetUsername);
        if (memberUsernames.contains(targetUsername)) {
          isMember = true;
        }

       //TO DO
       //implement the others
       //find out what the user's role is and check it against roles that are allowed submitters
       //for each group, find out if the user is in that group




        //Create a Results object to hold the return values
        Results response = new Results();

        //add the return values to the Results object
        response.isMember = isMember;

        //Wrap the Results object in a List container (an extra step added to allow this interface to also support bulkification)
        List<Results> responseWrapper= new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;
    
    }

    public class Requests {
      @InvocableVariable(required=true)
      public String targetUsername; 

      @InvocableVariable 
      public List<String> memberUsernames; //although the UI has separate search categories for Users, Owner, Creator, Partner Users, and Customer Portal Users, it appears that these are all just User records and can be treated as one set.

      @InvocableVariable 
      public List<String> memberRoleNames; 

      @InvocableVariable 
      public String includeRoleSubordinates; //values appear to be RoleOnly, RolePlusInternalSubordinates, RolePlusSubordinates. hold off on implementing this for now

      @InvocableVariable 
      public List<String> memberGroupNames;

      
    }
    
    public class Results {
     
      @InvocableVariable
      public Boolean isMember;

    }



}
