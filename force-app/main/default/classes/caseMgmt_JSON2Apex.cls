public with sharing class caseMgmt_JSON2Apex {
    public class Status {
        public List<Values> values {get;set;}
        public String url {get;set;}
        public String eTag {get;set;}
        public Values defaultValue {get;set;}
        public ValidFor controllerValues {get;set;}

        public Status(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'values') {
                            values = arrayOfValues(parser);
                        } else if (text == 'url') {
                            url = parser.getText();
                        } else if (text == 'eTag') {
                            eTag = parser.getText();
                        } else if (text == 'defaultValue') {
                            defaultValue = new Values(parser);
                        } else if (text == 'controllerValues') {
                            controllerValues = new ValidFor(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Status consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Type_Z {
        public List<Values> values {get;set;}
        public String url {get;set;}
        public String eTag {get;set;}
        public Object defaultValue {get;set;}
        public ValidFor controllerValues {get;set;}

        public Type_Z(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'values') {
                            values = arrayOfValues(parser);
                        } else if (text == 'url') {
                            url = parser.getText();
                        } else if (text == 'eTag') {
                            eTag = parser.getText();
                        } else if (text == 'defaultValue') {
                            defaultValue = parser.readValueAs(Object.class);
                        } else if (text == 'controllerValues') {
                            controllerValues = new ValidFor(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Type_Z consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public PicklistFieldValues picklistFieldValues {get;set;}
    public String eTag {get;set;}

    public caseMgmt_JSON2Apex(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'picklistFieldValues') {
                        picklistFieldValues = new PicklistFieldValues(parser);
                    } else if (text == 'eTag') {
                        eTag = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public class Values {
        public String value {get;set;}
        public List<ValidFor> validFor {get;set;}
        public String label {get;set;}
        public Object attributes {get;set;}

        public Values(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'value') {
                            value = parser.getText();
                        } else if (text == 'validFor') {
                            validFor = arrayOfValidFor(parser);
                        } else if (text == 'label') {
                            label = parser.getText();
                        } else if (text == 'attributes') {
                            attributes = parser.readValueAs(Object.class);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Values consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class PicklistFieldValues {
        public Type_Z Type_Z {get;set;} // in json: Type
        public Status Status {get;set;}
        public Type_Z Reason {get;set;}
        public Status Priority {get;set;}
        public Type_Z Origin {get;set;}

        public PicklistFieldValues(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Type') {
                            Type_Z = new Type_Z(parser);
                        } else if (text == 'Status') {
                            Status = new Status(parser);
                        } else if (text == 'Reason') {
                            Reason = new Type_Z(parser);
                        } else if (text == 'Priority') {
                            Priority = new Status(parser);
                        } else if (text == 'Origin') {
                            Origin = new Type_Z(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'PicklistFieldValues consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class ValidFor {

        public ValidFor(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        {
                            System.debug(LoggingLevel.WARN, 'ValidFor consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }


    public static caseMgmt_JSON2Apex parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new caseMgmt_JSON2Apex(parser);
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





    private static List<Values> arrayOfValues(System.JSONParser p) {
        List<Values> res = new List<Values>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Values(p));
        }
        return res;
    }





    private static List<ValidFor> arrayOfValidFor(System.JSONParser p) {
        List<ValidFor> res = new List<ValidFor>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ValidFor(p));
        }
        return res;
    }
}