@isTest
public with sharing class WarehouseCalloutServiceTest {
    
    @isTest
    static void testWarehouseCalloutService() {
        
        Test.setMock( HttpCalloutMock.class, new WarehouseCalloutServiceMock() );

        Test.startTest();
            String jobId = System.enqueueJob( new WarehouseCalloutService() );
        Test.stopTest();

        Integer count = [ SELECT Count() FROM Product2 ];

        System.assertEquals( 22, count, 'No Products were created!');
    }

}
