#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

# Copyright 2010 BibLibre SARL
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
use CGI qw ( -utf8 );

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );

=head1 DESCRIPTION

This plugin is specific to AM123 but could be used as a base for similar operations.
It is used for stocknumber computation.

If the user send an empty string, we return a simple incremented stocknumber.
If a prefix is submited, we look for the highest stocknumber with this prefix, and return it incremented.
In this case, a stocknumber has this form : "PREFIX 0009678570".
 - PREFIX is an upercase word
 - a space separator
 - 10 digits, with leading 0s if needed

=cut

my $builder = sub {
    my ( $params ) = @_;
    my $res="
    <script>
        function Blur$params->{id}(ev) {
                var code = document.getElementById(ev.data.id);
                var url = '../cataloguing/plugin_launcher.pl?plugin_name=stocknumberam123.pl&code=' + code.value;
                var req = \$.get(url);
                req.done(function(resp){
                    code.value = resp;
                    return 1;
                });
                return 1;
        }
    </script>
    ";

    return $res;
};

my $launcher = sub {
    my ( $params ) = @_;
    my $input = $params->{cgi};
    my $code = $input->param('code');

    my ($template, $loggedinuser, $cookie) = get_template_and_user({
        template_name   => "cataloguing/value_builder/ajax.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => {editcatalogue => '*'},
    });

    my $dbh = C4::Context->dbh;
    # If the textbox is empty, we return a simple incremented stocknumber
    if ( $code eq "" ) {
        my $sth = $dbh->prepare("SELECT MAX(CAST(stocknumber AS SIGNED)) FROM items");
        $sth->execute;
    
        if ( my $max = $sth->fetchrow ) {
            $template->param(
                return => $max+1,
            );
        }
    # If a prefix is submited, we look for the highest stocknumber with this prefix, and return it incremented
    } elsif ( $code =~ m/^[a-zA-Z]+$/ ) {
        my $sth = $dbh->prepare("SELECT MAX(CAST(SUBSTRING_INDEX(stocknumber,' ',-1) AS SIGNED)) FROM items WHERE stocknumber LIKE ?");
        $sth->execute($code.' %');
        
        if ( my $max = $sth->fetchrow ) {
            $template->param(
                return => $code.' '.sprintf('%010s',($max+1)),
            );
        }
    # The user entered a custom value, we don't touch it, this could be handled in js
    } else {
        $template->param(
            return => $code,
        );
    }
    output_html_with_http_headers $input, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
