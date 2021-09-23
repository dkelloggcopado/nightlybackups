<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Apex_Test_Results</fullName>
        <description>Apex Test Results</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>copado__Copado_Deployer/copado__NewApexTestResultSummary</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Failures_Field_on_Credential</fullName>
        <field>Latest_Number_of_Test_Failures__c</field>
        <formula>copado__Failures__c</formula>
        <name>Update Failures Field on Credential</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>copado__Org__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Send Email Alert if Failed Tests</fullName>
        <actions>
            <name>Apex_Test_Results</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>copado__Org__c.Latest_Number_of_Test_Failures__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Latest Number of Failures Field</fullName>
        <actions>
            <name>Update_Failures_Field_on_Credential</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>copado__Apex_Test_Result__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
