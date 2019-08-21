global with sharing class InitialSubmittersSelectController {

    static final Map<String, String> TYPE_TO_SOBJECT = new Map<String, String>{
            'User' => 'User',
            'Role_subordinates' => 'UserRole',
            'Role' => 'UserRole',
            'Group' => 'Group',
            'Queue' => 'Group'
    };

    static final Map<String, String> TYPE_TO_QUERY_CRITERIA = new Map<String, String>{
            'User' => 'WHERE IsActive = true AND Name LIKE (searchString)',
            'Role_subordinates' => 'WHERE Name LIKE (searchString)',
            'Role' => 'WHERE Name LIKE (searchString)',
            'Group' => 'WHERE (Type = \'Public\' OR Type = \'Regular\') AND Name LIKE (searchString)',
            'Queue' => 'WHERE Type = \'Queue\' AND Name LIKE (searchString)'
    };


    @AuraEnabled(cacheable=true)
    public static Map<String, List<Submitter>> searchSubmittersByType(List<String> submitterTypes, String searchString) {
        Map<String, List<Submitter>> resultMap = new Map<String, List<Submitter>>();

        for (String curType : TYPE_TO_SOBJECT.keySet()) {

            if (!submitterTypes.contains(curType)) {
                continue;
            }
            String queryString = 'SELECT Id, Name FROM ' + TYPE_TO_SOBJECT.get(curType) + ' ' + TYPE_TO_QUERY_CRITERIA.get(curType).replace('(searchString)', '\'%' + String.escapeSingleQuotes(searchString) + '%\'');

            List<SObject> types = Database.query(queryString);
            List<Submitter> submitters = new List<Submitter>();
            for (SObject t : types) {
                submitters.add(new Submitter((String) t.get('Name'), (String) t.get('Id')));
            }
            resultMap.put(curType, submitters);
        }

        return resultMap;
    }
    public static Map<String, String> getSubmittersByTypeAndId(Map<String, Set<String>> typeToIds) {

        Map<String, String> results = new Map<String, String>();
        for (String sObjectTypeName : typeToIds.keySet()) {
            Set<String> objectIds = typeToIds.get(sObjectTypeName);
            String queryString = 'SELECT Id, Name FROM ' + TYPE_TO_SOBJECT.get(sObjectTypeName) + ' WHERE Id IN: objectIds';

            List<SObject> shares = Database.query(queryString);
            for (SObject curShare : shares) {
                results.put((String) curShare.get('Id'), (String) curShare.get('Name'));
            }
        }
        return results;
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