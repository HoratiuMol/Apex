/**
 * CTLocationController
 * Main controller class for Location__c object
 * @author Manish
 */
public with sharing class CTLocationController {

    public static List<Location__c> getRecentStatusChanges(){
        return [SELECT id, Name, Address__c,Pincode__c,Red_Score__c,Status_Update_date__c,Status__c FROM Location__c ORDER BY Status_Update_date__c DESC NULLS LAST LIMIT 100];

    }

    public static List<Location__c> searchLocation(String searchTerm){
        searchTerm=searchTerm+'%';
        return [SELECT id, Name, Address__c,Pincode__c,Red_Score__c,Status_Update_date__c,Status__c 
        FROM Location__C 
        WHERE Name 
            LIKE :searchTerm 
            OR Address__c :=searchTerm
            OR Pincode__c :=searchTerm
        ORDER BY Status_Update_date__c DESC NULLS LAST LIMIT 100];
    }

    public static Location__c getLocationById(String locationId){
        List<Location__c> locations=[SELECT id, Name, Address__c,Pincode__c,Red_Score__c,Status_Update_date__c,Status__c 
        FROM Location__C 
        WHERE Id =:locationId 
        ORDER BY Status_Update_date__c DESC NULLS LAST LIMIT 100];
        if(locations != null && locations.size()>0){
            return locations[0];
        }
    }return null;


    public static Map<String, Integer> getStatusCount(){
        Map<String, Integer> statusCountMap=new Map<String, Integer>();

        For(AggregateResult ar: [SELECT Id, Name, Status,
                                    COUNT(Id) Status
                                     FROM Location__c
                                    GROUP BY Health_StatusStatus__c]){
                                  
            statusCountMap.put(String.valueof(ar.get('Location__c')),Integer.valueOf(ar.get('total')));

    }
    return statusCountMap;
}

    public static void updateRedScore(Set<Id> locationIds){
        List<Location__c> locationToUpdate=new List<Location__c>();
        AggregateResults[] redPoeplePerLocation=[SELECT Location__c, COUNT(Id) total FROM Location_Tracing__c
            WHERE Person__r.Health_Status__c = 'Red'
            AND Visit_Date__c = LAST_N_DAYS : 10
            AND Location__c IN : locationIds
            GROUP BY Location__c]

            for(AggregateResult ar:redPoeplePerLocation){
                String locationId=String.valueOf(ar.get('Location__c'));
                Integer redScore=String.valueOf(ar.get('total'));
                String status=getStatus(redScore);
                locationToUpdate.add(new Location__c(Id=locationId, Red_Score__c=redScore, Status__c=status));
            }

            if(locationToUpdate != null && locationToUpdate.size()>0){
                update locationToUpdate;
            }

    }
    
    public static String getStatus(Integer redScore){
        if(redScore ==0){
            return 'Green';
        }else if(redScore<=5){
            return 'Yellow';
        }else if(redScore <=10){
            return 'Orange';
        }else{
            return 'Red';
        }
    }
}
