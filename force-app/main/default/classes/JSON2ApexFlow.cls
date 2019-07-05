/**
 * Created by Shubham on 2/7/2019.
 JSON response parser used in CaseMgmt_FlowRestAPI controller class
 */

public with sharing class JSON2ApexFlow {
    public List<Actions> actions {get;set;}

    public JSON2ApexFlow(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'actions') {
                        actions = arrayOfActions(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public class Actions {
        public String label {get;set;}
        public String name {get;set;}
        public String type_Z {get;set;} // in json: type
        public String url {get;set;}

        public Actions(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'label') {
                            label = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'type') {
                            type_Z = parser.getText();
                        } else if (text == 'url') {
                            url = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Actions consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }


    public static JSON2ApexFlow parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new JSON2ApexFlow(parser);
    }

    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT ||
                    curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                    curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    private static List<Actions> arrayOfActions(System.JSONParser p) {
        List<Actions> res = new List<Actions>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Actions(p));
        }
        return res;
    }
}