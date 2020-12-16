$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
       ('ElasticsearchCrossFields', '1', '', 'Enable "cross_fields" option for searches using Elastic search.', 'YesNo')
    });
    NewVersion( $DBversion, 27252, "Add ElasticsearchCrossFields system preference");
}
