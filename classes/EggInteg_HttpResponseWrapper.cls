public inherited sharing class EggInteg_HttpResponseWrapper
    implements EggInteg_IHttpResponseWrapper
{
    private Integer statusCode;
    private String status;
    private String body;

    public EggInteg_HttpResponseWrapper(HttpResponse response)
    {
        this.statusCode = response.getStatusCode();
        this.status = response.getStatus();
        this.body = response.getBody();
    }

    @TestVisible
    private EggInteg_HttpResponseWrapper(Integer status_code, String status, String body)
    {
        this.statusCode = status_code;
        this.status = status;
        this.body = body;
    }

    private EggInteg_HttpResponseWrapper()
    {
        // Intentionally blank
    }

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