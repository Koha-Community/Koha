use Modern::Perl;

return {
    bug_number  => "29073",
    description => "Make DefaultHoldExpirationdate use 1/0 values",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            UPDATE systempreferences SET value = IF(value = 'yes',1,0)
            WHERE variable = 'DefaultHoldExpirationdate';
        }
        );
    },
    }
