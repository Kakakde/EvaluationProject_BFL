public with sharing class ContactMailingClass {
    @AuraEnabled(cacheable=true)
    public static String getContactMailingCity(Id contactId) {
        if (contactId == null) {
            throw new IllegalArgumentException('Contact Id cannot be null');
        }
        Contact con = [SELECT MailingCity FROM Contact WHERE Id = :contactId LIMIT 1];
        return con.MailingCity;
    }
}
