use Modern::Perl;
no warnings 'redefine';

use CGI;
use C4::Auth;
use C4::ClassSource;
use C4::Output;

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number, $tabloop ) = @_;
    my $function_name = "328" . ( int( rand(100000) ) + 1 );
    my $res = "
<script type=\"text/javascript\">
//<![CDATA[

function Clic$function_name(i) {
    q = document.getElementById('$field_number');
    window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=cn_browser.pl&popup&q=\"+q.value,\"cnbrowser\",\"width=500,height=400,toolbar=false,scrollbars=yes\");
}

//]]>
</script>
";

    return ( $function_name, $res );
}

sub plugin {
    my ($input)          = @_;
    my $cgi              = new CGI;
    my $params           = $cgi->Vars;
    my $results_per_page = 30;
    my $current_page = $cgi->param('page') || 1;

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "cataloguing/value_builder/cn_browser.tt",
            query           => $cgi,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
        }
    );

    my $cn_sort;

    my $dbh = C4::Context->dbh;
    my $sth;
    my @cn;
    my $query;
    my $real_limit = $results_per_page / 2;
    my $rows_lt    = 999;
    my $rows_gt    = 999;
    my $search;
    my $globalGreen = 0;
    my $lt          = '';
    my $gt          = '';
    my $q;

    if ( $q = $cgi->param('q') ) {
        $search = $q;
    }
    if ( $cgi->param('lt') ) {
        $lt     = $cgi->param('lt');
        $search = $lt;
    }
    if ( $cgi->param('gt') ) {
        $gt     = $cgi->param('gt');
        $search = $gt;
    }

    #Don't show half the results of show lt or gt
    $real_limit = $results_per_page if $search ne $q;
    $cn_sort = GetClassSort( undef, undef, $search );
    my $cn_sort_q = GetClassSort( undef, undef, $q );

    my $red = 0;
    if ( $search ne $gt ) {
        my $green = 0;

        #Results before the cn_sort
        $query = "SELECT b.title, itemcallnumber, biblionumber, barcode, cn_sort, branchname, author
        FROM items AS i
        JOIN biblio AS b USING (biblionumber)
        LEFT OUTER JOIN branches ON (branches.branchcode = homebranch)
        WHERE cn_sort < ?
        AND itemcallnumber != ''
        ORDER BY cn_sort DESC, itemnumber
        LIMIT $real_limit;";
        $sth = $dbh->prepare($query);
        $sth->execute($cn_sort);
        while ( my $data = $sth->fetchrow_hashref ) {
            if ( $data->{itemcallnumber} eq $q ) {
                $data->{background} = 'red';
                $red = 1;
            } elsif ( ( GetClassSort( undef, undef, $data->{itemcallnumber} ) lt $cn_sort_q ) && !$green && !$red ) {
                if ( $#cn != -1 ) {
                    unshift @cn, { 'background' => 'green' };
                    $globalGreen = 1;
                }
                $green = 1;
            }
            unshift @cn, $data;
        }
        $rows_lt = $sth->rows;
    }

    if ( $search ne $lt ) {
        my $green = 0;

        #Results after the cn_sort
        $query = "SELECT b.title, itemcallnumber, biblionumber, i.cn_sort, branchname, author
        FROM items AS i
        JOIN biblio AS b USING (biblionumber)
        LEFT OUTER JOIN branches ON (branches.branchcode = homebranch)
        WHERE i.cn_sort >= '$cn_sort'
        AND itemcallnumber != ''
        ORDER BY cn_sort, itemnumber
        LIMIT $real_limit";
        $sth = $dbh->prepare($query);
        $sth->execute();

        while ( my $data = $sth->fetchrow_hashref ) {
            if ( $data->{itemcallnumber} eq $q ) {
                $data->{background} = 'red';
                $red = 1;
            } elsif ( ( GetClassSort( undef, undef, $data->{itemcallnumber} ) gt $cn_sort_q ) && !$green && !$red && !$globalGreen ) {
                push @cn, { 'background' => 'green' };
                $green = 1;
            }
            push @cn, $data;
        }
        $rows_gt = $sth->rows;

        if ( !$green && !$red && !$globalGreen ) {
            push @cn, { 'background' => 'green' };
        }

        $sth->finish;
    }

    $template->param( 'q'       => $q );
    $template->param( 'cn_loop' => \@cn ) if $#cn != -1;
    $template->param( 'popup'   => defined( $cgi->param('popup') ) );

    output_html_with_http_headers $cgi, $cookie, $template->output;
}

1;
