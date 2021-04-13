@IsTest
private class EggInteg_ScheduleTaskCalloutTest
{
    @IsTest
    private static void NormalTest()
    {
        String expectedResult = 'a new task id';

        MockScheduleTaskCalloutWrapper wrapper = new MockScheduleTaskCalloutWrapper();
        wrapper.statusCode = 200;
        wrapper.body = '{"task_instance_id":"' + expectedResult + '"}';

        EggInteg_ScheduleTaskCallout.setMockWrapper(wrapper);

        Test.startTest();
        String result = EggInteg_ScheduleTaskCallout.construct().execute('sdjfljs', 'dsflasdjlfj');
        Test.stopTest();

        System.assertEquals(expectedResult, result);
    }

    @IsTest
    private static void ExceptionTest()
    {
        EggInteg_ScheduleTaskCallout.setMockWrapper(new MockScheduleTaskCalloutWrapper());

        try
        {
            Test.startTest();
            EggInteg_ScheduleTaskCallout.construct().execute('sdjfljs', 'dsflasdjlfj');
            Test.stopTest();
            System.assert(false, 'An AuthenticationCalloutException was expected.');
        }
        catch (EggInteg_ScheduleTaskCallout.ScheduleTaskCalloutException exc)
        {
            // As expected
        }
        catch (Exception exc)
        {
            System.assert(false, 'An unexpected Exception occurred.');
        }
    }

    private class MockScheduleTaskCalloutWrapper
        implements EggInteg_IHttpResponseWrapper
    {
        public Integer statusCode = 9999;
        public String status = 'default';
        public String body = 'default';

        public Integer getStatusCode()
        {
            return statusCode;
        }

        public String getStatus()
        {
            return status;
        }

        public String getBody()
        {
            return body;
        }
    }
}