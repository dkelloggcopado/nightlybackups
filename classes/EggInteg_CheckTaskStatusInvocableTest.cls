@IsTest
private class EggInteg_CheckTaskStatusInvocableTest
{
    @IsTest
    private static void test()
    {
        String expectedValue = 'SUCCESS';
        EggInteg_IHttpResponseWrapper mockHttpResponseWrapper = 
            new EggInteg_HttpResponseWrapper(
                200, 
                'okay', 
                EggInteg_CheckTaskStatusCalloutTest.createResponseJson(expectedValue)
            );

        EggInteg_CheckTaskStatusCallout.setMockWrapper(mockHttpResponseWrapper);

        EggInteg_CheckTaskStatusCalloutInvocable.CheckTaskStatusInput input = new EggInteg_CheckTaskStatusCalloutInvocable.CheckTaskStatusInput();
        input.access_token = 'slkdjflksjlf';
        input.task_instance_id = 'fbwfioqioqnc';

        Test.startTest();
        List<EggInteg_CheckTaskStatusCalloutInvocable.CheckTaskStatusOutput> outputList = EggInteg_CheckTaskStatusCalloutInvocable.checkTaskStatus(new List<EggInteg_CheckTaskStatusCalloutInvocable.CheckTaskStatusInput> {input});
        Test.stopTest();

        System.assertEquals(expectedValue, outputList.get(0).runstatus);
    }
}