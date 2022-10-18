use Modern::Perl;

return {
    bug_number => "30649",
    description => "Increase the vendor EDI account password field to 256 characters",
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(q{
            ALTER TABLE vendor_edi_accounts CHANGE COLUMN `password` `password` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL
        });

        require Koha::Encryption;
        my $e = Koha::Encryption->new;

        my $schema = Koha::Database->new()->schema();
        my $rs     = $schema->resultset('VendorEdiAccount')->search();
        while ( my $a = $rs->next() ) {
            my $password = $a->password;
            $password = $e->encrypt_hex($password);
            $a->password($password);
            $a->update();
        }
    },
};
