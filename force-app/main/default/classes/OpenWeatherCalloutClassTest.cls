@isTest
private class OpenWeatherCalloutClassTest {

    // ✅ Mock class to simulate successful Weather API response
    private class OpenWeatherCalloutMockSuccess implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            
            // ✅ JSON response with necessary fields for proper test coverage
            String mockResponse = '{' +
                '"location": { "name": "Berlin" },' +
                '"forecast": {' +
                    '"forecastday": [{' +
                        '"day": {' +
                            '"avgtemp_c": 15.5,' +
                            '"avghumidity": 78,' +
                            '"mintemp_c": 12.0,' +
                            '"maxtemp_c": 18.0' +
                        '},' +
                        '"hour": [' +
                            '{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},' + 
                            '{ "feelslike_c": 14.2, "pressure_mb": 1013 }' +
                        ']' +
                    '},' +  // First day
                    '{' +  // Second day (tomorrow)
                        '"day": {' +
                            '"avgtemp_c": 16.2,' +
                            '"avghumidity": 80,' +
                            '"mintemp_c": 13.0,' +
                            '"maxtemp_c": 19.5' +
                        '},' +
                        '"hour": [' +
                            '{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},' + 
                            '{ "feelslike_c": 15.1, "pressure_mb": 1015 }' +
                        ']' +
                    '}' +  
                    ']' +
                '}' +
            '}';

            response.setBody(mockResponse);
            return response;
        }
    }

    @isTest
    static void testGetWeatherDetails_Success() {
        // ✅ Set mock for success scenario
        Test.setMock(HttpCalloutMock.class, new OpenWeatherCalloutMockSuccess());

        Test.startTest();
        OpenWeatherCalloutClass.WeatherDetailsWrapper weather =
            OpenWeatherCalloutClass.getWeatherDetails('52.5200', '13.4050');
        Test.stopTest();

        // ✅ Assertions
        System.assertNotEquals(null, weather, 'Weather response should not be null');
        System.assertEquals('Berlin', weather.cityName, 'City name should be Berlin');
        System.assertEquals('80', weather.humidity, 'Humidity should be 80%');
        System.assertEquals('13.0', weather.tempMin, 'Min Temp should be 13.0°C');
        System.assertEquals('19.5', weather.tempMax, 'Max Temp should be 19.5°C');
        System.assertEquals('15.1', weather.feelsLike, 'Feels Like should be 15.1°C');
        System.assertEquals('1015', weather.pressure, 'Pressure should be 1015 mb');
    }
}