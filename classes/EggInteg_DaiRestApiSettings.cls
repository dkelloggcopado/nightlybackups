public inherited sharing class EggInteg_DaiRestApiSettings
    implements EggInteg_IDaiRestApiSettings
{
    private String username;
    private String password;
    private String server;

    public static EggInteg_IDaiRestApiSettings construct()
    {
        if (mock_instance != null)
        {
            return mock_instance;
        }

        return new EggInteg_DaiRestApiSettings();
    }

    public String getUsername()
    {
        return username;
    }

    public String getPassword()
    {
        return password;
    }

    public String getServer()
    {
        return server;
    }

    private EggInteg_DaiRestApiSettings()
    {
        Eggplant_Integration__c setting = getCustomSettingRecord();
        username = setting?.Username__c;
        password = setting?.Password__c;
        server = setting?.Server__c;
    }

    private static Eggplant_Integration__c getCustomSettingRecord()
    {
        if (mock_Eggplant_CustomSetting_Record != null)
        {
            return mock_Eggplant_CustomSetting_Record;
        }
    
        return Eggplant_Integration__c.getOrgDefaults();
    }

    //=============================================
    //  Testing functionality
    //=============================================
    @TestVisible
    private static Eggplant_Integration__c mock_Eggplant_CustomSetting_Record;

    private static EggInteg_IDaiRestApiSettings mock_instance;

    @TestVisible
    private static void setMock(EggInteg_IDaiRestApiSettings mock)
    {
        mock_instance = mock;
    }
}