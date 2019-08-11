global with sharing class InitialSubmittersSelectController {

    static final Map<String, String> TYPE_TO_QUERY = new Map<String, String>{
            'user' => 'User WHERE IsActive = true AND Name LIKE (searchString)',
            'role_subordinates' => 'UserRole WHERE Name LIKE (searchString)',
            'role' => 'UserRole WHERE Name LIKE (searchString)',
            'group' => 'Group WHERE Type = \'Public\' AND Name LIKE (searchString)',
            'queue' => 'Group WHERE Type = \'Queue\' AND Name LIKE (searchString)'
    };

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Submitter>> getSubmittersPerType(List<String> submitterTypes, String searchString) {
        Map<String, List<Submitter>> resultMap = new Map<String, List<Submitter>>();

        for (String curType : TYPE_TO_QUERY.keySet()) {
            if (!submitterTypes.contains(curType)) {
                continue;
            }
            String queryString = 'SELECT Id, Name FROM ' + TYPE_TO_QUERY.get(curType).replace('(searchString)', '\'%' + String.escapeSingleQuotes(searchString) + '%\'');

            List<SObject> types = Database.query(queryString);
            List<Submitter> submitters = new List<Submitter>();
            for (SObject t : types) {
                submitters.add(new Submitter((String) t.get('Name'), (String) t.get('Id')));
            }
            resultMap.put(curType, submitters);
        }

        return resultMap;
    }

    global class Submitter {
        @AuraEnabled global String label;
        @AuraEnabled global String value;
        public Submitter(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}