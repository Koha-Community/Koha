#!/usr/bin/perl

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

checkexpiration.pl

=head1 DESCRIPTION

This script check what subscription will expire before C<$datenumber $datelimit>

=head1 PARAMETERS

=over 4

=item title
    To filter subscription on title

=item issn
    To filter subscription on issn

=item date
The date to filter on.

=back

=cut

use Modern::Perl;
use CGI         qw ( -utf8 );
use C4::Auth    qw( get_template_and_user );
use C4::Serials qw( SearchSubscriptions GetExpirationDate );
use C4::Output  qw( output_html_with_http_headers );
use C4::Context;
use Koha::DateUtils qw( dt_from_string );

use DateTime;

my $query = CGI->new;

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name => "serials/checkexpiration.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { serials => 'check_expiration' },
    }
);

my $title  = $query->param('title');
my $issn   = $query->param('issn');
my $branch = $query->param('branch');
my $date   = $query->param('date');
$date = eval { dt_from_string( scalar $query->param('date') ) } if $date;
my $showhistoricexpired = $query->param('showhistoricexpired');

if ($date) {
    my @subscriptions = SearchSubscriptions( { title => $title, issn => $issn, orderby => 'title' } );
    my @subscriptions_loop;

    foreach my $subscription (@subscriptions) {
        my $subscriptionid = $subscription->{'subscriptionid'};
        my $expirationdate = GetExpirationDate($subscriptionid);

        $subscription->{expirationdate} = $expirationdate;

        next if $expirationdate !~ /\d{4}-\d{2}-\d{2}/;    # next if not in ISO format.

        next if $subscription->{closed};
        if (  !C4::Context->preference("IndependentBranches")
            or C4::Context->IsSuperLibrarian()
            or ( ref $flags->{serials}  and $flags->{serials}->{superserials} )
            or ( !ref $flags->{serials} and $flags->{serials} == 1 ) )
        {
            $subscription->{cannotedit} = 0;
        }
        next if $subscription->{cannotedit};

        my $expirationdate_dt = dt_from_string( $expirationdate, 'iso' );
        my $today_dt          = dt_from_string();
        if (   DateTime->compare( $date, $expirationdate_dt ) == 1
            && ( $showhistoricexpired || DateTime->compare( $expirationdate_dt, $today_dt ) == 1 )
            && ( !$branch             || ( $subscription->{'branchcode'} eq $branch ) ) )
        {
            push @subscriptions_loop, $subscription;
        }
    }

    $template->param(
        title               => $title,
        issn                => $issn,
        showhistoricexpired => $showhistoricexpired,
        numsubscription     => scalar @subscriptions_loop,
        date                => $date,
        subscriptions_loop  => \@subscriptions_loop,
        searched            => 1,
    );
}

my $can_change_library;
if (  !C4::Context->preference("IndependentBranches")
    or C4::Context->IsSuperLibrarian()
    or ( ref $flags->{serials}  and $flags->{serials}->{superserials} )
    or ( !ref $flags->{serials} and $flags->{serials} == 1 ) )
{
    $can_change_library = 1;
}

$template->param(
    ( uc( C4::Context->preference("marcflavour") ) ) => 1,
    can_change_library                               => $can_change_library,
    branch                                           => $branch,
);

output_html_with_http_headers $query, $cookie, $template->output;
