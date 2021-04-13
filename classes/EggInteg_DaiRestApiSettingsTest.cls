@IsTest
private class EggInteg_DaiRestApiSettingsTest
{
    @IsTest
    private static void NormalUsage()
    {
        Eggplant_Integration__c mockSetting = new Eggplant_Integration__c();
        mockSetting.username__c = 'GeorgeOfTheJungle';
        mockSetting.password__c = 'shhh_dont_tell_anyone';
        mockSetting.server__c = 'waiter.com';

        EggInteg_DaiRestApiSettings.mock_Eggplant_CustomSetting_Record = mockSetting;

        Test.startTest();
        EggInteg_IDaiRestApiSettings settings = EggInteg_DaiRestApiSettings.construct();
        Test.stopTest();

        System.assertEquals(mockSetting.username__c, settings.getUsername());
        System.assertEquals(mockSetting.password__c, settings.getPassword());
        System.assertEquals(mockSetting.server__c, settings.getServer());
    }

    @IsTest
    private static void ReturnsMockInstanceWhenProvided()
    {
        String testUsername = 'GeorgeOfTheJungle';
        DaiRestApiSettingsMock mockSetting = new DaiRestApiSettingsMock();
        mockSetting.userName = testUsername;

        EggInteg_DaiRestApiSettings.setMock(mockSetting);

        Test.startTest();
        EggInteg_IDaiRestApiSettings settings = EggInteg_DaiRestApiSettings.construct();
        Test.stopTest();

        System.assertEquals(testUsername, mockSetting.getUsername());
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