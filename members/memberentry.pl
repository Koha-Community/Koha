#!/usr/bin/perl

# Copyright 2006 SAN OUEST PROVENCE et Paul POULAIN
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

# pragma
use strict;

# external modules
use CGI;
# use Digest::MD5 qw(md5_base64);

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

use vars qw($debug);

BEGIN {
	$debug = $ENV{DEBUG} || 0;
}
	
my $input = new CGI;
($debug) or $debug = $input->param('debug') || 0;
my %data;

my $dbh = C4::Context->dbh;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/memberentrygen.tmpl",
           query => $input,
           type => "intranet",
           authnotrequired => 0,
           flagsrequired => {borrowers => 1},
           debug => ($debug) ? 1 : 0,
           });
my $guarantorid=$input->param('guarantorid');
my $borrowernumber=$input->param('borrowernumber');
my $actionType=$input->param('actionType') || '';
my $modify=$input->param('modify');
my $delete=$input->param('delete');
my $op=$input->param('op');
my $destination=$input->param('destination');
my $cardnumber=$input->param('cardnumber');
my $check_member=$input->param('check_member');
my $name_city=$input->param('name_city');
my $nodouble=$input->param('nodouble');
my $select_city=$input->param('select_city');
my $nok=$input->param('nok');
my $guarantorinfo=$input->param('guarantorinfo');
my $step=$input->param('step') || 0;
my @errors;
my $default_city;
# $check_categorytype contains the value of duplicate borrowers category type to redirect in good template in step =2
my $check_categorytype=$input->param('check_categorytype');
# NOTE: Alert for ethnicity and ethnotes fields, they are invalid in all borrowers form
my $borrower_data;
my $NoUpdateLogin;
my $userenv = C4::Context->userenv;

$template->param("uppercasesurnames" => C4::Context->preference('uppercasesurnames'));

# function to designate mandatory fields (visually with css)
my $check_BorrowerMandatoryField=C4::Context->preference("BorrowerMandatoryField");
my @field_check=split(/\|/,$check_BorrowerMandatoryField);
foreach (@field_check) {
	$template->param( "mandatory$_" => 1);    
}
$template->param("add"=>1) if ($op eq 'add');
$template->param("checked" => 1) if ($nodouble eq 1);
($borrower_data = GetMember($borrowernumber,'borrowernumber')) if ($op eq 'modify' or $op eq 'save');
my $categorycode = $input->param('categorycode') || $borrower_data->{'categorycode'};
my $category_type = $input->param('category_type');
my $new_c_type = $category_type; #if we have input param, then we've already chosen the cat_type.
unless ($category_type or !($categorycode)){
  my $borrowercategory= GetBorrowercategory($categorycode);
  $category_type = $borrowercategory->{'category_type'};
  my $category_name = $borrowercategory->{'description'}; 
  $template->param("categoryname"=>$category_name);
}
$category_type="A" unless $category_type; # FIXME we should display a error message instead of a 500 error !

# if a add or modify is requested => check validity of data.
%data = %$borrower_data if ($borrower_data);

my %newdata;	# comes from $input->param()
if ($op eq 'insert' || $op eq 'modify' || $op eq 'save') {
    my @names= ($borrower_data && $op ne 'save') ? keys %$borrower_data : $input->param();
    foreach my $key (@names) {
        $newdata{$key} = $input->param($key) if (defined $input->param($key));
        $newdata{$key} =~ s/\"/&quot;/gg unless $key eq 'borrowernotes' or $key eq 'opacnote';
    }
	my $dateobject = C4::Dates->new();
	my $syspref = $dateobject->regexp();		# same syspref format for all 3 dates
	my $iso     = $dateobject->regexp('iso');	# 
	foreach (qw(dateenrolled dateexpiry dateofbirth)) {
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
    if (ref($borrower_data) && ($borrower_data->{'category_type'} eq 'S') && ! (C4::Auth::haspermission($dbh,$userenv->{'id'},{'staffaccess'=>1})) )  {
		$NoUpdateLogin =1;
	}
}

#############test for member being unique #############
if ($op eq 'insert'){
        my $category_type_send=$category_type if ($category_type eq 'I'); 
        my $check_category; # recover the category code of the doublon suspect borrowers
			#   ($result,$categorycode) = checkuniquemember($collectivity,$surname,$firstname,$dateofbirth)
        ($check_member,$check_category) = checkuniquemember(
			$category_type_send, 
			($newdata{surname}     ? $newdata{surname}     : $data{surname}    ),
			($newdata{firstname}   ? $newdata{firstname}   : $data{firstname}  ),
			($newdata{dateofbirth} ? $newdata{dateofbirth} : $data{dateofbirth})
		);
          
  #   recover the category type if the borrowers is a doublon 
    if ($check_category) {
      my $tmpborrowercategory=GetBorrowercategory($check_category);
      $check_categorytype=$tmpborrowercategory->{'category_type'};
    }   
}

  #recover all data from guarantor address phone ,fax... 
if (($category_type eq 'C' || $category_type eq 'P') and $guarantorid ne '' ){
  my $guarantordata=GetMember($guarantorid);
  $guarantorinfo=$guarantordata->{'surname'}." , ".$guarantordata->{'firstname'};
  if (($data{'contactname'} eq '' or $data{'contactname'} ne $guarantordata->{'surname'})) {
    $data{'contactfirstname'}= $guarantordata->{'firstname'}; 
    $data{'contactname'}     = $guarantordata->{'surname'};
    $data{'contacttitle'}    = $guarantordata->{'title'};  
	  foreach (qw(streetnumber address streettype address2 zipcode city phone phonepro mobile fax email emailpro branchcode)) {
		$data{$_} = $guarantordata->{$_};
	}
  }
}

###############test to take the right zipcode and city name ##############
if ($guarantorid eq '') {
    # set only if parameter was passed from the form
    $newdata{'city'}    = $input->param('city')    if defined($input->param('city'));
    $newdata{'zipcode'} = $input->param('zipcode') if defined($input->param('zipcode'));
}

#builds default userid
if ( (defined $newdata{'userid'}) && ($newdata{'userid'} eq '')){
  my $onefirstnameletter = substr($data{'firstname'},0,1);
  my  $fivesurnameletter = substr($data{'surname'},0,9);
  $newdata{'userid'}=lc($onefirstnameletter.$fivesurnameletter);
}
  
$debug and warn join "\t", map {"$_: $newdata{$_}"} qw(dateofbirth dateenrolled dateexpiry);
my $loginexist=0;
my $extended_patron_attributes = ();
if ($op eq 'save' || $op eq 'insert'){
  if (checkcardnumber($newdata{cardnumber},$newdata{borrowernumber})){ 
    push @errors, 'ERROR_cardnumber';
  } 
  my $dateofbirthmandatory = (scalar grep {$_ eq "dateofbirth"} @field_check) ? 1 : 0;
  if ($newdata{dateofbirth} && $dateofbirthmandatory) {
    my $age = GetAge($newdata{dateofbirth});
    my $borrowercategory=GetBorrowercategory($newdata{'categorycode'});   
	my ($low,$high) = ($borrowercategory->{'dateofbirthrequired'}, $borrowercategory->{'upperagelimit'});
    if (($high && ($age > $high)) or ($age < $low)) {
      push @errors, 'ERROR_age_limitations';
	  $template->param('ERROR_age_limitations' => "$low to $high");
    }
  }
  if (C4::Context->preference("IndependantBranches")) {
    if ($userenv && $userenv->{flags} != 1){
      $debug and print STDERR "  $newdata{'branchcode'} : ".$userenv->{flags}.":".$userenv->{branch};
      unless (!$newdata{'branchcode'} || $userenv->{branch} eq $newdata{'branchcode'}){
        push @errors, "ERROR_branch";
      }
    }
  }
  # Check if the userid is unique
  unless (Check_Userid($newdata{'userid'},$borrowernumber)) {
    push @errors, "ERROR_login_exist";
    $loginexist=1; 
  }

  if (C4::Context->preference('ExtendedPatronAttributes')) {
    $extended_patron_attributes = parse_extended_patron_attributes($input);
    foreach my $attr (@$extended_patron_attributes) {
        unless (C4::Members::Attributes::CheckUniqueness($attr->{code}, $attr->{value}, $borrowernumber)) {
            push @errors, "ERROR_extended_unique_id_failed";
            $template->param(ERROR_extended_unique_id_failed => "$attr->{code}/$attr->{value}");
        }
    }
  }
}

if ($op eq 'modify' || $op eq 'insert'){
  unless ($newdata{'dateexpiry'}){
	my $arg2 = $newdata{'dateenrolled'} || C4::Dates->today('iso');
    $newdata{'dateexpiry'} = GetExpiryDate($newdata{'categorycode'},$arg2);
  }
}

###  Error checks should happen before this line.

$nok = $nok || scalar(@errors);
if ((!$nok) and ($op eq 'insert' or $op eq 'save')){
	$debug and warn "$op dates: " . join "\t", map {"$_: $newdata{$_}"} qw(dateofbirth dateenrolled dateexpiry);
	if ($op eq 'insert'){
		# we know it's not a duplicate borrowernumber or there would already be an error
        $borrowernumber = &AddMember(%newdata);

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
                my $letter = getletter ('members', "ACCTDETAILS:$newdata{'branchcode'}") ;
                # if $branch notice fails, then email a default notice instead.
                $letter = getletter ('members', "ACCTDETAILS")  if !$letter;
                SendAlerts ( 'members' , \%newdata , $letter ) if $letter
            }
        } 

		if ($data{'organisations'}){            
			# need to add the members organisations
			my @orgs=split(/\|/,$data{'organisations'});
			add_member_orgs($borrowernumber,\@orgs);
		}
        if (C4::Context->preference('ExtendedPatronAttributes') and $input->param('setting_extended_patron_attributes')) {
            C4::Members::Attributes::SetBorrowerAttributes($borrowernumber, $extended_patron_attributes);
        }
	} elsif ($op eq 'save'){ 
		if ($NoUpdateLogin) {
			delete $newdata{'password'};
			delete $newdata{'userid'};
		}
		&ModMember(%newdata);    
        if (C4::Context->preference('ExtendedPatronAttributes') and $input->param('setting_extended_patron_attributes')) {
            C4::Members::Attributes::SetBorrowerAttributes($borrowernumber, $extended_patron_attributes);
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

if ($nok){
  $op="add" if ($op eq "insert");
  $op="modify" if ($op eq "save");
  %data=%newdata; 
  $template->param( updtype => ($op eq 'add' ?'I':'M'));	# used to check for $op eq "insert"... but we just changed $op!
  unless ($step){  
    $template->param( step_1 => 1,step_2 => 1,step_3 => 1, step_4 => 1);
  }  
} 
if (C4::Context->preference("IndependantBranches")) {
  my $userenv = C4::Context->userenv;
  if ($userenv->{flags} != 1 && $data{branchcode}){
    unless ($userenv->{branch} eq $data{'branchcode'}){
      print $input->redirect("/cgi-bin/koha/members/members-home.pl");
	  exit;
    }
  }
}
if ($op eq 'add'){
	my $arg2 = $newdata{'dateenrolled'} || C4::Dates->today('iso');
	$data{'dateexpiry'} = GetExpiryDate($newdata{'categorycode'},$arg2);
	$template->param( updtype => 'I',step_1=>1,step_2=>1,step_3=>1, step_4 => 1);
	
} 
if ($op eq "modify")  {
  $template->param( updtype => 'M',modify => 1 );
  $template->param( step_1=>1,step_2=>1,step_3=>1, step_4 => 1) unless $step;
}
# my $cardnumber=$data{'cardnumber'};
$data{'cardnumber'}=fixup_cardnumber($data{'cardnumber'}) if $op eq 'add';
if ($data{'sex'} eq 'F'){
  $template->param(female => 1);
} elsif ($data{'sex'} eq 'M'){
    $template->param(male => 1);
} else {
    $template->param(none => 1);
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
foreach (qw(C A S P I X)) {
    my $action="WHERE category_type=?";
	($categories,$labels)=GetborCatFromCatType($_,$action);
	my @categoryloop;
	foreach my $cat (@$categories){
		push @categoryloop,{'categorycode' => $cat,
			  'categoryname' => $labels->{$cat},
			  'categorycodeselected' => ($cat eq $borrower_data->{'categorycode'} || $cat eq $categorycode),
		};
	}
	my %typehash;
	$typehash{'typename'}=$_;
	$typehash{'categoryloop'}=\@categoryloop;
	push @typeloop,{'typename' => $_,
	  'categoryloop' => \@categoryloop};
}  
$template->param('typeloop' => \@typeloop);

# test in city
$select_city=getidcity($data{'city'}) if ($guarantorid ne '0');
($default_city=$select_city) if ($step eq 0);
if ($select_city eq '' ){
	$default_city = &getidcity($data{'city'});
}
my($cityid);
($cityid,$name_city)=GetCities();
$template->param( city_cgipopup => 1) if ($cityid );
my $citypopup = CGI::popup_menu(-name=>'select_city',
        -id => 'select_city',
        -values=>$name_city,
        -labels=>$name_city,
        -default=>$default_city,
        );  
  
my $default_roadtype;
$default_roadtype=$data{'streettype'} ;
my($roadtypeid,$road_type)=GetRoadTypes();
  $template->param( road_cgipopup => 1) if ($roadtypeid );
my $roadpopup = CGI::popup_menu(-name=>'streettype',
        -id => 'streettype',
        -values=>$roadtypeid,
        -labels=>$road_type,
        -override => 1,
        -default=>$default_roadtype
        );  

my $default_borrowertitle;
$default_borrowertitle=$data{'title'} ;
my($borrowertitle)=GetTitles();
$template->param( title_cgipopup => 1) if ($borrowertitle);
my $borrotitlepopup = CGI::popup_menu(-name=>'title',
        -id => 'btitle',
        -values=>$borrowertitle,
        -override => 1,
        -default=>$default_borrowertitle
        );    

my @relationships = split /,|\|/,C4::Context->preference('BorrowerRelationship');
my @relshipdata;
while (@relationships) {
  my $relship = shift @relationships || '';
  my %row = ('relationship' => $relship);
  if ($data{'relationship'} eq $relship) {
    $row{'selected'}=' selected';
  } else {
    $row{'selected'}='';
  }
  push(@relshipdata, \%row);
}

my %flags = ( 'gonenoaddress' => ['gonenoaddress' ],
        'lost'          => ['lost'],
        'debarred'      => ['debarred']);

 
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

#get Branches
my @branches;
my @select_branch;
my %select_branches;

my $onlymine=(C4::Context->preference('IndependantBranches') && 
              C4::Context->userenv && 
              C4::Context->userenv->{flags} !=1  && 
              C4::Context->userenv->{branch}?1:0);
              
my $branches=GetBranches($onlymine);
my $default;

for my $branch (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches) {
    push @select_branch,$branch;
    $select_branches{$branch} = $branches->{$branch}->{'branchname'};
    $default = C4::Context->userenv->{'branch'} if (C4::Context->userenv && C4::Context->userenv->{'branch'});
}
# --------------------------------------------------------------------------------------------------------
  #in modify mod :default value from $CGIbranch comes from borrowers table
  #in add mod: default value come from branches table (ip correspendence)
$default=$data{'branchcode'}  if ($op eq 'modify' || ($op eq 'add' && $category_type eq 'C'));
my $CGIbranch = CGI::scrolling_list(-id    => 'branchcode',
            -name   => 'branchcode',
            -values => \@select_branch,
            -labels => \%select_branches,
            -size   => 1,
            -override => 1,  
            -multiple =>0,
            -default => $default,
        );
my $CGIorganisations;
my $member_of_institution;
if (C4::Context->preference("memberofinstitution")){
    my $organisations=get_institutions();
    my @orgs;
    my %org_labels;
    foreach my $organisation (keys %$organisations) {
        push @orgs,$organisation;
        $org_labels{$organisation}=$organisations->{$organisation}->{'surname'};
    }
    $member_of_institution=1;
    
    $CGIorganisations = CGI::scrolling_list( -id => 'organisations',
        -name     => 'organisations',
        -labels   => \%org_labels,
        -values   => \@orgs,
        -size     => 5,
        -multiple => 'true'

    );
}


# --------------------------------------------------------------------------------------------------------

my $CGIsort = buildCGIsort("Bsort1","sort1",$data{'sort1'});
if ($CGIsort) {
  $template->param(CGIsort1 => $CGIsort);
}
$template->param( sort1 => $data{'sort1'});		# shouldn't this be in an "else" statement like the 2nd one?

$CGIsort = buildCGIsort("Bsort2","sort2",$data{'sort2'});
if ($CGIsort) {
  $template->param(CGIsort2 => $CGIsort);
} else {
  $template->param( sort2 => $data{'sort2'});
}

if ($nok) {
    foreach my $error (@errors) {
        $template->param($error) || $template->param( $error => 1);
    }
    $template->param(nok => 1);
}
  
  #Formatting data for display    
  
if ($data{'dateenrolled'} eq ''){
  $data{'dateenrolled'}=C4::Dates->today('iso');
}
if (C4::Context->preference('uppercasesurnames')) {
	$data{'surname'}    =uc($data{'surname'}    );
	$data{'contactname'}=uc($data{'contactname'});
}
foreach (qw(dateenrolled dateexpiry dateofbirth)) {
	$data{$_} = format_date($data{$_});	# back to syspref for display
	$template->param( $_ => $data{$_});
}

if (C4::Context->preference('ExtendedPatronAttributes')) {
    $template->param(ExtendedPatronAttributes => 1);
    patron_attributes_form($template, $borrowernumber);
}

$template->param( "showguarantor"  => ($category_type=~/A|I|S|X/) ? 0 : 1); # associate with step to know where you are
$debug and warn "memberentry step: $step";
$template->param(%data);
$template->param( "step_$step"  => 1) if $step;	# associate with step to know where u are
$template->param(  step  => $step   ) if $step;	# associate with step to know where u are
$template->param( debug  => $debug  ) if $debug;
$template->param(
  BorrowerMandatoryField => C4::Context->preference("BorrowerMandatoryField"),#field to test with javascript
  category_type => $category_type,#to know the category type of the borrower
  DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
  select_city => $select_city,
  "$category_type"  => 1,# associate with step to know where u are
  destination   => $destination,#to know wher u come from and wher u must go in redirect
  check_member    => $check_member,#to know if the borrower already exist(=>1) or not (=>0) 
  flags   =>$data{'flags'},   
  "op$op"   => 1,
  nodouble  => $nodouble,
  borrowernumber  => $borrowernumber,#register number
  "contacttitle_".$data{'contacttitle'} => "SELECTED" ,
  guarantorid => $guarantorid,
  ethcatpopup => $ethcatpopup,
  relshiploop => \@relshipdata,
  citypopup => $citypopup,
  roadpopup => $roadpopup,  
  borrotitlepopup => $borrotitlepopup,
  guarantorinfo   => $guarantorinfo,
  flagloop  => \@flagdata,
  dateformat      => C4::Dates->new()->visual(),
  C4::Context->preference('dateformat') => 1,
  check_categorytype =>$check_categorytype,#to recover the category type with checkcategorytype function
  modify          => $modify,
  nok     => $nok,#flag to konw if an error 
  CGIbranch => $CGIbranch,
  memberofinstution => $member_of_institution,
  CGIorganisations => $CGIorganisations,
  NoUpdateLogin =>  $NoUpdateLogin
  );
  
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
        my $code = $input->param("${key}_code");
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

    # map patron's attributes into a more convenient structure
    my %attr_hash = ();
    foreach my $attr (@$attributes) {
        push @{ $attr_hash{$attr->{code}} }, $attr;
    }

    my @attribute_loop = ();
    my $i = 0;
    foreach my $type_code (map { $_->{code} } @types) {
        my $attr_type = C4::Members::AttributeTypes->fetch($type_code);
        my $entry = {
            code              => $attr_type->code(),
            description       => $attr_type->description(),
            repeatable        => $attr_type->repeatable(),
            password_allowed  => $attr_type->password_allowed(),
            category          => $attr_type->authorised_value_category(),
            password          => '',
        };
        if (exists $attr_hash{$attr_type->code()}) {
            foreach my $attr (@{ $attr_hash{$attr_type->code()} }) {
                my $newentry = { map { $_ => $entry->{$_} } %$entry };
                $newentry->{value} = $attr->{value};
                $newentry->{password} = $attr->{password};
                $newentry->{use_dropdown} = 0;
                if ($attr_type->authorised_value_category()) {
                    $newentry->{use_dropdown} = 1;
                    $newentry->{auth_val_loop} = GetAuthorisedValues($attr_type->authorised_value_category(), $attr->{value});
                }
                $i++;
                $newentry->{form_id} = "patron_attr_$i";
                #use Data::Dumper; die Dumper($entry) if  $entry->{use_dropdown};
                push @attribute_loop, $newentry;
            }
        } else {
            $i++;
            my $newentry = { map { $_ => $entry->{$_} } %$entry };
            if ($attr_type->authorised_value_category()) {
                $newentry->{use_dropdown} = 1;
                $newentry->{auth_val_loop} = GetAuthorisedValues($attr_type->authorised_value_category());
            }
            $newentry->{form_id} = "patron_attr_$i";
            push @attribute_loop, $newentry;
        }
    }
    $template->param(patron_attributes => \@attribute_loop);

}

# Local Variables:
# tab-width: 8
# End:
