global class ApprovalResponseEmailHandler implements Messaging.InboundEmailHandler {

    private static final String ACTION_APPROVE = 'approve';
    private static final String ACTION_REJECT = 'reject';
    private static final String RECORD_ID_PREFIX = '#APST';
    private static final String RECORD_ID_SUFIX = '\n';

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,
            Messaging.InboundEnvelope env) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String actionResponse;
        String recordId;
        String emailBody = email.plainTextBody;
        if (emailBody.toLowerCase().indexOf(ACTION_APPROVE) == 0) {
            actionResponse = ACTION_APPROVE;
        } else if (emailBody.toLowerCase().indexOf(ACTION_REJECT) == 0) {
            actionResponse = ACTION_REJECT;
        }

        Integer recordIdPrefixIndex = emailBody.indexOf(RECORD_ID_PREFIX);
        if (recordIdPrefixIndex > 0) {
            recordId = emailBody.substring(recordIdPrefixIndex, emailBody.indexOf(RECORD_ID_SUFIX, recordIdPrefixIndex));
        }
        if (actionResponse != null && recordId != null) {
            result.success = true;
        } else {
            result.success = false;
        }

        if(result.success){
            Map<String, Object> params = new Map<String, Object>();
            params.put('stepTaskID', recordId);
            params.put('actionResponse', actionResponse);
            Flow.Interview.AP_Main_Response_Handler calcFlow = new Flow.Interview.AP_Main_Response_Handler(params);
            calcFlow.start();
        }

        return result;
    }
}