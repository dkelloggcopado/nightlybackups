public inherited sharing class EggInteg_ScheduleTaskCallout
    implements IScheduleTaskCallout
{
    public static IScheduleTaskCallout construct()
    {
        if (mockScheduleTaskCallout != null)
        {
            return mockScheduleTaskCallout;
        }

        return new EggInteg_ScheduleTaskCallout();
    }

    public String execute(String accessToken, String taskId)
    {
        EggInteg_IDaiRestApiSettings setting = EggInteg_DaiRestApiSettings.construct();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(setting.getServer() + '/task_scheduler_service/api/v1/task_instances/' + taskId);
        req.setMethod('POST');
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
                ScheduleTaskCalloutResponse scheduleTaskResponse = (ScheduleTaskCalloutResponse) JSON.deserialize(respWrapper.getBody(), ScheduleTaskCalloutResponse.class);
                return scheduleTaskResponse.task_instance_id;
            }
            when else
            {
                throw new ScheduleTaskCalloutException(
                    '{"statusCode:"' + respWrapper.getStatusCode() + '","status":"' + respWrapper.getStatus() + '"}'
                );
            }
        }
    }

    public interface IScheduleTaskCallout
    {
        String execute(String accessToken, String TaskId);
    }

    public class ScheduleTaskCalloutResponse
    {
        public String task_id;
        public String task_instance_id;
    }

    private class ScheduleTaskCalloutException
        extends Exception
    {
        // Intentionally blank
    }

    //=============================================
    //  Testing Functionality
    //=============================================
    private static IScheduleTaskCallout mockScheduleTaskCallout;
    @TestVisible static void setMock(IScheduleTaskCallout mock_callout)
    {
        mockScheduleTaskCallout = mock_callout;
    }

    private static EggInteg_IHttpResponseWrapper mockHttpResponseWrapper;
    @TestVisible
    private static void setMockWrapper(EggInteg_IHttpResponseWrapper mock_wrapper)
    {
        mockHttpResponseWrapper = mock_wrapper;
    }
}