#!/usr/bin/perl

# Parts Copyright Biblibre 2010
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

use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Members;
use Koha::Patron::Attribute::Types;
use Koha::Patron::Attributes;
use Koha::Patron::Modifications;
use Koha::Patrons;

use List::MoreUtils qw( uniq );

my $query = new CGI;

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {   template_name   => "members/members-update.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers => 'edit_borrowers' },
        debug           => 1,
    }
);

my $branch
    = (    C4::Context->preference("IndependentBranchesPatronModifications")
        || C4::Context->preference("IndependentBranches") )
    && !$flags->{'superlibrarian'}
    ? C4::Context->userenv()->{'branch'}
    : undef;

my $pending_modifications = Koha::Patron::Modifications->pending($branch);

my $borrowers;
foreach my $pm (@$pending_modifications) {

    my @modified_atypes = uniq( map { $_->code } @{ $pm->{extended_attributes} } );
    my $modified_attributes;

    foreach my $type (@modified_atypes) {
        my $type_obj = Koha::Patron::Attribute::Types->find($type);
        my @before   = Koha::Patron::Attributes->search(
            { borrowernumber => $pm->{borrowernumber}, code => $type } );
        my @after = grep { $_->code eq $type } @{ $pm->{extended_attributes} };
        push @{$modified_attributes}, { type => $type_obj, before => \@before, after => \@after };
    }

    $borrowers->{ $pm->{borrowernumber} } = Koha::Patrons->find($pm->{borrowernumber})->unblessed;
    $borrowers->{ $pm->{borrowernumber} }->{modified_attributes} = $modified_attributes;
}

$template->param(
    PendingModifications => $pending_modifications,
    borrowers            => $borrowers
);

output_html_with_http_headers $query, $cookie, $template->output;

1;
