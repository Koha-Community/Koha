use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38522",
    description => "Increase erm_agreements.license_info length",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ALTER TABLE erm_agreements MODIFY COLUMN license_info mediumtext DEFAULT NULL COMMENT 'info about the license'}
        );
        say_success( $out, "Updated erm_agreements.license_info to mediumtext." );
    },
};
