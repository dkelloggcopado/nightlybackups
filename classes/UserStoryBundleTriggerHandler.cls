public with sharing class UserStoryBundleTriggerHandler extends TriggerHandler {
    private Map<Id, copado__User_Story__c> userStoryNew;
    private Map<Id, copado__User_Story__c> userStoryOld;

    public UserStoryBundleTriggerHandler() {
        this.userStoryNew = (Map<Id, copado__User_Story__c>) Trigger.newMap;
        this.userStoryOld = (Map<Id, copado__User_Story__c>) Trigger.oldMap;
    }

    public override void afterUpdate() {
        UserStoryBundleTriggerHelper.moveChildUserStoriesAcrossEnvironments(userStoryNew, userStoryOld);
    }
}