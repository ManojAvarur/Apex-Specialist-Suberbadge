@isTest
public with sharing class WarehouseSyncScheduleTest {
    
    @isTest
    static void testSchedule(){

        String cron = '0 0 1 * * ?';
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        Test.startTest();
            System.assertEquals( 0 , [ SELECT Count() FROM Product2 ] );
            String jobId = System.schedule( 'WarehouseSyncScheduleJobTest', cron, new WarehouseSyncSchedule() );
        Test.stopTest();

            CronTrigger[] a=[SELECT Id FROM CronTrigger where NextFireTime > today ];
            System.assertEquals( jobID, a[2].Id );
    }
}
