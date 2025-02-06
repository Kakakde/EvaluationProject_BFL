public with sharing class GeolocationCalloutClass {
    @AuraEnabled
    public static GeoLocationWrapper getCoordinates(String cityName) {
        String apiKey = 'd30229392c36dda4141c8daaccba5dc1'; // Replace with your API key
        String encodedCityName = EncodingUtil.urlEncode(cityName, 'UTF-8');
        String endpoint = 'http://api.openweathermap.org/geo/1.0/direct?q=' + encodedCityName + '&limit=1&appid=' + apiKey;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        System.debug('Geo API Response: ' + response.getBody());

        GeoLocationWrapper location = new GeoLocationWrapper();

        if (response.getStatusCode() == 200) {
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
            if (!results.isEmpty()) {
                Map<String, Object> cityData = (Map<String, Object>) results[0];
                location.cityName = String.valueOf(cityData.get('name'));
                location.latitude = String.valueOf(cityData.get('lat'));
                location.longitude = String.valueOf(cityData.get('lon'));
            }
        }

        System.debug('Coordinates: ' + location);
        return location;
    }

    public class GeoLocationWrapper {
        @AuraEnabled public String cityName {get;set;}
        @AuraEnabled public String latitude {get;set;}
        @AuraEnabled public String longitude {get;set;}
    }
}
