#!/usr/bin/perl


# Copyright 2009 BibLibre
# Parts Copyright Catalyst IT 2011
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

use strict;
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Output;
use C4::Auth;
use C4::Items;
use C4::Biblio;
use C4::Serials;
use C4::Koha;
use C4::Reserves qw/MergeHolds/;
use C4::Acquisition qw/ModOrder GetOrdersByBiblionumber/;
use Koha::MetadataRecord;

my $input = new CGI;
my @biblionumber = $input->param('biblionumber');
my $merge = $input->param('merge');

my @errors;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "cataloguing/merge.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 'edit_catalogue' },
    }
);

#------------------------
# Merging
#------------------------
if ($merge) {

    my $dbh = C4::Context->dbh;
    my $sth;

    # Creating a new record from the html code
    my $record       = TransformHtmlToMarc( $input );
    my $tobiblio     =  $input->param('biblio1');
    my $frombiblio   =  $input->param('biblio2');

    # Rewriting the leader
    $record->leader(GetMarcBiblio($tobiblio)->leader());

    my $frameworkcode = $input->param('frameworkcode');
    my @notmoveditems;

    # Modifying the reference record
    ModBiblio($record, $tobiblio, $frameworkcode);

    # Moving items from the other record to the reference record
    # Also moving orders from the other record to the reference record, only if the order is linked to an item of the other record
    my $itemnumbers = get_itemnumbers_of($frombiblio);
    foreach my $itloop ($itemnumbers->{$frombiblio}) {
    foreach my $itemnumber (@$itloop) {
        my $res = MoveItemFromBiblio($itemnumber, $frombiblio, $tobiblio);
        if (not defined $res) {
            push @notmoveditems, $itemnumber;
        }
    }
    }
    # If some items could not be moved :
    if (scalar(@notmoveditems) > 0) {
        my $itemlist = join(' ',@notmoveditems);
        push @errors, { code => "CANNOT_MOVE", value => $itemlist };
    }

    # Moving subscriptions from the other record to the reference record
    my $subcount = CountSubscriptionFromBiblionumber($frombiblio);
    if ($subcount > 0) {
    $sth = $dbh->prepare("UPDATE subscription SET biblionumber = ? WHERE biblionumber = ?");
    $sth->execute($tobiblio, $frombiblio);

    $sth = $dbh->prepare("UPDATE subscriptionhistory SET biblionumber = ? WHERE biblionumber = ?");
    $sth->execute($tobiblio, $frombiblio);

    }

    # Moving serials
    $sth = $dbh->prepare("UPDATE serial SET biblionumber = ? WHERE biblionumber = ?");
    $sth->execute($tobiblio, $frombiblio);

    # TODO : Moving reserves

    # Moving orders (orders linked to items of frombiblio have already been moved by MoveItemFromBiblio)
    my @allorders = GetOrdersByBiblionumber($frombiblio);
    my @tobiblioitem = GetBiblioItemByBiblioNumber ($tobiblio);
    my $tobiblioitem_biblioitemnumber = $tobiblioitem [0]-> {biblioitemnumber };
    foreach my $myorder (@allorders) {
        $myorder->{'biblionumber'} = $tobiblio;
        ModOrder ($myorder);
    # TODO : add error control (in ModOrder?)
    }

    # Deleting the other record
    if (scalar(@errors) == 0) {
    # Move holds
    MergeHolds($dbh,$tobiblio,$frombiblio);
    my $error = DelBiblio($frombiblio);
    push @errors, $error if ($error);
    }

    # Parameters
    $template->param(
    result => 1,
    biblio1 => $input->param('biblio1')
    );

#-------------------------
# Show records to merge
#-------------------------
} else {
    my $mergereference = $input->param('mergereference');
    my $biblionumber = $input->param('biblionumber');

    if (scalar(@biblionumber) != 2) {
        push @errors, { code => "WRONG_COUNT", value => scalar(@biblionumber) };
    }
    else {
        my $data1 = GetBiblioData($biblionumber[0]);
        my $record1 = GetMarcBiblio($biblionumber[0]);

        my $data2 = GetBiblioData($biblionumber[1]);
        my $record2 = GetMarcBiblio($biblionumber[1]);

        # Checks if both records use the same framework
        my $frameworkcode1 = &GetFrameworkCode($biblionumber[0]);
        my $frameworkcode2 = &GetFrameworkCode($biblionumber[1]);


        my $subtitle1 = GetRecordValue('subtitle', $record1, $frameworkcode1);
        my $subtitle2 = GetRecordValue('subtitle', $record2, $frameworkcode1);

        if ($mergereference) {

            my $framework;
            if ($frameworkcode1 ne $frameworkcode2) {
                $framework = $input->param('frameworkcode')
                  or push @errors, "Famework not selected.";
            } else {
                $framework = $frameworkcode1;
            }

            # Getting MARC Structure
            my $tagslib = GetMarcStructure(1, $framework);

            my $notreference = ($biblionumber[0] == $mergereference) ? $biblionumber[1] : $biblionumber[0];

            # Creating a loop for display

            my $recordObj1 = new Koha::MetadataRecord({ 'record' => GetMarcBiblio($mergereference), 'schema' => lc C4::Context->preference('marcflavour') });
            my $recordObj2 = new Koha::MetadataRecord({ 'record' => GetMarcBiblio($notreference), 'schema' => lc C4::Context->preference('marcflavour') });

            my @record1 = $recordObj1->createMergeHash($tagslib);
            my @record2 = $recordObj2->createMergeHash($tagslib);

            # Parameters
            $template->param(
                biblio1 => $mergereference,
                biblio2 => $notreference,
                mergereference => $mergereference,
                record1 => @record1,
                record2 => @record2,
                framework => $framework,
            );
        }
        else {

        # Ask the user to choose which record will be the kept
            $template->param(
                choosereference => 1,
                biblio1 => $biblionumber[0],
                biblio2 => $biblionumber[1],
                title1 => $data1->{'title'},
                subtitle1 => $subtitle1,
                title2 => $data2->{'title'},
                subtitle2 => $subtitle2
            );
            if ($frameworkcode1 ne $frameworkcode2) {
                my $frameworks = getframeworks;
                my @frameworkselect;
                foreach my $thisframeworkcode ( keys %$frameworks ) {
                    my %row = (
                        value         => $thisframeworkcode,
                        frameworktext => $frameworks->{$thisframeworkcode}->{'frameworktext'},
                    );
                    if ($frameworkcode1 eq $thisframeworkcode){
                        $row{'selected'} = 1;
                        }
                    push @frameworkselect, \%row;
                }
                $template->param(
                    frameworkselect => \@frameworkselect,
                    frameworkcode1 => $frameworkcode1,
                    frameworkcode2 => $frameworkcode2,
                );
            }
        }
    }
}

if (@errors) {
    # Errors
    $template->param( errors  => \@errors );
}

output_html_with_http_headers $input, $cookie, $template->output;
exit;

=head1 FUNCTIONS

=cut

# ------------------------
# Functions
# ------------------------
