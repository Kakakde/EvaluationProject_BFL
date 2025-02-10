global with sharing class CalculateCallback implements SBQQ.CalculateCallback {
    global void callback(String quoteJSON){
      SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', quoteJSON);       
    }
  }