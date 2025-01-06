use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "36822",
    description => "Sanitize borrowers.updated_on",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $sth = $dbh->prepare(
            q{
            SELECT borrowernumber
            FROM borrowers
            WHERE CAST(updated_on AS CHAR(19)) = '0000-00-00 00:00:00'
        }
        );
        $sth->execute;
        my $results = $sth->fetchall_arrayref( {} );
        if (@$results) {
            sanitize_zero_date( 'borrowers', 'updated_on' );
            say_info( $out, "The following borrowers' updated_on has been sanitized: "
                    . join( ', ', map { $_->{borrowernumber} } @$results ) );
        }
    },
};
