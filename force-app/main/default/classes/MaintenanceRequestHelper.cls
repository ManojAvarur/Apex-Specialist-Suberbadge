public with sharing class MaintenanceRequestHelper extends TriggerHandler {
    
    public MaintenanceRequestHelper() { 
        // this.setMaxLoopCount(1);
    }

    public override void beforeUpdate(){

        List<Case> newCaseList = ( List<Case> ) Trigger.new;
        List<Case> oldCaseList = ( List<Case> ) Trigger.old;

        List<Case> newCaseListToInsert = new List<Case>();
        Set<Id> caseId = new Set<Id>();
        List<Equipment_Maintenance_Item__c> newEMIListToInsert = new List<Equipment_Maintenance_Item__c>();

        List<Map<Id, Id>> idListToRetriveData = new List<Map<Id, Id>>();
        Map<String, List<String>> EMIToInsertData = new Map<String, List<String>>();

        for( Integer i = 0; i < newCaseList.size(); i++ ){

            if( ( newCaseList[i].Type == 'Repair' || newCaseList[i].Type == 'Routine Maintenance' ) 
                    && ( newCaseList[i].Status == 'Closed' && oldCaseList[i].Status != 'Closed' ) 
            ){
                idListToRetriveData.add( new Map<Id, Id>{
                    oldCaseList[i].Id  => oldCaseList[i].Vehicle__c
                } );

                caseId.add( oldCaseList[i].Id );
                // idListToRetriveData.put( oldCaseList[i].Id,  oldCaseList[i].Vehicle__c );
            }

            // System.debug( newCaseList[i].Status == 'Closed' + ' and ' + oldCaseList[i].Status != 'Closed'  );

        }
        
        // System.debug(oldCaseList);
        // System.debug( caseId );

        List<Equipment_Maintenance_Item__c> caseDataWithMaintenanceCycle = [ SELECT Maintenance_Request__c, Equipment__r.Cost__c, 
                                                                                    Equipment__r.Maintenance_Cycle__c, Equipment__r.Name 
                                                                                FROM Equipment_Maintenance_Item__c 
                                                                                WHERE Maintenance_Request__c IN :caseId ];

        for( Integer i = 0 ; i < idListToRetriveData.size(); i++ ){

            Decimal lowestMaintenancecycle = -1;
            String vehicle = idListToRetriveData[i].values()[0];
            Id currentCaseId =  new List<Id>( idListToRetriveData[i].keySet() )[0];
            List<Id> tempEquipmentIdList = new List<Id>();

            for( Equipment_Maintenance_Item__c iterator : caseDataWithMaintenanceCycle ){
                
                if( iterator.Maintenance_Request__c == currentCaseId ){

                    if( lowestMaintenancecycle == -1 ){
                        lowestMaintenancecycle = iterator.Equipment__r.Maintenance_Cycle__c;
                    } else if ( iterator.Equipment__r.Maintenance_Cycle__c < lowestMaintenancecycle  ){
                        lowestMaintenancecycle = iterator.Equipment__r.Maintenance_Cycle__c;
                    }

                    tempEquipmentIdList.add( iterator.Equipment__r.Id );

                }

            }

            // System.debug('lowestMaintenancecycle = ' + lowestMaintenancecycle);

            EMIToInsertData.put( vehicle, tempEquipmentIdList );
            
            newCaseListToInsert.add( new Case(
                Vehicle__c = vehicle,
                Type = 'Routine Maintenance' ,
                Subject = '" Routine Maintenance " create by automation' ,
                Date_Reported__c = Datetime.now().date(),
                Date_Due__c = Datetime.now().date().addDays( ( Integer ) lowestMaintenancecycle )
            ));

        }

        if( newCaseListToInsert.size() > 0 ){

            // try{
                Database.insert( newCaseListToInsert, true);

                for( Case iterator : newCaseListToInsert ){

                    for( String equipmentId : EMIToInsertData.get( iterator.Vehicle__c ) ){

                        newEMIListToInsert.add( new Equipment_Maintenance_Item__c(
                            Equipment__c = equipmentId,
                            Maintenance_Request__c = iterator.Id
                        ));

                    }
                    
                }

                Database.insert( newEMIListToInsert, true);

                System.debug('Current User: ' + UserInfo.getUserName());
                System.debug('Current Profile: ' + UserInfo.getProfileId());

            // } catch ( Exception e ){
            //     System.debug('Error occured while inserting data. Please try again.');
            //     System.debug('Error : ' + e );
            // }

        }
        
    }

}