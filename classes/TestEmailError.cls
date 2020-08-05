@IsTest
public class TestEmailError {
    @IsTest
    static void testSendErrorEmail() {
        Test.startTest();
        EmailError.sendErrorEmail('User Story Bundle Error', 'Message', 'Error in Copado', UserInfo.getUserId());
        Test.stopTest();
    }
}