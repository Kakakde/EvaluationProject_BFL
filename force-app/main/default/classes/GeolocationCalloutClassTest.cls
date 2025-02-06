@isTest
private class GeolocationCalloutClassTest {

    // Mock class for simulating API response
    private class GeolocationCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            
            // Simulated API JSON response
            String mockResponse = '[{"name": "Berlin", "lat": 52.5200, "lon": 13.4050}]';
            response.setBody(mockResponse);
            
            return response;
        }
    }

    @isTest
    static void testGetCoordinates() {
        // Set mock response for HTTP callout
        Test.setMock(HttpCalloutMock.class, new GeolocationCalloutMock());

        Test.startTest();
        GeolocationCalloutClass.GeoLocationWrapper location = GeolocationCalloutClass.getCoordinates('Berlin');
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, location, 'Location should not be null');
        System.assertEquals('Berlin', location.cityName, 'City name should be Berlin');
        System.assertEquals('52.5200', location.latitude, 'Latitude should match');
        System.assertEquals('13.4050', location.longitude, 'Longitude should match');
    }
}