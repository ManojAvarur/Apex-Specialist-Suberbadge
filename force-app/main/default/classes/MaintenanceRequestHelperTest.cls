@isTest
public with sharing class MaintenanceRequestHelperTest {

    @TestSetup
    public static void makeData(){
        
        List<Vehicle__c> vehicleDataList = new List<Vehicle__c>();
        List<Product2> productDataList = new List<Product2>();
        List<Case> caseDataList = new List<Case>();
        List<Equipment_Maintenance_Item__c> EMIDataList = new List<Equipment_Maintenance_Item__c>();
        
        for( Integer i = 1; i <= 500; i++ ){
            
            vehicleDataList.add( new Vehicle__c(
                Name = 'Test Vehicle' + i
            ));

            productDataList.add( new product2(
                Name = 'Test Prodict' + i,
                Cost__c = Math.floor( Math.random() * ( 1000 - 100 )) + 100,
                Maintenance_Cycle__c = Math.floor( Math.random() * ( 200 - 30 )) + 30,
                Replacement_Part__c = true
            ));

            caseDataList.add( new Case(
                Origin = 'Phone',
                Type = ( Math.mod( i, 2 ) == 0 )? 'Repair' : 'Routine Maintenance',
                Subject = 'Test Case ' + i
            ));

        }

        insert vehicleDataList;
        insert productDataList;
        insert caseDataList;

        for( Integer i = 0; i < 500; i++ ){

            caseDataList[i].Vehicle__c = vehicleDataList[i].Id;

            EMIDataList.add( new Equipment_Maintenance_Item__c(
                Equipment__c = productDataList[ ( Integer ) Math.floor( Math.random() * ( 150 - 0 )) + 0 ].Id,
                Maintenance_Request__c = caseDataList[i].Id
            ));

            EMIDataList.add( new Equipment_Maintenance_Item__c(
                Equipment__c = productDataList[ ( Integer ) Math.floor( Math.random() * ( 300 - 150 )) + 150 ].Id,
                Maintenance_Request__c = caseDataList[i].Id
            ));

            EMIDataList.add( new Equipment_Maintenance_Item__c(
                Equipment__c = productDataList[ ( Integer ) Math.floor( Math.random() * ( 450 - 300 )) + 300 ].Id,
                Maintenance_Request__c = caseDataList[i].Id
            ));

            EMIDataList.add( new Equipment_Maintenance_Item__c(
                Equipment__c = productDataList[ ( Integer ) Math.floor( Math.random() * ( 499 - 450 )) + 450 ].Id,
                Maintenance_Request__c = caseDataList[i].Id
            ));

        }

        update caseDataList;
        insert EMIDataList;

    }
    
    @isTest
    public static void singleRecordPositiveTest(){

        Case testData = [ SELECT Status FROM Case LIMIT 1 ];
        Equipment_Maintenance_Item__c[] EMIOldData = [ SELECT Id FROM Equipment_Maintenance_Item__c ];
        
        testData.Status = 'Closed';

        Test.startTest();

            update testData;

            Case[] caseData = [ SELECT Id FROM Case ];
            Equipment_Maintenance_Item__c[] EMINewData = [ SELECT Id FROM Equipment_Maintenance_Item__c ];

            System.assertEquals( 
                501, 
                caseData.size(), 
                'Acctual Case Size is : "' + caseData.size() + '". Because no new case was created' 
            );

            System.assert( ( EMINewData.size() > EMIOldData.size() ), 'No new (EMI) Data was created!');

        Test.stopTest();
    }

    @isTest
    public static void singleRecordNegativeTest(){

        Case testData = [ SELECT Status FROM Case LIMIT 1 ];
        Equipment_Maintenance_Item__c[] EMIOldData = [ SELECT Id FROM Equipment_Maintenance_Item__c ];

        testData.Type = 'Other';
        testData.Status = 'Closed';

        Test.startTest();

            update testData;

            Case[] caseData = [ SELECT Id FROM Case ];
            Equipment_Maintenance_Item__c[] EMINewData = [ SELECT Id FROM Equipment_Maintenance_Item__c ];

            System.assertEquals( 
                500, 
                caseData.size(), 
                'Acctual Case Size is : "' + caseData.size() + '". Because a new case was created' 
            );

            System.assert( ( EMINewData.size() == EMIOldData.size() ), 'New (EMI) Data was created!');

        Test.stopTest();
    }

    @isTest
    public static void multipleRecordsPositiveTest(){

        Case[] caseList = [ SELECT Status FROM Case ];
        Equipment_Maintenance_Item__c[] EMIOldData = [ SELECT Id FROM Equipment_Maintenance_Item__c ];

        for( Case iterator : caseList ){
            iterator.Status = 'Closed';
        }

        Test.startTest();

            update caseList;

            Case[] caseData = [ SELECT Id FROM Case ];
            Equipment_Maintenance_Item__c[] EMINewData = [ SELECT Id FROM Equipment_Maintenance_Item__c ];
            

            System.assertEquals( 
                1000, 
                caseData.size(), 
                'Acctual Case Size is : "' + caseData.size() + '". Because no new case\'s were created' 
            );

            System.assert( ( EMINewData.size() > EMIOldData.size() ), 'No new (EMI) Data was created!');

        Test.stopTest();
    }

    @isTest
    public static void multipleRecordsNegativeTest(){

        Case[] caseList = [ SELECT Status FROM Case ];
        Equipment_Maintenance_Item__c[] EMIOldData = [ SELECT Id FROM Equipment_Maintenance_Item__c ];

        for( Case iterator : caseList ){
            iterator.Type = 'Other';
            iterator.Status = 'Closed';
        }

        Test.startTest();

            update caseList;

            Case[] caseData = [ SELECT Id FROM Case ];
            Equipment_Maintenance_Item__c[] EMINewData = [ SELECT Id FROM Equipment_Maintenance_Item__c ];
            

            System.assertEquals( 
                500, 
                caseData.size(), 
                'Acctual Case Size is : "' + caseData.size() + '". Because new case\'s were created' 
            );

            System.assert( ( EMINewData.size() == EMIOldData.size() ), 'New (EMI) Data was created!');

        Test.stopTest();
    }

    // @isTest
    // public static void testExeption(){
        
    //     User testUser = [ SELECT Id FROM User WHERE alias = 'ttest'];
    //     Case testData = [ SELECT Status FROM Case LIMIT 1 ];
        
    //     testData.Status = 'Closed';

    //     Test.startTest();
    //         System.runAs( testUser ){
                
    //             try{
    //                 update testData;    
                    
    //                 // System.assertEquals( 'idk',  'idkx');
    //             } catch ( Exception e ){
    //                 System.debug( e.getMessage() );
    //                 System.assertEquals( 'idk',  e.getMessage() );
    //             }
                
    //         }
    //     Test.stopTest();
    // }

}
