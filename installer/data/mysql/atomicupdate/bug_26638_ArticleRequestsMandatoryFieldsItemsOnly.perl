$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO `systempreferences` (`variable`, `value`, `options`, `explanation`, `type`) VALUES
            ('ArticleRequestsMandatoryFieldsItemOnly', '', NULL, 'Comma delimited list of required fields for bibs where article requests rule = ''item_only''', 'multiple')
    });
    $dbh->do(q{
        DELETE FROM systempreferences WHERE variable = "ArticleRequestsMandatoryFieldsItemsOnly"
    });
    NewVersion( $DBversion, 26638, "Add missing system preference ArticleRequestsMandatoryFieldsItemOnly");
}
