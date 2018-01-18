#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Parts Copyright 2010 Biblibre
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

serials-edit.pl

=head1 Parameters

=over 4

=item op
op can be :
    * modsubscriptionhistory :to modify the subscription history
    * serialchangestatus     :to modify the status of this subscription

=item subscriptionid

=item user

=item histstartdate

=item enddate

=item recievedlist

=item missinglist

=item opacnote

=item librariannote

=item serialid

=item serialseq

=item planneddate

=item notes

=item status

=back

=cut

use Modern::Perl;
use CGI qw ( -utf8 );
use Encode qw( decode is_utf8 );
use C4::Auth;
use C4::Biblio;
use C4::Items;
use C4::Koha;
use C4::Output;
use C4::Context;
use C4::Serials;
use C4::Search qw/enabled_staff_search_views/;
use Koha::DateUtils;
use Koha::Serial::Items;

use List::MoreUtils qw/uniq/;

my $query           = CGI->new();
my $dbh             = C4::Context->dbh;
my @serialids       = $query->multi_param('serialid');
my @serialseqs      = $query->multi_param('serialseq');
my @planneddates    = $query->multi_param('planneddate');
my @publisheddates  = $query->multi_param('publisheddate');
my @publisheddatetexts = $query->multi_param('publisheddatetext');
my @status          = $query->multi_param('status');
my @notes           = $query->multi_param('notes');
my @subscriptionids = $query->multi_param('subscriptionid');
my $op              = $query->param('op');
if ( scalar(@subscriptionids) == 1 && index( $subscriptionids[0], q|,| ) > 0 ) {
    @subscriptionids = split( /,/, $subscriptionids[0] );
}
my @errors;
my @errseq;

# If user comes from subscription details
unless (@serialids) {
    my $serstatus = $query->param('serstatus');
    my @statuses = split ',', $serstatus;
    if ($serstatus) {
        foreach my $subscriptionid (@subscriptionids) {
            my @tmpser = GetSerials2( $subscriptionid, \@statuses );
            push @serialids, map { $_->{serialid} } @tmpser;
        }
    }
}

unless ( @serialids ) {
    my $string =
      'serials-collection.pl?subscriptionid=' . join ',', uniq @subscriptionids;
    $string =~ s/,$//;

    print $query->redirect($string);
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => 'serials/serials-edit.tt',
        query           => $query,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { serials => 'receive_serials' },
        debug           => 1,
    }
);

my @serialdatalist;
my %processedserialid;

my $today = output_pref( { dt => dt_from_string, dateonly => 1 } );

foreach my $serialid (@serialids) {

    #filtering serialid for duplication
    #NEW serial should appear only once and are created afterwards
    if (   $serialid
        && $serialid =~ /^[0-9]+$/
        && !$processedserialid{$serialid} )
    {
        my $serinfo = GetSerialInformation($serialid); #TODO duplicates work done by GetSerials2 above

        for my $d ( qw( publisheddate planneddate )){
            if ( $serinfo->{$d} =~m/^00/ ) {
                $serinfo->{$d} = q{};
            }
            else {
                $serinfo->{$d} = output_pref( { dt => dt_from_string( $serinfo->{$d} ), dateonly => 1 } );
            }
        }
        $serinfo->{arriveddate} = $today;

        $serinfo->{'editdisable'} = (
            (
                HasSubscriptionExpired( $serinfo->{subscriptionid} )
                && $serinfo->{'status1'}
            )
            || $serinfo->{'cannotedit'}
        );
        $serinfo->{editdisable} = 0 if C4::Auth::haspermission( C4::Context->userenv->{id}, { serials => 'receive_serials' } );
        $serinfo->{editdisable} ||= ($serinfo->{status8} and $serinfo->{closed});
        push @serialdatalist, $serinfo;
        $processedserialid{$serialid} = 1;
    }
}
my $biblio = Koha::Biblios->find( $serialdatalist[0]->{biblionumber} );

my @newserialloop;
my @subscriptionloop;

# check, for each subscription edited, that we have an empty item line if applicable for the subscription
my %processedsubscriptionid;
foreach my $subscriptionid (@subscriptionids) {

    #Do not process subscriptionid twice if it was already processed.
    if ( $subscriptionid && !$processedsubscriptionid{$subscriptionid} )
    {
        my $cell;
        if ( $serialdatalist[0]->{'serialsadditems'} ) {

            #Create New empty item
            $cell =
              PrepareItemrecordDisplay( $serialdatalist[0]->{'biblionumber'},
                '', GetSubscription($subscriptionid) );
            $cell->{serialsadditems} = 1;
        }
        $cell->{'subscriptionid'} = $subscriptionid;
        $cell->{biblionumber} = $serialdatalist[0]->{'biblionumber'};
        $cell->{'itemid'}         = 'NNEW';
        $cell->{'serialid'}       = 'NEW';
        $cell->{'issuesatonce'}   = 1;
        $cell->{arriveddate}      = $today;

        push @newserialloop, $cell;
        push @subscriptionloop,
          {
            'subscriptionid'      => $subscriptionid,
            'abouttoexpire'       => abouttoexpire($subscriptionid),
            'subscriptionexpired' => HasSubscriptionExpired($subscriptionid),
          };
        $processedsubscriptionid{$subscriptionid} = 1;
    }
}
$template->param( newserialloop => \@newserialloop );
$template->param( subscriptions => \@subscriptionloop );

if ( $op and $op eq 'serialchangestatus' ) {

    # Convert serialseqs to UTF-8 to prevent encoding problems
    foreach my $seq (@serialseqs) {
        $seq = Encode::decode('UTF-8', $seq) unless Encode::is_utf8($seq);
    }

    my $newserial;
    for ( my $i = 0 ; $i <= $#serialids ; $i++ ) {
        my ($plan_date, $pub_date);

        if (defined $planneddates[$i] && $planneddates[$i] ne 'XXX') {
            $plan_date = eval { output_pref( { dt => dt_from_string( $planneddates[$i] ), dateonly => 1, dateformat => 'iso' } ); };
        }
        if (defined $publisheddates[$i] && $publisheddates[$i] ne 'XXX') {
            $pub_date = eval { output_pref( { dt => dt_from_string( $publisheddates[$i] ), dateonly => 1, dateformat => 'iso' } ); };
        }

        if ( $serialids[$i] && $serialids[$i] eq 'NEW' ) {
            if ( $serialseqs[$i] ) {

            #IF newserial was provided a name Then we have to create a newSerial
                ### FIXME if NewIssue is modified to use subscription biblionumber, then biblionumber would not be useful.
                $newserial = NewIssue(
                    $serialseqs[$i],
                    $subscriptionids[0],
                    $serialdatalist[0]->{'biblionumber'},
                    $status[$i],
                    $plan_date,
                    $pub_date,
                    $publisheddatetexts[$i],
                    $notes[$i]
                );
            }
        }
        elsif ( $serialids[$i] ) {
            ModSerialStatus(
                $serialids[$i],
                $serialseqs[$i],
                $plan_date,
                $pub_date,
                $publisheddatetexts[$i],
                $status[$i],
                $notes[$i]
            );
        }
        my $makePreviousSerialAvailable = C4::Context->preference('makePreviousSerialAvailable');
        if ($makePreviousSerialAvailable && $serialids[$i] ne "NEW") {
            # We already have created the new expected serial at this point, so we get the second previous serial
            my $previous = GetPreviousSerialid($subscriptionids[$i]);
            if ($previous) {

                my $serialitem = Koha::Serial::Items->search( {serialid => $previous} )->next;
                my $itemnumber = $serialitem ? $serialitem->itemnumber : undef;
                if ($itemnumber) {

                    # Getting the itemtype to set from the database
                    my $subscriptioninfos = GetSubscription($subscriptionids[$i]);

                    # Changing the status to "available" and the itemtype according to the previousitemtype db field
                    ModItem({notforloan => 0, itype => $subscriptioninfos->{'previousitemtype'} }, undef, $itemnumber);
                }
            }
        }

    }
    my @moditems = $query->multi_param('moditem');
    if ( scalar(@moditems) ) {
        my @tags         = $query->multi_param('tag');
        my @subfields    = $query->multi_param('subfield');
        my @field_values = $query->multi_param('field_value');
        my @serials      = $query->multi_param('serial');
        my @bibnums      = $query->multi_param('bibnum');
        my @itemid       = $query->multi_param('itemid');
        my @ind_tag      = $query->multi_param('ind_tag');
        my @indicator    = $query->multi_param('indicator');

        #Rebuilding ALL the data for items into a hash
        # parting them on $itemid.
        my %itemhash;
        my $countdistinct;
        my $range = scalar(@itemid);
        for ( my $i = 0 ; $i < $range ; $i++ ) {
            unless ( $itemhash{ $itemid[$i] } ) {
                if (   $serials[$countdistinct]
                    && $serials[$countdistinct] ne "NEW" )
                {
                    $itemhash{ $itemid[$i] }->{'serial'} =
                      $serials[$countdistinct];
                }
                else {
                    $itemhash{ $itemid[$i] }->{'serial'} = $newserial;
                }
                $itemhash{ $itemid[$i] }->{'bibnum'} = $bibnums[$countdistinct];
                $countdistinct++;
            }
            push @{ $itemhash{ $itemid[$i] }->{'tags'} },      $tags[$i];
            push @{ $itemhash{ $itemid[$i] }->{'subfields'} }, $subfields[$i];
            push @{ $itemhash{ $itemid[$i] }->{'field_values'} },
              $field_values[$i];
            push @{ $itemhash{ $itemid[$i] }->{'ind_tag'} },   $ind_tag[$i];
            push @{ $itemhash{ $itemid[$i] }->{'indicator'} }, $indicator[$i];
        }
        foreach my $item ( keys %itemhash ) {

       # Verify Itemization is "Valid", i.e. serial status is Arrived or Missing
            my $index = -1;
            for ( my $i = 0 ; $i < scalar(@serialids) ; $i++ ) {
                  if (
                    $itemhash{$item}->{serial} eq $serialids[$i]
                    || (   $itemhash{$item}->{serial} == $newserial
                        && $serialids[$i] eq 'NEW' )
                ) {
                    $index = $i
                  }
            }
            if ( $index >= 0 && $status[$index] == 2 ) {
                my $xml = TransformHtmlToXml(
                    $itemhash{$item}->{'tags'},
                    $itemhash{$item}->{'subfields'},
                    $itemhash{$item}->{'field_values'},
                    $itemhash{$item}->{'indicator'},
                    $itemhash{$item}->{'ind_tag'}
                );

                #           warn $xml;
                my $bib_record = MARC::Record::new_from_xml( $xml, 'UTF-8' );
                if ( $item =~ /^N/ ) {

                    #New Item

                  # if autoBarcode is set to 'incremental', calculate barcode...
                    my ( $barcodetagfield, $barcodetagsubfield ) =
                      GetMarcFromKohaField(
                        'items.barcode',
                        GetFrameworkCode(
                            $serialdatalist[0]->{'biblionumber'}
                        )
                      );
                    if ( C4::Context->preference('autoBarcode') eq
                        'incremental' )
                    {
                        if (
                            !(
                                   $bib_record->field($barcodetagfield)
                                && $bib_record->field($barcodetagfield)->subfield($barcodetagsubfield)
                            )
                          )
                        {
                            my $sth_barcode = $dbh->prepare(
                                'select max(abs(barcode)) from items');
                            $sth_barcode->execute;
                            my ($newbarcode) = $sth_barcode->fetchrow;

# OK, we have the new barcode, add the entry in MARC record # FIXME -> should be  using barcode plugin here.
                            $bib_record->field($barcodetagfield)
                              ->update( $barcodetagsubfield => ++$newbarcode );
                        }
                    }

                    # check for item barcode # being unique
                    my $exists;
                    if (
                        $bib_record->subfield(
                            $barcodetagfield, $barcodetagsubfield
                        )
                      )
                    {
                        $exists = GetItemnumberFromBarcode(
                            $bib_record->subfield(
                                $barcodetagfield, $barcodetagsubfield
                            )
                        );
                    }

                    #           push @errors,"barcode_not_unique" if($exists);
                    # if barcode exists, don't create, but report The problem.
                    if ($exists) {
                        push @errors, 'barcode_not_unique';
                        push @errseq, { serialseq => $serialseqs[$index] };
                    }
                    else {
                        my ( $biblionumber, $bibitemnum, $itemnumber ) =
                          AddItemFromMarc( $bib_record,
                            $itemhash{$item}->{bibnum} );
                        AddItem2Serial( $itemhash{$item}->{serial},
                            $itemnumber );
                    }
                }
                else {

                    #modify item
                    my ( $oldbiblionumber, $oldbibnum, $itemnumber ) =
                      ModItemFromMarc( $bib_record,
                        $itemhash{$item}->{'bibnum'}, $item );
                }
            }
        }
    }


    if ( @errors ) {
        $template->param( Errors => 1 );
        if ( @errseq ) {
            $template->param( barcode_not_unique => 1, errseq => \@errseq );
        }
    }
    else {
        my $redirect = 'serials-collection.pl?';
        $redirect .= join( '&', map { 'subscriptionid=' . $_ } @subscriptionids );
        print $query->redirect($redirect);
    }
}
my $location = $serialdatalist[0]->{'location'};
my $default_bib_view = get_default_view();

$template->param(
    serialsadditems => $serialdatalist[0]->{'serialsadditems'},
    callnumber	     => $serialdatalist[0]->{'callnumber'},
    internalnotes   => $serialdatalist[0]->{'internalnotes'},
    bibliotitle     => $biblio->title,
    biblionumber    => $serialdatalist[0]->{'biblionumber'},
    serialslist     => \@serialdatalist,
    default_bib_view => $default_bib_view,
    location         => $location,
    (uc(C4::Context->preference("marcflavour"))) => 1

);
output_html_with_http_headers $query, $cookie, $template->output;

sub get_default_view {
    my $defaultview = C4::Context->preference('IntranetBiblioDefaultView');
    my %views       = C4::Search::enabled_staff_search_views();
    if ( $defaultview eq 'isbd' && $views{can_view_ISBD} ) {
        return 'ISBDdetail';
    }
    elsif ( $defaultview eq 'marc' && $views{can_view_MARC} ) {
        return 'MARCdetail';
    }
    elsif ( $defaultview eq 'labeled_marc' && $views{can_view_labeledMARC} ) {
        return 'labeledMARCdetail';
    }
    return 'detail';
}
