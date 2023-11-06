/**
 * CTPersonController
 * Main controller class for Person__c object
 * @author Manish
 */
public with sharing class CTPersonController {
    /*
    Blob:
    A collection of binary data stored as a single object. 
    You can convert this data type to String or from String using the toString and valueOf methods, 
    respectively. Blobs can be accepted as Web service arguments, stored in a document (the body of a document is a Blob), 
    or sent as attachments. For more information, see Crypto Class.
    
    CryptoClass:
    The methods in the Crypto class can be used for securing content in Lightning Platform,
    or for integrating with external services such as Google or Amazon WebServices (AWS).
    */

    public static String getToken(String mobileNo){
        Blob value = Blob.valueOf(mobileNo);
        Blob hash = Crypto.generateDigest('MD5', value);
        // return encoded string
        return EncodingUtil.base64Encode(hash);
    }

    //we need to SFDX: Refresch Object Definition
    public static List<Person__c> getRecentHealthChanges(){
        /*List<Person__c> people=*/
        //or we can use straight "return"
        return [SELECT Id, Name, Health_Status__c,Mobile__c,Status_Update_Date__c, Token__c FROM Person__c ORDER BY Status_Update_Date__c DESC LIMIT 100];

    }

    public static List<Person__c> searchPeople(String searchTerm){
        searchTerm=searchTerm+'%';        
        
        return [SELECT Id, Name, Health_Status__c,Mobile__c,Status_Update_Date__c FROM Person__c 
        WHERE 
            (Name LIKE :searchTerm 
            OR Mobile__c LIKE :searchTerm 
            OR Token__c LIKE :searchTerm) 
        ORDER BY Status_Update_Date__c DESC NULLS LAST];
    }

    public static Person__c getPersonById(String personId){
       //we cant directly return, beacuse we must only get one person recrod
       //instead of a querry list
       List<Person__c> people=[SELECT Id, Name, Health_Status__c,Mobile__c,Status_Update_Date__c FROM Person__c 
        WHERE Id =:personId];
        //so here we must use the list object to save the files and make sure we get one
        if(people!=null && people.size()>0){
            return people[0];
            //we give back the first elemente
        }
        return null; //if there is no elemente, we return null
    }

    public static Map<String, Integer> getHealthStatusCount(){

        Map<String, Integer> healthCountMap=new Map<String, Integer>();

        For(AggregateResult ar: [SELECT Id, Name, Health_Status__c,
                                    COUNT(Id) Health_Status__c
                                     FROM Person__c
                                    GROUP BY Health_Status__c]){
            String healtStatusString.valueof(ar.get('Health_Status__c'));
            Integer count=Integer.valueOf(ar.get('total'));                       
            healthCountMap.put(ar.get('Health_Status__c'),ar.get('total'));
}

            return healthCountMap;
    }

    public static Set<Id> getCohabitants(Set<Id> personIds){
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};

        List<People_Tracing__c> peopleTraces=[SELECT Id, Person_1__c, person_2__c FROM People_Tracing__c 
                                                WHERE (Person_1__c IN :personIds OR person_2__c IN :personIds) 
                                                 AND Contact_Type__c = 'Cohabitant'
                                                 AND (Person_1__r.Health_Status__c IN :healthStatuses 
                                                    OR Person_2__r.Health_Status__c IN :healthStatuses)
                                                    ];

        Set<Id> cohabitants= new Set<Id>();
        for(People_Tracing__c pt: peopleTraces){
            if(!personIds.contains(pt.Person_1__c)){
                cohabitants.add(pt.Person_1__c);
            }
            if(!personIds.contains(pt.Person_2__c)){
                cohabitants.add(pt.Person_2__c);
            }
        }
        return cohabitants;
    }

    public static Set<Id> getNeighbours(Set<Id> personIds){
        
        List<People_Tracing__c> peopleTraces=[SELECT Id, Person_1__c, person_2__c FROM People_Tracing__c 
                                                WHERE (Person_1__c IN :personIds OR person_2__c IN :personIds) 
                                                 AND Contact_Type__c = 'Neighbour'
                                                 AND (Person_1__r.Health_Status__c ='Green' 
                                                    OR Person_2__r.Health_Status__c ='Green')
                                                    ];

        Set<Id> neighbours= new Set<Id>();
        for(People_Tracing__c pt: peopleTraces){
            if(!personIds.contains(pt.Person_1__c)){
                neighbours.add(pt.Person_1__c);
            }
            if(!personIds.contains(pt.Person_2__c)){
                neighbours.add(pt.Person_2__c);
            }
        }
        return neighbours;
    }

    public static Set<Id> getPrimaryContacts(Set<Id> personIds){
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        
        List<People_Tracing__c> peopleTraces=[SELECT Id, Person_1__c, person_2__c FROM People_Tracing__c 
                                                WHERE (Person_1__c IN :personIds OR person_2__c IN :personIds) 
                                                 AND Contact_Type__c = 'Other'
                                                 And Contact_Date__c= LAST_N_DAYS:10
                                                 AND (Person_1__r.Health_Status__c IN :healthStatuses 
                                                    OR Person_2__r.Health_Status__c IN :healthStatuses)
                                                    ];

        Set<Id> primaryContacts= new Set<Id>();
        for(People_Tracing__c pt: peopleTraces){
            if(!personIds.contains(pt.Person_1__c)){
                primaryContacts.add(pt.Person_1__c);
            }
            if(!personIds.contains(pt.Person_2__c)){
                primaryContacts.add(pt.Person_2__c);
            }
        }
        return primaryContacts;
    }

    public static Set<Id> getSecondaryContacts(Set<Id> primaryContactsIds){
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        
        List<People_Tracing__c> peopleTraces=[SELECT Id, Person_1__c, person_2__c FROM People_Tracing__c 
                                                WHERE (Person_1__c IN :primaryContactsIds OR person_2__c IN :primaryContactsIds) 
                                                 AND Contact_Type__c = 'Other'
                                                 And Contact_Date__c= LAST_N_DAYS:10
                                                 AND (Person_1__r.Health_Status__c IN :healthStatuses 
                                                    OR Person_2__r.Health_Status__c IN :healthStatuses)
                                                    ];

        Set<Id> secondaryContacts= new Set<Id>();
        for(People_Tracing__c pt: peopleTraces){
            if(!primaryContactsIds.contains(pt.Person_1__c)){
                secondaryContacts.add(pt.Person_1__c);
            }
            if(!primaryContactsIds .contains(pt.Person_2__c)){
                secondaryContacts.add(pt.Person_2__c);
            }
        }
        return secondaryContacts;
    }

    

}

   
    

