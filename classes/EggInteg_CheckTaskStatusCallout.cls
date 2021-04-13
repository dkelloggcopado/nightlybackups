public inherited sharing class EggInteg_CheckTaskStatusCallout
    implements ICheckTaskStatusCallout
{
    public static ICheckTaskStatusCallout construct()
    {
        if (mockCheckTaskStatusCallout != null)
        {
            return mockCheckTaskStatusCallout;
        }

        return new EggInteg_CheckTaskStatusCallout();
    }

    public String execute(String accessToken, String taskInstanceId)
    {
        EggInteg_IDaiRestApiSettings setting = EggInteg_DaiRestApiSettings.construct();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(setting.getServer() + '/ai/testconfigtasks/' + taskInstanceId + '/details');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', '*/*');
        req.setHeader('Authorization', 'Bearer ' + accessToken);

        EggInteg_IHttpResponseWrapper respWrapper;
        if (mockHttpResponseWrapper == null)
        {
            respWrapper = new EggInteg_HttpResponseWrapper(new Http().send(req));
        }
        else
        {
            respWrapper = mockHttpResponseWrapper;
        }

        switch on respWrapper.getStatusCode()
        {
            when 200
            {
                ScheduleTaskCalloutResponse checkTaskStatusResponse = (ScheduleTaskCalloutResponse) JSON.deserialize(respWrapper.getBody(), ScheduleTaskCalloutResponse.class);
                return JSON.serialize(checkTaskStatusResponse);
            }
            when else
            {
                throw new CheckTaskStatusCalloutException(
                    '{"statusCode:"' + respWrapper.getStatusCode() + '","status":"' + respWrapper.getStatus() + '"}'
                );
            }
        }
    }

    public interface ICheckTaskStatusCallout
    {
        String execute(String accessToken, String TaskInstanceId);
    }

    public class ScheduleTaskCalloutResponse
    {
        public String created_datetime;
        public String runstatus;
        public String test_config_id;
        public String task_instance_id;
        public String updated_datetime;
        public List<ScheduleTaskCalloutResponse_Message> messages;
    }

    public class ScheduleTaskCalloutResponse_Message
    {
        public String id;
        public String created;
        public String task_instance_id;
        public String sender;
        public String severity;
        public String message;
        public String error_time;
    }

    private class CheckTaskStatusCalloutException
        extends Exception
    {
        // Intentionally blank
    }

    //=============================================
    //  Testing Functionality
    //=============================================
    private static ICheckTaskStatusCallout mockCheckTaskStatusCallout;
    @TestVisible static void setMock(ICheckTaskStatusCallout mock_callout)
    {
        mockCheckTaskStatusCallout = mock_callout;
    }

    private static EggInteg_IHttpResponseWrapper mockHttpResponseWrapper;
    @TestVisible
    private static void setMockWrapper(EggInteg_IHttpResponseWrapper mock_wrapper)
    {
        mockHttpResponseWrapper = mock_wrapper;
    }
}