global with sharing class InitialSubmittersSelectController {

    static final Map<String, String> TYPE_TO_QUERY = new Map<String, String>{
            'User' => 'User WHERE IsActive = true',
            'Role and Subordinates' => 'UserRole',
            'Role' => 'UserRole',
            'Public Group' => 'Group WHERE Type = \'Public\'',
            'Queue' => 'Group WHERE Type = \'Queue\''
    };

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Submitter>> getSubmittersPerType(List<String> submitterTypes) {
        Map<String, List<Submitter>> resultMap = new Map<String, List<Submitter>>();

        for (String curType : TYPE_TO_QUERY.keySet()) {
            if (!submitterTypes.contains(curType)) {
                continue;
            }
            List<SObject> types = Database.query('SELECT Id, Name FROM ' + TYPE_TO_QUERY.get(curType));
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