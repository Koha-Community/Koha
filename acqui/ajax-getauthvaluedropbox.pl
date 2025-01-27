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

use CGI         qw ( -utf8 );
use C4::Charset qw( NormalizeString );
use C4::Auth    qw( check_api_auth );
use Koha::AuthorisedValues;

my $query = CGI->new();
binmode STDOUT, ':encoding(UTF-8)';

my ( $status, $cookie, $sessionID ) = check_api_auth( $query, { catalogue => '*' } );
unless ( $status eq "ok" ) {
    print $query->header( -type => 'text/plain', -status => '403 Forbidden' );
    print '<option></option>';
    exit 0;
}

my $input    = CGI->new;
my $name     = $input->param('name');
my $category = $input->param('category');
my $default  = $input->param('default');
$default = C4::Charset::NormalizeString($default);
my $branch_limit = C4::Context->userenv ? C4::Context->userenv->{"branch"} : "";

my $avs = Koha::AuthorisedValues->search_with_library_limits(
    {
        category => $category,
    },
    {
        order_by => [ 'category', 'lib', 'lib_opac' ],
    },
    $branch_limit
);
my $html = qq|<select id="$name" name="$name">|;
while ( my $av = $avs->next ) {
    if ( $av->authorised_value eq $default ) {
        $html .= q|<option value="| . $av->authorised_value . q|" selected="selected">| . $av->lib . q|</option>|;
    } else {
        $html .= q|<option value="| . $av->authorised_value . q|">| . $av->lib . q|</option>|;
    }
}
$html .= qq|</select>|;

binmode STDOUT, ':encoding(UTF-8)';
print $input->header( -type => 'text/plain', -charset => 'UTF-8' );
print $html;
