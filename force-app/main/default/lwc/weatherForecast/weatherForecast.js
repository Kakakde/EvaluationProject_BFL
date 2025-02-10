import { LightningElement, track, api, wire } from 'lwc';
import getAccountBillingCity from '@salesforce/apex/AccountBillingClass.getAccountBillingCity';
import getContactMailingCity from '@salesforce/apex/ContactMailingClass.getContactMailingCity';
import getCoordinates from '@salesforce/apex/GeolocationCalloutClass.getCoordinates';
import getWeatherDetails from '@salesforce/apex/OpenWeatherCalloutClass.getWeatherDetails';
import { CurrentPageReference } from 'lightning/navigation';

export default class WeatherForecast extends LightningElement {
    @track weatherData;
    @api recordId;
    @track cityName = '';
    @api objectApiName; // This will hold the object type
    isLoading = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference?.state?.recordId) {
            this.recordId = currentPageReference.state.recordId;
            console.log('Extracted recordId from URL:', this.recordId);
        }
    }

    fetchWeather() {
        console.log('Fetching weather for recordId:', this.recordId);
        console.log('Object Type:', this.objectApiName); // ✅ This should log 'Account' or 'Contact'

        if (!this.recordId || !this.objectApiName) {
            console.error(' Missing recordId or objectApiName.');
            return;
        }

        this.isLoading = true;

        let cityPromise;
        if (this.objectApiName === 'Account') {
            cityPromise = getAccountBillingCity({ accountId: this.recordId });
        } else if (this.objectApiName === 'Contact') {
            cityPromise = getContactMailingCity({ contactId: this.recordId });
        } else {
            console.error('Unsupported object type:', this.objectApiName);
            this.isLoading = false;
            return;
        }

        cityPromise // this is promise that dynamically fetches city based on object type.
            .then(city => {
                console.log('City:', city);
                if (!city) {
                    throw new Error('City is empty or not available');
                }
                this.cityName = city;
                return getCoordinates({ cityName: city });
            })
            .then(geoResult => {
                console.log('Geo Data:', geoResult);
                return getWeatherDetails({
                    latitude: geoResult.latitude,
                    longitude: geoResult.longitude
                });
            })
            .then(weatherResult => {
                this.weatherData = weatherResult;
                console.log('Weather Data:', this.weatherData);
            })
            .catch(error => {
                console.error('Error fetching weather:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    clearWeather() {
        this.weatherData = null;
}
}