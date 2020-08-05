public with sharing class UserStoryBundleController {
    private Set<Id> userStoryIds { get; set; }
    private List<MetaDataItem> allMetadataItems { get; set; }
    private Map<Id, copado__User_Story__c> userStoriesById { get; set; }
    public List<copado__User_Story__c> userStories { get; set; }
    public copado__User_Story__c bundleUs { get; set; }

    public UserStoryBundleController(ApexPages.StandardSetController std) {
        if (!Test.isRunningTest()) {
            std.addFields(new List<String>{ 'Name', 'Is_Bundle__c', 'Bundle_User_Story__c', 'copado__Environment__c' });
        }
        createBundleUserStory();
        userStoriesById = new Map<Id, copado__User_Story__c>((List<copado__User_Story__c>) std.getSelected());
        userStoryIds = new Set<Id>(userStoriesById.keySet());
        userStories = new List<copado__User_Story__c>(userStoriesById.values());
    }

    /**
     * Checks User Story Bundle consistency. Selection can't be user stories already in a bundle, Bundled user stories or from different environments.
     */
    public Boolean getCheckUserStorySelectionConsistency() {
        Set<String> environments = new Set<String>();
        if (userStories.isEmpty()) {
            genericWarningMessage(ApexPages.Severity.WARNING, 'You need to select at least one user story with commits.');
            return false;
        }
        for (copado__User_Story__c userStoryItem : userStories) {
            if (userStoryItem.Bundle_User_Story__c != null) {
                genericWarningMessage(ApexPages.Severity.WARNING, userStoryItem.Name + ' is already bundled.');
            }
            environments.add(userStoryItem.copado__Environment__c);
        }
        if (environments.size() > 1) {
            genericWarningMessage(
                ApexPages.Severity.WARNING,
                'The selected user stories are located in different environments. Make sure all user stories are in the same environment to avoid git and Salesforce to become out of sync.'
            );
        }
        checkUnsupportedOperations();
        return !Apexpages.hasMessages();
    }

    /**
     * Checks User Stories Selected have unsupported operations (Destructive Changes)
     */
    private void checkUnsupportedOperations() {
        try {
            // Desctructive Changes
            for (copado__User_Story_Commit__c destructiveChangesOperation : [
                SELECT Id, copado__User_Story__r.Name
                FROM copado__User_Story_Commit__c
                WHERE
                    copado__User_Story__r.Id IN :userStoryIds
                    AND copado__Snapshot_Commit__r.copado__Git_Operation__c = 'Destructive Changes'
                    AND copado__Snapshot_Commit__r.copado__Status__c = 'Complete'
            ]) {
                genericWarningMessage(
                    ApexPages.Severity.WARNING,
                    destructiveChangesOperation.copado__User_Story__r.Name + ' Contains Unsupported Operations (Destructive Changes)'
                );
            }

            // Full Profiles and Permission Sets
            for (Attachment userStoryAttachamentItem : [
                SELECT Id, Name, ParentId
                FROM Attachment
                WHERE ParentId = :userStoryIds AND Name = 'Full Profile Permission Set'
            ]) {
                genericWarningMessage(
                    ApexPages.Severity.WARNING,
                    userStoriesById.get(userStoryAttachamentItem.ParentId).Name +
                    ' Contains Unsupported Operations (Full Profiles and Permission Sets)'
                );
            }
        } catch (NoAccessException ex) {
            genericWarningMessage(ApexPages.Severity.WARNING, ex.getMessage());
        }
    }

    /**
     * Initialize Bundle user story
     */
    private void createBundleUserStory() {
        bundleUs = new copado__User_Story__c();
        bundleUs.RecordTypeId = Schema.SObjectType.copado__User_Story__c.getRecordTypeInfosByName().get('User Story').getRecordTypeId();
        bundleUs.Is_Bundle__c = true;
        bundleUs.copado__Status__c = 'Draft';
    }

    /**
     * Assign metadata from user stories selected to Bundle User Story
     */
    public PageReference assign() {
        Id attachmentId;
        Savepoint sp = Database.setSavepoint();
        try {
            // Strip fields that are not insertable
            SObjectAccessDecision bundleUsDecision = Security.stripInaccessible(AccessType.CREATABLE, new List<copado__User_Story__c>{ bundleUs });
            bundleUs = (copado__User_Story__c) bundleUsDecision.getRecords()[0];
            insert bundleUs;
            assignChildUsToBundle();
            assignDeploymentTasksToBundleUs();
            attachmentId = createGitCommitAttachment();
        } catch (NoAccessException ex) {
            Database.rollback(sp);
            genericWarningMessage(ApexPages.Severity.WARNING, ex.getMessage());
            return null;
        } catch (Exception ex) {
            Database.rollback(sp);
            genericWarningMessage(ApexPages.Severity.ERROR, ex.getStackTraceString());
            return null;
        }

        Boolean isScratchOrg =
            String.isNotBlank(bundleUs.copado__Environment_Type__c) && bundleUs.copado__Environment_Type__c.containsIgnoreCase('Scratch Org');

        PageReference pReference = Page.copado__GitCommitMain;
        pReference.setRedirect(true);
        pReference.getParameters().put('userStoryId', bundleUs.Id);
        pReference.getParameters().put('MetadataPreselectionId', attachmentId);
        pReference.getParameters().put('variant', isScratchOrg ? 'DxCommit' : 'UserStoryCommit');
        return pReference;
    }

    /**
     * Assign selected user stories to Bunlde User Story
     * Exclude from CBM and Stop Indexing Metadata so only Bundle User Story will appear for Back Promotion
     */
    private void assignChildUsToBundle() {
        for (copado__User_Story__c userStoryItem : userStories) {
            userStoryItem.copado__Stop_Indexing_Metadata__c = true;
            userStoryItem.copado__Exclude_From_CBM__c = true;
            userStoryItem.Bundle_User_Story__c = bundleUs.Id;
        }
        try {
            // Strip fields that are not insertable
            SObjectAccessDecision userStoriesDecision = Security.stripInaccessible(AccessType.UPDATABLE, userStories);
            update userStoriesDecision.getRecords();
        } catch (NoAccessException ex) {
            genericWarningMessage(ApexPages.Severity.WARNING, ex.getMessage());
        }
    }

    /**
     * If selected user stories have Deployment tasks, those are copied and assigned to Bundle User Story
     */
    private void assignDeploymentTasksToBundleUs() {
        try {
            List<copado__Deployment_Task__c> bundleDeploymentTasks = new List<copado__Deployment_Task__c>();
            for (copado__Deployment_Task__c depTaskItem : [
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
                WHERE copado__User_Story__c = :userStoryIds
                WITH SECURITY_ENFORCED
            ]) {
                copado__Deployment_Task__c deploymentTaskCopy = depTaskItem.clone();
                deploymentTaskCopy.copado__User_Story__c = bundleUs.Id;
                bundleDeploymentTasks.add(deploymentTaskCopy);
            }
            // Strip fields that are not insertable
            SObjectAccessDecision bundleDeploymentTasksDecision = Security.stripInaccessible(AccessType.CREATABLE, bundleDeploymentTasks);
            insert bundleDeploymentTasksDecision.getRecords();
        } catch (NoAccessException ex) {
            genericWarningMessage(ApexPages.Severity.WARNING, ex.getMessage());
        } catch (System.QueryException exceptions) {
            genericWarningMessage(
                ApexPages.Severity.WARNING,
                'Insufficient access rights to ' + Schema.SObjectType.copado__Deployment_Task__c.getLabel()
            );
        }
    }

    /**
     * Creates the attachment for Git Commit Page selections
     */
    private Id createGitCommitAttachment() {
        Attachment gitCommitAttachment = new Attachment(
            ParentId = bundleUs.Id,
            Name = 'MetadataPreselection-UsertStoryImport',
            Body = Blob.valueOf(JSON.serialize(allMetadataItems))
        );
        insert gitCommitAttachment;
        return gitCommitAttachment.Id;
    }

    /**
     * Get selected user stories metadata.
     * Fetch each MetaData attachment from each commit associated with each user story
     */
    public List<MetaDataItem> getAllMetadata() {
        Map<String, MetaDataItem> allMetadataItemsByKey = new Map<String, MetaDataItem>();
        List<Attachment> metadataAttachments = new List<Attachment>();
        try {
            metadataAttachments = [
                SELECT Id, Body
                FROM Attachment
                WHERE
                    Name = 'Metadata'
                    AND ParentId IN (
                        SELECT copado__Snapshot_Commit__c
                        FROM copado__User_Story_Commit__c
                        WHERE copado__User_Story__r.Id IN :userStoryIds AND copado__Snapshot_Commit__r.copado__Status__c = 'Complete'
                    )
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
            ];
        } catch (System.QueryException exceptions) {
            genericWarningMessage(
                ApexPages.Severity.WARNING,
                'Insufficient access rights to ' + Schema.SObjectType.copado__User_Story_Commit__c.getLabel()
            );
        }

        for (Attachment att : metadataAttachments) {
            List<MetaDataItem> metaDataItems = new List<MetaDataItem>();
            try {
                metaDataItems = (List<MetaDataItem>) JSON.deserialize(att.Body.toString(), List<MetaDataItem>.class);
            } catch (Exception excp) {
                genericWarningMessage(ApexPages.Severity.ERROR, 'Could not parse Metadata Item: ' + excp.getMessage());
            }
            // Merge the commit metadata to the allMetadataItemsByKey set.
            for (MetaDataItem metadata : metaDataItems) {
                String key = metadata.t + '.' + metadata.n;
                if (!allMetadataItemsByKey.containsKey(key)) {
                    metadata.s = true;
                    allMetadataItemsByKey.put(key, metadata);
                } else {
                    // If it exists, check if it has metadata.r = false, and ensure it's also false in allMetadataItemsByKey
                    // This is to ensure if it is not retrieve-only at least once, it must be not retrieve only.
                    if (metadata.r == null || !metadata.r) {
                        allMetadataItemsByKey.get(key).r = false;
                    }
                }
            }
        }
        allMetadataItems = allMetadataItemsByKey.values();
        if (allMetadataItems == null || allMetadataItems.isEmpty()) {
            genericWarningMessage(ApexPages.Severity.ERROR, 'There is no metadata selection in the selected user stories');
        }
        return allMetadataItems;
    }

    public PageReference cancel() {
        return new PageReference('/' + Schema.SObjectType.copado__User_Story__c.getKeyPrefix() + '/o');
    }

    private void genericWarningMessage(ApexPages.Severity severityLevel, Object messageToShow) {
        ApexPages.addMessage(new ApexPages.Message(severityLevel, messageToShow.toString()));
    }

    public class MetaDataItem {
        public String t { get; set; }
        public String n { get; set; }
        public Boolean r;
        public Boolean s;
        public String cb;
        public String cd;
    }
}