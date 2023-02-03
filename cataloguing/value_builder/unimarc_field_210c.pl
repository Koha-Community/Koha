#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use C4::Auth qw( get_template_and_user );
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( pagination_bar output_html_with_http_headers );
use CGI qw ( -utf8 );
use C4::Search;
use C4::Koha qw( getnbpages );
use C4::AuthoritiesMarc qw( GetAuthority SearchAuthorities );

###TODO To rewrite in order to use SearchAuthorities

sub plugin_javascript {
my ($dbh,$record,$tagslib,$field_number) = @_;
my $function_name= $field_number;
#---- build editors list.
#---- the editor list is built from the "EDITORS" thesaurus
#---- this thesaurus category must be filled as follow :
#---- 200$a for isbn
#---- 200$b for editor
#---- 200$c (repeated) for collections


my $res  = "
<script>
function Clic$function_name(event) {
    event.preventDefault();
    defaultvalue=escape(document.getElementById(event.data.id).value);
    newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_210c.pl&index=\" + event.data.id, \"unimarc_225a\",'width=500,height=600,toolbar=false,scrollbars=yes');
}
</script>
";
return ($function_name,$res);
}

sub plugin {
my ($input) = @_;
    my $query=CGI->new;
    my $op = $query->param('op');
    my $authtypecode = $query->param('authtypecode');
    my $index = $query->param('index');
    my $category = $query->param('category');
    my $resultstring = $query->param('result');
    my $dbh = C4::Context->dbh;

    my $startfrom = $query->param('startfrom') // 1; # Page number starting at 1
    my ($template, $loggedinuser, $cookie);
    my $resultsperpage = $query->param('resultsperpage') // 20; # TODO hardcoded
    my $offset = ( $startfrom - 1 ) * $resultsperpage;

    if ($op eq "do_search") {
        my @marclist = $query->multi_param('marclist');
        my @and_or = $query->multi_param('and_or');
        my @excluding = $query->multi_param('excluding');
        my @operator = $query->multi_param('operator');
        my @value = $query->multi_param('value');
        my $orderby   = $query->param('orderby');

        # builds tag and subfield arrays
        my @tags;

        my ($results,$total) = SearchAuthorities( \@tags,\@and_or,
                                            \@excluding, \@operator, \@value,
                                            $offset, $resultsperpage,$authtypecode, $orderby);

	# Getting the $b if it exists
	for (@$results) {
	    my $authority = GetAuthority($_->{authid});
		if ($authority->field('200') and $authority->subfield('200','b')) {
		    $_->{to_report} = $authority->subfield('200','b');
	    }
 	}

        ($template, $loggedinuser, $cookie)
            = get_template_and_user({template_name => "cataloguing/value_builder/unimarc_field_210c.tt",
                    query => $query,
                    type => 'intranet',
                    flagsrequired => {editcatalogue => '*'},
                    });

        # Results displayed in current page
        my $from = $offset + 1;
        my $to = ( $offset + $resultsperpage > $total ) ? $total : $offset + $resultsperpage;

        my $link="../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_210c.pl&amp;authtypecode=EDITORS&amp;".join("&amp;",map {"value=".$_} @value)."&amp;op=do_search&amp;type=intranet&amp;index=$index";

        $template->param(result => $results) if $results;
        $template->param('index' => scalar $query->param('index'));
        $template->param(
                                total=>$total,
                                from=>$from,
                                to=>$to,
                                authtypecode =>$authtypecode,
                                resultstring =>$value[0],
                                pagination_bar => pagination_bar(
                                    $link,
                                    getnbpages($total, $resultsperpage),
                                    $startfrom,
                                    'startfrom'
                                ),
                                );
    } else {
        ($template, $loggedinuser, $cookie)
            = get_template_and_user({template_name => "cataloguing/value_builder/unimarc_field_210c.tt",
                    query => $query,
                    type => 'intranet',
                    flagsrequired => {editcatalogue => '*'},
                    });

        $template->param(index => $index,
                        resultstring => $resultstring
                        );
    }

    $template->param(category => $category);

    # Print the page
    output_html_with_http_headers $query, $cookie, $template->output;
}
