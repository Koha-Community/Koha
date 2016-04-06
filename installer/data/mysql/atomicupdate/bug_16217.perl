my $dbh = C4::Context->dbh;
my $letters = $dbh->selectall_arrayref(q|
    SELECT code, name
    FROM letter
    WHERE message_transport_type="email"
|, { Slice => {} });
for my $letter ( @$letters ) {
    $dbh->do(q|
        UPDATE letter
        SET name = ?
        WHERE code = ?
        AND message_transport_type <> "email"
    |, undef, $letter->{name}, $letter->{code});
}
