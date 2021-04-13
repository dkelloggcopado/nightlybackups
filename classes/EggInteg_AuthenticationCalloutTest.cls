@IsTest
private class EggInteg_AuthenticationCalloutTest
{
    @IsTest
    private static void NormalTest()
    {
        String expectedResult = 'hello';

        MockAuthenticationCalloutWrapper wrapper = new MockAuthenticationCalloutWrapper();
        wrapper.statusCode = 200;
        wrapper.body = '{"access_token":"' + expectedResult + '"}';

        EggInteg_AuthenticationCallout.setMockWrapper(wrapper);

        Test.startTest();
        String result = EggInteg_AuthenticationCallout.construct().execute();
        Test.stopTest();

        System.assertEquals(expectedResult, result);
    }

    @IsTest
    private static void ExceptionTest()
    {
        EggInteg_AuthenticationCallout.setMockWrapper(new MockAuthenticationCalloutWrapper());

        try
        {
            Test.startTest();
            String result = EggInteg_AuthenticationCallout.construct().execute();
            Test.stopTest();
            System.assert(false, 'An AuthenticationCalloutException was expected.');
        }
        catch (EggInteg_AuthenticationCallout.AuthenticationCalloutException exc)
        {
            // As expected
        }
        catch (Exception exc)
        {
            System.assert(false, 'An unexpected Exception occurred.');
        }
    }

    private class MockAuthenticationCalloutWrapper
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