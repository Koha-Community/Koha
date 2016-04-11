my $dbh = C4::Context->dbh;
my ( $column_has_been_used ) = $dbh->selectrow_array(q|
    SELECT COUNT(*)
    FROM borrower_attributes
    WHERE password IS NOT NULL
|);

if ( $column_has_been_used ) {
    warn q|WARNING: The columns borrower_attribute_types.password_allowed and borrower_attributes.column have been removed from the Koha codebase. There were not used. However your installation has at least 1 borrower_attributes.password defined. In order not to alter your data, the columns have been kept, please remove them manually if you do not use them this feature.|;
} else {
    $dbh->do(q|
        ALTER TABLE borrower_attribute_types DROP column password_allowed
    |);
    $dbh->do(q|
        ALTER TABLE borrower_attributes DROP column password;
    |);
}
