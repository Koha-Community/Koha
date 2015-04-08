#!/usr/bin/perl

# Copyright 2006 SAN OUEST PROVENCE et Paul POULAIN
# Copyright 2010 BibLibre
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

# pragma
use strict;
use warnings;

# external modules
use CGI;
# use Digest::MD5 qw(md5_base64);
use List::MoreUtils qw/uniq/;

# internal modules
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Members;
use C4::Members::Attributes;
use C4::Members::AttributeTypes;
use C4::Koha;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Input;
use C4::Log;
use C4::Letters;
use C4::Branch; # GetBranches
use C4::Form::MessagingPreferences;
use Koha::Borrower::Debarments;
use Koha::DateUtils;
use Module::Load;
if ( C4::Context->preference('NorwegianPatronDBEnable') && C4::Context->preference('NorwegianPatronDBEnable') == 1 ) {
    load Koha::NorwegianPatronDB, qw( NLGetSyncDataFromBorrowernumber );
}

use vars qw($debug);

BEGIN {
	$debug = $ENV{DEBUG} || 0;
}
	
my $input = new CGI;
($debug) or $debug = $input->param('debug') || 0;
my %data;

my $dbh = C4::Context->dbh;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/memberentrygen.tt",
           query => $input,
           type => "intranet",
           authnotrequired => 0,
           flagsrequired => {borrowers => 1},
           debug => ($debug) ? 1 : 0,
       });

my $guarantorid    = $input->param('guarantorid');
my $borrowernumber = $input->param('borrowernumber');
my $actionType     = $input->param('actionType') || '';
my $modify         = $input->param('modify');
my $delete         = $input->param('delete');
my $op             = $input->param('op');
my $destination    = $input->param('destination');
my $cardnumber     = $input->param('cardnumber');
my $check_member   = $input->param('check_member');
my $nodouble       = $input->param('nodouble');
my $duplicate      = $input->param('duplicate');
$nodouble = 1 if ($op eq 'modify' or $op eq 'duplicate');    # FIXME hack to represent fact that if we're
                                     # modifying an existing patron, it ipso facto
                                     # isn't a duplicate.  Marking FIXME because this
                                     # script needs to be refactored.
my $select_city   = $input->param('select_city');
my $nok           = $input->param('nok');
my $guarantorinfo = $input->param('guarantorinfo');
my $step          = $input->param('step') || 0;
my @errors;
my $default_city;
# $check_categorytype contains the value of duplicate borrowers category type to redirect in good template in step =2
my $check_categorytype=$input->param('check_categorytype');
# NOTE: Alert for ethnicity and ethnotes fields, they are invalid in all borrowers form
my $borrower_data;
my $NoUpdateLogin;
my $userenv = C4::Context->userenv;


## Deal with debarments
$template->param(
    debarments => GetDebarments( { borrowernumber => $borrowernumber } ) );
my @debarments_to_remove = $input->param('remove_debarment');
foreach my $d ( @debarments_to_remove ) {
    DelDebarment( $d );
}
if ( $input->param('add_debarment') ) {

    my $expiration = $input->param('debarred_expiration');
    $expiration =
      $expiration
      ? output_pref(
        { 'dt' => dt_from_string($expiration), 'dateformat' => 'iso' } )
      : undef;

    AddDebarment(
        {
            borrowernumber => $borrowernumber,
            type           => 'MANUAL',
            comment        => $input->param('debarred_comment'),
            expiration     => $expiration,
        }
    );
}

$template->param("uppercasesurnames" => C4::Context->preference('uppercasesurnames'));

my $minpw = C4::Context->preference('minPasswordLength');
$template->param("minPasswordLength" => $minpw);

# function to designate mandatory fields (visually with css)
my $check_BorrowerMandatoryField=C4::Context->preference("BorrowerMandatoryField");
my @field_check=split(/\|/,$check_BorrowerMandatoryField);
foreach (@field_check) {
	$template->param( "mandatory$_" => 1);    
}
# we'll need this, later.
my $dateofbirthmandatory = (scalar grep {$_ eq "dateofbirth"} @field_check) ? 1 : 0;
# function to designate unwanted fields
my $check_BorrowerUnwantedField=C4::Context->preference("BorrowerUnwantedField");
@field_check=split(/\|/,$check_BorrowerUnwantedField);
foreach (@field_check) {
    next unless m/\w/o;
	$template->param( "no$_" => 1);
}
$template->param( "add" => 1 ) if ( $op eq 'add' );
$template->param( "duplicate" => 1 ) if ( $op eq 'duplicate' );
$template->param( "checked" => 1 ) if ( defined($nodouble) && $nodouble eq 1 );
( $borrower_data = GetMember( 'borrowernumber' => $borrowernumber ) ) if ( $op eq 'modify' or $op eq 'save' or $op eq 'duplicate' );
my $categorycode  = $input->param('categorycode') || $borrower_data->{'categorycode'};
my $category_type = $input->param('category_type') || '';
if ($category_type){
    $template->{VARS}->{'type_only'} = 1;
}
my $new_c_type = $category_type; #if we have input param, then we've already chosen the cat_type.
unless ($category_type or !($categorycode)){
    my $borrowercategory = GetBorrowercategory($categorycode);
    $category_type    = $borrowercategory->{'category_type'};
    my $category_name = $borrowercategory->{'description'}; 
    $template->param("categoryname"=>$category_name);
 }
$category_type="A" unless $category_type; # FIXME we should display a error message instead of a 500 error !

# if a add or modify is requested => check validity of data.
%data = %$borrower_data if ($borrower_data);

# initialize %newdata
my %newdata;                                                                             # comes from $input->param()
if ( $op eq 'insert' || $op eq 'modify' || $op eq 'save' || $op eq 'duplicate' ) {
    my @names = ( $borrower_data && $op ne 'save' ) ? keys %$borrower_data : $input->param();
    foreach my $key (@names) {
        if (defined $input->param($key)) {
            $newdata{$key} = $input->param($key);
            $newdata{$key} =~ s/\"/&quot;/g unless $key eq 'borrowernotes' or $key eq 'opacnote';
        }
    }

    my $dateobject = C4::Dates->new();
    my $syspref = $dateobject->regexp();		# same syspref format for all 3 dates
    my $iso     = $dateobject->regexp('iso');	#
    foreach (qw(dateenrolled dateexpiry dateofbirth)) {
        next unless exists $newdata{$_};
        my $userdate = $newdata{$_} or next;
        if ($userdate =~ /$syspref/) {
            $newdata{$_} = format_date_in_iso($userdate);	# if they match syspref format, then convert to ISO
        } elsif ($userdate =~ /$iso/) {
            warn "Date $_ ($userdate) is already in ISO format";
        } else {
            ($userdate eq '0000-00-00') and warn "Data error: $_ is '0000-00-00'";
            $template->param( "ERROR_$_" => 1 );	# else ERROR!
            push(@errors,"ERROR_$_");
        }
    }
  # check permission to modify login info.
    if (ref($borrower_data) && ($borrower_data->{'category_type'} eq 'S') && ! (C4::Auth::haspermission($userenv->{'id'},{'staffaccess'=>1})) )  {
        $NoUpdateLogin = 1;
    }
}

# remove keys from %newdata that ModMember() doesn't like
{
    my @keys_to_delete = (
        qr/^BorrowerMandatoryField$/,
        qr/^category_type$/,
        qr/^check_member$/,
        qr/^destination$/,
        qr/^nodouble$/,
        qr/^op$/,
        qr/^save$/,
        qr/^updtype$/,
        qr/^SMSnumber$/,
        qr/^setting_extended_patron_attributes$/,
        qr/^setting_messaging_prefs$/,
        qr/^digest$/,
        qr/^modify$/,
        qr/^step$/,
        qr/^\d+$/,
        qr/^\d+-DAYS/,
        qr/^patron_attr_/,
    );
    for my $regexp (@keys_to_delete) {
        for (keys %newdata) {
            delete($newdata{$_}) if /$regexp/;
        }
    }
}

#############test for member being unique #############
if ( ( $op eq 'insert' ) and !$nodouble ) {
    my $category_type_send;
    if ( $category_type eq 'I' ) {
        $category_type_send = $category_type;
    }
    my $check_category;    # recover the category code of the doublon suspect borrowers
     #   ($result,$categorycode) = checkuniquemember($collectivity,$surname,$firstname,$dateofbirth)
    ( $check_member, $check_category ) = checkuniquemember(
        $category_type_send,
        ( $newdata{surname}     ? $newdata{surname}     : $data{surname} ),
        ( $newdata{firstname}   ? $newdata{firstname}   : $data{firstname} ),
        ( $newdata{dateofbirth} ? $newdata{dateofbirth} : $data{dateofbirth} )
    );
    if ( !$check_member ) {
        $nodouble = 1;
    }

    #   recover the category type if the borrowers is a doublon
    if ($check_category) {
        my $tmpborrowercategory = GetBorrowercategory($check_category);
        $check_categorytype = $tmpborrowercategory->{'category_type'};
    }
}

  #recover all data from guarantor address phone ,fax... 
if ( $guarantorid and ( $category_type eq 'C' || $category_type eq 'P' )) {
    if (my $guarantordata=GetMember(borrowernumber => $guarantorid)) {
        $guarantorinfo=$guarantordata->{'surname'}." , ".$guarantordata->{'firstname'};
        $newdata{'contactfirstname'}= $guarantordata->{'firstname'};
        $newdata{'contactname'}     = $guarantordata->{'surname'};
        $newdata{'contacttitle'}    = $guarantordata->{'title'};
        if ( $op eq 'add' ) {
	        foreach (qw(streetnumber address streettype address2
                        zipcode country city state phone phonepro mobile fax email emailpro branchcode
                        B_streetnumber B_streettype B_address B_address2
                        B_city B_state B_zipcode B_country B_email B_phone)) {
		        $newdata{$_} = $guarantordata->{$_};
	        }
        }
    }
}

###############test to take the right zipcode, country and city name ##############
# set only if parameter was passed from the form
$newdata{'city'}    = $input->param('city')    if defined($input->param('city'));
$newdata{'zipcode'} = $input->param('zipcode') if defined($input->param('zipcode'));
$newdata{'country'} = $input->param('country') if defined($input->param('country'));

#builds default userid
if ( (defined $newdata{'userid'}) && ($newdata{'userid'} eq '')){
    if ( ( defined $newdata{'firstname'} ) && ( defined $newdata{'surname'} ) ) {
        # Full page edit, firstname and surname input zones are present
        $newdata{'userid'} = Generate_Userid( $borrowernumber, $newdata{'firstname'}, $newdata{'surname'} );
    }
    elsif ( ( defined $data{'firstname'} ) && ( defined $data{'surname'} ) ) {
        # Partial page edit (access through "Details"/"Library details" tab), firstname and surname input zones are not used
        # Still, if the userid field is erased, we can create a new userid with available firstname and surname
        $newdata{'userid'} = Generate_Userid( $borrowernumber, $data{'firstname'}, $data{'surname'} );
    }
    else {
        $newdata{'userid'} = $data{'userid'};
    }
}
  
$debug and warn join "\t", map {"$_: $newdata{$_}"} qw(dateofbirth dateenrolled dateexpiry);
my $extended_patron_attributes = ();
if ($op eq 'save' || $op eq 'insert'){
    # If the cardnumber is blank, treat it as null.
    $newdata{'cardnumber'} = undef if $newdata{'cardnumber'} =~ /^\s*$/;

    if (my $error_code = checkcardnumber($newdata{cardnumber},$newdata{borrowernumber})){
        push @errors, $error_code == 1
            ? 'ERROR_cardnumber_already_exists'
            : $error_code == 2
                ? 'ERROR_cardnumber_length'
                : ()
    }

    if ($newdata{dateofbirth} && $dateofbirthmandatory) {
        my $age = GetAge($newdata{dateofbirth});
        my $borrowercategory=GetBorrowercategory($newdata{'categorycode'});   
        my ($low,$high) = ($borrowercategory->{'dateofbirthrequired'}, $borrowercategory->{'upperagelimit'});
        if (($high && ($age > $high)) or ($age < $low)) {
            push @errors, 'ERROR_age_limitations';
            $template->param( age_low => $low);
            $template->param( age_high => $high);
        }
    }
  
    if($newdata{surname} && C4::Context->preference('uppercasesurnames')) {
        $newdata{'surname'} = uc($newdata{'surname'});
    }

  if (C4::Context->preference("IndependentBranches")) {
    unless ( C4::Context->IsSuperLibrarian() ){
      $debug and print STDERR "  $newdata{'branchcode'} : ".$userenv->{flags}.":".$userenv->{branch};
      unless (!$newdata{'branchcode'} || $userenv->{branch} eq $newdata{'branchcode'}){
        push @errors, "ERROR_branch";
      }
    }
  }
  # Check if the 'userid' is unique. 'userid' might not always be present in
  # the edited values list when editing certain sub-forms. Get it straight
  # from the DB if absent.
  my $userid = $newdata{ userid } // $borrower_data->{ userid };
  unless (Check_Userid($userid,$borrowernumber)) {
    push @errors, "ERROR_login_exist";
  }
  
  my $password = $input->param('password');
  my $password2 = $input->param('password2');
  push @errors, "ERROR_password_mismatch" if ( $password ne $password2 );
  push @errors, "ERROR_short_password" if( $password && $minpw && $password ne '****' && (length($password) < $minpw) );

  if (C4::Context->preference('ExtendedPatronAttributes')) {
    $extended_patron_attributes = parse_extended_patron_attributes($input);
    foreach my $attr (@$extended_patron_attributes) {
        unless (C4::Members::Attributes::CheckUniqueness($attr->{code}, $attr->{value}, $borrowernumber)) {
            my $attr_info = C4::Members::AttributeTypes->fetch($attr->{code});
            push @errors, "ERROR_extended_unique_id_failed";
            $template->param(
                ERROR_extended_unique_id_failed_code => $attr->{code},
                ERROR_extended_unique_id_failed_value => $attr->{value},
                ERROR_extended_unique_id_failed_description => $attr_info->description()
            );
        }
    }
  }
}

if ( ($op eq 'modify' || $op eq 'insert' || $op eq 'save'|| $op eq 'duplicate') and ($step == 0 or $step == 3 )){
    unless ($newdata{'dateexpiry'}){
        my $arg2 = $newdata{'dateenrolled'} || C4::Dates->today('iso');
        $newdata{'dateexpiry'} = GetExpiryDate($newdata{'categorycode'},$arg2);
    }
}

if (
        defined $input->param('SMSnumber')
    &&  (
           $input->param('SMSnumber') eq ""
        or $input->param('SMSnumber') ne $newdata{'mobile'}
        )
) {
    $newdata{smsalertnumber} = $input->param('SMSnumber');
}

###  Error checks should happen before this line.
$nok = $nok || scalar(@errors);
if ((!$nok) and $nodouble and ($op eq 'insert' or $op eq 'save')){
	$debug and warn "$op dates: " . join "\t", map {"$_: $newdata{$_}"} qw(dateofbirth dateenrolled dateexpiry);
	if ($op eq 'insert'){
		# we know it's not a duplicate borrowernumber or there would already be an error
        $borrowernumber = &AddMember(%newdata);
        $newdata{'borrowernumber'} = $borrowernumber;

        # If 'AutoEmailOpacUser' syspref is on, email user their account details from the 'notice' that matches the user's branchcode.
        if ( C4::Context->preference("AutoEmailOpacUser") == 1 && $newdata{'userid'}  && $newdata{'password'}) {
            #look for defined primary email address, if blank - attempt to use borr.email and borr.emailpro instead
            my $emailaddr;
            if  (C4::Context->preference("AutoEmailPrimaryAddress") ne 'OFF'  && 
                $newdata{C4::Context->preference("AutoEmailPrimaryAddress")} =~  /\w\@\w/ ) {
                $emailaddr =   $newdata{C4::Context->preference("AutoEmailPrimaryAddress")} 
            } 
            elsif ($newdata{email} =~ /\w\@\w/) {
                $emailaddr = $newdata{email} 
            }
            elsif ($newdata{emailpro} =~ /\w\@\w/) {
                $emailaddr = $newdata{emailpro} 
            }
            elsif ($newdata{B_email} =~ /\w\@\w/) {
                $emailaddr = $newdata{B_email} 
            }
            # if we manage to find a valid email address, send notice 
            if ($emailaddr) {
                $newdata{emailaddr} = $emailaddr;
                my $err;
                eval {
                    $err = SendAlerts ( 'members', \%newdata, "ACCTDETAILS" );
                };
                if ( $@ ) {
                    $template->param(error_alert => $@);
                } elsif ( ref($err) eq "HASH" && defined $err->{error} and $err->{error} eq "no_email" ) {
                    $template->{VARS}->{'error_alert'} = "no_email";
                } else {
                    $template->{VARS}->{'info_alert'} = 1;
                }
            }
        }

        if (C4::Context->preference('ExtendedPatronAttributes') and $input->param('setting_extended_patron_attributes')) {
            C4::Members::Attributes::SetBorrowerAttributes($borrowernumber, $extended_patron_attributes);
        }
        if (C4::Context->preference('EnhancedMessagingPreferences') and $input->param('setting_messaging_prefs')) {
            C4::Form::MessagingPreferences::handle_form_action($input, { borrowernumber => $borrowernumber }, $template, 1, $newdata{'categorycode'});
        }
        # Try to do the live sync with the Norwegian national patron database, if it is enabled
        if ( exists $data{'borrowernumber'} && C4::Context->preference('NorwegianPatronDBEnable') && C4::Context->preference('NorwegianPatronDBEnable') == 1 ) {
            NLSync({ 'borrowernumber' => $borrowernumber });
        }
	} elsif ($op eq 'save'){ 
		if ($NoUpdateLogin) {
			delete $newdata{'password'};
			delete $newdata{'userid'};
		}
        &ModMember(%newdata) unless scalar(keys %newdata) <= 1; # bug 4508 - avoid crash if we're not
                                                                # updating any columns in the borrowers table,
                                                                # which can happen if we're only editing the
                                                                # patron attributes or messaging preferences sections
        if (C4::Context->preference('ExtendedPatronAttributes') and $input->param('setting_extended_patron_attributes')) {
            C4::Members::Attributes::SetBorrowerAttributes($borrowernumber, $extended_patron_attributes);
        }
        if (C4::Context->preference('EnhancedMessagingPreferences') and $input->param('setting_messaging_prefs')) {
            C4::Form::MessagingPreferences::handle_form_action($input, { borrowernumber => $borrowernumber }, $template);
        }
	}
	print scalar ($destination eq "circ") ? 
		$input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber") :
		$input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber") ;
	exit;		# You can only send 1 redirect!  After that, content or other headers don't matter.
}

if ($delete){
	print $input->redirect("/cgi-bin/koha/deletemem.pl?member=$borrowernumber");
	exit;		# same as above
}

if ($nok or !$nodouble){
    $op="add" if ($op eq "insert");
    $op="modify" if ($op eq "save");
    %data=%newdata; 
    $template->param( updtype => ($op eq 'add' ?'I':'M'));	# used to check for $op eq "insert"... but we just changed $op!
    unless ($step){  
        $template->param( step_1 => 1,step_2 => 1,step_3 => 1, step_4 => 1, step_5 => 1, step_6 => 1);
    }  
} 
if (C4::Context->preference("IndependentBranches")) {
    my $userenv = C4::Context->userenv;
    if ( !C4::Context->IsSuperLibrarian() && $data{'branchcode'} ) {
        unless ($userenv->{branch} eq $data{'branchcode'}){
            print $input->redirect("/cgi-bin/koha/members/members-home.pl");
            exit;
        }
    }
}
if ($op eq 'add'){
    $template->param( updtype => 'I', step_1=>1, step_2=>1, step_3=>1, step_4=>1, step_5 => 1, step_6 => 1);
}
if ($op eq "modify")  {
    $template->param( updtype => 'M',modify => 1 );
    $template->param( step_1=>1, step_2=>1, step_3=>1, step_4=>1, step_5 => 1, step_6 => 1) unless $step;
    if ( $step == 4 ) {
        $template->param( categorycode => $borrower_data->{'categorycode'} );
    }
    # Add sync data to the user data
    if ( C4::Context->preference('NorwegianPatronDBEnable') && C4::Context->preference('NorwegianPatronDBEnable') == 1 ) {
        my $sync = NLGetSyncDataFromBorrowernumber( $borrowernumber );
        if ( $sync ) {
            $template->param(
                sync => $sync->sync,
            );
        }
    }
}
if ( $op eq "duplicate" ) {
    $template->param( updtype => 'I' );
    $template->param( step_1 => 1, step_2 => 1, step_3 => 1, step_4 => 1, step_5 => 1, step_6 => 1 ) unless $step;
    $data{'cardnumber'} = "";
}

$data{'cardnumber'}=fixup_cardnumber($data{'cardnumber'}) if ( ( $op eq 'add' ) or ( $op eq 'duplicate' ) );
if(!defined($data{'sex'})){
    $template->param( none => 1);
} elsif($data{'sex'} eq 'F'){
    $template->param( female => 1);
} elsif ($data{'sex'} eq 'M'){
    $template->param(  male => 1);
} else {
    $template->param(  none => 1);
}

##Now all the data to modify a member.
my ($categories,$labels)=ethnicitycategories();
  
my $ethnicitycategoriescount=$#{$categories};
my $ethcatpopup;
if ($ethnicitycategoriescount>=0) {
  $ethcatpopup = CGI::popup_menu(-name=>'ethnicity',
        -id => 'ethnicity',
        -tabindex=>'',
        -values=>$categories,
        -default=>$data{'ethnicity'},
        -labels=>$labels);
  $template->param(ethcatpopup => $ethcatpopup); # bad style, has to be fixed
}

my @typeloop;
my $no_categories = 1;
my $no_add;
foreach (qw(C A S P I X)) {
    my $action="WHERE category_type=?";
	($categories,$labels)=GetborCatFromCatType($_,$action);
    if(scalar(@$categories) > 0){ $no_categories = 0; }
	my @categoryloop;
	foreach my $cat (@$categories){
		push @categoryloop,{'categorycode' => $cat,
			  'categoryname' => $labels->{$cat},
			  'categorycodeselected' => ((defined($borrower_data->{'categorycode'}) && 
                                                     $cat eq $borrower_data->{'categorycode'}) 
                                                     || (defined($categorycode) && $cat eq $categorycode)),
		};
	}
	my %typehash;
	$typehash{'typename'}=$_;
    my $typedescription = "typename_".$typehash{'typename'};
	$typehash{'categoryloop'}=\@categoryloop;
	push @typeloop,{'typename' => $_,
        $typedescription => 1,
	  'categoryloop' => \@categoryloop};
}
$template->param('typeloop' => \@typeloop,
        no_categories => $no_categories);
if($no_categories){ $no_add = 1; }
# test in city
if ( $guarantorid ) {
    $select_city = getidcity($data{city});
}
($default_city=$select_city) if ($step eq 0);
if (!defined($select_city) or $select_city eq '' ){
	$default_city = &getidcity($data{'city'});
}

my $city_arrayref = GetCities();
if (@{$city_arrayref} ) {
    $template->param( city_cgipopup => 1);

    if ($default_city) { # flag the current or default val
        for my $city ( @{$city_arrayref} ) {
            if ($default_city == $city->{cityid}) {
                $city->{selected} = 1;
                last;
            }
        }
    }
}
  
my $roadtypes = C4::Koha::GetAuthorisedValues( 'ROADTYPE', $data{streettype} );
$template->param( roadtypes => $roadtypes);

my $default_borrowertitle = '';
unless ( $op eq 'duplicate' ) { $default_borrowertitle=$data{'title'} }
my($borrowertitle)=GetTitles();
$template->param( title_cgipopup => 1) if ($borrowertitle);
my $borrotitlepopup = CGI::popup_menu(-name=>'title',
        -id => 'btitle',
        -values=>$borrowertitle,
        -override => 1,
        -default=>$default_borrowertitle
        );    

my @relationships = split /,|\|/, C4::Context->preference('borrowerRelationship');
my @relshipdata;
while (@relationships) {
  my $relship = shift @relationships || '';
  my %row = ('relationship' => $relship);
  if (defined($data{'relationship'}) and $data{'relationship'} eq $relship) {
    $row{'selected'}=' selected';
  } else {
    $row{'selected'}='';
  }
  push(@relshipdata, \%row);
}

my %flags = ( 'gonenoaddress' => ['gonenoaddress' ],
        'lost'          => ['lost']);

 
my @flagdata;
foreach (keys(%flags)) {
	my $key = $_;
	my %row =  ('key'   => $key,
		    'name'  => $flags{$key}[0]);
	if ($data{$key}) {
		$row{'yes'}=' checked';
		$row{'no'}='';
    }
	else {
		$row{'yes'}='';
		$row{'no'}=' checked';
	}
	push @flagdata,\%row;
}

# get Branch Loop
# in modify mod: userbranch value for GetBranchesLoop() comes from borrowers table
# in add    mod: userbranch value come from branches table (ip correspondence)

my $userbranch = '';
if (C4::Context->userenv && C4::Context->userenv->{'branch'}) {
    $userbranch = C4::Context->userenv->{'branch'};
}

if (defined ($data{'branchcode'}) and ( $op eq 'modify' || $op eq 'duplicate' || ( $op eq 'add' && $category_type eq 'C' ) )) {
    $userbranch = $data{'branchcode'};
}

my $branchloop = GetBranchesLoop( $userbranch );

if( !$branchloop ){
    $no_add = 1;
    $template->param(no_branches => 1);
}
if($no_categories){
    $no_add = 1;
    $template->param(no_categories => 1);
}
$template->param(no_add => $no_add);
# --------------------------------------------------------------------------------------------------------

$template->param( sort1 => $data{'sort1'});
$template->param( sort2 => $data{'sort2'});

if ($nok) {
    foreach my $error (@errors) {
        $template->param($error) || $template->param( $error => 1);
    }
    $template->param(nok => 1);
}
  
  #Formatting data for display    
  
if (!defined($data{'dateenrolled'}) or $data{'dateenrolled'} eq ''){
  $data{'dateenrolled'}=C4::Dates->today('iso');
}
if ( $op eq 'duplicate' ) {
    $data{'dateenrolled'} = C4::Dates->today('iso');
    $data{'dateexpiry'} = GetExpiryDate( $data{'categorycode'}, $data{'dateenrolled'} );
}
if (C4::Context->preference('uppercasesurnames')) {
    $data{'surname'} &&= uc( $data{'surname'} );
    $data{'contactname'} &&= uc( $data{'contactname'} );
}

foreach (qw(dateenrolled dateexpiry dateofbirth)) {
	$data{$_} = format_date($data{$_});	# back to syspref for display
	$template->param( $_ => $data{$_});
}

if (C4::Context->preference('ExtendedPatronAttributes')) {
    $template->param(ExtendedPatronAttributes => 1);
    patron_attributes_form($template, $borrowernumber);
}

if (C4::Context->preference('EnhancedMessagingPreferences')) {
    if ($op eq 'add') {
        C4::Form::MessagingPreferences::set_form_values({ categorycode => $categorycode }, $template);
    } else {
        C4::Form::MessagingPreferences::set_form_values({ borrowernumber => $borrowernumber }, $template);
    }
    $template->param(SMSSendDriver => C4::Context->preference("SMSSendDriver"));
    $template->param(SMSnumber     => defined $data{'smsalertnumber'} ? $data{'smsalertnumber'} : $data{'mobile'});
    $template->param(TalkingTechItivaPhone => C4::Context->preference("TalkingTechItivaPhoneNotification"));
}

$template->param( "showguarantor"  => ($category_type=~/A|I|S|X/) ? 0 : 1); # associate with step to know where you are
$debug and warn "memberentry step: $step";
$template->param(%data);
$template->param( "step_$step"  => 1) if $step;	# associate with step to know where u are
$template->param(  step  => $step   ) if $step;	# associate with step to know where u are

$template->param(
  BorrowerMandatoryField => C4::Context->preference("BorrowerMandatoryField"),#field to test with javascript
  category_type => $category_type,#to know the category type of the borrower
  select_city => $select_city,
  "$category_type"  => 1,# associate with step to know where u are
  destination   => $destination,#to know wher u come from and wher u must go in redirect
  check_member    => $check_member,#to know if the borrower already exist(=>1) or not (=>0) 
  "op$op"   => 1);

$template->param( branchloop => $branchloop ) if ( $branchloop );
$template->param(
  nodouble  => $nodouble,
  borrowernumber  => $borrowernumber, #register number
  guarantorid => ($borrower_data->{'guarantorid'} || $guarantorid),
  ethcatpopup => $ethcatpopup,
  relshiploop => \@relshipdata,
  city_loop => $city_arrayref,
  borrotitlepopup => $borrotitlepopup,
  guarantorinfo   => $guarantorinfo,
  flagloop  => \@flagdata,
  check_categorytype =>$check_categorytype,#to recover the category type with checkcategorytype function
  category_type =>$category_type,
  modify          => $modify,
  nok     => $nok,#flag to konw if an error 
  NoUpdateLogin =>  $NoUpdateLogin
  );

if(defined($data{'flags'})){
  $template->param(flags=>$data{'flags'});
}
if(defined($data{'contacttitle'})){
  $template->param("contacttitle_" . $data{'contacttitle'} => "SELECTED");
}


my ( $min, $max ) = C4::Members::get_cardnumber_length();
if ( defined $min ) {
    $template->param(
        minlength_cardnumber => $min,
        maxlength_cardnumber => $max
    );
}

output_html_with_http_headers $input, $cookie, $template->output;

sub  parse_extended_patron_attributes {
    my ($input) = @_;
    my @patron_attr = grep { /^patron_attr_\d+$/ } $input->param();

    my @attr = ();
    my %dups = ();
    foreach my $key (@patron_attr) {
        my $value = $input->param($key);
        next unless defined($value) and $value ne '';
        my $password = $input->param("${key}_password");
        my $code     = $input->param("${key}_code");
        next if exists $dups{$code}->{$value};
        $dups{$code}->{$value} = 1;
        push @attr, { code => $code, value => $value, password => $password };
    }
    return \@attr;
}

sub patron_attributes_form {
    my $template = shift;
    my $borrowernumber = shift;

    my @types = C4::Members::AttributeTypes::GetAttributeTypes();
    if (scalar(@types) == 0) {
        $template->param(no_patron_attribute_types => 1);
        return;
    }
    my $attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
    my @classes = uniq( map {$_->{class}} @$attributes );
    @classes = sort @classes;

    # map patron's attributes into a more convenient structure
    my %attr_hash = ();
    foreach my $attr (@$attributes) {
        push @{ $attr_hash{$attr->{code}} }, $attr;
    }

    my @attribute_loop = ();
    my $i = 0;
    my %items_by_class;
    foreach my $type_code (map { $_->{code} } @types) {
        my $attr_type = C4::Members::AttributeTypes->fetch($type_code);
        my $entry = {
            class             => $attr_type->class(),
            code              => $attr_type->code(),
            description       => $attr_type->description(),
            repeatable        => $attr_type->repeatable(),
            password_allowed  => $attr_type->password_allowed(),
            category          => $attr_type->authorised_value_category(),
            category_code     => $attr_type->category_code(),
            password          => '',
        };
        if (exists $attr_hash{$attr_type->code()}) {
            foreach my $attr (@{ $attr_hash{$attr_type->code()} }) {
                my $newentry = { %$entry };
                $newentry->{value} = $attr->{value};
                $newentry->{password} = $attr->{password};
                $newentry->{use_dropdown} = 0;
                if ($attr_type->authorised_value_category()) {
                    $newentry->{use_dropdown} = 1;
                    $newentry->{auth_val_loop} = GetAuthorisedValues($attr_type->authorised_value_category(), $attr->{value});
                }
                $i++;
                $newentry->{form_id} = "patron_attr_$i";
                push @{$items_by_class{$attr_type->class()}}, $newentry;
            }
        } else {
            $i++;
            my $newentry = { %$entry };
            if ($attr_type->authorised_value_category()) {
                $newentry->{use_dropdown} = 1;
                $newentry->{auth_val_loop} = GetAuthorisedValues($attr_type->authorised_value_category());
            }
            $newentry->{form_id} = "patron_attr_$i";
            push @{$items_by_class{$attr_type->class()}}, $newentry;
        }
    }
    while ( my ($class, @items) = each %items_by_class ) {
        my $lib = GetAuthorisedValueByCode( 'PA_CLASS', $class ) || $class;
        push @attribute_loop, {
            class => $class,
            items => @items,
            lib   => $lib,
        }
    }

    $template->param(patron_attributes => \@attribute_loop);

}

# Local Variables:
# tab-width: 8
# End:
