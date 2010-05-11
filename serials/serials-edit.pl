#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

serials-recieve.pl

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

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Biblio;
use C4::Items;
use C4::Koha;
use C4::Output;
use C4::Context;
use C4::Serials;

my $query           = CGI->new();
my $dbh             = C4::Context->dbh;
my @serialids       = $query->param('serialid');
my @serialseqs      = $query->param('serialseq');
my @planneddates    = $query->param('planneddate');
my @publisheddates  = $query->param('publisheddate');
my @status          = $query->param('status');
my @notes           = $query->param('notes');
my @subscriptionids = $query->param('subscriptionid');
my $op              = $query->param('op');
if ( scalar(@subscriptionids) == 1 && index( $subscriptionids[0], q|,| ) > 0 ) {
    @subscriptionids = split( /,/, $subscriptionids[0] );
}
my @errors;
my @errseq;

# If user comes from subscription details
unless (@serialids) {
    foreach my $subscriptionid (@subscriptionids) {
        my $serstatus = $query->param('serstatus');
        if ($serstatus) {
            my @tmpser = GetSerials2( $subscriptionid, $serstatus );
            foreach (@tmpser) {
                push @serialids, $_->{'serialid'};
            }
        }
    }
}

unless ( scalar(@serialids) ) {
    my $string =
      "serials-collection.pl?subscriptionid=" . join( ",", @subscriptionids );
    $string =~ s/,$//;

    print $query->redirect($string);
}
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "serials/serials-edit.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { serials => 1 },
        debug           => 1,
    }
);

my @serialdatalist;
my %processedserialid;

my $today = C4::Dates->new();  
foreach my $tmpserialid (@serialids) {

    #filtering serialid for duplication
    #NEW serial should appear only once and are created afterwards
    if (   defined($tmpserialid)
        && $tmpserialid =~ /^[0-9]+$/
        && !$processedserialid{$tmpserialid} )
    {
        my $data = GetSerialInformation($tmpserialid);
        $data->{publisheddate} = format_date( $data->{publisheddate} );
        $data->{planneddate}   = format_date( $data->{planneddate} );
	$data->{arriveddate}=$today->output('us');
        $data->{'editdisable'} = (
            (
                HasSubscriptionExpired( $data->{subscriptionid} )
                  && $data->{'status1'}
            )
              || $data->{'cannotedit'}
        );
        push @serialdatalist, $data;
        $processedserialid{$tmpserialid} = 1;
    }
}
my $bibdata = GetBiblioData( $serialdatalist[0]->{'biblionumber'} );

my @newserialloop;
my @subscriptionloop;

# check, for each subscription edited, that we have an empty item line if applicable for the subscription
my %processedsubscriptionid;
foreach my $subscriptionid (@subscriptionids) {

    #Do not process subscriptionid twice if it was already processed.
    if ( defined($subscriptionid)
        && !$processedsubscriptionid{$subscriptionid} )
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
        $cell->{'itemid'}         = "NNEW";
        $cell->{'serialid'}       = "NEW";
        $cell->{'issuesatonce'}   = 1;
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

    my $newserial;
    for ( my $i = 0 ; $i <= $#serialids ; $i++ ) {

        if ( $serialids[$i] && $serialids[$i] eq "NEW" ) {
            if ( $serialseqs[$i] ) {

            #IF newserial was provided a name Then we have to create a newSerial
                ### FIXME if NewIssue is modified to use subscription biblionumber, then biblionumber would not be useful.
                $newserial = NewIssue(
                    $serialseqs[$i],
                    $subscriptionids[$i],
                    $serialdatalist[0]->{'biblionumber'},
                    $status[$i],
                    format_date_in_iso( $planneddates[$i] ),
                    format_date_in_iso( $publisheddates[$i] ),
                    $notes[$i]
                );
            }
        }
        elsif ( $serialids[$i] ) {
            ModSerialStatus(
                $serialids[$i],
                $serialseqs[$i],
                format_date_in_iso( $planneddates[$i] ),
                format_date_in_iso( $publisheddates[$i] ),
                $status[$i],
                $notes[$i]
            );
        }
    }
    my @moditems = $query->param('moditem');
    if ( scalar(@moditems) ) {
        my @tags         = $query->param('tag');
        my @subfields    = $query->param('subfield');
        my @field_values = $query->param('field_value');
        my @serials      = $query->param('serial');
        my @bibnums      = $query->param('bibnum');
        my @itemid       = $query->param('itemid');
        my @ind_tag      = $query->param('ind_tag');
        my @indicator    = $query->param('indicator');

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
                    if ( C4::Context->preference("autoBarcode") eq
                        'incremental' )
                    {
                        if ( !$bib_record->field($barcodetagfield)
                            ->subfield($barcodetagsubfield) )
                        {
                            my $sth_barcode = $dbh->prepare(
                                "select max(abs(barcode)) from items");
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
        my $redirect = "serials-collection.pl?";
        $redirect .= join( '&', map { "subscriptionid=" . $_ } sort @subscriptionids );# ID The sort necessary
        print $query->redirect($redirect);
    }
}
my $default_bib_view = get_default_view();

$template->param(
    serialsadditems => $serialdatalist[0]->{'serialsadditems'},
    bibliotitle     => $bibdata->{'title'},
    biblionumber    => $serialdatalist[0]->{'biblionumber'},
    serialslist     => \@serialdatalist,
    default_bib_view => $default_bib_view,
);
output_html_with_http_headers $query, $cookie, $template->output;

sub get_default_view {
    my $defaultview = C4::Context->preference('IntranetBiblioDefaultView');
    my $views = { C4::Search::enabled_staff_search_views };
    if ($defaultview eq 'isbd' && $views->{can_view_ISBD}) {
        return 'ISBDdetail';
    } elsif  ($defaultview eq 'marc' && $views->{can_view_MARC}) {
        return 'MARCdetail';
    } elsif  ($defaultview eq 'labeled_marc' && $views->{can_view_labeledMARC}) {
        return 'labeledMARCdetail';
    } else {
        return 'detail';
    }
}
