<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Onboarding_Welcome_Email</fullName>
        <description>Onboarding: Welcome Email</description>
        <protected>false</protected>
        <recipients>
            <field>New_Hire__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Onboarding_Day_1_email</template>
    </alerts>
</Workflow>
