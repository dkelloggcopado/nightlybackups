public inherited sharing class EggInteg_AuthenticationInvocable
{
    @InvocableMethod
    (
        label = 'Eggplant Authentication'
        description = 'Using Custom Settings, authenticates with the Eggplant API, responding with the access token.'
        callout = true
        category = 'Eggplant DAI Service'
    )
    public static List<AuthenticationOutput> authenticate()
    {
        AuthenticationOutput output = new AuthenticationOutput();
        output.access_token = EggInteg_AuthenticationCallout.construct().execute();
        return new List<AuthenticationOutput> {output};
    }

    public class AuthenticationOutput
    {
        @InvocableVariable
        (
            label = 'Access Token'
            description = 'Authentication string to be used in Bearer authentication protocol.'
        )
        public String access_token;
    }
}