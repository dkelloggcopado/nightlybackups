trigger UserStoryBundleTrigger on copado__User_Story__c (after update) {
    new UserStoryBundleTriggerHandler().run();
}