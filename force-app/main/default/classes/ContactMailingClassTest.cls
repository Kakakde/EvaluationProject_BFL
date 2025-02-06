
@isTest
private class ContactMailingClassTest {

    @TestSetup
    static void testSetupData(){
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.MailingCity = 'Berlin';
        insert con;
    }

    @isTest
    static void ContactMailingClassTest() {
        Contact ContactList = [SELECT Id, LastName, MailingCity FROM Contact];
        Test.startTest();
        String mailingCity = ContactMailingClass.getContactMailingCity(ContactList.Id);
        Test.StopTest();
        System.assertEquals('Berlin', mailingCity, 'Mailing City should be Berlin');
        System.assertNotEquals(Null, mailingCity, 'Mailing City should not be Null');
    }

    @isTest
    static void ContactMailingClassIdNullTest() {
        try {
            Test.startTest();
            ContactMailingClass.getContactMailingCity(null);
            Test.stopTest();
            System.assert(false, 'Expected exception when passing null Contact Id');
        } catch (Exception e) {
            System.debug('Actual Exception Message: ' + e.getMessage());
            System.assert(e.getMessage().contains('Contact Id cannot be null'), 
                'Expected a null argument exception, but got: ' + e.getMessage());
        }
    }

}