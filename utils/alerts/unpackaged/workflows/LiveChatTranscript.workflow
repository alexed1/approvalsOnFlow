<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Attach Contact ID</fullName>
        <active>false</active>
        <criteriaItems>
            <field>LiveChatTranscript.ContactId</field>
            <operation>notEqual</operation>
            <value>asdfasdfasdfsa</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
