#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2012 BibLibre
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

=head1 NAME

ajax-getauthvaluedropbox.pl - returns an authorised values dropbox

=head1 DESCRIPTION

this script returns an authorised values dropbox

=head1 CGI PARAMETERS

=over 4

=item name

The name of the dropbox.

=item category

The category of authorised values.

=item default

Default value for the dropbox.

=back

=cut

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Koha;
use C4::Charset;
use C4::Auth qw/check_api_auth/;

my $query = CGI->new();
binmode STDOUT, ':encoding(UTF-8)';

my ($status, $cookie, $sessionID) = check_api_auth($query, { catalogue => '*'} );
unless ($status eq "ok") {
    print $query->header(-type => 'text/plain', -status => '403 Forbidden');
    print '<option></option>';
    exit 0;
}

my $input = new CGI;
my $name = $input->param('name');
my $category = $input->param('category');
my $default = $input->param('default');
$default = C4::Charset::NormalizeString($default);

binmode STDOUT, ':encoding(UTF-8)';
print $input->header(-type => 'text/plain', -charset => 'UTF-8');
my $avs = C4::Koha::GetAuthvalueDropbox($category, $default);
my $html = qq|<select id="$name" name="$name">|;
for my $av ( @$avs ) {
    if ( $av->{default} ) {
        $html .= qq|<option value="$av->{value}" selected="selected">$av->{label}</option>|;
    } else {
        $html .= qq|<option value="$av->{value}">$av->{label}</option>|;
    }
}
$html .= qq|</select>|;

print $html;
