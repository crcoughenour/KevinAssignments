trigger HousingAssignmentTrigger on HousingAssignment__c (after delete) {
    
    if(trigger.isAfter && trigger.isDelete) {
        HousingAssignmentTriggerHelper.unoccupyBeds(trigger.old);
    }

}