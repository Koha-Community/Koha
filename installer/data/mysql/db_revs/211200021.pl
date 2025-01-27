use Modern::Perl;

return {
    bug_number  => "30063",
    description => "Fix DefaultPatronSearchFields order",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            UPDATE systempreferences SET value="firstname,surname,othernames,cardnumber,userid"
            WHERE variable="DefaultPatronSearchFields" AND value="surname,firstname,othernames,cardnumber,userid"
        }
        );
    },
};
