@IsTest
private class EggInteg_ScheduleTaskCalloutInvocbleTest
{
    @IsTest
    private static void test()
    {
        String expectedValue = 'not really a guid';
        EggInteg_IHttpResponseWrapper mockHttpResponseWrapper = 
            new EggInteg_HttpResponseWrapper(
                200, 
                'okay', 
                '{"task_instance_id": "' + expectedValue + '"}'
            );

        EggInteg_ScheduleTaskCallout.setMockWrapper(mockHttpResponseWrapper);

        EggInteg_ScheduleTaskCalloutInvocable.ScheduleTaskInput input = new EggInteg_ScheduleTaskCalloutInvocable.ScheduleTaskInput();
        input.access_token = 'slkdjflksjlf';
        input.task_id = 'fbwfioqioqnc';

        Test.startTest();
        List<EggInteg_ScheduleTaskCalloutInvocable.ScheduleTaskOutput> outputList = EggInteg_ScheduleTaskCalloutInvocable.scheduleAndRunTask(new List<EggInteg_ScheduleTaskCalloutInvocable.ScheduleTaskInput> {input});
        Test.stopTest();

        System.assertEquals(expectedValue, outputList.get(0).task_instance_id);
    }
}