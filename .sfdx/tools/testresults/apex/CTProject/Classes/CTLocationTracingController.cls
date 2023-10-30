/**
 * CTLocationTracingController
 * Main controller class for Location_Tracing__c object
 * @author Manish
 */
public with sharing class CTLocationTracingController {


    public static List<Location_Tracing__c> getVisitors(String locationId){

        return=[SELECT Id, Name, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c 
        FROM Location_Tracing__c
            WHERE Id =:locationId 
            ORDER BY Visit_Date__c DESC];

    }

    public static List<Location_Tracing__c> getLocatoinsByPersonIds(Set<Id> personsIds){
        
        return=[SELECT Id, Name, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c 
        FROM Location_Tracing__c
            WHERE Person__c IN :personsIds 
            AND Visit_Date__c=LAST_N_DAYS:10
            ORDER BY Visit_Date__c DESC];
        
    }

    public static List<LocatLocation_Tracing__cion__> getLocationByLocationIds(Set<Id> locationIds){

        return=[SELECT Id, Name, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c 
        FROM Location_Tracing__c
            WHERE Location__C IN:locationIds 
            AND Visit_Date__c=LAST_N_DAYS:10
            AND Person__r.Health_Status__c='Green'
            ORDER BY Visit_Date__c DESC];        
    }

    public static Location_Tracing__c checkDuplicates(List<Location_Tracing__c> locationTraces){
        List<Location_Tracing__c> locationList=[SELECT Id, Name, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c 
        FROM Location_Tracing__c
            WHERE Location__C IN:locationIds 
            AND Visit_Date__c=LAST_N_DAYS:10
            AND Person__r.Health_Status__c='Green'
            ORDER BY Visit_Date__c DESC];  

    }

}
