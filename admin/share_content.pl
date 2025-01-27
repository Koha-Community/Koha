#!/usr/bin/perl

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

use CGI  qw ( -utf8 );
use JSON qw( to_json );
use HTTP::Request;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::SharedContent;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "admin/share_content.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_mana' },
    }
);

my $op        = $query->param('op')                || q{};
my $mana_base = C4::Context->config('mana_config') || '';

# Check the mana server actually exists at the other end
my $bad_url;
if ($mana_base) {
    my $request = HTTP::Request->new( GET => $mana_base );
    my $result  = Koha::SharedContent::process_request($request);
    $bad_url = 1 unless ( exists( $result->{version} ) );
}

if ( $op eq 'cud-save' ) {
    my $auto_share = $query->param('autosharewithmana') || q{};
    my $mana       = $query->param('mana');

    C4::Context->set_preference( 'Mana', $mana );

    if ( $auto_share ne '' ) {
        C4::Context->set_preference( 'AutoShareWithMana', 'subscription' );
    } else {
        C4::Context->set_preference( 'AutoShareWithMana', '' );
    }
}

if ( $op eq 'cud-reset' ) {
    C4::Context->set_preference( 'ManaToken', '' );
}

if ( $op eq 'cud-send' && not $bad_url ) {
    my $name  = $query->param('name');
    my $email = $query->param('email');

    my $content = to_json(
        {
            name  => $name,
            email => $email
        }
    );

    my $url     = "$mana_base/getsecuritytoken";
    my $request = HTTP::Request->new( POST => $url );
    $request->content($content);
    my $result = Koha::SharedContent::process_request($request);

    $template->param( result => $result );

    if ( $result->{code} eq '201' && $result->{token} ) {
        C4::Context->set_preference( 'ManaToken', $result->{token} );
    }
}

$template->param(
    mana_url => $mana_base,
    bad_url  => $bad_url,
);

output_html_with_http_headers $query, $cookie, $template->output;
