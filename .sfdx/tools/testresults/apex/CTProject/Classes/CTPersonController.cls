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

    

}

   
    

