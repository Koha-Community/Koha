#!/usr/bin/perl

# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# Copyright 2007 Tamil s.a.r.l.
# Parts copyright 2010-2012 Athens County Public Libraries
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

=head1 ysearch.pl

=cut

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth qw( check_cookie_auth );
use Koha::Patrons;
use Koha::DateUtils qw( format_sqldatetime );
use Koha::Libraries;

use JSON qw( to_json );

my $input = CGI->new;
my $query = $input->param('term');

binmode STDOUT, ":encoding(UTF-8)";
print $input->header( -type => 'text/plain', -charset => 'UTF-8' );

my ( $auth_status ) = check_cookie_auth( $input->cookie('CGISESSID'), { catalogue => '1' } );
if ( $auth_status ne "ok" ) {
    exit 0;
}

my $limit_on_branch;
if (   C4::Context->preference("IndependentBranches")
    && C4::Context->userenv
    && !C4::Context->IsSuperLibrarian()
    && C4::Context->userenv->{'branch'} ) {
    $limit_on_branch = 1;
}

my @parts = split( /,\s|\s/, $query );
my @params;
foreach my $p (@parts) {
    push(
        @params,
        -or => [
            surname     => { -like => "%$p%" },
            firstname   => { -like => "%$p%" },
            middle_name => { -like => "%$p%" },
            cardnumber  => { -like => "$p%" },
        ]
    );
}

push( @params, { 'me.branchcode' => C4::Context->userenv->{branch} } ) if $limit_on_branch;

my $borrowers_rs = Koha::Patrons->search_limited(
    { -and => \@params },
    {
        # Get the first 10 results
        page     => 1,
        rows     => 10,
        order_by => [ 'surname', 'firstname', 'middle_name' ],
        prefetch => 'branchcode',
    },
);

my @borrowers;
while ( my $b = $borrowers_rs->next ) {
    push @borrowers,
      {
        borrowernumber => $b->borrowernumber,
        surname        => $b->surname     // '',
        firstname      => $b->firstname   // '',
        middle_name    => $b->middle_name // '',
        cardnumber     => $b->cardnumber  // '',
        dateofbirth    => format_sqldatetime( $b->dateofbirth, undef, undef, 1 ) // '',
        age        => $b->get_age             // '',
        address    => $b->address             // '',
        city       => $b->city                // '',
        zipcode    => $b->zipcode             // '',
        country    => $b->country             // '',
        branchcode => $b->branchcode          // '',
        branchname => $b->library->branchname // '',
      };
}

print to_json( \@borrowers );
