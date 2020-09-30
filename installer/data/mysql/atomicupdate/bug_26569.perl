$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET explanation='Define which baskets a user is allowed to view: their own only, any within their branch, or all' WHERE variable='AcqViewBaskets'" );
    $dbh->do( "UPDATE systempreferences SET explanation='If enabled, the patron can set checkouts to be visible to their guarantor' WHERE variable='AllowPatronToSetCheckoutsVisibilityForGuarantor'" );
    $dbh->do( "UPDATE systempreferences SET explanation='If enabled, the patron can set fines to be visible to their guarantor' WHERE variable='AllowPatronToSetFinesVisibilityForGuarantor'" );
    $dbh->do( "UPDATE systempreferences SET explanation='If on, and a patron is logged into the OPAC, items from their home library will be emphasized and shown first in search results and item details.' WHERE variable='HighlightOwnItemsOnOPAC'" );
    $dbh->do( "UPDATE systempreferences SET explanation='If ON, the next user will automatically get the last searches in their history' WHERE variable='LoadSearchHistoryToTheFirstLoggedUser'" );
    $dbh->do( "UPDATE systempreferences SET explanation='If enabled, any patron attempting to register themselves via the OPAC will be required to verify themselves via email to activate their account.' WHERE variable='PatronSelfRegistrationVerifyByEmail'" );


    NewVersion( $DBversion, 26569, "Use gender neutral pronouns in system preference explanations");
}