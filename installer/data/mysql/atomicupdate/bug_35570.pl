use Modern::Perl;

use C4::Context;
use Koha::Reports;
use Term::ANSIColor;

return {
    bug_number  => "35570",
    description => "Update 'FreeForm' ILL backend to 'Standard'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my ($illbatches) = $dbh->selectrow_array(
            q|
            SELECT count(*) from illbatches where backend = 'FreeForm';
        |
        );

        if ($illbatches) {
            $dbh->do("UPDATE illbatches SET backend = 'Standard' where backend = 'FreeForm'");
            say $out colored( "Bug 35570: Updated ILL batches from 'FreeForm' to 'Standard'", 'green' );
        }

        my ($illrequestattributes) = $dbh->selectrow_array(
            q|
            SELECT count(*) from illrequestattributes where backend = 'FreeForm';
        |
        );

        if ($illrequestattributes) {
            $dbh->do("UPDATE illrequestattributes SET backend = 'Standard' where backend = 'FreeForm'");
            say $out colored( "Bug 35570: Updated ILL request attributes from 'FreeForm' to 'Standard'", 'green' );
        }

        my ($illrequests) = $dbh->selectrow_array(
            q|
            SELECT count(*) from illrequests where backend = 'FreeForm';
        |
        );

        if ($illrequests) {
            $dbh->do("UPDATE illrequests SET backend = 'Standard' where backend = 'FreeForm'");
            say $out colored( "Bug 35570: Updated ILL requests from 'FreeForm' to 'Standard'", 'green' );
        }

        my $reports = join(
            "\n",
            map( "\tReport ID: "
                    . $_->id
                    . ' | Edit link: '
                    . C4::Context->preference('staffClientBaseURL')
                    . '/cgi-bin/koha/reports/guided_reports.pl?reports='
                    . $_->id
                    . "&phase=Edit%20SQL",
                Koha::Reports->search( { savedsql => { -like => "%FreeForm%" } } )->as_list )
        );

        if ($reports) {
            say $out colored(
                "Bug 35570: **ACTION REQUIRED**: Saved SQL reports containing occurrences of 'FreeForm' were found. The following reports MUST be updated accordingly ('FreeForm' -> 'Standard'):",
                'yellow'
            );
            say $out colored( $reports, 'blue');
        } else {
            say $out "Bug 35570: Finished database update.";
        }

    },
};
