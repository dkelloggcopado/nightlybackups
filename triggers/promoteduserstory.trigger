trigger promoteduserstory on copado__Promoted_User_Story__c (after insert) {
    
    For(copado__Promoted_User_Story__c pro : Trigger.new )
    {
        ID userStoryID = pro.copado__User_Story__r.ID;
        List<copado__Promoted_User_Story__c> PromotionList = new List<copado__Promoted_User_Story__c> ();        
        PromotionList = [SELECT copado__Promotion__c 
        FROM copado__Promoted_User_Story__c 
        where copado__User_Story__c =:userStoryID 
        and copado__Promoted_User_Story__c.copado__Promotion__r.copado__Back_Promotion__c = true 
        and copado__Promoted_User_Story__c.copado__Promotion__r.copado__Status__c = 'Completed'
        ORDER BY CreatedDate DESC];
       
        List<copado__Promotion__c> backpromotions = New List<copado__Promotion__c>();
        Set<String> pids = New Set<String>();
        Set<String>pusids = New SEt<String>();
        
        
        //if(PromotionList.size() > 0 && (PromotionList[0].copado__User_Story__r.copado__Latest_Commit_Date__c > PromotionList[0].copado__Promotion__r.CreatedDate)){
        For(copado__Promoted_User_Story__c pus: PromotionList ){
            if(pus.copado__User_Story__r.copado__Latest_Commit_Date__c > pus.copado__Promotion__r.CreatedDate){
                pids.add(pus.copado__Promotion__c);
            }
            //objpromoteduserstory.copado__Promotion__r.copado__Status__c = 'Draft';
            //backpromotions.add(objpromoteduserstory.copado__Promotion__r);
        } 
        backpromotions = [Select id, copado__Status__c 
        from copado__Promotion__C 
        where id in:pids];
        
        for(copado__Promotion__c pr:backpromotions){
            pr.copado__Status__c = 'Draft';
        }
        update backpromotions;
            

    }
}