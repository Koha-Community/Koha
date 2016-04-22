my $dbh = C4::Context->dbh;
my ( $column_has_been_used ) = $dbh->selectrow_array(q|
    SELECT COUNT(*)
    FROM borrower_attributes
    WHERE password IS NOT NULL
|);

if ( $column_has_been_used ) {
    print q|WARNING: The columns borrower_attribute_types.password_allowed and borrower_attributes.password have been removed from the Koha codebase. They were not used. However your installation has at least one borrower_attributes.password defined. In order not to alter your data, the columns have been kept, please save the information elsewhere and remove these columns manually.|;
} else {
    $dbh->do(q|
        ALTER TABLE borrower_attribute_types DROP column password_allowed
    |);
    $dbh->do(q|
        ALTER TABLE borrower_attributes DROP column password;
    |);
}
