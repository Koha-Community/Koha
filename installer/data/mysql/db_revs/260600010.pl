use Modern::Perl;
use Koha::Installer::Output qw(say_success say_failure);

return {
    bug_number  => "42988",
    description => "Set holds_get_captured default to 1 in sip_accounts",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $updated = $dbh->do(q{UPDATE sip_accounts SET holds_get_captured = 1 WHERE holds_get_captured IS NULL});
        if ($updated) {
            say_success(
                $out,
                "Set holds_get_captured to 1 for " . ( $updated + 0 ) . " sip_accounts rows where it was NULL"
            );
        } else {
            say_failure( $out, "Failed to update NULL holds_get_captured rows in sip_accounts: " . $dbh->errstr );
        }

        my $altered = $dbh->do(q{ALTER TABLE sip_accounts ALTER COLUMN holds_get_captured SET DEFAULT 1});
        if ($altered) {
            say_success( $out, "Changed default of 'holds_get_captured' in sip_accounts to 1" );
        } else {
            say_failure( $out, "Failed to change default of 'holds_get_captured' in sip_accounts: " . $dbh->errstr );
        }
    },
};
