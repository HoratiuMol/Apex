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

    public static List<LocatLocation_Tracing__cion__> getLocationsByLocationIds(Set<Id> locationIds){

        return=[SELECT Id, Name, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c 
        FROM Location_Tracing__c
            WHERE Location__C IN:locationIds 
            AND Visit_Date__c=LAST_N_DAYS:10
            AND Person__r.Health_Status__c='Green'
            ORDER BY Visit_Date__c DESC];        
    }

    public static Location_Tracing__c checkDuplicates(List<Location_Tracing__c> newlocationTraces){
        /*
        Step1: iterate over location
        Step2: Queery location using ids collected
        Step3: Create a Map<locationId, Set<personId>
        Step4: Loop overt new locationrecords in Map
        Step5:Return list of duplicates
        */

        //store unique locationid
        Set<Id> locationIds=new Set<Id>();
        //store uniqueperson id
        Set<Id> personIds=new Set<Id>();

        for(Location_Tracing__c trace : newlocationTraces){
            locationsIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        //query existing location tracing records
        [SELECT Id, Person__c, Location__c
        FROM Location_Tracing__c
            WHERE Location__C IN:locationIds 
            AND Person__c IN:personIds
            AND Visit_Date__c=LAST_N_DAYS:10];
    }
    //map Location id,set of person id
    Map<Id, Set<Id>> mapOfExistingRecords=new Map<Id, Set<Id>>();
    //location1[person1,person2]

    //querry existing location tracing records
    List<Location_Tracing__c> existingRecords=[SELECT Id, Person__c, Location__c
    FROM Location_Tracing__c
        WHERE Location__C IN:locationIds 
        AND Person__c IN:personIds
        AND Visit_Date__c=LAST_N_DAYS:10];

    //create list of duplicate records (blank)
    List<Location_Tracing__c> duplicates=new List<Location_Tracing__c>();
        if(existingRecords != null && existingRecords.size()>0){
            for(Location_Tracing__c trace: existingRecords){
                
            String locationId=trace.Location__c;
            String personId=trace.Person__c;
            //check if map already has the location id key
                if(! mapOfExistingRecords.containsKey(locationId)){
                    //map does not have this key
                    //add this new item  in the map using location id as key
                    //add blanck Set<Id> as value
                    mapOfExistingRecords.put(locationId, new Set<Id>);
                }
                //get map item using locationid Key
                Set<Id> personIds= mapOfExistingRecords.get(locationId);
                //add the person id to the set
                personsIds.add(personId);
                //overwrite the existing map value
                mapOfExistingRecords.put(locationId,personIds);
            }

            //loop over new location tracing record
            for(Location_Tracing__c trace : newlocationTraces){
                //first chekc for location id
                //if item found in map, then chekc for person id in set
                if(mapOfExistingRecords.containsKey(trace.Location__c)
                && mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)){
                    duplicates.add(trace);
                }

            }
        }
        return duplicates;

}
