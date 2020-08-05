@IsTest
public class TestUserStoryBundle {
    @TestSetup
    static void makeData() {
        assignPermissionSet();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            assignLicense();
            List<copado__Org__c> orgCreds = new List<copado__Org__c>();
            copado__Org__c devOrgCredential = new copado__Org__c(
                Name = 'Dev 1',
                copado__Org_Type__c = 'Production/Developer',
                copado__SFDC_Org_ID__c = '00D1i00000095bEEAQ_0050X000007h8hTQAQ_6'
            );
            orgCreds.add(devOrgCredential);
            copado__Org__c stagingOrgCredential = new copado__Org__c(
                Name = 'Staging',
                copado__Org_Type__c = 'Production/Developer',
                copado__SFDC_Org_ID__c = '00D1i00000095cEEAQ_0050X000007h8cTQAQ_3'
            );
            orgCreds.add(stagingOrgCredential);
            insert orgCreds;
            update orgCreds;

            copado__Git_Repository__c gitRepo = new copado__Git_Repository__c(Name = 'My Repo');
            insert gitRepo;

            copado__Git_Backup__c gitSnapshot = new copado__Git_Backup__c(
                copado__Git_Repository__c = gitRepo.Id,
                copado__Org__c = devOrgCredential.Id
            );
            insert gitSnapshot;

            copado__Git_Org_Commit__c gitOrgCommit1 = new copado__Git_Org_Commit__c(
                copado__Git_Backup__c = gitSnapshot.Id,
                copado__Org__c = devOrgCredential.Id,
                copado__Commit_Id__c = 'b7adccf3937495e8928d1023c5a5c644198b8974',
                copado__Commit_Date__c = Date.today(),
                copado__Commit_Message__c = 'test message',
                copado__Status__c = 'Complete'
            );
            copado__Git_Org_Commit__c gitOrgCommit2 = new copado__Git_Org_Commit__c(
                copado__Git_Backup__c = gitSnapshot.Id,
                copado__Org__c = devOrgCredential.Id,
                copado__Commit_Id__c = 'b7adccf3937495e8928d1023c5a5c644198b8975',
                copado__Commit_Date__c = Date.today(),
                copado__Commit_Message__c = 'test message 2',
                copado__Status__c = 'Complete'
            );
            insert new List<copado__Git_Org_Commit__c>{ gitOrgCommit1, gitOrgCommit2 };

            // Metadata selections via the grid
            Attachment att1 = new Attachment(
                ParentId = gitOrgCommit1.Id,
                Name = 'Metadata',
                Body = Blob.valueOf('[{"t":"EmailTemplate","n":"Template1","s":true,"r":true}, {"t":"EmailTemplate","n":"Template2","s":false}]')
            );

            Attachment att2 = new Attachment(
                ParentId = gitOrgCommit2.Id,
                Name = 'Metadata',
                Body = Blob.valueOf('[{"t":"EmailTemplate","n":"Template1","s":true,"r":false}, {"t":"EmailTemplate","n":"a_Template","s":true}]')
            );
            insert new List<Attachment>{ att1, att2 };

            copado__User_Story__c userStory1 = new copado__User_Story__c(copado__User_Story_Title__c = 'User Story 1');
            copado__User_Story__c userStory2 = new copado__User_Story__c(copado__User_Story_Title__c = 'User Story 2');
            copado__User_Story__c userStory3 = new copado__User_Story__c(copado__User_Story_Title__c = 'User Story 3');
            copado__User_Story__c userStory4 = new copado__User_Story__c(copado__User_Story_Title__c = 'User Story 4');
            copado__User_Story__c userStory5 = new copado__User_Story__c(copado__User_Story_Title__c = 'User Story 5');
            copado__User_Story__c userStory6 = new copado__User_Story__c(copado__User_Story_Title__c = 'User Story 6');
            insert new List<copado__User_Story__c>{ userStory1, userStory2, userStory3, userStory4, userStory5, userStory6 };

            copado__User_Story_Commit__c userStoryCommit1 = new copado__User_Story_Commit__c(
                copado__User_Story__c = userStory1.Id,
                copado__Snapshot_Commit__c = gitOrgCommit1.Id
            );
            copado__User_Story_Commit__c userStoryCommit2 = new copado__User_Story_Commit__c(
                copado__User_Story__c = userStory2.Id,
                copado__Snapshot_Commit__c = gitOrgCommit2.Id
            );
            insert new List<copado__User_Story_Commit__c>{ userStoryCommit1, userStoryCommit2 };

            copado__Deployment_Task__c deploymentTask = new copado__Deployment_Task__c(
                copado__User_Story__c = userStory1.Id,
                copado__Task_Description__c = 'Deployment Task Description',
                copado__Type__c = 'Manual Task'
            );
            insert deploymentTask;
        }
    }

    /**
     * Test: user stories with commits and metadata selection.
     */
    @IsTest
    static void testUserStoryBundleCreation() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            copado__Org__c orgCred = [SELECT Id, Name FROM copado__Org__c LIMIT 1];
            Map<Id, copado__User_Story__c> selectedUserStoriesById = getSelectedUserStoriesById();
            List<copado__User_Story__c> selectedUserStories = new List<copado__User_Story__c>(selectedUserStoriesById.values());
            Set<Id> selectedUserStoriesIds = new Set<Id>(selectedUserStoriesById.keySet());

            PageReference pageRef = Page.UserStoryBundle;
            Test.setCurrentPage(pageRef);

            Test.startTest();

            ApexPages.StandardSetController bundleUserStoryStandardSetController = new ApexPages.StandardSetController(selectedUserStories);
            bundleUserStoryStandardSetController.setSelected(selectedUserStories);
            UserStoryBundleController bundleController = new UserStoryBundleController(bundleUserStoryStandardSetController);
            bundleController.getAllMetadata();
            Boolean userStoryConsistency = bundleController.getCheckUserStorySelectionConsistency();
            System.assertEquals(true, userStoryConsistency, 'User consistency must be true');
            System.assertEquals(0, ApexPages.getMessages().size(), 'It should not be any erros at this point');
            bundleController.bundleUs.copado__User_Story_Title__c = 'Bundled User Story';
            bundleController.bundleUs.copado__Org_Credential__c = orgCred.Id;

            PageReference gitCommitPage = bundleController.assign();
            Test.setCurrentPage(gitCommitPage);

            Test.stopTest();
            copado__User_Story__c resultUserStory = [
                SELECT
                    Id,
                    Is_Bundle__c,
                    copado__User_Story_Title__c,
                    copado__Org_Credential__c,
                    (
                        SELECT Id, Name, copado__Stop_Indexing_Metadata__c, copado__Exclude_From_CBM__c, Bundle_User_Story__c
                        FROM Bundle_User_Stories__r
                    )
                FROM copado__User_Story__c
                WHERE copado__User_Story_Title__c = 'Bundled User Story'
                LIMIT 1
            ];
            Attachment resultAttachment = [SELECT Id FROM Attachment WHERE ParentId = :resultUserStory.Id];
            Set<copado__User_Story__c> childUserStories = new Set<copado__User_Story__c>(
                [
                    SELECT Id, Name, copado__Stop_Indexing_Metadata__c, copado__Exclude_From_CBM__c, Bundle_User_Story__c
                    FROM copado__User_Story__c
                    WHERE copado__User_Story_Title__c IN ('User Story 1', 'User Story 2')
                ]
            );
            Set<copado__User_Story__c> assertChildUserStories = new Set<copado__User_Story__c>(resultUserStory.Bundle_User_Stories__r);

            List<copado__Deployment_Task__c> childDeploymentTasks = [
                SELECT
                    copado__Notify_Task_Owner__c,
                    copado__Order__c,
                    copado__Perform_Manual_Task__c,
                    copado__Perform_in_Destination_Orgs__c,
                    copado__Perform_in_Source_Org__c,
                    copado__Status__c,
                    copado__Task_Description__c,
                    copado__Type__c,
                    copado__dataJSON__c
                FROM copado__Deployment_Task__c
                WHERE copado__User_Story__c = :selectedUserStoriesIds
            ];
            List<copado__Deployment_Task__c> assertDeploymentTasks = [
                SELECT
                    copado__Notify_Task_Owner__c,
                    copado__Order__c,
                    copado__Perform_Manual_Task__c,
                    copado__Perform_in_Destination_Orgs__c,
                    copado__Perform_in_Source_Org__c,
                    copado__Status__c,
                    copado__Task_Description__c,
                    copado__Type__c,
                    copado__dataJSON__c
                FROM copado__Deployment_Task__c
                WHERE copado__User_Story__c = :resultUserStory.Id
            ];

            PageReference assertCommitPage = Page.copado__GitCommitMain;
            assertCommitPage.getParameters().put('userStoryId', resultUserStory.Id);
            assertCommitPage.getParameters().put('MetadataPreselectionId', resultAttachment.Id);
            assertCommitPage.getParameters().put('variant', 'UserStoryCommit');
            System.assertEquals(assertCommitPage.getUrl(), gitCommitPage.getUrl(), 'Url expected is not correct');

            System.assertEquals(true, resultUserStory.Is_Bundle__c, 'Is Bundle field must be TRUE');
            System.assertEquals('Bundled User Story', resultUserStory.copado__User_Story_Title__c, 'Title is not correct');
            System.assertEquals(orgCred.Id, resultUserStory.copado__Org_Credential__c, 'Org Credential is not correct');

            System.assert(assertChildUserStories.equals(childUserStories), 'Child USer Stories are not correct');
            System.assertEquals(assertDeploymentTasks.size(), childDeploymentTasks.size(), 'Child DeploymentTasks are not correct');
            System.assertEquals(
                assertDeploymentTasks[0].copado__Task_Description__c,
                childDeploymentTasks[0].copado__Task_Description__c,
                'Task Descriptiion mismatches'
            );
            System.assertEquals(assertDeploymentTasks[0].copado__Type__c, childDeploymentTasks[0].copado__Type__c, 'Task Type mismatches');
        }
    }

    /**
     * Test UserStories selected has no metadata
     */
    @IsTest
    static void testNoMetadataInSelection() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            copado__Org__c orgCred = [SELECT Id, Name FROM copado__Org__c LIMIT 1];
            List<copado__User_Story__c> selectedUserStories = [
                SELECT
                    Id,
                    Name,
                    copado__Stop_Indexing_Metadata__c,
                    copado__Exclude_From_CBM__c,
                    Bundle_User_Story__c,
                    copado__User_Story__c.copado__Environment__c
                FROM copado__User_Story__c
                WHERE copado__User_Story_Title__c IN ('User Story 3', 'User Story 4')
            ];
            PageReference pageRef = Page.UserStoryBundle;
            Test.setCurrentPage(pageRef);

            Test.startTest();

            ApexPages.StandardSetController bundleUserStoryStandardSetController = new ApexPages.StandardSetController(selectedUserStories);
            bundleUserStoryStandardSetController.setSelected(selectedUserStories);
            UserStoryBundleController bundleController = new UserStoryBundleController(bundleUserStoryStandardSetController);
            bundleController.getAllMetadata();
            Boolean userStoryConsistency = bundleController.getCheckUserStorySelectionConsistency();
            System.assertEquals(false, userStoryConsistency, 'User consistency must be false');
            System.assertEquals(
                'There is no metadata selection in the selected user stories',
                ApexPages.getMessages()[0].getDetail(),
                'The message is not correct'
            );

            Test.stopTest();
        }
    }

    /**
     * Test No user story selection
     */
    @IsTest
    static void testNoUserStorySelection() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            PageReference pageRef = Page.UserStoryBundle;
            Test.setCurrentPage(pageRef);

            Test.startTest();
            List<copado__User_Story__c> selectedUserStories = new List<copado__User_Story__c>();
            ApexPages.StandardSetController bundleUserStoryStandardSetController = new ApexPages.StandardSetController(selectedUserStories);
            UserStoryBundleController bundleController = new UserStoryBundleController(bundleUserStoryStandardSetController);
            Boolean userStoryConsistency = bundleController.getCheckUserStorySelectionConsistency();
            System.assertEquals(false, userStoryConsistency, 'User consistency must be false');
            System.assertEquals(
                'You need to select at least one user story with commits.',
                ApexPages.getMessages()[0].getDetail(),
                'The message is not correct'
            );

            Test.stopTest();
        }
    }

    /**
     * Test: user stories with inconsistency selection
     */
    @IsTest
    static void testUserStorySelectionConsistency() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            copado__Org__c devOrgCredential = new copado__Org__c();
            copado__Org__c stagingOrgCredential = new copado__Org__c();
            for (copado__Org__c orgCredentialItem : [
                SELECT Id, Name, copado__Environment__c
                FROM copado__Org__c
                WHERE Name IN ('Dev 1', 'Staging')
            ]) {
                switch on orgCredentialItem.Name {
                    when 'Dev 1' {
                        devOrgCredential = orgCredentialItem;
                    }
                    when 'Staging' {
                        stagingOrgCredential = orgCredentialItem;
                    }
                }
            }
            copado__User_Story__c bundleUs = new copado__User_Story__c();
            bundleUs.copado__User_Story_Title__c = 'Bundled User Story';
            bundleUs.copado__Org_Credential__c = devOrgCredential.Id;
            bundleUs.RecordTypeId = Schema.SObjectType.copado__User_Story__c.getRecordTypeInfosByName().get('User Story').getRecordTypeId();
            bundleUs.Is_Bundle__c = true;
            bundleUs.copado__Status__c = 'Draft';
            insert bundleUs;

            Map<Id, copado__User_Story__c> selectedUserStoriesById = getSelectedUserStoriesById();
            List<copado__User_Story__c> selectedUserStories = new List<copado__User_Story__c>(selectedUserStoriesById.values());
            Set<Id> selectedUserStoriesIds = new Set<Id>(selectedUserStoriesById.keySet());
            System.debug('selectedUserStories: ' + selectedUserStories);

            selectedUserStories[0].copado__Org_Credential__c = devOrgCredential.Id;
            selectedUserStories[0].copado__Environment__c = devOrgCredential.copado__Environment__c;
            selectedUserStories[0].Bundle_User_Story__c = bundleUs.Id;
            selectedUserStories[1].copado__Org_Credential__c = stagingOrgCredential.Id;
            selectedUserStories[1].copado__Environment__c = stagingOrgCredential.copado__Environment__c;
            selectedUserStories[1].Bundle_User_Story__c = bundleUs.Id;
            update selectedUserStories;
            System.debug('selectedUserStories: ' + selectedUserStories);

            PageReference pageRef = Page.UserStoryBundle;
            Test.setCurrentPage(pageRef);

            Test.startTest();

            ApexPages.StandardSetController bundleUserStoryStandardSetController = new ApexPages.StandardSetController(selectedUserStories);
            bundleUserStoryStandardSetController.setSelected(selectedUserStories);
            UserStoryBundleController bundleController = new UserStoryBundleController(bundleUserStoryStandardSetController);
            Boolean userStoryConsistency = bundleController.getCheckUserStorySelectionConsistency();
            bundleController.getAllMetadata();
            System.assertEquals(false, userStoryConsistency, 'User consistency must be false');
            Test.stopTest();
        }
    }

    /**
     * Test: user stories with unsupported operations
     */
    @IsTest
    static void testUserStorySelectionUnsupportedOperations() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            copado__Git_Org_Commit__c gitOrgCommit1 = [
                SELECT Id
                FROM copado__Git_Org_Commit__c
                WHERE copado__Commit_Id__c = 'b7adccf3937495e8928d1023c5a5c644198b8974'
            ];
            gitOrgCommit1.copado__Git_Operation__c = 'Destructive Changes';
            update gitOrgCommit1;

            List<copado__User_Story__c> selectedUserStories = new List<copado__User_Story__c>(getSelectedUserStoriesById().values());
            Attachment fullProfilesAttachment = new Attachment();
            fullProfilesAttachment.ParentId = selectedUserStories[1].Id;
            fullProfilesAttachment.Name = 'Full Profile Permission Set';
            fullProfilesAttachment.Body = Blob.valueOf('');
            insert fullProfilesAttachment;

            PageReference pageRef = Page.UserStoryBundle;
            Test.setCurrentPage(pageRef);

            Test.startTest();

            ApexPages.StandardSetController bundleUserStoryStandardSetController = new ApexPages.StandardSetController(selectedUserStories);
            bundleUserStoryStandardSetController.setSelected(selectedUserStories);
            UserStoryBundleController bundleController = new UserStoryBundleController(bundleUserStoryStandardSetController);
            bundleController.getAllMetadata();
            Boolean userStoryConsistency = bundleController.getCheckUserStorySelectionConsistency();
            System.assertEquals(false, userStoryConsistency, 'User consistency must be false');
            System.assertEquals(2, Apexpages.getMessages().size());

            Test.stopTest();
        }
    }

    /**
     * Test "Cancel" button
     */
    @IsTest
    static void testCancelButton() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            copado__Org__c orgCred = [SELECT Id, Name FROM copado__Org__c LIMIT 1];
            List<copado__User_Story__c> selectedUserStories = getSelectedUserStoriesById().values();
            PageReference pageRef = Page.UserStoryBundle;
            Test.setCurrentPage(pageRef);

            Test.startTest();

            ApexPages.StandardSetController bundleUserStoryStandardSetController = new ApexPages.StandardSetController(selectedUserStories);
            bundleUserStoryStandardSetController.setSelected(selectedUserStories);
            UserStoryBundleController bundleController = new UserStoryBundleController(bundleUserStoryStandardSetController);
            bundleController.getAllMetadata();
            Boolean userStoryConsistency = bundleController.getCheckUserStorySelectionConsistency();
            PageReference userStoryTabPage = bundleController.cancel();
            Test.setCurrentPage(userStoryTabPage);

            Test.stopTest();
            System.assertEquals(true, userStoryConsistency, 'User consistency must be true');
            Pagereference assertCancelButton = new PageReference('/' + Schema.SObjectType.copado__User_Story__c.getKeyPrefix() + '/o');
            System.assertEquals(assertCancelButton.getUrl(), userStoryTabPage.getUrl(), 'Url expected is not correct');
        }
    }

    private static Map<Id, copado__User_Story__c> getSelectedUserStoriesById() {
        return new Map<Id, copado__User_Story__c>(
            [
                SELECT
                    Id,
                    Name,
                    copado__Stop_Indexing_Metadata__c,
                    copado__Exclude_From_CBM__c,
                    Bundle_User_Story__c,
                    copado__Org_Credential__c,
                    copado__Environment__c
                FROM copado__User_Story__c
                WHERE copado__User_Story_Title__c IN ('User Story 1', 'User Story 2')
            ]
        );
    }

    /**
     * Assign user licenses
     */
    public static void assignLicense() {
        copado.GlobalAPI copadoGlobalAPI = new copado.GlobalAPI();
        copado.GlobalAPI.UserLicense userLicense = new copado.GlobalAPI.UserLicense();
        userLicense.isCCMEnabled = true;
        userLicense.isCopadoEnabled = true;
        userLicense.userId = UserInfo.getUserId();
        copadoGlobalAPI.upsertCopadoLicense(userLicense);
    }

    /**
     * Assign PermissionSet
     */
    public static void assignPermissionSet() {
        PermissionSetAssignment permSetAssignment = new PermissionSetAssignment();
        permSetAssignment.PermissionSetId = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Copado_User_Story_Bundle' LIMIT 1].Id;
        permSetAssignment.AssigneeId = UserInfo.getUserId();
        insert permSetAssignment;
    }
}