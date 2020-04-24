$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('SIP2SortBinMapping','',NULL,'Use the following mappings to determine the sort_bin of a returned item. The mapping should be on the form \"branchcode:item field:item field value:sort bin number\", with one mapping per line.','free'),;
    });
    NewVersion( $DBversion, 20517, "Add SIP2SortBinMapping system preference");
}
