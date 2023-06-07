use Modern::Perl;

return {
    bug_number  => "30649",
    description => "Increase the vendor EDI account password field to 256 characters",
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(q{
            ALTER TABLE vendor_edi_accounts CHANGE COLUMN `password` `password` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL
        });

        my $edi_vendors =
          $dbh->selectall_arrayref( "SELECT * FROM vendor_edit_accounts", { Slice => {} } );
        if (@$edi_vendors) {
            require Koha::Encryption;
            my $e = Koha::Encryption->new;
            for my $edi_vendor (@$edi_vendors) {
                my $id       = $edi_vendor->{id};
                my $password = $edi_vendor->{password};
                $password = $e->encrypt_hex($password);
                $dbh->do("UPDATE edi_vendor_accounts SET password = $password WHERE id = $id");
            }
        }
    },
};
