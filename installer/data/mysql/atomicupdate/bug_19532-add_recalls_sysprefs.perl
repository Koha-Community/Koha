$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
        ('RecallsLog','1',NULL,'If ON, log create/cancel/expire/fulfill actions on recalls','YesNo'),
        ('RecallsMaxPickUpDelay','7',NULL,'Define the maximum time a recall can be awaiting pickup','Integer'),
        ('UseRecalls','0',NULL,'Enable or disable recalls','YesNo')
    });

    NewVersion( $DBversion, 19532, "Add RecallsLog, RecallsMaxPickUpDelay and UseRecalls system preferences");
}
