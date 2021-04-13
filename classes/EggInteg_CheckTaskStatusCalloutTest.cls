@IsTest
@TestVisible
private class EggInteg_CheckTaskStatusCalloutTest
{
    @IsTest
    private static void NormalTest()
    {
        String expectedResult = 'desired_status';

        MockCheckTaskStatusCalloutWrapper wrapper = new MockCheckTaskStatusCalloutWrapper();
        wrapper.statusCode = 200;
        wrapper.body = createResponseJson(expectedResult);

        EggInteg_CheckTaskStatusCallout.setMockWrapper(wrapper);

        Test.startTest();
        String result = EggInteg_CheckTaskStatusCallout.construct().execute('sdjfljs', 'dsflasdjlfj');
        Test.stopTest();

        EggInteg_CheckTaskStatusCallout.ScheduleTaskCalloutResponse response =
            (EggInteg_CheckTaskStatusCallout.ScheduleTaskCalloutResponse)
            JSON.deserialize(result, EggInteg_CheckTaskStatusCallout.ScheduleTaskCalloutResponse.class);

        System.assertEquals(expectedResult, response.runstatus);
    }

    @IsTest
    private static void ExceptionTest()
    {
        EggInteg_CheckTaskStatusCallout.setMockWrapper(new MockCheckTaskStatusCalloutWrapper());

        try
        {
            Test.startTest();
            EggInteg_CheckTaskStatusCallout.construct().execute('sdjfljs', 'dsflasdjlfj');
            Test.stopTest();
            System.assert(false, 'An AuthenticationCalloutException was expected.');
        }
        catch (EggInteg_CheckTaskStatusCallout.CheckTaskStatusCalloutException exc)
        {
            // As expected
        }
        catch (Exception exc)
        {
            System.assert(false, 'An unexpected Exception occurred.');
        }
    }

    @TestVisible
    public static String createResponseJson(String status)
    {
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX';
        return
            '{'
            + '"created_datetime": "' + Datetime.newInstance(2021, 3, 25, 9, 6, 0).format(dateFormat) + '",'
            + '"runstatus": "' + status + '",'
            + '"test_config_id": "ksjdfljlksjfls",'
            + '"task_instance_id": "euoghgvnueqh",'
            + '"updated_datetime": "' + Datetime.newInstance(2021, 3, 25, 9, 13, 0).format(dateFormat) + '",'
            + '"messages": ['
                + '{'
                + '"id": "vnnfedsninsl",'
                + '"created": "' + Datetime.newInstance(2021, 3, 25, 9, 6, 0).format(dateFormat) + '",'
                + '"task_instance_id": "vnnfedsninsl",'
                + '"sender": "some_random_service",'
                + '"severity": "informational",'
                + '"message": "this is what i have to say",'
                + '"error_time": "' + Datetime.newInstance(2021, 3, 25, 9, 6, 0).format(dateFormat) + '"'
                + '}'
            + ']'
            + '}';
    }

    private class MockCheckTaskStatusCalloutWrapper
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