#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

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
use C4::Auth;
use CGI qw ( -utf8 );
use C4::Context;

use C4::Search;
use C4::Output;
use Koha::Util::FrameworkPlugin qw|date_entered|;

use constant FIXLEN_DATA_ELTS => '|| aca||aabn           | a|a     d';
use constant PREF_008 => 'MARCAuthorityControlField008';

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};
    my $dateentered = date_entered();
    my $defaultval = substr( C4::Context->preference(PREF_008) || FIXLEN_DATA_ELTS, 0, 34 );
    my $res="
<script type=\"text/javascript\">
//<![CDATA[

function Focus$function_name(event) {
    if (!document.getElementById(event.data.id).value) {
    var authtype=document.forms['f'].elements['authtypecode'].value;
    var fieldval='$dateentered$defaultval';
    if(authtype && (authtype == 'TOPIC_TERM' || authtype == 'GENRE/FORM' || authtype == 'CHRON_TERM')) {
      fieldval= fieldval.substr(0,14)+'b'+fieldval.substr(15);
    }
        document.getElementById(event.data.id).value=fieldval;
    }
    return 1;
}

function Click$function_name(event) {
    var authtype=document.forms['f'].elements['authtypecode'].value;
    defaultvalue=document.getElementById(event.data.id).value;
    newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=marc21_field_008_authorities.pl&index=\"+ event.data.id +\"&result=\"+defaultvalue+\"&authtypecode=\"+authtype,\"tag_editor\",'width=1000,height=600,toolbar=false,scrollbars=yes');

}
//]]>
</script>
";

    return $res;
};

my $launcher = sub {
    my ( $params ) = @_;
    my $input = $params->{cgi};
    my $index= $input->param('index');
    my $result= $input->param('result');
    my $authtype= $input->param('authtypecode')||'';

    my $defaultval = substr( C4::Context->preference(PREF_008) || FIXLEN_DATA_ELTS, 0, 34 );
    substr($defaultval,14-6,1)='b' if $authtype=~ /TOPIC_TERM|GENRE.FORM|CHRON_TERM/;

    my $dbh = C4::Context->dbh;

    my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "cataloguing/value_builder/marc21_field_008_authorities.tt",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {editcatalogue => '*'},
                 debug => 1,
                 });
    my $dateentered = date_entered();
    $result = "$dateentered$defaultval" unless $result;
    my @f;
    for(0,6..17,28,29,31..33,38,39) {
        $f[$_]=substr($result,$_,$_==0?6:1);
    }
    $template->param(index => $index);

    $f[0]= $dateentered if !$f[0] || $f[0]=~/\s/;
    $template->param(f1 => $f[0]);

    for(6..17,28,29,31..33,38,39) {
        $template->param(
            "f$_" => $f[$_],
            "f$_".($f[$_] eq '|'? 'pipe': $f[$_]) => $f[$_],
        );
    }
    output_html_with_http_headers $input, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
