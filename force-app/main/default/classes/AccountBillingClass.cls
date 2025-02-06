public with sharing class AccountBillingClass {
    
    @AuraEnabled(cacheable=true)
    public static String getAccountBillingCity(Id accountId) {
        // Query the Account to retrieve the BillingCity field
        Account acc = [SELECT BillingCity FROM Account WHERE Id = :accountId LIMIT 1];
        System.debug(acc);
        // Return the BillingCity
        return acc.BillingCity;
    }
}
