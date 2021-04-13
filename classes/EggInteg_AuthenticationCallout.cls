public inherited sharing class EggInteg_AuthenticationCallout
    implements IAuthenticationCallout
{
    public static IAuthenticationCallout construct()
    {
        if (mockAuthenticationCallout != null)
        {
            return mockAuthenticationCallout;
        }

        return new EggInteg_AuthenticationCallout();
    }

    public String execute()
    {
        EggInteg_IDaiRestApiSettings setting = EggInteg_DaiRestApiSettings.construct();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(setting.getServer() + '/ai/auth');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', '*/*');
        req.setBody(constructBody(setting));

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
                AuthenticationCalloutResponse authResponse = (AuthenticationCalloutResponse) JSON.deserialize(respWrapper.getBody(), AuthenticationCalloutResponse.class);
                return authResponse.access_token;
            }

            when else
            {
                throw new AuthenticationCalloutException(
                    '{"statusCode:"' + respWrapper.getStatusCode() + '","status":"' + respWrapper.getStatus() + '"}'
                );
            }
        }
    }

    private static String constructBody(EggInteg_IDaiRestApiSettings setting)
    {
        return
            'username=' + setting.getUsername()
            + '&password=' + setting.getPassword();
    }

    public interface IAuthenticationCallout
    {
        String execute();
    }

    public class AuthenticationCalloutResponse
    {
        public String access_token;
        public Integer expires_in;
        public String token_type;
        public String user_id;
    }

    private class AuthenticationCalloutException
        extends Exception
    {
        // Intentionally blank
    }

    //=============================================
    //  Testing Functionality
    //=============================================
    private static IAuthenticationCallout mockAuthenticationCallout;
    @TestVisible static void setMock(IAuthenticationCallout mock_callout)
    {
        mockAuthenticationCallout = mock_callout;
    }

    private static EggInteg_IHttpResponseWrapper mockHttpResponseWrapper;
    @TestVisible
    private static void setMockWrapper(EggInteg_IHttpResponseWrapper mock_wrapper)
    {
        mockHttpResponseWrapper = mock_wrapper;
    }
}