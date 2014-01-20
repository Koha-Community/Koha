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

use strict;
use warnings;

use CGI qw ( -utf8 );
use Date::Calc qw(Today Day_of_Year Week_of_Year Add_Delta_Days Add_Delta_YM);
use C4::Koha;
use C4::Biblio;
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Acquisition;
use C4::Output;
use C4::Context;
use C4::Branch; # GetBranches
use C4::Serials;
use C4::Serials::Frequency;
use C4::Serials::Numberpattern;
use C4::Letters;
use Koha::AdditionalField;
use Carp;

#use Smart::Comments;

our $query = CGI->new;
my $op = $query->param('op') || '';
my $dbh = C4::Context->dbh;
my $sub_length;

my @budgets;

# Permission needed if it is a modification : edit_subscription
# Permission needed otherwise (nothing or dup) : create_subscription
my $permission = ($op eq "modify") ? "edit_subscription" : "create_subscription";

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/subscription-add.tt",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => $permission},
				debug => 1,
				});



my $sub_on;

my $subs;
our $firstissuedate;

if ($op eq 'modify' || $op eq 'dup' || $op eq 'modsubscription') {

    my $subscriptionid = $query->param('subscriptionid');
    $subs = GetSubscription($subscriptionid);

    ## FIXME : Check rights to edit if mod. Could/Should display an error message.
    if ($subs->{'cannotedit'} && $op eq 'modify'){
      carp "Attempt to modify subscription $subscriptionid by ".C4::Context->userenv->{'id'}." not allowed";
      print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    }
    $firstissuedate = $subs->{firstacquidate} || '';  # in iso format.
    for (qw(startdate firstacquidate histstartdate enddate histenddate)) {
        next unless defined $subs->{$_};
	# TODO : Handle date formats properly.
         if ($subs->{$_} eq '0000-00-00') {
            $subs->{$_} = ''
    	} else {
            $subs->{$_} = $subs->{$_};
        }
	  }
      if (!defined $subs->{letter}) {
          $subs->{letter}= q{};
      }
    my $nextexpected = GetNextExpected($subscriptionid);
    $nextexpected->{'isfirstissue'} = $nextexpected->{planneddate} eq $firstissuedate ;
    $subs->{nextacquidate} = $nextexpected->{planneddate}  if($op eq 'modify');
    unless($op eq 'modsubscription') {
        foreach my $length_unit (qw(numberlength weeklength monthlength)) {
            if ($subs->{$length_unit}) {
                $sub_length=$subs->{$length_unit};
                $sub_on=$length_unit;
                last;
            }
        }

        $template->param( %{$subs} );
        $template->param(
                    $op => 1,
                    "subtype_$sub_on" => 1,
                    sublength =>$sub_length,
                    history => ($op eq 'modify'),
                    firstacquiyear => substr($firstissuedate,0,4),
                    );

        if($op eq 'modify') {
            my ($serials_number) = GetSerials($subscriptionid);
            if($serials_number > 1) {
                $template->param(more_than_one_serial => 1);
            }
        }
    }

    if ( $op eq 'dup' ) {
        my $dont_copy_fields = C4::Context->preference('SubscriptionDuplicateDroppedInput');
        my @fields_id = map { fieldid => $_ }, split '\|', $dont_copy_fields;
        $template->param( dont_export_field_loop => \@fields_id );
    }

    my $letters = get_letter_loop( $subs->{letter} );
    $template->param( letterloop => $letters );

}

my $onlymine =
     C4::Context->preference('IndependentBranches')
  && C4::Context->userenv
  && !C4::Context->IsSuperLibrarian
  && (
    not C4::Auth::haspermission( C4::Context->userenv->{id}, { serials => 'superserials' } )
  )
  && C4::Context->userenv->{branch};
my $branches = GetBranches($onlymine);
my $branchloop;
for my $thisbranch (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %{$branches}) {
    my $selected = 0;
    $selected = 1 if (defined($subs) && $thisbranch eq $subs->{'branchcode'});
    push @{$branchloop}, {
        value => $thisbranch,
        selected => $selected,
        branchname => $branches->{$thisbranch}->{'branchname'},
    };
}

my $locations_loop = GetAuthorisedValues("LOC",$subs->{'location'});

$template->param(branchloop => $branchloop,
    locations_loop=>$locations_loop,
);


my $additional_fields = Koha::AdditionalField->all( { tablename => 'subscription' } );
for my $field ( @$additional_fields ) {
    if ( $field->{authorised_value_category} ) {
        $field->{authorised_value_choices} = GetAuthorisedValues( $field->{authorised_value_category} );
    }
}
$template->param( additional_fields_for_subscription => $additional_fields );

# prepare template variables common to all $op conditions:
if ($op!~/^mod/) {
    my $letters = get_letter_loop();
    $template->param( letterloop => $letters );
}

if ($op eq 'addsubscription') {
    redirect_add_subscription();
} elsif ($op eq 'modsubscription') {
    redirect_mod_subscription();
} else {

    $template->param(
        subtypes => [ qw( numberlength weeklength monthlength ) ],
        subtype => $sub_on,
    );

    if ( $op ne 'modsubscription' && $op ne 'dup' && $op ne 'modify' ) {
        my $letters = get_letter_loop();
        $template->param( letterloop => $letters );
    }

    my $new_biblionumber = $query->param('biblionumber_for_new_subscription');
    if (defined $new_biblionumber) {
        my $bib = GetBiblioData($new_biblionumber);
        if (defined $bib) {
            $template->param(bibnum      => $new_biblionumber);
            $template->param(bibliotitle => $bib->{title});
        }
    }

    $template->param((uc(C4::Context->preference("marcflavour"))) => 1);

    my @frequencies = GetSubscriptionFrequencies;
    my @frqloop;
    foreach my $freq (@frequencies) {
        my $selected = 0;
        $selected = 1 if ($subs->{periodicity} and $freq->{id} eq $subs->{periodicity});
        my $row = {
            id => $freq->{'id'},
            selected => $selected,
            label => $freq->{'description'},
        };
        push @frqloop, $row;
    }
    $template->param(frequencies => \@frqloop);

    my @numpatterns = GetSubscriptionNumberpatterns;
    my @numberpatternloop;
    foreach my $numpattern (@numpatterns) {
        my $selected = 0;
        $selected = 1 if($subs->{numberpattern} and $numpattern->{id} eq $subs->{numberpattern});
        my $row = {
            id => $numpattern->{'id'},
            selected => $selected,
            label => $numpattern->{'label'},
        };
        push @numberpatternloop, $row;
    }
    $template->param(numberpatterns => \@numberpatternloop);

    my $languages = [ map {
        {
            language => $_->{iso639_2_code},
            description => $_->{language_description} || $_->{language}
        }
    } @{ C4::Languages::getAllLanguages() } ];

    $template->param( locales => $languages );

    output_html_with_http_headers $query, $cookie, $template->output;
}

sub get_letter_loop {
    my ($selected_lettercode) = @_;
    my $letters = GetLetters({ module => 'serial' });
    return [
        map {
            {
                value      => $_->{code},
                lettername => $_->{name},
                ( $_->{code} eq $selected_lettercode ? ( selected => 1 ) : () ),
            }
          } @$letters
    ];
}

sub _get_sub_length {
    my ($type, $length) = @_;
    return
        (
            $type eq 'issues' ? $length : 0,
            $type eq 'weeks'   ? $length : 0,
            $type eq 'months'  ? $length : 0,
        );
}

sub _guess_enddate {
    my ($startdate_iso, $frequencyid, $numberlength, $weeklength, $monthlength) = @_;
    my ($year, $month, $day);
    my $enddate;
    if($numberlength != 0) {
        my $frequency = GetSubscriptionFrequency($frequencyid);
        if($frequency->{'unit'} eq 'day') {
            ($year, $month, $day) = Add_Delta_Days(split(/-/, $startdate_iso), $numberlength * $frequency->{'unitsperissue'} / $frequency->{'issuesperunit'});
        } elsif($frequency->{'unit'} eq 'week') {
            ($year, $month, $day) = Add_Delta_Days(split(/-/, $startdate_iso), $numberlength * 7 * $frequency->{'unitsperissue'} / $frequency->{'issuesperunit'});
        } elsif($frequency->{'unit'} eq 'month') {
            ($year, $month, $day) = Add_Delta_YM(split(/-/, $startdate_iso), 0, $numberlength * $frequency->{'unitsperissue'} / $frequency->{'issuesperunit'});
        } elsif($frequency->{'unit'} eq 'year') {
            ($year, $month, $day) = Add_Delta_YM(split(/-/, $startdate_iso), $numberlength * $frequency->{'unitsperissue'} / $frequency->{'issuesperunit'}, 0);
        }
    } elsif($weeklength != 0) {
        ($year, $month, $day) = Add_Delta_Days(split(/-/, $startdate_iso), $weeklength * 7);
    } elsif($monthlength != 0) {
        ($year, $month, $day) = Add_Delta_YM(split(/-/, $startdate_iso), 0, $monthlength);
    }
    if(defined $year) {
        $enddate = sprintf("%04d-%02d-%02d", $year, $month, $day);
    } else {
        undef $enddate;
    }
    return $enddate;
}

sub redirect_add_subscription {
    my $auser          = $query->param('user');
    my $branchcode     = $query->param('branchcode');
    my $aqbooksellerid = $query->param('aqbooksellerid');
    my $cost           = $query->param('cost');
    my $aqbudgetid     = $query->param('aqbudgetid');
    my $periodicity    = $query->param('frequency');
    my @irregularity   = $query->param('irregularity');
    my $numberpattern  = $query->param('numbering_pattern');
    my $locale         = $query->param('locale');
    my $graceperiod    = $query->param('graceperiod') || 0;

    my $subtype = $query->param('subtype');
    my $sublength = $query->param('sublength');
    my ( $numberlength, $weeklength, $monthlength )
        = _get_sub_length( $subtype, $sublength );
    my $add1              = $query->param('add1');
    my $lastvalue1        = $query->param('lastvalue1');
    my $innerloop1        = $query->param('innerloop1');
    my $innerloop2        = $query->param('innerloop2');
    my $lastvalue2        = $query->param('lastvalue2');
    my $lastvalue3        = $query->param('lastvalue3');
    my $innerloop3        = $query->param('innerloop3');
    my $status            = 1;
    my $biblionumber      = $query->param('biblionumber');
    my $callnumber        = $query->param('callnumber');
    my $notes             = $query->param('notes');
    my $internalnotes     = $query->param('internalnotes');
    my $letter            = $query->param('letter');
    my $manualhistory     = $query->param('manualhist') ? 1 : 0;
    my $serialsadditems   = $query->param('serialsadditems');
    my $staffdisplaycount = $query->param('staffdisplaycount');
    my $opacdisplaycount  = $query->param('opacdisplaycount');
    my $location          = $query->param('location');
    my $skip_serialseq    = $query->param('skip_serialseq');
    my $startdate = format_date_in_iso( $query->param('startdate') );
    my $enddate = format_date_in_iso( $query->param('enddate') );
    my $firstacquidate  = format_date_in_iso($query->param('firstacquidate'));
    if(!defined $enddate || $enddate eq '') {
        if($subtype eq "issues") {
            $enddate = _guess_enddate($firstacquidate, $periodicity, $numberlength, $weeklength, $monthlength);
        } else {
            $enddate = _guess_enddate($startdate, $periodicity, $numberlength, $weeklength, $monthlength);
        }
    }

    my $subscriptionid = NewSubscription(
        $auser, $branchcode, $aqbooksellerid, $cost, $aqbudgetid, $biblionumber,
        $startdate, $periodicity, $numberlength, $weeklength,
        $monthlength, $lastvalue1, $innerloop1, $lastvalue2, $innerloop2,
        $lastvalue3, $innerloop3, $status, $notes, $letter, $firstacquidate,
        join(";",@irregularity), $numberpattern, $locale, $callnumber,
        $manualhistory, $internalnotes, $serialsadditems,
        $staffdisplaycount, $opacdisplaycount, $graceperiod, $location, $enddate,
        $skip_serialseq
    );

    my $additional_fields = Koha::AdditionalField->all( { tablename => 'subscription' } );
    insert_additional_fields( $additional_fields, $biblionumber, $subscriptionid );

    print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    return;
}

sub redirect_mod_subscription {
    my $subscriptionid = $query->param('subscriptionid');
    my @irregularity = $query->param('irregularity');
    my $auser = $query->param('user');
    my $librarian => $query->param('librarian'),
    my $branchcode = $query->param('branchcode');
    my $cost = $query->param('cost');
    my $aqbooksellerid = $query->param('aqbooksellerid');
    my $biblionumber = $query->param('biblionumber');
    my $aqbudgetid = $query->param('aqbudgetid');
    my $startdate = format_date_in_iso($query->param('startdate'));
    my $firstacquidate = format_date_in_iso( $query->param('firstacquidate') );
    my $nextacquidate = $query->param('nextacquidate') ?
                            format_date_in_iso($query->param('nextacquidate')):
                            $firstacquidate;
    my $enddate = format_date_in_iso($query->param('enddate'));
    my $periodicity = $query->param('frequency');

    my $subtype = $query->param('subtype');
    my $sublength = $query->param('sublength');
    my ($numberlength, $weeklength, $monthlength)
        = _get_sub_length( $subtype, $sublength );
    my $numberpattern = $query->param('numbering_pattern');
    my $locale = $query->param('locale');
    my $lastvalue1 = $query->param('lastvalue1');
    my $innerloop1 = $query->param('innerloop1');
    my $lastvalue2 = $query->param('lastvalue2');
    my $innerloop2 = $query->param('innerloop2');
    my $lastvalue3 = $query->param('lastvalue3');
    my $innerloop3 = $query->param('innerloop3');
    my $status = 1;
    my $callnumber = $query->param('callnumber');
    my $notes = $query->param('notes');
    my $internalnotes = $query->param('internalnotes');
    my $letter = $query->param('letter');
    my $manualhistory = $query->param('manualhist') ? 1 : 0;
    my $serialsadditems = $query->param('serialsadditems');
	my $staffdisplaycount = $query->param('staffdisplaycount');
	my $opacdisplaycount = $query->param('opacdisplaycount');
    my $graceperiod     = $query->param('graceperiod') || 0;
    my $location = $query->param('location');
    my $skip_serialseq    = $query->param('skip_serialseq');

    # Guess end date
    if(!defined $enddate || $enddate eq '') {
        if($subtype eq "issues") {
            $enddate = _guess_enddate($nextacquidate, $periodicity, $numberlength, $weeklength, $monthlength);
        } else {
            $enddate = _guess_enddate($startdate, $periodicity, $numberlength, $weeklength, $monthlength);
        }
    }

    my $nextexpected = GetNextExpected($subscriptionid);
    #  If it's  a mod, we need to check the current 'expected' issue, and mod it in the serials table if necessary.
    if ( $nextexpected->{planneddate} && $nextacquidate ne $nextexpected->{planneddate} ) {
        ModNextExpected($subscriptionid, $nextacquidate);
        # if we have not received any issues yet, then we also must change the firstacquidate for the subs.
        $firstissuedate = $nextacquidate if($nextexpected->{isfirstissue});
    }

    ModSubscription(
        $auser, $branchcode, $aqbooksellerid, $cost, $aqbudgetid, $startdate,
        $periodicity, $firstacquidate, join(";",@irregularity),
        $numberpattern, $locale, $numberlength, $weeklength, $monthlength, $lastvalue1,
        $innerloop1, $lastvalue2, $innerloop2, $lastvalue3, $innerloop3,
        $status, $biblionumber, $callnumber, $notes, $letter,
        $manualhistory, $internalnotes, $serialsadditems, $staffdisplaycount,
        $opacdisplaycount, $graceperiod, $location, $enddate, $subscriptionid,
        $skip_serialseq
    );

    my $additional_fields = Koha::AdditionalField->all( { tablename => 'subscription' } );
    insert_additional_fields( $additional_fields, $biblionumber, $subscriptionid );

    print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    return;
}

sub insert_additional_fields {
    my ( $additional_fields, $biblionumber, $subscriptionid ) = @_;
    my @additional_field_values;
    my $record = GetMarcBiblio( $biblionumber, 1 );
    for my $field ( @$additional_fields ) {
        my $af = Koha::AdditionalField->new({ id => $field->{id} })->fetch;
        if ( $af->{marcfield} ) {
            my ( $field, $subfield ) = split /\$/, $af->{marcfield};
            $af->{values} = undef;
            if ( $field and $subfield ) {
                my $value = $record->subfield( $field, $subfield );
                $af->{values} = {
                    $subscriptionid => $value
                };
            }
        } else {
            $af->{values} = {
                $subscriptionid => $query->param('additional_field_' . $field->{id})
            } if defined $query->param('additional_field_' . $field->{id});
        }
        $af->insert_values;
    }
}
