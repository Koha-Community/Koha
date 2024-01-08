use Modern::Perl;

return {
    bug_number  => "35724",
    description => "Add new fields to EDI accounts for librarians to configure non-standard EDI SFTP port numbers",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'vendor_edi_accounts', 'upload_port' ) ) {
            $dbh->do(
                q{
              ALTER TABLE vendor_edi_accounts ADD COLUMN `upload_port` varchar(40) DEFAULT '22' AFTER `password`
          }
            );

            say $out "Added column 'vendor_edi_accounts.upload_port'";
        }

        if ( !column_exists( 'vendor_edi_accounts', 'download_port' ) ) {
            $dbh->do(
                q{
              ALTER TABLE vendor_edi_accounts ADD COLUMN `download_port` varchar(40) DEFAULT '22' AFTER `password`
          }
            );

            say $out "Added column 'vendor_edi_accounts.download_port'";
        }
    },
};
