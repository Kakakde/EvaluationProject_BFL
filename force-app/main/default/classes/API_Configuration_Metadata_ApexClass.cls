public with sharing class API_Configuration_Metadata_ApexClass {
   @AuraEnabled(cacheable=true)
   public static string getOpenWeatherAPIKey() {
    API_Configuration__mdt Key  = [SELECT MasterLabel, API_Key__C FROM API_Configuration__mdt WHERE MasterLabel = 'OpenWeather API Key'];
    return Key.API_Key__C;
   }
   @AuraEnabled(cacheable=true)
   public static string getWeatherAPIKey(){
    API_Configuration__mdt key = [SELECT MasterLabel, API_Key__c FROM API_Configuration__mdt WHERE MasterLabel = 'WeatherAPI Key'];
    return key.API_Key__c;
   }
}