#!/usr/bin/perl

# script to administer the systempref table
# written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

=head1 systempreferences.pl

ALGO :
 this script use an $op to know what to do.
 if $op is empty or none of the above values,
    - the default screen is build (with all records, or filtered datas).
    - the   user can clic on add, modify or delete record.
 if $op=add_form
    - if primkey exists, this is a modification,so we read the $primkey record
    - builds the add/modify form
 if $op=add_validate
    - the user has just send datas, so we create/modify the record
 if $op=delete_form
    - we show the record having primkey=$primkey and ask for deletion validation form
 if $op=delete_confirm
    - we delete the record having primkey=$primkey

=cut

use strict;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Koha;
use C4::Languages qw(getTranslatedLanguages);
use C4::ClassSource;
use C4::Log;
use C4::Output;

# use Smart::Comments;


# FIXME, shouldnt we store this stuff in the systempreferences table? 

# FIXME: This uses hash in a backwards way.  What we really want is:
# 		$tabsysprefs{key} = $array_ref;
# 				like
# 		$tabsysprefs{Cataloguing} = [qw(autoBarcode ISBD marc ...)];
#
# 	Because some things *should* be on more than one tab.
# 	And the tabname is the unique part (the key).

my %tabsysprefs;
# Acquisitions
    $tabsysprefs{acquisitions}="Acquisitions";
    $tabsysprefs{gist}="Acquisitions";
    $tabsysprefs{emailPurchaseSuggestions}="Acquisitions";
	$tabsysprefs{RenewSerialAddsSuggestion}="Acquisitions";
    $tabsysprefs{serialsadditems}="Acquisitions";

# Admin
    $tabsysprefs{singleBranchMode}="Admin";
    $tabsysprefs{staffClientBaseURL}="Admin";
    $tabsysprefs{Version}="Admin";
    $tabsysprefs{OpacMaintenance}="Admin";
    $tabsysprefs{FrameworksLoaded}="Admin";
    $tabsysprefs{libraryAddress}="Admin";
    $tabsysprefs{delimiter}="Admin";
    $tabsysprefs{IndependantBranches}="Admin";
    $tabsysprefs{insecure}="Admin";
    $tabsysprefs{KohaAdmin}="Admin";
    $tabsysprefs{KohaAdminEmailAddress}="Admin";
    $tabsysprefs{MIME}="Admin";
    $tabsysprefs{timeout}="Admin";
    $tabsysprefs{Intranet_includes}="Admin";
    $tabsysprefs{AutoLocation}="Admin";
    $tabsysprefs{DebugLevel}="Admin";
    $tabsysprefs{SessionStorage}="Admin";
    $tabsysprefs{noItemTypeImages}="Admin";
    $tabsysprefs{OPACBaseURL}="Admin";
    $tabsysprefs{GranularPermissions}="Admin";

# Authorities
    $tabsysprefs{authoritysep}="Authorities";
    $tabsysprefs{AuthDisplayHierarchy}="Authorities";
    $tabsysprefs{dontmerge}="Authorities";
    $tabsysprefs{BiblioAddsAuthorities}="Authorities";
# Cataloguing
    $tabsysprefs{advancedMARCEditor}="Cataloguing";
    $tabsysprefs{autoBarcode}="Cataloguing";
    $tabsysprefs{hide_marc}="Cataloguing";
    $tabsysprefs{IntranetBiblioDefaultView} = "Cataloguing";
    $tabsysprefs{ISBD}="Cataloguing";
    $tabsysprefs{itemcallnumber}="Cataloguing";
    $tabsysprefs{LabelMARCView}="Cataloguing";
    $tabsysprefs{marc}="Cataloguing";
    $tabsysprefs{marcflavour}="Cataloguing";
    $tabsysprefs{MARCOrgCode}="Cataloguing";
    $tabsysprefs{z3950AuthorAuthFields}="Cataloguing";
    $tabsysprefs{z3950NormalizeAuthor}="Cataloguing";
    $tabsysprefs{Stemming}="Cataloguing";
    $tabsysprefs{WeightFields}="Cataloguing";
    $tabsysprefs{NoZebra}="Cataloguing";
    $tabsysprefs{NoZebraIndexes}="Cataloguing";
    $tabsysprefs{ReceiveBackIssues}="Cataloguing";
    $tabsysprefs{DefaultClassificationSource}="Cataloguing";
    $tabsysprefs{RoutingSerials}="Cataloguing";
    $tabsysprefs{'item-level_itypes'}="Cataloguing";

# Circulation
    $tabsysprefs{maxoutstanding}="Circulation";
    $tabsysprefs{maxreserves}="Circulation";
    $tabsysprefs{noissuescharge}="Circulation";
    $tabsysprefs{IssuingInProcess}="Circulation";
    $tabsysprefs{patronimages}="Circulation";
    $tabsysprefs{printcirculationslips}="Circulation";
    $tabsysprefs{ReturnBeforeExpiry}="Circulation";
    $tabsysprefs{SpecifyDueDate}="Circulation";
    $tabsysprefs{AutomaticItemReturn}="Circulation";
    $tabsysprefs{ReservesMaxPickUpDelay}="Circulation";
    $tabsysprefs{TransfersMaxDaysWarning}="Circulation";
    $tabsysprefs{useDaysMode}="Circulation";
    $tabsysprefs{ReservesNeedReturns}="Circulation";
    $tabsysprefs{CircAutocompl}="Circulation";
    $tabsysprefs{canreservefromotherbranches}="Circulation";
    $tabsysprefs{finesMode}="Circulation";
    $tabsysprefs{emailLibrarianWhenHoldIsPlaced}="Circulation";
    $tabsysprefs{globalDueDate}="Circulation";
    $tabsysprefs{holdCancelLength}="Circulation";
    $tabsysprefs{itemBarcodeInputFilter}="Circulation";
    $tabsysprefs{noOPACHolds}="Circulation";
    $tabsysprefs{WebBasedSelfCheck}="Circulation";
    $tabsysprefs{CircControl}="Circulation";
    $tabsysprefs{finesCalendar}="Circulation";
    $tabsysprefs{previousIssuesDefaultSortOrder}="Circulation";
    $tabsysprefs{todaysIssuesDefaultSortOrder}="Circulation";
    $tabsysprefs{HomeOrHoldingBranch}="Circulation";
	$tabsysprefs{RandomizeHoldsQueueWeight}="Circulation";
	$tabsysprefs{StaticHoldsQueueWeight}="Circulation";
    $tabsysprefs{AllowOnShelfHolds}="Circulation";
    $tabsysprefs{AllowHoldsOnDamagedItems}="Circulation";

# Staff Client
    $tabsysprefs{TemplateEncoding}="StaffClient";
    $tabsysprefs{template}="StaffClient";
    $tabsysprefs{intranetstylesheet}="StaffClient";
    $tabsysprefs{IntranetNav}="StaffClient";
    $tabsysprefs{intranetcolorstylesheet}="StaffClient";
    $tabsysprefs{intranetuserjs}="StaffClient";
    $tabsysprefs{yuipath}="StaffClient";
    $tabsysprefs{IntranetmainUserblock}="StaffClient";
    
# Patrons
    $tabsysprefs{autoMemberNum}="Patrons";
    $tabsysprefs{checkdigit}="Patrons";
    $tabsysprefs{intranetreadinghistory}="Patrons";
    $tabsysprefs{NotifyBorrowerDeparture}="Patrons";
    $tabsysprefs{memberofinstitution}="Patrons";
    $tabsysprefs{ReadingHistory}="Patrons";
    $tabsysprefs{BorrowerMandatoryField}="Patrons";
    $tabsysprefs{borrowerRelationship}="Patrons";
    $tabsysprefs{BorrowersTitles}="Patrons";    
    $tabsysprefs{patronimages}="Patrons";
    $tabsysprefs{MinPasswordLength}="Patrons";
    $tabsysprefs{uppercasesurnames}="Patrons";
    $tabsysprefs{NoReturnSetLost}="Patrons";
    $tabsysprefs{MaxFine}="Patrons";
    $tabsysprefs{NotifyBorrowerDeparture}="Patrons";
    $tabsysprefs{AddPatronLists}="Patrons";
    $tabsysprefs{PatronsPerPage}="Patrons";
    $tabsysprefs{ExtendedPatronAttributes}="Patrons";
    $tabsysprefs{AutoEmailOpacUser}="Patrons";
    $tabsysprefs{AutoEmailPrimaryAddress}="Patrons";
    $tabsysprefs{EnhancedMessagingPreferences}="Patrons";

# I18N/L10N
    $tabsysprefs{dateformat}="I18N/L10N";
    $tabsysprefs{opaclanguages}="I18N/L10N";
    $tabsysprefs{opacthemes}="I18N/L10N";
    $tabsysprefs{language}="I18N/L10N";

# Searching
    $tabsysprefs{defaultSortField}="Searching";
    $tabsysprefs{defaultSortOrder}="Searching";
    $tabsysprefs{maxItemsInSearchResults}="Searching";
    $tabsysprefs{numSearchResults}="Searching";
    $tabsysprefs{OPACdefaultSortField}="Searching";
    $tabsysprefs{OPACdefaultSortOrder}="Searching";
    $tabsysprefs{OPACItemsResultsDisplay}="Searching";
    $tabsysprefs{OPACnumSearchResults}="Searching";
    $tabsysprefs{QueryFuzzy}="Searching";
    $tabsysprefs{QueryStemming}="Searching";
    $tabsysprefs{QueryWeightFields}="Searching";
    $tabsysprefs{expandedSearchOption}="Searching";
    $tabsysprefs{sortbynonfiling}="Searching";
    $tabsysprefs{QueryAutoTruncate}="Searching";
    $tabsysprefs{QueryRemoveStopwords}="Searching";
    $tabsysprefs{AdvancedSearchTypes}="Searching";

# EnhancedContent
   $tabsysprefs{AmazonContent}="EnhancedContent";
   $tabsysprefs{AWSAccessKeyID}="EnhancedContent";
   $tabsysprefs{AmazonLocale}="EnhancedContent";
   $tabsysprefs{AmazonAssocTag}="EnhancedContent";
   $tabsysprefs{AmazonSimilarItems}="EnhancedContent";
   $tabsysprefs{OPACAmazonContent}="EnhancedContent";
   $tabsysprefs{OPACAmazonSimilarItems}="EnhancedContent";

# Baker & Taylor 
   $tabsysprefs{BakerTaylorBookstoreURL} = 'EnhancedContent';
   $tabsysprefs{BakerTaylorEnabled}      = 'EnhancedContent';
   $tabsysprefs{BakerTaylorPassword}     = 'EnhancedContent';
   $tabsysprefs{BakerTaylorUsername}     = 'EnhancedContent';
# FRBR    
   $tabsysprefs{FRBRizeEditions}="EnhancedContent";
   $tabsysprefs{XISBN}="EnhancedContent";
   $tabsysprefs{OCLCAffiliateID}="EnhancedContent";
   $tabsysprefs{XISBNDailyLimit}="EnhancedContent";
   $tabsysprefs{PINESISBN}="EnhancedContent";
   $tabsysprefs{ThingISBN}="EnhancedContent";
   $tabsysprefs{OPACFRBRizeEditions}="EnhancedContent";
# Tags
   $tabsysprefs{TagsEnabled}            = 'EnhancedContent';
   $tabsysprefs{TagsExternalDictionary} = 'EnhancedContent';
   $tabsysprefs{TagsInputOnDetail}      = 'EnhancedContent';
   $tabsysprefs{TagsInputOnList}        = 'EnhancedContent';
   $tabsysprefs{TagsShowOnDetail}       = 'EnhancedContent';
   $tabsysprefs{TagsShowOnList}         = 'EnhancedContent';
   $tabsysprefs{TagsModeration}         = 'EnhancedContent';
   $tabsysprefs{GoogleJackets} 			= 'EnhancedContent';
   $tabsysprefs{AuthorisedValueImages}  = "EnhancedContent";

# OPAC
    $tabsysprefs{BiblioDefaultView}="OPAC";
    $tabsysprefs{LibraryName}="OPAC";
    $tabsysprefs{opaccolorstylesheet}="OPAC";
    $tabsysprefs{opaccredits}="OPAC";
    $tabsysprefs{opaclargeimage}="OPAC";
    $tabsysprefs{opaclayoutstylesheet}="OPAC";
    $tabsysprefs{OpacNav}="OPAC";
    $tabsysprefs{opacsmallimage}="OPAC";
    $tabsysprefs{opacstylesheet}="OPAC";
    $tabsysprefs{opacthemes}="OPAC";
    $tabsysprefs{opacuserjs}="OPAC";
    $tabsysprefs{SubscriptionHistory}="OPAC";
    $tabsysprefs{opacheader}="OPAC";
    $tabsysprefs{noOPACUserLogin}="OPAC";
    $tabsysprefs{hideBiblioNumber}="OPAC";
    $tabsysprefs{OPACDisplayExtendedSubInfo}="OPAC";
    $tabsysprefs{OpacMainUserBlock}="OPAC";
    $tabsysprefs{OPACSubscriptionDisplay}="OPAC";
    $tabsysprefs{OPACURLOpenInNewWindow}="OPAC";
    $tabsysprefs{OPACUserCSS}="OPAC";
    $tabsysprefs{OPACHighlightedWords}="OPAC";
    $tabsysprefs{OPACViewOthersSuggestions}="OPAC";
    $tabsysprefs{URLLinkText}="OPAC";
    $tabsysprefs{OPACShelfBrowser}="OPAC";

# OPAC
    $tabsysprefs{SearchMyLibraryFirst}="OPAC";
    $tabsysprefs{Disable_Dictionary}="OPAC";
    $tabsysprefs{hidelostitems}="OPAC";
    $tabsysprefs{opacbookbag}="OPAC";
    $tabsysprefs{opaclanguagesdisplay}="OPAC";
    $tabsysprefs{OpacPasswordChange}="OPAC";
    $tabsysprefs{opacreadinghistory}="OPAC";
    $tabsysprefs{virtualshelves}="OPAC";
    $tabsysprefs{RequestOnOpac}="OPAC";
    $tabsysprefs{reviewson}="OPAC";
    $tabsysprefs{OpacTopissues}="OPAC";
    $tabsysprefs{OpacAuthorities}="OPAC";
    $tabsysprefs{OpacCloud}="OPAC";
    $tabsysprefs{opacuserlogin}="OPAC";
    $tabsysprefs{AnonSuggestions}="OPAC";
    $tabsysprefs{suggestion}="OPAC";
    $tabsysprefs{OpacTopissue}="OPAC";
    $tabsysprefs{OpacBrowser}="OPAC";
    $tabsysprefs{kohaspsuggest} = "OPAC";
    $tabsysprefs{OpacRenewalAllowed} = "OPAC";
    $tabsysprefs{OPACItemHolds} = "OPAC";
    $tabsysprefs{OPACGroupResults}="OPAC";
    $tabsysprefs{XSLTDetailsDisplay}="OPAC";
    $tabsysprefs{XSLTResultsDisplay}="OPAC";

# LOGFeatures
    $tabsysprefs{CataloguingLog}  = "Logs";
    $tabsysprefs{BorrowersLog}    = "Logs";
    $tabsysprefs{SubscriptionLog} = "Logs";
    $tabsysprefs{IssueLog}        = "Logs";
    $tabsysprefs{ReturnLog}       = "Logs";
    $tabsysprefs{LetterLog}       = "Logs";
    $tabsysprefs{FinesLog}        = "Logs";
    
# OAI-PMH variables
   $tabsysprefs{'OAI-PMH'}           = "OAI-PMH";
   $tabsysprefs{'OAI-PMH:archiveID'} = "OAI-PMH";
   $tabsysprefs{'OAI-PMH:MaxCount'}  = "OAI-PMH";
   $tabsysprefs{'OAI-PMH:Set'}       = "OAI-PMH";
   $tabsysprefs{'OAI-PMH:Subset'}    = "OAI-PMH";

sub StringSearch  {
    my ($searchstring,$type)=@_;
    my $dbh = C4::Context->dbh;
    $searchstring=~ s/\'/\\\'/g;
    my @data=split(' ',$searchstring);
    my $count=@data;
    my @results;
    my $cnt=0;

    # used for doing a plain-old sys-pref search
    if ($type eq 'all' ){
        my $sth=$dbh->prepare("SELECT * FROM systempreferences 
                WHERE variable LIKE ? OR explanation LIKE ? 
                ORDER BY VARIABLE");
        $sth->execute("%$searchstring%", "%$searchstring%");
        while (my $data=$sth->fetchrow_hashref){
            $data->{value} =~ s/</&lt;/g;
            $data->{value} =~ s/>/&gt;/g;
            $data->{value}=substr($data->{value},0,60)."..." if length($data->{value}) >60;
            push(@results,$data);
            $cnt++;
        }
        $sth->finish;

    }  elsif ($type){
        foreach my $syspref (sort { lc $a cmp lc $b } keys %tabsysprefs){
            if ($tabsysprefs{$syspref} eq $type){
                my $sth=$dbh->prepare("Select variable,value,explanation,type,options from systempreferences where (variable like ?) order by variable");
                $sth->execute($syspref);
                while (my $data=$sth->fetchrow_hashref){
                    $data->{value} =~ s/</&lt;/g;
                    $data->{value} =~ s/>/&gt;/g;
                    $data->{value}=substr($data->{value},0,60)."..." if length($data->{value}) >60;
                    push(@results,$data);
                    $cnt++;
                }
                $sth->finish;
            }
        }
    } else {
        my $strsth ="Select variable,value,explanation,type,options from systempreferences where variable not in (";
        foreach my $syspref (keys %tabsysprefs){
            $strsth .= $dbh->quote($syspref).",";
        }
        $strsth =~ s/,$/) /;
        $strsth .= " order by variable";
        my $sth=$dbh->prepare($strsth);
        $sth->execute();
        while (my $data=$sth->fetchrow_hashref){
            $data->{value}=substr($data->{value},0,60);
            push(@results,$data);
            $cnt++;
        }
        $sth->finish;
    }
    return ($cnt,\@results);
}

my $input = new CGI;
my $searchfield = $input->param('searchfield');
my $Tvalue = $input->param('Tvalue');
my $offset = $input->param('offset');
my $script_name="/cgi-bin/koha/admin/systempreferences.pl";

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "admin/systempreferences.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {parameters => 1},
                 debug => 1,
                 });
my $pagesize=100;
my $op = $input->param('op');
$searchfield=~ s/\,//g;

if ($op) {
$template->param(script_name => $script_name,
                        $op              => 1); # we show only the TMPL_VAR names $op
} else {
$template->param(script_name => $script_name,
                        else              => 1); # we show only the TMPL_VAR names $op
}

if ($op eq 'update_and_reedit') {
    foreach ($input->param) {
    }
    my $value='';
    if (my $currentorder=$input->param('currentorder')) {
        my @currentorder=split /\|/, $currentorder;
        my $orderchanged=0;
        foreach my $param ($input->param) {
            if ($param=~m#up-(\d+).x#) {
                my $temp=$currentorder[$1];
                $currentorder[$1]=$currentorder[$1-1];
                $currentorder[$1-1]=$temp;
                $orderchanged=1;
                last;
            } elsif ($param=~m#down-(\d+).x#) {
                my $temp=$currentorder[$1];
                $currentorder[$1]=$currentorder[$1+1];
                $currentorder[$1+1]=$temp;
                $orderchanged=1;
                last;
            }
        }
        $value=join ' ', @currentorder;
        if ($orderchanged) {
            $op='add_form';
            $template->param(script_name => $script_name,
                            $op              => 1); # we show only the TMPL_VAR names $op
        } else {
            $op='';
            $searchfield='';
            $template->param(script_name => $script_name,
                            else              => 1); # we show only the TMPL_VAR names $op
        }
    }
    my $dbh = C4::Context->dbh;
    my $query="select * from systempreferences where variable=?";
    my $sth=$dbh->prepare($query);
    $sth->execute($input->param('variable'));
    if ($sth->rows) {
        unless (C4::Context->config('demo') eq 1) {
            my $sth=$dbh->prepare("update systempreferences set value=?,explanation=?,type=?,options=? where variable=?");
            $sth->execute($value, $input->param('explanation'), $input->param('variable'), $input->param('preftype'), $input->param('prefoptions'));
            $sth->finish;
			warn "logaction !! mod ";
			logaction('SYSTEMPREFERENCE','MODIFY',undef, $input->param('variable') . " | " . $value );
        }
    } else {
        unless (C4::Context->config('demo') eq 1) {
            my $sth=$dbh->prepare("insert into systempreferences (variable,value,explanation) values (?,?,?,?,?)");
            $sth->execute($input->param('variable'), $input->param('value'), $input->param('explanation'), $input->param('preftype'), $input->param('prefoptions'));
            $sth->finish;
			warn "logaction !! add ";
			logaction('SYSTEMPREFERENCE','ADD',undef, $input->param('variable') . " | " . $input->param('value') );
        }
    }
    $sth->finish;

}

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record

if ($op eq 'add_form') {
    #---- if primkey exists, it's a modify action, so read values to modify...
    my $data;
    if ($searchfield) {
        my $dbh = C4::Context->dbh;
        my $sth=$dbh->prepare("select variable,value,explanation,type,options from systempreferences where variable=?");
        $sth->execute($searchfield);
        $data=$sth->fetchrow_hashref;
        $sth->finish;
        $template->param(modify => 1);
        # save tab to return to if user cancels edit
        $template->param(return_tab => $tabsysprefs{$searchfield});
    }

    my @options;
    foreach my $option (split(/\|/, $data->{'options'})) {
        my $selected='0';
        $option eq $data->{'value'} and $selected=1;
        push @options, { option => $option, selected => $selected };
    }
    if ($data->{'type'} eq 'Choice') {
        $template->param('type-choice' => 1);
    } elsif ($data->{'type'} eq 'YesNo') {
        $template->param('type-yesno' => 1);
        $data->{'value'}=C4::Context->boolean_preference($data->{'variable'});
        ($data->{'value'} eq '1') ? ($template->param('value-yes'=>1)) : ($template->param('value-no'=>1));
    } elsif ($data->{'type'} eq 'Integer') {
        $template->param('type-free' => 1);
        $template->param('fieldlength' => $data->{'options'});
    } elsif ($data->{'type'} eq 'Textarea') {
        $template->param('type-textarea' => 1);
        $data->{options} =~ /(.*)\|(.*)/;
        $template->param('cols' => $1, 'rows' => $2);;
    } elsif ($data->{'type'} eq 'Float') {
        $template->param('type-free' => 1);
        $template->param('fieldlength' => $data->{'options'});
    } elsif ($data->{'type'} eq 'Themes') {
        $template->param('type-choice' => 1);
        my $type='';
        ($data->{'variable'}=~m#opac#i) ? ($type='opac') : ($type='intranet');
        @options=();
        my $currently_selected_themes;
        my $counter=0;
        foreach my $theme (split /\s+/, $data->{'value'}) {
            push @options, { option => $theme, counter => $counter };
            $currently_selected_themes->{$theme}=1;
            $counter++;
        }
        foreach my $theme (getallthemes($type)) {
            my $selected='0';
            next if $currently_selected_themes->{$theme};
            push @options, { option => $theme, counter => $counter };
            $counter++;
        }
    } elsif ($data->{'type'} eq 'ClassSources') {
        $template->param('type-choice' => 1);
        my $type='';
        @options=();
        my $sources = GetClassSources();
        my $counter=0;
        foreach my $cn_source (sort keys %$sources) {
            if ($cn_source eq $data->{'value'}) {
                push @options, { option => $cn_source, counter => $counter, selected => 1 };
            } else {
                push @options, { option => $cn_source, counter => $counter };
            }
            $counter++; 
        }
    } elsif ($data->{'type'} eq 'Languages') {
	my $currently_selected_languages;
        foreach my $language (split /\s+/, $data->{'value'}) {
            $currently_selected_languages->{$language}=1;
        }
	# current language
        my $lang = $template->param('lang');
        my $theme;
	my $interface;
	if ($data->{'variable'} =~ /opac/) {
		# this is the OPAC
		$interface = 'opac';
        	$theme = C4::Context->preference('opacthemes');
	}
	else {
		# this is the staff client	
		$interface = 'intranet';
		$theme = C4::Context->preference('template');
	}
	my $languages_loop = getTranslatedLanguages($interface,$theme,$lang,$currently_selected_languages);

    	$template->param('languages_loop' => $languages_loop);
        $template->param('type-langselector' => 1);
    } else {
        $template->param('type-free' => 1);
        $template->param('fieldlength' => $data->{'options'}>0?$data->{'options'}:60);
    }
    $template->param(explanation => $data->{'explanation'},
             value => $data->{'value'},
             type => $data->{'type'},
             options => \@options,
             preftype => $data->{'type'},
             prefoptions => $data->{'options'},
             searchfield => $searchfield);

################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select * from systempreferences where variable=?");
    $sth->execute($input->param('variable'));
    # to handle multiple values
    my $value;
    # handle multiple value strings (separated by ',')
    my $params = $input->Vars;
    my @values = split("\0",$params->{'value'}) if $params->{'value'};
    for my $vl (@values) {
    	$value .= "$vl,";
    }
    $value =~ s/,$//;
    if ($sth->rows) {
        unless (C4::Context->config('demo') eq 1) {
            my $sth=$dbh->prepare("update systempreferences set value=?,explanation=?,type=?,options=? where variable=?");
            $sth->execute($value, $input->param('explanation'), $input->param('preftype'), $input->param('prefoptions'), $input->param('variable'));
            $sth->finish;
			logaction('SYSTEMPREFERENCE','MODIFY',undef, $input->param('variable') . " | " . $value );
        }
    } else {
        unless (C4::Context->config('demo') eq 1) {
            my $sth=$dbh->prepare("insert into systempreferences (variable,value,explanation,type,options) values (?,?,?,?,?)");
            $sth->execute($input->param('variable'), $value, $input->param('explanation'), $input->param('preftype'), $input->param('prefoptions'));
            $sth->finish;
			logaction('SYSTEMPREFERENCE','ADD',undef, $input->param('variable') . " | " . $value );
        }
    }
    $sth->finish;
    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=systempreferences.pl?tab=".$tabsysprefs{$input->param('variable')}."\"></html>";
    exit;
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select variable,value,explanation,type,options from systempreferences where variable=?");
    $sth->execute($searchfield);
    my $data=$sth->fetchrow_hashref;
    $sth->finish;
    $template->param(searchfield => $searchfield,
                            Tvalue => $data->{'value'},
                            );

                                                    # END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("delete from systempreferences where variable=?");
    $sth->execute($searchfield);
	my $logstring =  $searchfield . " | " . $Tvalue ;
	logaction('SYSTEMPREFERENCE','DELETE',undef,$logstring);
    $sth->finish;

                                                    # END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
    #Adding tab management for system preferences
    my $tab=$input->param('tab');
    $template->param($tab => 1);
    my ($count,$results)=StringSearch($searchfield,$tab);
    my $toggle=0;
    my @loop_data = ();
    for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
          if ($toggle eq 0){
            $toggle=1;
          } else {
            $toggle=0;
          }
        my %row_data;  # get a fresh hash for the row data
        $row_data{variable} = $results->[$i]{'variable'};
        $row_data{value} = $results->[$i]{'value'};
        $row_data{yes} = 1 if ($results->[$i]{'value'} == 1);
        $row_data{yesno} = 1 if ($results->[$i]{'type'} eq 'YesNo');
        $row_data{explanation} = $results->[$i]{'explanation'};
        $row_data{toggle} = $toggle;
        $row_data{edit} = "$script_name?op=add_form&amp;searchfield=".$results->[$i]{'variable'};
        $row_data{delete} = "$script_name?op=delete_confirm&amp;searchfield=".$results->[$i]{'variable'};
        push(@loop_data, \%row_data);
    }
    $tab=($tab?$tab:"Local Use");
    $template->param(loop => \@loop_data, $tab => 1);
    if ($offset>0) {
        my $prevpage = $offset-$pagesize;
        $template->param("<a href=$script_name?offset=".$prevpage.'&lt;&lt; Prev</a>');
    }
    if ($offset+$pagesize<$count) {
        my $nextpage =$offset+$pagesize;
        $template->param("a href=$script_name?offset=".$nextpage.'Next &gt;&gt;</a>');
    }
    $template->param(        tab => $tab,
            );
} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;
