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

use strict;
#use warnings; FIXME - Bug 2505

use Koha::Util::FrameworkPlugin qw(wrapper);
use C4::Auth;
use CGI;
use C4::Context;
use C4::Output;


=head1 FUNCTIONS

=head2 plugin_parameters

Other parameters added when the plugin is called by the dopop function

=cut

sub plugin_parameters {
    my ( $dbh, $record, $tagslib, $i, $tabloop ) = @_;
    return "";
}

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number, $tabloop ) = @_;
    my $res           = "
        <script type='text/javascript'>
            function Focus$field_number() {
                return 1;
            }

            function Blur$field_number() {
                return 1;
            }

            function Clic$field_number(i) {
                var defaultvalue;
                try {
                    defaultvalue = document.getElementById(i).value;
                } catch(e) {
                    alert('error when getting '+i);
                    return;
                }
                window.open(\"/cgi-bin/koha/cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_100.pl&index=\"+i+\"&result=\"+defaultvalue,\"unimarc_field_100\",'width=1000,height=600,toolbar=false,scrollbars=yes');
            }
        </script>
";

    return ( $field_number, $res );
}


sub plugin {
    my ($input) = @_;
    my $index  = $input->param('index');
    my $result = $input->param('result');

    my $dbh = C4::Context->dbh;

    my $defaultlanguage = C4::Context->preference("UNIMARCField100Language");
    $defaultlanguage = "fre" if (!$defaultlanguage || length($defaultlanguage) != 3);

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "cataloguing/value_builder/unimarc_field_100.tt",
            query         => $input,
            type          => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => '*' },
            debug           => 1,
        }
    );
    $result = "        d        u  y0".$defaultlanguage."y50      ba" unless $result;
    my $f1 = substr( $result, 0, 8 );
    if ( $f1 eq '        ' ) {
        my @today = Date::Calc::Today();
        $f1 = $today[0] . sprintf('%02s',$today[1]) . sprintf('%02s',$today[2]);
    }
    my $f2  = substr( $result, 8,  1 ); $f2  = wrapper( $f2 ) if $f2;
    my $f3  = substr( $result, 9,  4 );
    $f3='' if $f3 eq '    '; # empty publication year if only spaces, otherwise it's hard to fill the field
    my $f4  = substr( $result, 13, 4 );
    $f4='' if $f4 eq '    ';
    my $f5  = substr( $result, 17, 1 ); $f5  = wrapper( $f5 ) if $f5;
    my $f6  = substr( $result, 18, 1 ); $f6  = wrapper( $f6 ) if $f6;
    my $f7  = substr( $result, 19, 1 ); $f7  = wrapper( $f7 ) if $f7;
    my $f8  = substr( $result, 20, 1 );
    my $f9  = substr( $result, 21, 1 );
    my $f10 = substr( $result, 22, 3 );
    my $f11 = substr( $result, 25, 1 );
    my $f12 = substr( $result, 26, 2 );
    my $f13 = substr( $result, 28, 2 );
    my $f14 = substr( $result, 30, 4 );
    my $f15 = substr( $result, 34, 2 ); $f15 = wrapper( $f15 ) if $f15;

    $template->param(
        index     => $index,
        f1        => $f1,
        f3        => $f3,
        "f2$f2"   => 1,
        f4        => $f4,
        "f5$f5"   => 1,
        "f6$f6"   => 1,
        "f7$f7"   => 1,
        "f8$f8"   => 1,
        "f9$f9"   => 1,
        "f10"     => $f10,
        "f11$f11" => 1,
        "f12$f12" => 1,
        "f13$f13" => 1,
        "f14"     => $f14,
        "f15$f15" => 1
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}

1;
