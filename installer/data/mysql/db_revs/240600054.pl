use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

use C4::Context;
use Koha::Reports;

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
            say_success(
                $out,
                "Updated ILL batches from 'FreeForm' to 'Standard'"
            );
        }

        my ($illrequestattributes) = $dbh->selectrow_array(
            q|
            SELECT count(*) from illrequestattributes where backend = 'FreeForm';
        |
        );

        if ($illrequestattributes) {
            $dbh->do("UPDATE illrequestattributes SET backend = 'Standard' where backend = 'FreeForm'");
            say_success(
                $out,
                "Updated ILL request attributes from 'FreeForm' to 'Standard'"
            );
        }

        my ($illrequests) = $dbh->selectrow_array(
            q|
            SELECT count(*) from illrequests where backend = 'FreeForm';
        |
        );

        if ($illrequests) {
            $dbh->do("UPDATE illrequests SET backend = 'Standard' where backend = 'FreeForm'");
            say_success(
                $out,
                "Updated ILL requests from 'FreeForm' to 'Standard'"
            );
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
            say_warning(
                $out,
                "Bug 35570: **ACTION REQUIRED**: Saved SQL reports containing occurrences of 'FreeForm' were found. The following reports MUST be updated accordingly ('FreeForm' -> 'Standard'):"
            );
            say_info(
                $out,
                $reports
            );
        }

    },
};
