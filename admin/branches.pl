#!/usr/bin/perl
# NOTE: Use standard 8-space tabs for this file (indents are 4 spaces)

#require '/u/acli/lib/cvs.pl';#DEBUG
#open(DEBUG,'>/tmp/koha.debug');

# FIXME: individual fields in branch address need to be exported to templates,
#        in order to fix bug 180; need to notify translators
# FIXME: looped html (e.g., list of checkboxes) need to be properly
#        TMPL_LOOP'ized; doing this properly will fix bug 130; need to
#        notify translators
# FIXME: need to implement the branch categories stuff
# FIXME: heading() need to be moved to templates, need to notify translators
# FIXME: there are too many TMPL_IF's; the proper way to do it is to have
#        separate templates for each individual action; need to notify
#        translators
# FIXME: there are lots of error messages exported to the template; a lot
#        of these should be converted into exported booleans / counters etc
#        so that the error messages can be localized; need to notify translators

# Finlay working on this file from 26-03-2002
# Reorganising this branches admin page.....


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

use strict;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use HTML::Template;

# Fixed variables
my $linecolor1='#ffffcc';
my $linecolor2='white';
my $backgroundimage="/images/background-mem.gif";
my $script_name="/cgi-bin/koha/admin/branches.pl";
my $pagesize=20;


#######################################################################################
# Main loop....

my $input = new CGI;
my $branchcode=$input->param('branchcode');
my $op = $input->param('op');

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "parameters/branches.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });
if ($op) {
    $template->param(script_name => $script_name,
		     $op         => 1); # we show only the TMPL_VAR names $op
} else {
    $template->param(script_name => $script_name,
		     else        => 1); # we show only the TMPL_VAR names $op
}
$template->param(action => $script_name);

if ($op eq 'add') {
# If the user has pressed the "add new branch" button.
    heading("Branches: Add Branch");
    editbranchform();

} elsif ($op eq 'edit') {
# if the user has pressed the "edit branch settings" button.
    heading("Branches: Edit Branch");
    $template->param(add => 1);
    editbranchform($branchcode);

} elsif ($op eq 'add_validate') {
# confirm settings change...
    my $params = $input->Vars;
    unless ($params->{'branchcode'} && $params->{'branchname'}) {
	default ("Cannot change branch record: You must specify a Branchname and a Branchcode");
    } else {
	setbranchinfo($params);
	$template->param(else => 1);
	default ("Branch record changed for branch: $params->{'branchname'}");
    }

} elsif ($op eq 'delete') {
# if the user has pressed the "delete branch" button.
    my $message = checkdatabasefor($branchcode);
    if ($message) {
	$template->param(else => 1);
	default($message);
    } else {
	deleteconfirm($branchcode);
        $template->param(delete_confirm => 1);
	$template->param(branchcode => $branchcode);
    }

} elsif ($op eq 'delete_confirmed') {
# actually delete branch and return to the main screen....
    deletebranch($branchcode);
    $template->param(else => 1);
    default("The branch with code $branchcode has been deleted.");

} elsif ($op eq 'add_cat') {
# If the user has pressed the "add new category" button.
    heading("Branches: Add Branch");
    editcatform();

} else {
# if no operation has been set...
    default();
}



######################################################################################################
#
# html output functions....

sub default {
    my ($message) = @_;
    heading("Branches");
    $template->param(message => $message);
    $template->param(action => $script_name);
    branchinfotable();
    
    
}

# FIXME: this function should not exist; otherwise headings are untranslatable
sub heading {
    my ($head) = @_;
    $template->param(head => $head);
}

sub editbranchform {
# prepares the edit form...
    my ($branchcode) = @_;
    my $data;
    if ($branchcode) {
	$data = getbranchinfo($branchcode);
	$data = $data->[0];
	$template->param(branchcode => $data->{'branchcode'});
        $template->param(branchname => $data->{'branchname'});
        $template->param(branchaddress1 => $data->{'branchaddress1'});
        $template->param(branchaddress2 => $data->{'branchaddress2'});
        $template->param(branchaddress3 => $data->{'branchaddress3'});
        $template->param(branchphone => $data->{'branchphone'});
        $template->param(branchfax => $data->{'branchfax'});
        $template->param(branchemail => $data->{'branchemail'});
    }

    # make the checkboxs.....
    #
    # We export a "categoryloop" array to the template, each element of which
    # contains separate 'categoryname', 'categorycode', 'codedescription', and
    # 'checked' fields. The $checked field is either '' or 'checked'
    # (see bug 130)
    #
    my $catinfo = getcategoryinfo();
    my $catcheckbox;
#    print DEBUG "catinfo=".cvs($catinfo)."\n";
    my @categoryloop = ();
    foreach my $cat (@$catinfo) {
	my $checked = "";
	my $tmp = quotemeta($cat->{'categorycode'});
	if (grep {/^$tmp$/} @{$data->{'categories'}}) {
	    $checked = "CHECKED";
	}
	push @categoryloop, {
		categoryname    => $cat->{'categoryname'},
		categorycode    => $cat->{'categorycode'},
		codedescription => $cat->{'codedescription'},
		checked         => $checked,
	    };
    }
    $template->param(categoryloop => \@categoryloop);

    # {{{ Leave this here until bug 130 is completely resolved in the templates
    for my $obsolete ('categoryname', 'categorycode', 'codedescription') {
	$template->param($obsolete => 'Your template is out of date (bug 130)');
    }
    # }}}
}

sub deleteconfirm {
# message to print if the 
    my ($branchcode) = @_;
}


sub branchinfotable {
# makes the html for a table of branch info from reference to an array of hashs.

    my ($branchcode) = @_;
    my $branchinfo;
    if ($branchcode) {
	$branchinfo = getbranchinfo($branchcode);
    } else {
	$branchinfo = getbranchinfo();
    }
    my $color;
    my @loop_data =();
    foreach my $branch (@$branchinfo) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
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
	for my $field ('branchaddress1', 'branchaddress2', 'branchaddress3',
		'branchphone', 'branchfax', 'branchemail') {

	    $row{$field} = $branch->{$field};
	    $address_empty_p = 0;
	}
	$row{'address-empty-p'} = $address_empty_p;
	# {{{ Leave this here until bug 180 is completely resolved in templates
	$row{'address'} = 'Your template is out of date (see bug 180)';
	# }}}

	# Handle categories
	my $no_categories_p = 1;
	my @categories = '';
	foreach my $cat (@{$branch->{'categories'}}) {
	    my ($catinfo) = @{getcategoryinfo($cat)};
	    push @categories, {'categoryname' => $catinfo->{'categoryname'}};
	    $no_categories_p = 0;
	}
	# {{{ Leave this here until bug 180 is completely resolved in templates
	$row{'categories'} = 'Your template is out of date (see bug 180)';
	# }}}
	$row{'category_list'} = \@categories;
	$row{'no-categories-p'} = $no_categories_p;

	# Handle all other fields
	$row{'branch_name'} = $branch->{'branchname'};
	$row{'branch_code'} = $branch->{'branchcode'};
	$row{'color'} = $color;
	$row{'value'} = $branch->{'branchcode'};
	$row{'action'} = '/cgi-bin/koha/admin/branches.pl';

	push @loop_data, { %row };
    }
    $template->param(branches => \@loop_data);

}

# FIXME logic seems wrong
sub branchcategoriestable {
#Needs to be implemented...

    my $categoryinfo = getcategoryinfo();
    my $color;
    foreach my $cat (@$categoryinfo) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	$template->param(color => $color);
	$template->param(categoryname => $cat->{'categoryname'});
	$template->param(categorycode => $cat->{'categorycode'});
	$template->param(codedescription => $cat->{'codedescription'});
    }
}

######################################################################################################
#
# Database functions....

sub getbranchinfo {
# returns a reference to an array of hashes containing branches,

    my ($branchcode) = @_;
    my $dbh = C4::Context->dbh;
    my ($query, @query_args);
    if ($branchcode) {
	$query = "Select * from branches where branchcode = ?";
	@query_args = ($branchcode);
    } else {
	$query = "Select * from branches";
    }
    my $sth = $dbh->prepare($query);
    $sth->execute(@query_args);
    my @results;
    while (my $data = $sth->fetchrow_hashref) { 
	$query = "select categorycode from branchrelations where branchcode = ?";
	my $nsth = $dbh->prepare($query);
	$nsth->execute($data->{'branchcode'});;
	my @cats = ();
	while (my ($cat) = $nsth->fetchrow_array) {
	    push(@cats, $cat);
	}
	$nsth->finish;
	$data->{'categories'} = \@cats;
	push(@results, $data);
    }
    $sth->finish;
    return \@results;
}

# FIXME This doesn't belong here; it should be moved into a module
sub getcategoryinfo {
# returns a reference to an array of hashes containing branches,
    my ($catcode) = @_;
    my $dbh = C4::Context->dbh;
    my ($query, @query_args);
#    print DEBUG "getcategoryinfo: entry: catcode=".cvs($catcode)."\n";
    if ($catcode) {
	$query = "select * from branchcategories where categorycode = ?";
	@query_args = ($catcode);
    } else {
	$query = "Select * from branchcategories";
    }
#    print DEBUG "getcategoryinfo: query=".cvs($query)."\n";
    my $sth = $dbh->prepare($query);
    $sth->execute(@query_args);
    my @results;
    while (my $data = $sth->fetchrow_hashref) { 
	push(@results, $data);
    }
    $sth->finish;
#    print DEBUG "getcategoryinfo: exit: returning ".cvs(\@results)."\n";
    return \@results;
}

# FIXME This doesn't belong here; it should be moved into a module
sub setbranchinfo {
# sets the data from the editbranch form, and writes to the database...
    my ($data) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "replace branches (branchcode,branchname,branchaddress1,branchaddress2,branchaddress3,branchphone,branchfax,branchemail) values (?,?,?,?,?,?,?,?)";
    my $sth=$dbh->prepare($query);
    $sth->execute($data->{'branchcode'}, $data->{'branchname'},
	    $data->{'branchaddress1'}, $data->{'branchaddress2'},
	    $data->{'branchaddress3'}, $data->{'branchphone'},
	    $data->{'branchfax'}, $data->{'branchemail'});

    $sth->finish;
# sort out the categories....
    my @checkedcats;
    my $cats = getcategoryinfo();
    foreach my $cat (@$cats) {
	my $code = $cat->{'categorycode'};
	if ($data->{$code}) {
	    push(@checkedcats, $code);
	}
    }
    my $branchcode = $data->{'branchcode'};
    my $branch = getbranchinfo($branchcode);
    $branch = $branch->[0];
    my $branchcats = $branch->{'categories'};
    my @addcats;
    my @removecats;
    foreach my $bcat (@$branchcats) {
	unless (grep {/^$bcat$/} @checkedcats) {
	    push(@removecats, $bcat);
	}
    }
    foreach my $ccat (@checkedcats){
	unless (grep {/^$ccat$/} @$branchcats) {
	    push(@addcats, $ccat);
	}
    }	
    # FIXME - There's already a $dbh in this scope.
    my $dbh = C4::Context->dbh;
    foreach my $cat (@addcats) {
	my $query = "insert into branchrelations (branchcode, categorycode) values(?, ?)";
	my $sth = $dbh->prepare($query);
	$sth->execute($branchcode, $cat);
	$sth->finish;
    }
    foreach my $cat (@removecats) {
	my $query = "delete from branchrelations where branchcode=? and categorycode=?";
	my $sth = $dbh->prepare($query);
	$sth->execute($branchcode, $cat);
	$sth->finish;
    }
}

sub deletebranch {
# delete branch...
    my ($branchcode) = @_;
    my $query = "delete from branches where branchcode = ?";
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare($query);
    $sth->execute($branchcode);
    $sth->finish;
}

sub checkdatabasefor {
# check to see if the branchcode is being used in the database somewhere....
    my ($branchcode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select count(*) from items where holdingbranch=? or homebranch=?");
    $sth->execute($branchcode, $branchcode);
    my ($total) = $sth->fetchrow_array;
    $sth->finish;
    my $message;
    if ($total) {
	# FIXME: need to be replaced by an exported boolean parameter
	$message = "Branch cannot be deleted because there are $total items using that branch.";
    } 
    return $message;
}

output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
