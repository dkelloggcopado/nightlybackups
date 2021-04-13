@IsTest
private class EggInteg_AuthenticationInvocableTest
{
    @IsTest
    private static void test()
    {
        String expectedValue = 'not really a guid';

        EggInteg_DaiRestApiSettings.setMock(new DaiRestApiSettingsMock());

        EggInteg_IHttpResponseWrapper mockHttpResponseWrapper = 
            new EggInteg_HttpResponseWrapper(
                200, 
                'okay', 
                '{"access_token": "' + expectedValue + '"}'
            );
        EggInteg_AuthenticationCallout.setMockWrapper(mockHttpResponseWrapper);

        Test.startTest();
        List<EggInteg_AuthenticationInvocable.AuthenticationOutput> outputList = EggInteg_AuthenticationInvocable.authenticate();
        Test.stopTest();

        System.assertEquals(expectedValue, outputList.get(0).access_token);
    }

    private class DaiRestApiSettingsMock
        implements EggInteg_IDaiRestApiSettings
    {
        public String username = 'default';
    
        public String getUserName()
        {
            return username;
        }

        public String password = 'default';

        public String getPassword()
        {
            return password;
        }

        public String server = 'default';

        public String getServer()
        {
            return server;
        }
    }
}