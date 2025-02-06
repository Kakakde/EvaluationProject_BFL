public with sharing class OpenWeatherCalloutClass {
    @AuraEnabled
    public static WeatherDetailsWrapper getWeatherDetails(String latitude, String longitude) {
        String apiKey = '4d5fef4ad2d54be08d1100258250402'; // Replace with your weather API key
        String endpoint = 'http://api.weatherapi.com/v1/forecast.json?key=' + apiKey +
                          '&q=' + latitude + ',' + longitude + '&days=2';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        System.debug('Weather API Response: ' + response.getBody());

        WeatherDetailsWrapper weather = new WeatherDetailsWrapper();

        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> location = (Map<String, Object>) results.get('location');
            List<Object> forecastList = (List<Object>) ((Map<String, Object>) results.get('forecast')).get('forecastday');

            weather.cityName = String.valueOf(location.get('name'));

            if (!forecastList.isEmpty() && forecastList.size() > 1) {
                Map<String, Object> tomorrowForecast = (Map<String, Object>) forecastList[1]; // Next day
                Map<String, Object> dayData = (Map<String, Object>) tomorrowForecast.get('day');

                weather.temperature = String.valueOf(dayData.get('avgtemp_c')) ;
                weather.humidity = String.valueOf(dayData.get('avghumidity'));
                weather.tempMin = String.valueOf(dayData.get('mintemp_c'));
                weather.tempMax = String.valueOf(dayData.get('maxtemp_c'));

                // ✅ Extract Hourly Data for Feels Like Temperature & Pressure
                List<Object> hourlyData = (List<Object>) tomorrowForecast.get('hour');
                if (!hourlyData.isEmpty() && hourlyData.size() >= 13) { // Mid-day forecast (12 PM)
                    Map<String, Object> middayHour = (Map<String, Object>) hourlyData[12]; // 12:00 PM data
                    
                    weather.feelsLike = String.valueOf(middayHour.get('feelslike_c'));
                    weather.pressure = String.valueOf(middayHour.get('pressure_mb'));
                }
            }
        }

        System.debug('Weather Details: ' + weather);
        return weather;
    }

    public class WeatherDetailsWrapper {
        @AuraEnabled public String cityName {get;set;}
        @AuraEnabled public String temperature {get;set;}
        @AuraEnabled public String pressure {get;set;}
        @AuraEnabled public String humidity {get;set;}
        @AuraEnabled public String feelsLike {get;set;}
        @AuraEnabled public String tempMin {get;set;}
        @AuraEnabled public String tempMax {get;set;}
    }
}
