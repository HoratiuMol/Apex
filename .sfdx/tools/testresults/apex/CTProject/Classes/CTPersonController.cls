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

    }

    /**
     * generate unique token using mobile number
     * use MD5 algorithm to generate one-way hash
     * @param mobile
     * @return string token
     */
    
    public static String getToken(String mobileNo){
        Blob value = Blob.valueOf(mobileNo);
        Blob hash = Crypto.generateDigest('MD5', value);
        // return encoded string
        return EncodingUtil.base64Encode(hash);
    }

