import { LightningElement, track, api, wire } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';

export default class WeatherAPI_withoutSSC extends LightningElement {
    @track GeoLocationData = null;
    @track weatherData = null;  
    @track city = '';
    @api recordId;
    @api objectApiName;

    apiKey = 'd30229392c36dda4141c8daaccba5dc1'; // OpenWeather API Key
    weatherApiKey = '4d5fef4ad2d54be08d1100258250402'; // WeatherAPI Key

    get fieldtoFetch(){
        return this.objectApiName === 'Account' ?
        ['Account.BillingCity'] :
        ['Contact.MailingCity'];
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$fieldtoFetch' })
    wiredRecord({ error, data }) {
        if (data) {
            if (this.objectApiName === 'Account') {
                this.city = data.fields.BillingCity?.value || '';
            } else if (this.objectApiName === 'Contact') {
                this.city = data.fields.MailingCity?.value || '';
            }
            console.log(`City (${this.objectApiName}):`, this.city);
        } else if (error) {
            console.error('Error fetching city:', error);
        }
    }

    getLocation() {
        if (!this.city) {
            alert('Billing City is not available.');
            return;
        }
        console.log('Fetching coordinates for:', this.city);

        // Fetch latitude & longitude from OpenWeather API
        fetch(`https://api.openweathermap.org/geo/1.0/direct?q=${encodeURIComponent(this.city)}&limit=1&appid=${this.apiKey}`)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`OpenWeather API Error: ${response.status} - ${response.statusText}`);
                }
                return response.json();
            })
            .then(data => {
                if (!data || data.length === 0) {
                    throw new Error('City not found.');
                }

                const longitude = data[0].lon;
                const latitude = data[0].lat;

                this.GeoLocationData = { longitude, latitude };
                console.log('Coordinates:', this.GeoLocationData);

                // Fetch weather data using the correct coordinates
                const weatherUrl = `https://api.weatherapi.com/v1/forecast.json?key=${this.weatherApiKey}&q=${latitude},${longitude}&days=1`;
                console.log('Fetching weather from:', weatherUrl);

                return fetch(weatherUrl);
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`WeatherAPI Error: ${response.status} - ${response.statusText}`);
                }
                return response.json();
            })
            .then(weatherData => {
                if (!weatherData || !weatherData.current) {
                    throw new Error('Invalid weather data received.');
                }

                this.weatherData = weatherData;
                console.log('Weather Data:', this.weatherData);
            })
            .catch(error => {
                console.error('Error fetching data:', error);
                this.GeoLocationData = null;
                this.weatherData = null;
                alert(`Failed to fetch weather data: ${error.message}`);
            });
    }
}

