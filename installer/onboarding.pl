#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2017 Catalyst IT
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

#Recommended pragmas
use Modern::Perl;
use diagnostics;
use C4::InstallAuth;
use CGI qw ( -utf8 );
use C4::Output;
use C4::Members;
use Koha::Patrons;
use Koha::Libraries;
use Koha::Database;
use Koha::DateUtils;
use Koha::Patron::Categories;
use Koha::Patron::Category;
use Koha::ItemTypes;
use Koha::IssuingRule;
use Koha::IssuingRules;

#Setting variables
my $input = new CGI;
my $step  = $input->param('step');

#Getting the appropriate template to display to the user
my ( $template, $loggedinuser, $cookie ) =
  C4::InstallAuth::get_template_and_user(
    {
        template_name => "/onboarding/onboardingstep"
          . ( $step ? $step : 1 ) . ".tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        debug           => 1,
    }
  );

#Check database connection
my %info;
$info{'dbname'} = C4::Context->config("database");
$info{'dbms'}   = (
      C4::Context->config("db_scheme")
    ? C4::Context->config("db_scheme")
    : "mysql"
);

$info{'hostname'} = C4::Context->config("hostname");
$info{'port'}     = C4::Context->config("port");
$info{'user'}     = C4::Context->config("user");
$info{'password'} = C4::Context->config("pass");
my $dbh = DBI->connect(
    "DBI:$info{dbms}:dbname=$info{dbname};host=$info{hostname}"
      . ( $info{port} ? ";port=$info{port}" : "" ),
    $info{'user'}, $info{'password'}
);

#Store the value of the template input name='op' in the variable $op so we can check if the user has pressed the button with the name="op" and value="finish" meaning the user has finished the onboarding tool.
my $op = $input->param('op') || '';
$template->param( 'op' => $op );

my $schema = Koha::Database->new()->schema();

if ( $op && $op eq 'finish' )
{ #If the value of $op equals 'finish' then redirect user to /cgi-bin/koha/mainpage.pl
    print $input->redirect("/cgi-bin/koha/mainpage.pl");
    exit;
}

my $libraries = Koha::Libraries->search( {}, { order_by => ['branchcode'] }, );
$template->param(
     libraries   => $libraries,
     group_types => [
     {
            categorytype => 'searchdomain',
            categories   => [
               Koha::LibraryCategories->search(
                   { categorytype => 'searchdomain' }
               )
            ],
     },
     {
            categorytype => 'properties',
            categories   => [
               Koha::LibraryCategories->search(
                   { categorytype => 'properties' }
               )
            ],
     },
     ]
);


#Select all the patron category records in the categories database table and give them to the template
    my $categories = Koha::Patron::Categories->search();
    $template->param( 'categories' => $categories, );

#Check if the $step variable equals 1 i.e. the user has clicked to create a library in the create library screen 1
    my $itemtypes = Koha::ItemTypes->search();
    $template->param( 'itemtypes' => $itemtypes, );

if ( $step && $step == 1 ) {
    #store inputted parameters in variables
    my $branchcode = $input->param('branchcode');
    $branchcode = uc($branchcode);
    my $categorycode = $input->param('categorycode');
    my $op = $input->param('op') || 'list';
    my $message;
    my $library;

    #Take the text 'branchname' and store it in the @fields array
    my @fields = qw(
      branchname
    );

    $template->param( 'branchcode' => $branchcode );
    $branchcode =~ s|\s||g
      ; # Use a regular expression to check the value of the inputted branchcode

#Create a new library object and store the branchcode and @fields array values in this new library object
    $library = Koha::Library->new(
        {
            branchcode => $branchcode,
            ( map { $_ => scalar $input->param($_) || undef } @fields )
        }
    );

    eval { $library->store; }; #Use the eval{} function to store the library object
    if ($library) {
        $message = 'success_on_insert';
    }
    else {
        $message = 'error_on_insert';
    }
    $template->param( 'message' => $message );

#Check if the $step variable equals 2 i.e. the user has clicked to create a patron category in the create patron category screen 1
}
elsif ( $step && $step == 2 ) {
    if ($op eq "add_validate_category"){
        #Initialising values
        my $searchfield  = $input->param('description') // q||;
        my $categorycode = $input->param('categorycode');
        my $op           = $input->param('op') // 'list';
        my $message;
        my $category;
        $template->param( 'categorycode' => $categorycode );

        my ( $template, $loggedinuser, $cookie ) =
            C4::InstallAuth::get_template_and_user(
            {
                template_name   => "/onboarding/onboardingstep2.tt",
                query           => $input,
                type            => "intranet",
                authnotrequired => 0,
                flagsrequired =>
                { parameters => 'parameters_remaining_permissions' },
                debug => 1,
            }
            );

        #Once the user submits the page, this code validates the input and adds it
        #to the database as a new patron category
        $categorycode = $input->param('categorycode');
        my $description           = $input->param('description');
        my $overduenoticerequired = $input->param('overduenoticerequired');
        my $category_type         = $input->param('category_type');
        my $default_privacy       = $input->param('default_privacy');
        my $enrolmentperiod       = $input->param('enrolmentperiod');
        my $enrolmentperioddate   = $input->param('enrolmentperioddate') || undef;

        #Converts the string into a date format
        if ($enrolmentperioddate) {
            $enrolmentperioddate = output_pref(
                {
                    dt         => dt_from_string($enrolmentperioddate),
                    dateformat => 'iso',
                    dateonly   => 1,
                }
            );
        }

        #Adds a new patron category to the database
        $category = Koha::Patron::Category->new(
            {
                categorycode          => $categorycode,
                description           => $description,
                overduenoticerequired => $overduenoticerequired,
                category_type         => $category_type,
                default_privacy       => $default_privacy,
                enrolmentperiod       => $enrolmentperiod,
                enrolmentperioddate   => $enrolmentperioddate,
            }
        );

        eval { $category->store; };

        #Error messages
        if ($category) {
            $message = 'success_on_insert';
        }
        else {
            $message = 'error_on_insert';
        }

        $template->param( 'message' => $message );
    }
    #Create a patron
}
elsif ( $step && $step == 3 ) {
    my $firstpassword  = $input->param('password') || '';
    my $secondpassword = $input->param('password2') || '';


    #Find all patron records in the database and hand them to the template
    my %currentpatrons = Koha::Patrons->search();
    my $currentpatrons = values %currentpatrons;
    $template->param( 'patrons' =>$currentpatrons);


#Find all library records in the database and hand them to the template to display in the library dropdown box
    my $libraries =
      Koha::Libraries->search( {}, { order_by => ['branchcode'] }, );
    $template->param(
        libraries   => $libraries,
        group_types => [
            {
                categorytype => 'searchdomain',
                categories   => [
                    Koha::LibraryCategories->search(
                        { categorytype => 'searchdomain' }
                    )
                ],
            },
            {
                categorytype => 'properties',
                categories   => [
                    Koha::LibraryCategories->search(
                        { categorytype => 'properties' }
                    )
                ],
            },
        ]
    );

#Find all patron categories in the database and hand them to the template to display in the patron category dropdown box
    my $categories = Koha::Patron::Categories->search();
    $template->param( 'categories' => $categories, );

#Incrementing the highest existing patron cardnumber to prevent duplicate cardnumber entry

    my $existing_cardnumber = $schema->resultset('Borrower')->get_column('cardnumber')->max() // 0;

    my $new_cardnumber = $existing_cardnumber + 1;
    $template->param( "newcardnumber" => $new_cardnumber );

    my $op = $input->param('op') // 'list';
    my $minpw = C4::Context->preference("minPasswordLength");
    $template->param( "minPasswordLength" => $minpw );
    my @messages;
    my @errors;
    my $nok            = $input->param('nok');
    my $cardnumber     = $input->param('cardnumber');
    my $borrowernumber = $input->param('borrowernumber');
    my $userid         = $input->param('userid');

    # function to designate mandatory fields (visually with css)
    my $check_BorrowerMandatoryField =
      C4::Context->preference("BorrowerMandatoryField");
    my @field_check = split( /\|/, $check_BorrowerMandatoryField );
    foreach (@field_check) {
        $template->param( "mandatory$_" => 1 );
        $template->param(
            BorrowerMandatoryField =>
              C4::Context->preference("BorrowerMandatoryField")
            ,    #field to test with javascript
        );
    }

 #If the entered cardnumber causes an error hand this error to the @errors array
    if ( my $error_code = checkcardnumber( $cardnumber, $borrowernumber ) ) {
        push @errors,
            $error_code == 1 ? 'ERROR_cardnumber_already_exists'
          : $error_code == 2 ? 'ERROR_cardnumber_length'
          :                    ();
    }

   #If the entered password causes an error hand this error to the @errors array
    push @errors, "ERROR_password_mismatch"
      if $firstpassword ne $secondpassword;
    push @errors, "ERROR_short_password"
      if ( $firstpassword
        && $minpw
        && $firstpassword ne '****'
        && ( length($firstpassword) < $minpw ) );

    #Passing errors to template
    $nok = $nok || scalar(@errors);

#If errors have been generated from the users inputted cardnumber or password then display the error and do not insert the patron into the borrowers table
    if ($nok) {
        foreach my $error (@errors) {
            if ( $error eq 'ERROR_password_mismatch' ) {
                $template->param( errorpasswordmismatch => 1 );
            }
            if ( $error eq 'ERROR_login_exist' ) {
                $template->param( errorloginexists => 1 );
            }
            if ( $error eq 'ERROR_cardnumber_already_exists' ) {
                $template->param( errorcardnumberexists => 1 );
            }
            if ( $error eq 'ERROR_cardnumber_length' ) {
                $template->param( errorcardnumberlength => 1 );
            }
            if ( $error eq 'ERROR_short_password' ) {
                $template->param( errorshortpassword => 1 );
            }
        }
        $template->param( 'nok' => 1 );

#Else if no errors have been caused by the users inputted card number or password then insert the patron into the borrowers table
    }
    else {
        my ( $template, $loggedinuser, $cookie ) =
          C4::InstallAuth::get_template_and_user(
            {
                template_name   => "/onboarding/onboardingstep3.tt",
                query           => $input,
                type            => "intranet",
                authnotrequired => 0,
                flagsrequired   => { borrowers => 1 },
                debug           => 1,
            }
          );

        if ( $op eq 'add_validate' ) {
            my %newdata;

            #Store the template form values in the newdata hash
            $newdata{borrowernumber} = $input->param('borrowernumber');
            $newdata{surname}        = $input->param('surname');
            $newdata{firstname}      = $input->param('firstname');
            $newdata{cardnumber}     = $input->param('cardnumber');
            $newdata{branchcode}     = $input->param('libraries');
            $newdata{categorycode}   = $input->param('categorycode_entry');
            $newdata{userid}         = $input->param('userid');
            $newdata{password}       = $input->param('password');
            $newdata{password2}      = $input->param('password2');
            $newdata{privacy}        = "default";
            $newdata{address}        = "";
            $newdata{city}           = "";

#Hand tne the dateexpiry of the patron based on the patron category it is created from
            my $patron_category = Koha::Patron::Categories->find( $newdata{categorycode} );
            $newdata{dateexpiry} = $patron_category->get_expiry_date( $newdata{dateenrolled} );

#Hand the newdata hash to the AddMember subroutine in the C4::Members module and it creates a patron and hands back a borrowernumber which is being stored
            my $borrowernumber = &AddMember(%newdata);

#Create a hash named member2 and fill it with the borrowernumber of the borrower that has just been created
            my %member2;
            $member2{'borrowernumber'} = $borrowernumber;

#Perform data validation on the flag that has been handed to onboarding.pl by the template
            my $flag = $input->param('flag');
            if ( $input->param('newflags') ) {
                my $dbh              = C4::Context->dbh();
                my @perms            = $input->multi_param('flag');
                my %all_module_perms = ();
                my %sub_perms        = ();
                foreach my $perm (@perms) {
                    if ( $perm !~ /:/ ) {
                        $all_module_perms{$perm} = 1;
                    }
                    else {
                        my ( $module, $sub_perm ) = split /:/, $perm, 2;
                        push @{ $sub_perms{$module} }, $sub_perm;
                    }
                }

                # construct flags
                my @userflags = $schema->resultset('Userflag')->search({},{
                        order_by => { -asc =>'bit'},
                        }
                );

#Setting superlibrarian permissions for new patron
                my $flags = Koha::Patrons->find($borrowernumber)->set({flags=>1})->store;

                #Error handling checking if the patron was created successfully
                if ( !$borrowernumber ) {
                    push @messages,
                      { type => 'error', code => 'error_on_insert' };
                }
                else {
                    push @messages,
                      { type => 'message', code => 'success_on_insert' };
                }
            }
        }
    }
}
elsif ( $step && $step == 4 ) {
    my ( $template, $borrowernumber, $cookie ) =
      C4::InstallAuth::get_template_and_user(
        {
            template_name   => "/onboarding/onboardingstep4.tt",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired =>
              { parameters => 'parameters_remaining_permissions' },
            debug => 1,
        }
    );
  if ($op eq "add_validate"){
        my $description   = $input->param('description');
        my $itemtype_code = $input->param('itemtype');
        $itemtype_code = uc($itemtype_code);

  #Create a new itemtype object using the user inputted itemtype and description
        my $itemtype = Koha::ItemType->new(
            {
                itemtype    => $itemtype_code,
                description => $description,
            }
        );
        eval { $itemtype->store; };
        my $message;

#Fill the $message variable with an error if the item type object was not successfully created and inserted into the itemtypes table
        if ($itemtype) {
            $message = 'success_on_insert';
        }
        else {
            $message = 'error_on_insert';
        }
        $template->param( 'message' => $message );
    }
}
elsif ( $step && $step == 5 ) {

  #Find all the existing categories to display in a dropdown box in the template
    my $categories;
    $categories = Koha::Patron::Categories->search();
    $template->param( categories => $categories, );

 #Find all the exisiting item types to display in a dropdown box in the template
    my $itemtypes;
    $itemtypes = Koha::ItemTypes->search();
    $template->param( itemtypes => $itemtypes, );

  #Find all the exisiting libraries to display in a dropdown box in the template
    my $libraries =
      Koha::Libraries->search( {}, { order_by => ['branchcode'] }, );
    $template->param(
        libraries   => $libraries,
        group_types => [
            {
                categorytype => 'searchdomain',
                categories   => [
                    Koha::LibraryCategories->search(
                        { categorytype => 'searchdomain' }
                    )
                ],
            },
            {
                categorytype => 'properties',
                categories   => [
                    Koha::LibraryCategories->search(
                        { categorytype => 'properties' }
                    )
                ],
            },
        ]
    );

    my $input = CGI->new;
    my $dbh   = C4::Context->dbh;

    my ( $template, $loggedinuser, $cookie ) =
      C4::InstallAuth::get_template_and_user(
        {
            template_name   => "/onboarding/onboardingstep5.tt",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { parameters => 'manage_circ_rules' },
            debug           => 1,
        }
      );

    #If no libraries exist then set the $branch value to *
    my $branch = $input->param('branch');
    unless ($branch) {
        if ( C4::Context->preference('DefaultToLoggedInLibraryCircRules') ) {
            $branch =
              Koha::Libraries->search->count() == 1
              ? undef
              : C4::Context::mybranch();
        }
        else {
            $branch =
              C4::Context::only_my_library()
              ? ( C4::Context::mybranch() || '*' )
              : '*';
        }
    }
    $branch = '*' if $branch eq 'NO_LIBRARY_SET';
    my $op = $input->param('op') || q{};

    if ( $op eq 'add_validate' ) {
        my $type            = $input->param('type');
        my $br              = $input->param('branch');
        my $bor             = $input->param('categorycode');
        my $itemtype        = $input->param('itemtype');
        my $maxissueqty     = $input->param('maxissueqty');
        my $issuelength     = $input->param('issuelength');
        my $lengthunit      = $input->param('lengthunit');
        my $renewalsallowed = $input->param('renewalsallowed');
        my $renewalperiod   = $input->param('renewalperiod');
        my $onshelfholds    = $input->param('onshelfholds') || 0;
        $maxissueqty =~ s/\s//g;
        $maxissueqty = undef if $maxissueqty !~ /^\d+/;
        $issuelength = $issuelength eq q{} ? undef : $issuelength;

        my $params = {
            branchcode      => $br,
            categorycode    => $bor,
            itemtype        => $itemtype,
            maxissueqty     => $maxissueqty,
            renewalsallowed => $renewalsallowed,
            renewalperiod   => $renewalperiod,
            issuelength     => $issuelength,
            lengthunit      => $lengthunit,
            onshelfholds    => $onshelfholds,
        };

        my @messages;

#Allows for the 'All' option to work when selecting all libraries for a circulation rule to apply to.
        if ( $branch eq "*" ) {
            my $search_default_rules = $schema->resultset('DefaultCircRule')->count();
            my $insert_default_rules = $schema->resultset('Issuingrule')->new(
                    { maxissueqty => $maxissueqty, onshelfholds => $onshelfholds }
                );
        }
#Allows for the 'All' option to work when selecting all patron categories for a circulation rule to apply to.
        elsif ( $bor eq "*" ) {

            my $search_default_rules = $schema->resultset('DefaultCircRule')->count();
            my $insert_default_rules = $schema->resultset('Issuingrule')->new(
                        { maxissueqty => $maxissueqty}
            );
        }

#Allows for the 'All' option to work when selecting all itemtypes for a circulation rule to apply to
        elsif ( $itemtype eq "*" ) {
            my $search_default_rules = $schema->resultset('DefaultCircRule')->search({},{
                    branchcode => $branch
                    }

            );

            my $insert_default_rules = $schema->resultset('Issuingrule')->new(
                           { branchcode => $branch, onshelfholds => $onshelfholds }
            );
        }

        my $issuingrule = Koha::IssuingRules->find(
            { categorycode => $bor, itemtype => $itemtype, branchcode => $br }
        );
        if ($issuingrule) {
            $issuingrule->set($params)->store();
            push @messages,
              {
                type => 'error',
                code => 'error_on_insert'
              }; #Stops crash of the onboarding tool if someone makes a circulation rule with the same item type, library and patron categroy as an exisiting circulation rule.

        }
        else {
            Koha::IssuingRule->new()->set($params)->store();
        }
    }
}

output_html_with_http_headers $input, $cookie, $template->output;
