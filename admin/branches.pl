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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

=head1 branches.pl

 FIXME: individual fields in branch address need to be exported to templates,
        in order to fix bug 180; need to notify translators
FIXME: looped html (e.g., list of checkboxes) need to be properly
        TMPL_LOOP'ized; doing this properly will fix bug 130; need to
        notify translators
 FIXME: need to implement the branch categories stuff
 FIXME: there are too many TMPL_IF's; the proper way to do it is to have
        separate templates for each individual action; need to notify
        translators
 FIXME: there are lots of error messages exported to the template; a lot
        of these should be converted into exported booleans / counters etc
        so that the error messages can be localized; need to notify translators

 NOTE:  heading() should now be called like this:
        1. Use heading() as before
        2. $template->param('heading-LISPISHIZED-HEADING-p' => 1);
        3. $template->param('use-heading-flags-p' => 1);
        This ensures that both converted and unconverted templates work

 Finlay working on this file from 26-03-2002
 Reorganising this branches admin page.....
 
=cut

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::Branch;

# Fixed variables
my $script_name = "/cgi-bin/koha/admin/branches.pl";
my $pagesize    = 20;

################################################################################
# Main loop....
my $input        = new CGI;
my $branchcode   = $input->param('branchcode');
my $branchname   = $input->param('branchname');
my $categorycode = $input->param('categorycode');
my $op           = $input->param('op');

if(!defined($op)){
  $op = '';
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/branches.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 1},
        debug           => 1,
    }
);
if ($op) {
    $template->param(
        script_name => $script_name,
        $op         => 1
    );    # we show only the TMPL_VAR names $op
}
else {
    $template->param(
        script_name => $script_name,
        else        => 1
    );    # we show only the TMPL_VAR names $op
}
$template->param( action => $script_name );
if ( $op eq 'add' ) {

    # If the user has pressed the "add new branch" button.
    $template->param( 'heading-branches-add-branch-p' => 1 );
    editbranchform($branchcode,$template);

}
elsif ( $op eq 'edit' ) {

    # if the user has pressed the "edit branch settings" button.
    $template->param( 'heading-branches-add-branch-p' => 0,
                        'add' => 1, );
    editbranchform($branchcode,$template);
}
elsif ( $op eq 'add_validate' ) {

    # confirm settings change...
    my $params = $input->Vars;
    unless ( $params->{'branchcode'} && $params->{'branchname'} ) {
        $template->param( else => 1 );
        default("MESSAGE1",$template);
    }
    else {
        ModBranch($params);
        $template->param( else => 1 );
        default("MESSAGE2",$template);
    }
}
elsif ( $op eq 'delete' ) {
    # if the user has pressed the "delete branch" button.
    
    # check to see if the branchcode is being used in the database somewhere....
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select count(*) from items where holdingbranch=? or homebranch=?");
    $sth->execute( $branchcode, $branchcode );
    my ($total) = $sth->fetchrow_array;
    $sth->finish;
    
    my $message;

    if ($total) {
        $message = "MESSAGE7";
    }
   
    if ($message) {
        $template->param( else => 1 );
        default($message,$template);
    }
    else {
        $template->param( branchname     => $branchname );
        $template->param( delete_confirm => 1 );
        $template->param( branchcode     => $branchcode );
    }
}
elsif ( $op eq 'delete_confirmed' ) {

    # actually delete branch and return to the main screen....
    DelBranch($branchcode);
    $template->param( else => 1 );
    default("MESSAGE3",$template);
}
elsif ( $op eq 'editcategory' ) {

    # If the user has pressed the "add new category" or "modify" buttons.
    $template->param( 'heading-branches-edit-category-p' => 1 );
    editcatform($categorycode,$template);
}
elsif ( $op eq 'addcategory_validate' ) {

    # confirm settings change...
    my $params = $input->Vars;
    unless ( $params->{'categorycode'} && $params->{'categoryname'} ) {
        $template->param( else => 1 );
        default("MESSAGE4",$template);
    }
    else {
        ModBranchCategoryInfo($params);
        $template->param( else => 1 );
        default("MESSAGE5",$template);
    }
}
elsif ( $op eq 'delete_category' ) {

    # if the user has pressed the "delete branch" button.
    my $message = "MESSAGE8" if CheckBranchCategorycode($categorycode);
    if ($message) {
        $template->param( else => 1 );
        default($message,$template);
    }
    else {
        $template->param( delete_category => 1 );
        $template->param( categorycode    => $categorycode );
    }
}
elsif ( $op eq 'categorydelete_confirmed' ) {

    # actually delete branch and return to the main screen....
    DelBranchCategory($categorycode);
    $template->param( else => 1 );
    default("MESSAGE6",$template);

}
else {

    # if no operation has been set...
    default("",$template);
}

################################################################################
#
# html output functions....

sub default {
    my ($message,$innertemplate) = @_;
    $innertemplate->param( 'heading-branches-p' => 1 );
    $innertemplate->param( "$message"           => 1 );
    $innertemplate->param( action               => $script_name );
    branchinfotable("",$innertemplate);
}

sub editbranchform {
    my ($branchcode,$innertemplate) = @_;
    # initiate the scrolling-list to select the printers
    my $printers = GetPrinters();
    my @printerloop;
    my $printercount = 0;
    my $oldprinter;
    my $CGIprinter;
    
    my $data;

    if ($branchcode) {
        $data = GetBranchInfo($branchcode);
        $data = $data->[0];

        # get the old printer of the branch
        $oldprinter = $data->{'branchprinter'};

        # 	printer loop
        foreach my $thisprinter ( keys %$printers ) {

            my $selected = 1
              if $oldprinter and ( $oldprinter eq $printers->{$thisprinter} );

            my %row = (
                value         => $thisprinter,
                selected      => $selected,
                branchprinter => $printers->{$thisprinter}->{'printqueue'},
            );
            push @printerloop, \%row;
        }

        $innertemplate->param( 
             printerloop    => \@printerloop,
             branchcode     => $data->{'branchcode'},
             branch_name    => $data->{'branchname'},
             branchaddress1 => $data->{'branchaddress1'},
             branchaddress2 => $data->{'branchaddress2'},
             branchaddress3 => $data->{'branchaddress3'},
             branchphone    => $data->{'branchphone'},
             branchfax      => $data->{'branchfax'},
             branchemail    => $data->{'branchemail'},
             branchip       => $data->{'branchip'} 
        );
    }
    else {    #case of an add branch select printer
        foreach my $thisprinter ( keys %$printers ) {
            my %row = (
                value         => $thisprinter,
                branchprinter => $printers->{$thisprinter}->{'printqueue'},
            );
            push @printerloop, \%row;
        }
        $innertemplate->param( printerloop => \@printerloop );
    }

    # make the checkboxs.....
    #
    # We export a "categoryloop" array to the template, each element of which
    # contains separate 'categoryname', 'categorycode', 'codedescription', and
    # 'checked' fields. The $checked field is either '' or 'checked'
    # (see bug 130)
    #
    my $catinfo = GetBranchCategory();
    my $catcheckbox;

    #    print DEBUG "catinfo=".cvs($catinfo)."\n";
    my @categoryloop = ();
    foreach my $cat (@$catinfo) {
        my $checked = "";
        my $tmp     = quotemeta( $cat->{'categorycode'} );
        if ( grep { /^$tmp$/ } @{ $data->{'categories'} } ) {
            $checked = "checked=\"checked\"";
        }
        push @categoryloop,
          {
            categoryname    => $cat->{'categoryname'},
            categorycode    => $cat->{'categorycode'},
            categorytype    => $cat->{'categorytype'},
            codedescription => $cat->{'codedescription'},
            checked         => $checked,
          };
    }
    $innertemplate->param( categoryloop => \@categoryloop );

    # {{{ Leave this here until bug 130 is completely resolved in the templates
    for my $obsolete ( 'categoryname', 'categorycode', 'codedescription' ) {
        $innertemplate->param(
            $obsolete => 'Your template is out of date (bug 130)' );
    }

    # }}}
}

sub editcatform {

    # prepares the edit form...
    my ($categorycode,$innertemplate) = @_;
    warn "cat : $categorycode";
    my $data;
	my @cats;
    $innertemplate->param( categorytype => \@cats);
	if ($categorycode) {
        $data = GetBranchCategory($categorycode);
        $data = $data->[0];
        $innertemplate->param(	categorycode    => $data->{'categorycode'} ,
        				categoryname    => $data->{'categoryname'},
        				codedescription => $data->{'codedescription'} ,
						);
    }
	for my $ctype (GetCategoryTypes()) {
		push @cats , { type => $ctype , selected => ($data->{'categorytype'} eq $ctype) };
	}
}

sub deleteconfirm {

    # message to print if the
    my ($branchcode) = @_;
}

sub branchinfotable {

# makes the html for a table of branch info from reference to an array of hashs.

    my ($branchcode,$innertemplate) = @_;
    my $branchinfo;
    if ($branchcode) {
        $branchinfo = GetBranchInfo($branchcode);
    }
    else {
        $branchinfo = GetBranchInfo();
    }
    my $toggle;
    my $i = 0;
    my @loop_data = ();
    foreach my $branch (@$branchinfo) {
        ( $i % 2 ) ? ( $toggle = 1 ) : ( $toggle = 0 );

        #
        # We export the following fields to the template. These are not
        # pre-composed as a single "address" field because the template
        # might (and should) escape what is exported here. (See bug 180)
        #
        # - color
        # - branch_name     (Note: not "branchname")
        # - branch_code     (Note: not "branchcode")
        # - address         (containing a static error message)
        # - branchaddress1 \
        # - branchaddress2  |
        # - branchaddress3  | comprising the old "address" field
        # - branchphone     |
        # - branchfax       |
        # - branchemail    /
        # - address-empty-p (1 if no address information, 0 otherwise)
        # - categories      (containing a static error message)
        # - category_list   (loop containing "categoryname")
        # - no-categories-p (1 if no categories set, 0 otherwise)
        # - value
        # - action
        #
        my %row = ();

        # Handle address fields separately
        my $address_empty_p = 1;
        for my $field (
            'branchaddress1', 'branchaddress2',
            'branchaddress3', 'branchphone',
            'branchfax',      'branchemail',
            'branchip',       'branchprinter'
          )
        {
            $row{$field} = $branch->{$field};
            if ( $branch->{$field} ) {
                $address_empty_p = 0;
            }
        }
        $row{'address-empty-p'} = $address_empty_p;

        # {{{ Leave this here until bug 180 is completely resolved in templates
        $row{'address'} = 'Your template is out of date (see bug 180)';

        # }}}

        # Handle categories
        my $no_categories_p = 1;
        my @categories;
        foreach my $cat ( @{ $branch->{'categories'} } ) {
            my ($catinfo) = @{ GetBranchCategory($cat) };
            push @categories, { 'categoryname' => $catinfo->{'categoryname'} };
            $no_categories_p = 0;
        }

        # {{{ Leave this here until bug 180 is completely resolved in templates
        $row{'categories'} = 'Your template is out of date (see bug 180)';

        # }}}
        $row{'category_list'}   = \@categories;
        $row{'no-categories-p'} = $no_categories_p;

        # Handle all other fields
        $row{'branch_name'} = $branch->{'branchname'};
        $row{'branch_code'} = $branch->{'branchcode'};
        $row{'toggle'}      = $toggle;
        $row{'value'}       = $branch->{'branchcode'};
        $row{'action'}      = '/cgi-bin/koha/admin/branches.pl';

        push @loop_data, {%row};
        $i++;
    }
    my @branchcategories = ();
	for my $ctype ( GetCategoryTypes() ) {
    	my $catinfo = GetBranchCategories(undef,$ctype);
    	my @categories;
		foreach my $cat (@$catinfo) {
	       	push @categories,
        	  {
        	    categoryname    => $cat->{'categoryname'},
        	    categorycode    => $cat->{'categorycode'},
        	    codedescription => $cat->{'codedescription'},
        	    categorytype => $cat->{'categorytype'},
        	  };
    	}
	push @branchcategories, { categorytype => $ctype , $ctype => 1 , catloop => \@categories};
	}
    $innertemplate->param(
        branches         => \@loop_data,
        branchcategories => \@branchcategories
    );

}

# FIXME logic seems wrong   ##  sub is not used.
sub branchcategoriestable {
    my $innertemplate = shift;
    #Needs to be implemented...

    my $categoryinfo = GetBranchCategory();
    my $color;
    foreach my $cat (@$categoryinfo) {
        $innertemplate->param( categoryname    => $cat->{'categoryname'} );
        $innertemplate->param( categorycode    => $cat->{'categorycode'} );
        $innertemplate->param( codedescription => $cat->{'codedescription'} );
    }
}

output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
