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

use CGI qw ( -utf8 );
use Date::Calc qw( Add_Delta_Days Add_Delta_YM );
use C4::Koha qw( GetAuthorisedValues );
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_and_exit output_html_with_http_headers );
use C4::Context;
use C4::Serials qw( GetSubscription GetNextExpected GetSerials GetSubscriptionLength NewSubscription ModNextExpected ModSubscription );
use C4::Serials::Frequency;
use C4::Serials::Numberpattern;
use C4::Letters qw( GetLetters );
use Koha::AdditionalFields;
use Koha::Biblios;
use Koha::DateUtils qw( output_pref );
use Koha::ItemTypes;
use Carp qw( carp );

use Koha::Subscription::Numberpattern;
use Koha::Subscription::Frequency;
use Koha::SharedContent;

our $query = CGI->new;
my $op = $query->param('op') || '';
my $dbh = C4::Context->dbh;
my $sub_length;


# Permission needed if it is a modification : edit_subscription
# Permission needed otherwise (nothing or dup) : create_subscription
my $permission =
  ( $op eq 'modify' || $op eq 'modsubscription' ) ? "edit_subscription" : "create_subscription";

our ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/subscription-add.tt",
				query => $query,
				type => "intranet",
				flagsrequired => {serials => $permission},
				});



my $sub_on;

my $subs;
our $firstissuedate;

my $mana_url = C4::Context->config('mana_config');
$template->param( 'mana_url' => $mana_url );
my $subscriptionid = $query->param('subscriptionid');

if ($op eq 'modify' || $op eq 'dup' || $op eq 'modsubscription') {

    $subs = GetSubscription($subscriptionid);

    output_and_exit( $query, $cookie, $template, 'unknown_subscription')
        unless $subs;

    ## FIXME : Check rights to edit if mod. Could/Should display an error message.
    if ($subs->{'cannotedit'} && $op eq 'modify'){
      carp "Attempt to modify subscription $subscriptionid by ".C4::Context->userenv->{'id'}." not allowed";
      print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    }
    $firstissuedate = $subs->{firstacquidate} || '';  # in iso format.
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

my $locations_loop = GetAuthorisedValues("LOC");
my $ccodes_loop     = GetAuthorisedValues("CCODE");

$template->param(
    branchcode => $subs->{branchcode},
    locations_loop=>$locations_loop,
    ccodes_loop=>$ccodes_loop
);

my @additional_fields = Koha::AdditionalFields->search({ tablename => 'subscription' })->as_list;
my %additional_field_values;
if ($subscriptionid) {
    my $subscription = Koha::Subscriptions->find($subscriptionid);
    foreach my $value ($subscription->additional_field_values->as_list) {
        $additional_field_values{$value->field_id} = $value->value;
    }
}

$template->param(
    additional_fields => \@additional_fields,
    additional_field_values => \%additional_field_values,
);

my $typeloop = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search_with_localization->unblessed } };

# FIXME We should use the translated_description for item types
my @typearg =
    map { { code => $_, value => $typeloop->{$_}{'description'}, selected => ( ( $subs->{itemtype} and $_ eq $subs->{itemtype} ) ? "selected=\"selected\"" : "" ), } } sort keys %{$typeloop};
my @previoustypearg =
    map { { code => $_, value => $typeloop->{$_}{'description'}, selected => ( ( $subs->{previousitemtype} and $_ eq $subs->{previousitemtype} ) ? "selected=\"selected\"" : "" ), } } sort keys %{$typeloop};

$template->param(
    typeloop                 => \@typearg,
    previoustypeloop         => \@previoustypearg,
    locations_loop=>$locations_loop,
);

# prepare template variables common to all $op conditions:
$template->param('makePreviousSerialAvailable' => 1) if (C4::Context->preference('makePreviousSerialAvailable'));

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
        my $biblio = Koha::Biblios->find( $new_biblionumber );
        if (defined $biblio) {
            $template->param(bibnum      => $new_biblionumber);
            $template->param(bibliotitle => $biblio->title);
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

    my @bookseller_ids = Koha::Acquisition::Booksellers->search->get_column('id');
    $template->param( bookseller_ids => \@bookseller_ids );

    output_html_with_http_headers $query, $cookie, $template->output;
}

sub get_letter_loop {
    my ($selected_lettercode) = @_;
    $selected_lettercode //= '';
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
    my $periodicity = $query->param('frequency');
    if ($periodicity eq 'mana') {
        my $subscription_freq = Koha::Subscription::Frequency->new()->set(
            {
                description   => $query->param('sfdescription'),
                unit          => $query->param('unit'),
                unitsperissue => $query->param('unitsperissue'),
                issuesperunit => $query->param('issuesperunit'),
            }
        )->store();
        $periodicity = $subscription_freq->id;
    }
    my $numberpattern = Koha::Subscription::Numberpatterns->new_or_existing({ $query->Vars });

    my $auser          = $query->param('user');
    my $branchcode     = $query->param('branchcode');
    my $aqbooksellerid = $query->param('aqbooksellerid');
    my $cost           = $query->param('cost');
    my $aqbudgetid     = $query->param('aqbudgetid');
    my @irregularity   = $query->multi_param('irregularity');
    my $locale         = $query->param('locale');
    my $graceperiod    = $query->param('graceperiod') || 0;

    my $subtype = $query->param('subtype');
    my $sublength = $query->param('sublength');
    my ( $numberlength, $weeklength, $monthlength )
        = GetSubscriptionLength( $subtype, $sublength );
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
    my $itemtype          = $query->param('itemtype');
    my $previousitemtype  = $query->param('previousitemtype');
    my $skip_serialseq    = $query->param('skip_serialseq');
    my $ccode             = $query->param('ccode');
    my $published_on_template = $query->param('published_on_template');

    my $mana_id;
    if ( $query->param('mana_id') ne "" ) {
        $mana_id = $query->param('mana_id');
        Koha::SharedContent::increment_entity_value("subscription",$mana_id, "nbofusers");
    }

    my $startdate      = output_pref( { str => scalar $query->param('startdate'),      dateonly => 1, dateformat => 'iso' } );
    my $enddate        = output_pref( { str => scalar $query->param('enddate'),        dateonly => 1, dateformat => 'iso' } );
    my $firstacquidate = output_pref( { str => scalar $query->param('firstacquidate'), dateonly => 1, dateformat => 'iso' } );

    if(!defined $enddate || $enddate eq '') {
        if($subtype eq "issues") {
            $enddate = _guess_enddate($firstacquidate, $periodicity, $numberlength, $weeklength, $monthlength)
        } else {
            $enddate = _guess_enddate($startdate, $periodicity, $numberlength, $weeklength, $monthlength)
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
        $skip_serialseq, $itemtype, $previousitemtype, $mana_id, $ccode, $published_on_template
    );
    if ( (C4::Context->preference('Mana') == 1) and ( grep { $_ eq "subscription" } split(/,/, C4::Context->preference('AutoShareWithMana'))) ){
        my $result = Koha::SharedContent::send_entity( $query->param('mana_language') || '', $loggedinuser, $subscriptionid, 'subscription');
        $template->param( mana_msg => $result->{msg} );
    }

    my @additional_fields;
    my $biblio = Koha::Biblios->find($biblionumber);
    my $subscription_fields = Koha::AdditionalFields->search({ tablename => 'subscription' });
    while ( my $field = $subscription_fields->next ) {
        my $value = $query->param('additional_field_' . $field->id);
        push @additional_fields, {
            id => $field->id,
            value => $value,
        };
    }
    Koha::Subscriptions->find($subscriptionid)->set_additional_fields(\@additional_fields);

    print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    return;
}

sub redirect_mod_subscription {
    my $subscriptionid = $query->param('subscriptionid');
    my @irregularity = $query->multi_param('irregularity');
    my $auser = $query->param('user');
    my $librarian => scalar $query->param('librarian'),
    my $branchcode = $query->param('branchcode');
    my $cost = $query->param('cost');
    my $aqbooksellerid = $query->param('aqbooksellerid');
    my $biblionumber = $query->param('biblionumber');
    my $aqbudgetid = $query->param('aqbudgetid');

    my $startdate      = output_pref( { str => scalar $query->param('startdate'),      dateonly => 1, dateformat => 'iso' } );
    my $enddate        = output_pref( { str => scalar $query->param('enddate'),        dateonly => 1, dateformat => 'iso' } );
    my $firstacquidate = output_pref( { str => scalar $query->param('firstacquidate'), dateonly => 1, dateformat => 'iso' } );

    my $nextacquidate  = $query->param('nextacquidate');
    $nextacquidate = $nextacquidate
        ? output_pref( { str => $nextacquidate, dateonly => 1, dateformat => 'iso' } )
        : $firstacquidate;

    my $periodicity = $query->param('frequency');
    if ($periodicity eq 'mana') {
        my $subscription_freq = Koha::Subscription::Frequency->new()->set(
            {
                description   => $query->param('sfdescription'),
                unit          => $query->param('unit'),
                unitsperissue => $query->param('unitsperissue'),
                issuesperunit => $query->param('issuesperunit'),
            }
        )->store();
        $periodicity = $subscription_freq->id;
    }
    my $numberpattern = Koha::Subscription::Numberpatterns->new_or_existing({ $query->Vars });

    my $subtype = $query->param('subtype');
    my $sublength = $query->param('sublength');
    my ($numberlength, $weeklength, $monthlength) = GetSubscriptionLength( $subtype, $sublength );
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
    my $itemtype          = $query->param('itemtype');
    my $previousitemtype  = $query->param('previousitemtype');
    my $skip_serialseq    = $query->param('skip_serialseq');
    my $ccode             = $query->param('ccode');
    my $published_on_template = $query->param('published_on_template');

    my $mana_id;
    if ( $query->param('mana_id') ne "" ) {
        $mana_id = $query->param('mana_id');
        Koha::SharedContent::increment_entity_value("subscription",$mana_id, "nbofusers");
    }
    else {
        $mana_id = undef;
    }

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
        $skip_serialseq, $itemtype, $previousitemtype, $mana_id, $ccode, $published_on_template
    );

    my @additional_fields;
    my $biblio = Koha::Biblios->find($biblionumber);
    my $subscription_fields = Koha::AdditionalFields->search({ tablename => 'subscription' });
    while ( my $field = $subscription_fields->next ) {
        my $value = $query->param('additional_field_' . $field->id);
        push @additional_fields, {
            id => $field->id,
            value => $value,
        };
    }
    Koha::Subscriptions->find($subscriptionid)->set_additional_fields(\@additional_fields);

    print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    return;
}
