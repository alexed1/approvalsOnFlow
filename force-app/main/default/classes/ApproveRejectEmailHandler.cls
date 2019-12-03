
global class ApproveRejectEmailHandler implements Messaging.InboundEmailHandler {
    private static final Map<String, String> RESPONSE_TO_STEP_STATUS_MAP = new Map<String, String>{
            'approve' => 'Approved',
            'approved' => 'Approved',
            'reject' => 'Rejected',
            'rejected' => 'Rejected'
    };

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
            Messaging.InboundEnvelope envelope) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String emailBody = email.plainTextBody;

        Pattern myPattern = pattern.compile('(?<=processStepTaskId=).{18}');
        Matcher m = myPattern.matcher(emailBody);
        m.find();
        Id stepTaskId = (Id) m.group(0);

        myPattern = pattern.compile('\\w*');
        m = myPattern.matcher(emailBody);
        m.find();
        String stepAction = m.group(0);

        if (RESPONSE_TO_STEP_STATUS_MAP.get(stepAction.toLowerCase()) != null) {
            update (new Approval_Process_Step_Task__c(Id = stepTaskId, Status__c = RESPONSE_TO_STEP_STATUS_MAP.get(stepAction.toLowerCase())));
            Map<String, Object> params = new Map<String, Object>();
            params.put('CurrentStepTaskId', stepTaskId);
            params.put('TakenAction', RESPONSE_TO_STEP_STATUS_MAP.get(stepAction.toLowerCase()));
            Flow.Interview.AP_Main_Response_Handler calcFlow = new Flow.Interview.AP_Main_Response_Handler(params);
            calcFlow.start();
        }

        result.success = true;
        return result;
    }
}


