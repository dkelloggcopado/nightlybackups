@IsTest
private class EggInteg_HttpResponseWrapperTest
{
    @IsTest
    private static void test()
    {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(777);
        resp.setStatus('I\'m okay');
        resp.setBody('Hello world');

        Test.startTest();
        EggInteg_HttpResponseWrapper wrap = new EggInteg_HttpResponseWrapper(resp);
        Test.stopTest();

        System.assertEquals(resp.getStatusCode(), wrap.getStatusCode());
        System.assertEquals(resp.getStatus(), wrap.getStatus());
        System.assertEquals(resp.getBody(), wrap.getBody());
    }
}