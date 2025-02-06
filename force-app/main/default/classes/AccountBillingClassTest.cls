
@isTest
private class AccountBillingClassTest {

    @TestSetup
    static void TestSetupData(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCity = 'Oslo';
    insert acc;
    }
    @isTest
    static void testAccountBillingCity() {
       Account accountList = [SELECT Id, BillingCity FROM Account];
       Test.startTest();
       String billingCity = AccountBillingClass.getAccountBillingCity(accountList.Id);
       Test.StopTest();

       //Assertion
       System.assertEquals('Oslo', billingCity, 'Billing City should be Oslo');
       System.assertNotEquals(Null, billingCity, 'Billing City should not be Null');
    }
    @isTest
    static void testAccountBillingId() {
        Account accountList = [SELECT Id, BillingCity FROM Account];
        try{
        Test.startTest();
        AccountBillingClass.getAccountBillingCity(null);
        Test.stopTest();
        System.assert(false, 'Exception will be thrown if AccountId is Null');
        }
        catch(Exception e){
            System.assertEquals('No rows for assignment in sObject', e.getMessage().substring(0, 40),'Expected query exception for invalid Id');
        }
    }

}