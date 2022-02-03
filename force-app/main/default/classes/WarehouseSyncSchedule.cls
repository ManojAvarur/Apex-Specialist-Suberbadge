global class WarehouseSyncSchedule implements Schedulable {
 

    global void execute(SchedulableContext ctx) {
 

        System.enqueueJob(new WarehouseCalloutService());
 

    }
 

}

// global class WarehouseSyncSchedule implements Schedulable {
//     global void execute( SchedulableContext ctx ){
//         // WarehouseCalloutService updateJob = new WarehouseCalloutService();
//         ID jobID = System.enqueueJob( new WarehouseCalloutService() );
//         // System.debug( jobID );
//     }
// }
