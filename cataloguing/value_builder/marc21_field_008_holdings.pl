#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2017-2018 University of Helsinki (The National Library Of Finland)
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

use XML::LibXML;
use Koha::Util::FrameworkPlugin qw|date_entered|;

my $builder = sub {
    my ( $params ) = @_;

    my $lang = C4::Context->preference('DefaultLanguageField008' );
    $lang = "eng" unless $lang;
    $lang = pack("A3", $lang);

    my $function_name = $params->{id};
    my $dateentered = date_entered();
    my $res           = "
<script type=\"text/javascript\">
//<![CDATA[

function Focus$function_name(event) {
    if ( document.getElementById(event.data.id).value ) {
	}
	else {
        document.getElementById(event.data.id).value='$dateentered' + '0u    0   4   uu${lang}0$dateentered';
	}
    return 1;
}

function Click$function_name(event) {
    defaultvalue=document.getElementById(event.data.id).value;
    //Retrieve full leader string and pass it to the 008 tag editor
    var leader_value = \$(\"input[id^='tag_000']\").val();
    var leader_parameter = \"\";
    if (leader_value){
        //Only add the parameter to the URL if there is a value to add
        leader_parameter = \"&leader=\"+leader_value;
    }
    newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=marc21_field_008_holdings.pl&index=\"+ event.data.id +\"&result=\"+defaultvalue+leader_parameter,\"tag_editor\",'width=1000,height=600,toolbar=false,scrollbars=yes');

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

    my $lang = C4::Context->preference('DefaultLanguageField008' );
    $lang = "eng" unless $lang;
    $lang = pack("A3", $lang);

    my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "cataloguing/value_builder/marc21_field_008_holdings.tt",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {editcatalogue => '*'},
                 debug => 1,
                 });
    my $dateentered = date_entered();
    $result = $dateentered + '0u    0   0   uu' + $lang + '0' + $dateentered unless $result;
    my @f;
    for(0,6..8,12..17,20..22,25,26) {
        my $len = 1;
        if ($_ == 0 || $_ == 26) {
            $len = 6;
        } elsif ($_ == 8) {
            $len = 4;
        } elsif ($_ == 17 || $_ == 22) {
            $len = 3;
        }
        warn ($_ . ': ' . $len);
        $f[$_]=substr($result,$_,$len);
    }
    $template->param(index => $index);

    $f[0]= $dateentered if !$f[0] || $f[0]=~/\s/;
    $template->param(f1 => $f[0]);

    for(6..8,12..17,20..22,25,26) {
        $template->param(
            "f$_" => $f[$_],
            "f$_".($f[$_] eq '|'? 'pipe': $f[$_]) => $f[$_],
        );
    }
    output_html_with_http_headers $input, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
