use Modern::Perl;
use Koha::Installer::Output qw(say_success say_failure);

return {
    bug_number  => "42769",
    description => "Split the sip2 permission into manage_sip2 and test_sip2_messages",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my %permissions = (
            manage_sip2        => 'Manage SIP2 institutions, accounts and system preference overrides',
            test_sip2_messages => 'Test the SIP2 messages a SIP2 account would return',
        );

        foreach my $code ( sort keys %permissions ) {
            my $exists = $dbh->selectrow_array(
                q{SELECT COUNT(*) FROM permissions WHERE module_bit = 31 AND code = ?},
                undef, $code
            );
            next if $exists;

            my $ok = $dbh->do(
                q{
                    INSERT IGNORE INTO permissions (module_bit, code, description)
                    VALUES (31, ?, ?)
                },
                undef, $code, $permissions{$code}
            );
            if ($ok) {
                say_success( $out, "Added new permission 'sip2.$code'" );
            } else {
                say_failure( $out, "Failed to add new permission 'sip2.$code': " . $dbh->errstr );
            }
        }
    },
};
