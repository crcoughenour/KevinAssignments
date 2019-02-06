/*
 *Purpose: Control the Housing Assignment Modal's interaction with the server
 *Created By: Cody Coughenour
 *Last Modified: 2/6/2019
 */
public class HousingAssignmentModalApexController {

    /*
     * This method initializes all of the necessary data:
     * * contactToAssign - The Contact object for the Housing Assignment
     * * availableBeds - The name of each Bed with its Unit and Complex
     * * peersByUnit - A count of Peers, associates in same class, by Unit
     * * carCountByUnit - A count of Cars, associates that have a car, by Unit
     * 
     * It then packages the data utilizing the wrapper classes, which can be found below:
     * * TableDataWrapper - The Bed information and both counts
     * * HousingAssignmentWrapper - The Contact Object and a List of TableDataWrapper
     * 
     * @param contactId the Id of the contact to be assigned housing
     * @return a HousingAssignmentWrapper object containing all data
     */
    @AuraEnabled
    public static HousingAssignmentWrapper getRelatedData(String contactId) {

        //SOQL assignment to a single contact
        Contact contactToAssign = [SELECT Id, Name, Gender__c, HasCar__c, TrainingClass__c, TrainingEndDate__c
                                   FROM Contact
                                   WHERE Id = :contactID Limit 1];
        
        //Get beds, units, complex data
        List<HousingBed__c> availableBeds = [SELECT Id, Name, IsOccupied__c, HousingUnit__c, HousingUnit__r.Name, HousingUnit__r.Gender__c, HousingUnit__r.HousingComplex__r.Name
                                             FROM HousingBed__c
                                             WHERE HousingUnit__r.Gender__c = :contactToAssign.Gender__c AND IsOccupied__c = false
                                             ORDER BY HousingUnit__r.HousingComplex__r.Name, HousingUnit__r.Name, Name];
        
        //Get map of Car counts by Unit
        Map<Id, Integer> carCountByUnit = new Map<Id, Integer>();
        for(AggregateResult carsInUnit: [SELECT Count(Contact__c) carCount, HousingBed__r.HousingUnit__c unitId
                                        FROM HousingAssignment__c
                                        WHERE HousingBed__r.HousingUnit__r.Gender__c = :contactToAssign.Gender__c
                                        AND Contact__r.HasCar__c = true
                                        Group By HousingBed__r.HousingUnit__c])
        {
            Id unitId = (ID) carsInUnit.get('unitId');
            Integer carCount = (Integer) carsInUnit.get('carCount');
            carCountByUnit.put(unitId,carCount);
        }
        
        //Get map of Peer counts by Unit
        Map<Id, Integer> peersByUnit = new Map<Id, Integer>();
        for(AggregateResult peersInUnit: [SELECT Count(Contact__c) peerCount, HousingBed__r.HousingUnit__c unitId
                                          FROM HousingAssignment__c
                                          WHERE HousingBed__r.HousingUnit__r.Gender__c = :contactToAssign.Gender__c
                                          AND Contact__r.TrainingClass__c = :contactToAssign.TrainingClass__c
                                          Group By HousingBed__r.HousingUnit__c])
        {
            Id unitId = (ID) peersInUnit.get('unitId');
            Integer peerCount = (Integer) peersInUnit.get('peerCount');
            peersByUnit.put(unitId,peerCount);
        }

        //Create list of table data rows using TableDataWrapper
        List<TableDataWrapper> rows = new List<TableDataWrapper>();
        for(HousingBed__c bed: availableBeds) {
            Integer numCars = carCountByUnit.get(bed.HousingUnit__c);
            if (numCars == null) {numCars = 0;}
            Integer numPeers = peersByUnit.get(bed.HousingUnit__c);
            if (numPeers == null) {numPeers = 0;}
            rows.add(new TableDataWrapper(bed, numCars, numPeers));
        }
        
        //Package list of rows with contact in HousingAssignmentWrapper
        HousingAssignmentWrapper assignmentData = new HousingAssignmentWrapper(contactToAssign, rows);
        
        //return data
        return assignmentData;
    }
    
    //Create a new housing assignment
    @AuraEnabled
    public static void createAssignment(String contactId, String bedId, Date arrivalDate) {
        HousingAssignment__c newHousingAssignment = new HousingAssignment__c();
        newHousingAssignment.Contact__c = contactId;
        newHousingAssignment.HousingBed__c = bedId;
        newHousingAssignment.ArrivalDate__c = arrivalDate;
        newHousingAssignment.Status__c = 'Moving In';
        
        insert newHousingAssignment;
    }
    
    //wrapper class for the list of rows and the contact
    public class HousingAssignmentWrapper {
        @AuraEnabled
        public Contact contactToAssign;
        @AuraEnabled
        public List<TableDataWrapper> rows;
        
        public HousingAssignmentWrapper(){
            this.contactToAssign = new Contact();
            this.rows = new List<TableDataWrapper>();
        }
        
        public HousingAssignmentWrapper(Contact contactToAssign,List<TableDataWrapper> rows) 
        {
            this.contactToAssign = contactToAssign;
            this.rows = rows;
        }
    }
    
    //wrapper class for a row in our table
    public class TableDataWrapper {
        @AuraEnabled
        public HousingBed__c bed;
        @AuraEnabled
        public Integer numCars;
        @AuraEnabled
        public Integer numPeers;
        
        public TableDataWrapper(){
            this.bed = new HousingBed__c();
            this.numCars = 0; 
            this.numPeers = 0; 
        }
        
        public TableDataWrapper(HousingBed__c bed,
                                Integer numCars,
                                Integer numPeers) 
        {
            this.bed = bed;
            this.numCars = numCars;
            this.numPeers = numPeers;
        }
    }
    
}