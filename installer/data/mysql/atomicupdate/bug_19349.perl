$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES
        ('MarcFieldForCreatorId','',NULL,'Where to store the borrowernumber of the record''s creator','Free'),
        ('MarcFieldForCreatorName','',NULL,'Where to store the name of the record''s creator','Free'),
        ('MarcFieldForModifierId','',NULL,'Where to store the borrowernumber of the record''s last modifier','Free'),
        ('MarcFieldForModifierName','',NULL,'Where to store the name of the record''s last modifier','Free')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19349 - Add system preferences MarcFieldForCreatorId, MarcFieldForCreatorName, MarcFieldForModifierId, MarcFieldForModifierName)\n";
}
