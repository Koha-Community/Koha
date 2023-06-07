#!/usr/bin/perl

# Copyright 2011-2013 Biblibre SARL
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

=head1 NAME

showpredictionpattern.pl

=head1 DESCRIPTION

This script calculate numbering of serials based on numbering pattern, and
publication date, based on frequency and first publication date.

=cut

use Modern::Perl;

use CGI qw ( -utf8 );
use Date::Calc qw( Add_Delta_Days Add_Delta_YM Day_of_Week Delta_Days );
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Serials qw( GetSubscription GetFictiveIssueNumber GetSeq GetSubscriptionIrregularities GetNextDate GetNextSeq );
use C4::Serials::Frequency;
use Koha::DateUtils qw( dt_from_string );

my $input = CGI->new;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'serials/showpredictionpattern.tt',
    query           => $input,
    type            => 'intranet',
    flagsrequired   => { 'serials' => '*' },
} );

my $subscriptionid = $input->param('subscriptionid');
my $frequencyid = $input->param('frequency');
my $firstacquidate = $input->param('firstacquidate');
my $nextacquidate = $input->param('nextacquidate');
my $enddate = $input->param('to');
my $subtype = $input->param('subtype');
my $sublength = $input->param('sublength');
my $custompattern = $input->param('custompattern');


my $frequency;
if ( $frequencyid eq 'mana' ) {
    $frequency = {
        'id'            => undef,
        'displayorder'  => undef,
        'description'   => scalar $input->param('sfdescription') // '',
        'unitsperissue' => scalar $input->param('unitsperissue') // '',
        'issuesperunit' => scalar $input->param('issuesperunit') // '',
        'unit'          => scalar $input->param('unit') // ''
    };
}
else {
    $frequency = GetSubscriptionFrequency($frequencyid);
}

my %pattern = (
    numberingmethod => scalar $input->param('numberingmethod') // '',
    numbering1      => scalar $input->param('numbering1') // '',
    numbering2      => scalar $input->param('numbering2') // '',
    numbering3      => scalar $input->param('numbering3') // '',
    add1            => scalar $input->param('add1') // '',
    add2            => scalar $input->param('add2') // '',
    add3            => scalar $input->param('add3') // '',
    whenmorethan1   => scalar $input->param('whenmorethan1') // '',
    whenmorethan2   => scalar $input->param('whenmorethan2') // '',
    whenmorethan3   => scalar $input->param('whenmorethan3') // '',
    setto1          => scalar $input->param('setto1') // '',
    setto2          => scalar $input->param('setto2') // '',
    setto3          => scalar $input->param('setto3') // '',
    every1          => scalar $input->param('every1') // '',
    every2          => scalar $input->param('every2') // '',
    every3          => scalar $input->param('every3') // '',
);

$firstacquidate = $firstacquidate ? dt_from_string($firstacquidate)->ymd : dt_from_string->ymd;

$enddate = dt_from_string($enddate)->ymd if $enddate;

$nextacquidate = $nextacquidate ? dt_from_string($nextacquidate)->ymd : $firstacquidate;
my $date = $nextacquidate;

my %subscription = (
    locale      => scalar $input->param('locale') // '',
    lastvalue1      => scalar $input->param('lastvalue1') // '',
    lastvalue2      => scalar $input->param('lastvalue2') // '',
    lastvalue3      => scalar $input->param('lastvalue3') // '',
    innerloop1      => scalar $input->param('innerloop1') // '',
    innerloop2      => scalar $input->param('innerloop2') // '',
    innerloop3      => scalar $input->param('innerloop3') // '',
    irregularity    => '',
    countissuesperunit  => 1,
    firstacquidate  => $firstacquidate,
);

my $issuenumber;
if(defined $subscriptionid) {
    ($issuenumber) = C4::Serials::GetFictiveIssueNumber(\%subscription, $date, $frequency);
} else {
    $issuenumber = 1;
}

my @predictions_loop;
my ($calculated) = GetSeq(\%subscription, \%pattern);
push @predictions_loop, {
    number => $calculated,
    publicationdate => $date,
    issuenumber => $issuenumber,
    dow => Day_of_Week(split /-/, $date),
};
my @irreg = ();
if(defined $subscriptionid) {
    @irreg = C4::Serials::GetSubscriptionIrregularities($subscriptionid);
    while(@irreg && $issuenumber > $irreg[0]) {
        shift @irreg;
    }
    if(@irreg && $issuenumber == $irreg[0]){
        $predictions_loop[0]->{'not_published'} = 1;
        shift @irreg;
    }
}

my $i = 1;
while( $i < 1000 ) {
    my %line;

    if(defined $date){
        $date = GetNextDate(\%subscription, $date, $frequency);
    }
    if(defined $date){
        $line{'publicationdate'} = $date;
        $line{'dow'} = Day_of_Week(split /-/, $date);
    }

    # Check if we don't have exceed end date
    if($sublength){
        if($subtype eq "issues" && $i >= $sublength){
            last;
        } elsif($subtype eq "weeks" && $date && Delta_Days( split(/-/, $date), Add_Delta_Days( split(/-/, $firstacquidate), 7*$sublength - 1 ) ) < 0) {
            last;
        } elsif($subtype eq "months" && $date && (Delta_Days( split(/-/, $date), Add_Delta_YM( split(/-/, $firstacquidate), 0, $sublength) ) - 1) < 0 ) {
            last;
        }
    }
    if($enddate && $date && Delta_Days( split(/-/, $date), split(/-/, $enddate) ) <= 0 ) {
        last;
    }

    ($calculated, $subscription{'lastvalue1'}, $subscription{'lastvalue2'}, $subscription{'lastvalue3'}, $subscription{'innerloop1'}, $subscription{'innerloop2'}, $subscription{'innerloop3'}) = GetNextSeq(\%subscription, \%pattern, $frequency);
    $issuenumber++;
    $line{'number'} = $calculated;
    $line{'issuenumber'} = $issuenumber;
    if(@irreg && $issuenumber == $irreg[0]){
        $line{'not_published'} = 1;
        shift @irreg;
    }
    push @predictions_loop, \%line;

    $i++;
}

$template->param(
    predictions_loop => \@predictions_loop,
);

if ( $frequency->{unit} and not $custompattern ) {
    $template->param( ask_for_irregularities => 1 );
    if ( $frequency->{unit} eq 'day' and $frequency->{unitsperissue} == 1 ) {
        $template->param( daily_options => 1 );
    }
}

if (   ( $date && $enddate && $date ne $enddate )
    or ( $subtype eq 'issues' && $i < $sublength ) )
{
    $template->param( not_consistent_end_date => 1 );
}

output_html_with_http_headers $input, $cookie, $template->output;
