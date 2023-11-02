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

    public static Location__c locationId(String locationId){
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
