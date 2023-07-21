use Modern::Perl;

return {
    bug_number  => "29145",
    description => "Change type of AutoRemoveOverduesRestrictions system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{UPDATE `systempreferences` SET `type` = 'Choice', `options` = 'no|when_no_overdue|when_no_overdue_causing_debarment', `explanation` = 'Defines if and on what conditions OVERDUES debarments should automatically be lifted when overdue items are returned by the patron.', `value` = CASE `value` WHEN '1' THEN 'when_no_overdue' WHEN '0' THEN 'no' ELSE `value` END WHERE variable = 'AutoRemoveOverduesRestrictions'}
        );
        say $out "Type of AutoRemoveOverduesRestrictions system preference has been changed";
    },
    }
