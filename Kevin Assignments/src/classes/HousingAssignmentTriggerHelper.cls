public class HousingAssignmentTriggerHelper {
    
    public static void unoccupyBeds(List<HousingAssignment__c> deletedAssignments) {
        //build list of all bed ids in deleted assignments        
        List<Id> bedIdsToChange = new List<Id>();
        for(HousingAssignment__c currentHousingAssignment : deletedAssignments) {
            bedIdsToChange.add(currentHousingAssignment.HousingBed__c);
        }
        
        //change isOccupied on bed object to false
        List<HousingBed__c> bedsToChange = [SELECT Id, IsOccupied__c
                                            FROM HousingBed__c
                                            WHERE Id IN :bedIdsToChange];
        for(HousingBed__c currentBed: bedsToChange) {
            currentBed.IsOccupied__c = false;
        }
        
        update bedsToChange;
    }
    
}