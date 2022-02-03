global class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {
    // @future( callout = true )
    global void execute( QueueableContext qc ){

        List<Product2> toUpdateOrInsertProduct = new List<Product2>();

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment?_ga=2.126495245.1823948643.1643347145-751897319.1639149891');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');

        HttpResponse response = new Http().send( request );

        List<Object> responseBody = ( List<Object> ) JSON.deserializeUntyped( response.getBody() );

        for( Object iterator : responseBody ){

            Map<String,Object> data = ( Map<String,Object> ) iterator;
            toUpdateOrInsertProduct.add( new Product2(
                Name = ( String ) data.get('name'),
                ExternalId = ( String ) data.get('_id'),
                Replacement_Part__c = true,
                Cost__c = ( Decimal ) data.get('cost'),
                Current_Inventory__c = ( Integer ) data.get('quantity'),
                Lifespan_Months__c = ( Integer ) data.get('lifespan'),
                Maintenance_Cycle__c = ( Integer ) data.get('maintenanceperiod'),
                Warehouse_SKU__c = ( String ) data.get('sku')
            ));

        }

        // try{
            Database.upsert( toUpdateOrInsertProduct, Product2.Warehouse_SKU__c, true );
        // } catch( Exception e ){
        //     System.debug('Error Occured while upserting data. Error : ' + e );
        // }

    }
}
