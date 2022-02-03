trigger Case_NewMaintenanceRequest on Case ( before update ) {
    new MaintenanceRequestHelper().run();
}