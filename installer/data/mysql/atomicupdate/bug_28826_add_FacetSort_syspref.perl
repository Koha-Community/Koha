$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences
        ( variable, value, options, explanation, type ) VALUES
        ('FacetOrder','Alphabetical','Alphabetical|Usage','Specify the order of facets within each category','Choice')
    });
    NewVersion( $DBversion, 28826, "Add system preference FacetOrder");
}
