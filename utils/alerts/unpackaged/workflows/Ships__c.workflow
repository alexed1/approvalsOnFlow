<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert</fullName>
        <description>Approval Initiated</description>
        <protected>false</protected>
        <recipients>
            <recipient>alextest@edelstein.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Approval_Initiated</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_for_Ship_2</fullName>
        <description>Email Alert for Ship 2</description>
        <protected>false</protected>
        <recipients>
            <recipient>alextest@edelstein.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/alexapproval2</template>
    </alerts>
    <alerts>
        <fullName>Step_Approved</fullName>
        <description>Step Approved</description>
        <protected>false</protected>
        <recipients>
            <recipient>alextest@edelstein.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Approval_Step_Approved</template>
    </alerts>
    <alerts>
        <fullName>Step_Rejected</fullName>
        <description>Step Rejected</description>
        <protected>false</protected>
        <recipients>
            <recipient>alextest@edelstein.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Approval_Step_Rejected</template>
    </alerts>
</Workflow>
