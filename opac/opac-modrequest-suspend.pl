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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Output;
use C4::Reserves qw( SuspendAll );
use C4::Auth     qw( get_template_and_user );

use Koha::Patrons;

my $query = CGI->new;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-account.tt",
        query         => $query,
        type          => "opac",
    }
);

my $op            = $query->param('op') || q{};
my $suspend       = $query->param('suspend');
my $suspend_until = $query->param('suspend_until') || undef;
my $reserve_id    = $query->param('reserve_id');

if ( $op eq 'cud-suspend' ) {
    my $patron = Koha::Patrons->find($borrowernumber);
    my $hold   = $patron->holds->find($reserve_id);
    $hold->suspend_hold($suspend_until) if $hold && $hold->is_cancelable_from_opac;
} elsif ( $op eq 'cud-unsuspend' ) {
    my $patron = Koha::Patrons->find($borrowernumber);
    my $hold   = $patron->holds->find($reserve_id);
    $hold->resume if $hold && $hold->is_cancelable_from_opac;
} elsif ( $op eq 'cud-suspend_all' || $op eq 'cud-unsuspend_all' ) {
    SuspendAll(
        borrowernumber => $borrowernumber,
        suspend        => $suspend,
        suspend_until  => $suspend_until,
    );
}

print $query->redirect("/cgi-bin/koha/opac-user.pl?opac-user-holds=1");
