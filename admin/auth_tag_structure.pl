#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
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
use C4::Auth;
use C4::Koha;
use C4::Context;
use C4::Output;
use C4::Context;


# retrieve parameters
my $input = new CGI;
my $authtypecode         = $input->param('authtypecode')         || '';    # set to select framework
my $existingauthtypecode = $input->param('existingauthtypecode') || '';    # set when we have to create a new framework (in authtype) by copying an old one (in existingauthtype)

# my $authtypeinfo = getauthtypeinfo($authtype);
my $searchfield = $input->param('searchfield') || 0;
my $offset      = $input->param('offset') || 0;
my $op          = $input->param('op')     || '';
$searchfield =~ s/\,//g;


my $script_name = "/cgi-bin/koha/admin/auth_tag_structure.pl";

my $dbh = C4::Context->dbh;

# open template
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/auth_tag_structure.tt",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {parameters => 'parameters_remaining_permissions'},
                 debug => 1,
                 });

# get authtype list
my $authtypes     = getauthtypes;
my @authtypesloop = ();
foreach my $thisauthtype ( sort keys %{$authtypes} ) {
    push @authtypesloop,
      { value        => $thisauthtype,
        selected     => $thisauthtype eq $authtypecode,
        authtypetext => $authtypes->{$thisauthtype}->{'authtypetext'},
      };
}

my $sth;
# check that authtype framework is defined in auth_tag_structure if we are on a default action
if (!$op or $op eq 'authtype_create_confirm') {
    $sth=$dbh->prepare("select count(*) from auth_tag_structure where authtypecode=?");
    $sth->execute($authtypecode);
    my ($authtypeexist) = $sth->fetchrow;
    if ($authtypeexist) {
    } else {
        # if authtype does not exists, then OP must be changed to "create authtype" if we are not on the way to create it
        # (op = authtyp_create_confirm)
        if ($op eq "authtype_create_confirm") {
            duplicate_auth_framework($authtypecode, $existingauthtypecode);
        } else {
            $op = "authtype_create";
        }
    }
}
$template->param(script_name  => $script_name);
$template->param(authtypeloop => \@authtypesloop);
if ($op && $op ne 'authtype_create_confirm') {
    $template->param($op  => 1);
} else {
    $template->param(else => 1);
}
 
################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
    #---- if primkey exists, it's a modify action, so read values to modify...
    my $data;
    if ($searchfield) {
        $sth=$dbh->prepare("select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from auth_tag_structure where tagfield=? and authtypecode=?");
        $sth->execute($searchfield,$authtypecode);
        $data=$sth->fetchrow_hashref;
    }

    my @authorised_values = @{C4::Koha::GetAuthorisedValueCategories()};    # function returns array ref, dereferencing
    unshift @authorised_values, "";                                         # put empty value first
    my $authorised_value = {
        values  => \@authorised_values,
        default => $data->{'authorised_value'},
    };

    if ($searchfield) {
        $template->param('searchfield' => $searchfield);
        $template->param('heading_modify_tag_p' => 1);
    } else {
        $template->param('heading_add_tag_p' => 1);
    }
    $template->param('use_heading_flags_p' => 1);
    $template->param(liblibrarian => $data->{'liblibrarian'},
                            libopac => $data->{'libopac'},
                            repeatable => "".$data->{'repeatable'},
                            mandatory => "".$data->{'mandatory'},
                            authorised_value => $authorised_value,
                            authtypecode => $authtypecode,
                            );
                                                    # END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
    my $tagfield         = $input->param('tagfield');
    my $liblibrarian     = $input->param('liblibrarian');
    my $libopac          = $input->param('libopac');
    my $repeatable       = $input->param('repeatable') ? 1 : 0;
    my $mandatory        = $input->param('mandatory')  ? 1 : 0;
    my $authorised_value = $input->param('authorised_value');
    unless (C4::Context->config('demo') eq 1) {
        if ($input->param('modif')) {
            $sth=$dbh->prepare("UPDATE auth_tag_structure SET tagfield=?, liblibrarian=?, libopac=?, repeatable=?, mandatory=?, authorised_value=? WHERE authtypecode=? AND tagfield=?");
            $sth->execute(
                $tagfield,
                $liblibrarian,
                $libopac,
                $repeatable,
                $mandatory,
                $authorised_value,
                $authtypecode,
                $tagfield,
            );
        } else {
            $sth=$dbh->prepare("INSERT INTO auth_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,authtypecode) VALUES (?,?,?,?,?,?,?)");
            $sth->execute(
                $tagfield,
                $liblibrarian,
                $libopac,
                $repeatable,
                $mandatory,
                $authorised_value,
                $authtypecode
           );
        }
    }
    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=auth_tag_structure.pl?searchfield=".$input->param('tagfield')."&authtypecode=$authtypecode\">";
    exit;
                                                    # END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
    $sth=$dbh->prepare("select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from auth_tag_structure where tagfield=?");
    $sth->execute($searchfield);
    my $data=$sth->fetchrow_hashref;
    $template->param(liblibrarian => $data->{'liblibrarian'},
                            searchfield => $searchfield,
                            authtypecode => $authtypecode,
                            );
                                                    # END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
    unless (C4::Context->config('demo') eq 1) {
        my $sth = $dbh->prepare("delete from auth_tag_structure where tagfield=? and authtypecode=?");
        $sth->execute($searchfield,$authtypecode);
        my $sth = $dbh->prepare("delete from auth_subfield_structure where tagfield=? and authtypecode=?");
        $sth->execute($searchfield,$authtypecode);
    }
    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=auth_tag_structure.pl?searchfield=".$input->param('tagfield')."&authtypecode=$authtypecode\">";
    exit;
                                                    # END $OP eq DELETE_CONFIRMED
################## ITEMTYPE_CREATE ##################################
# called automatically if an unexisting authtypecode is selected
} elsif ($op eq 'authtype_create') {
    $sth = $dbh->prepare("select count(*),auth_tag_structure.authtypecode,authtypetext from auth_tag_structure,auth_types where auth_types.authtypecode=auth_tag_structure.authtypecode group by auth_tag_structure.authtypecode");
    $sth->execute;
    my @existingauthtypeloop;
    while (my ($tot,$thisauthtype,$authtypetext) = $sth->fetchrow) {
        if ($tot>0) {
            my %line = ( value => $thisauthtype,
                        authtypetext => $authtypetext,
                    );
            push @existingauthtypeloop,\%line;
        }
    }
    @existingauthtypeloop = sort { lc($a->{authtypetext}) cmp lc($b->{authtypetext}) }@existingauthtypeloop;
    $template->param(existingauthtypeloop => \@existingauthtypeloop,
                    authtypecode => $authtypecode,
                    );
################## DEFAULT ##################################
} else { # DEFAULT
    # here, $op can be unset or set to "authtype_create_confirm".
#   warn "authtype : $authtypecode";
    if  ($searchfield ne '') {
         $template->param(searchfield => $searchfield);
    }
    my ($count,$results)=StringSearch($searchfield,$authtypecode);
    my @loop_data = ();
    for ( my $i = $offset ; $i < $count ; $i++ ) {
        my %row_data;  # get a fresh hash for the row data
        $row_data{tagfield}         = $results->[$i]{'tagfield'};
        $row_data{liblibrarian}     = $results->[$i]{'liblibrarian'};
        $row_data{repeatable}       = $results->[$i]{'repeatable'};
        $row_data{mandatory}        = $results->[$i]{'mandatory'};
        $row_data{authorised_value} = $results->[$i]{'authorised_value'};
        $row_data{subfield_link}    = "auth_subfields_structure.pl?tagfield=" . $results->[$i]{'tagfield'} . "&amp;authtypecode=" . $authtypecode;
        $row_data{edit}             = "$script_name?op=add_form&amp;searchfield=" . $results->[$i]{'tagfield'} . "&amp;authtypecode=" . $authtypecode;
        $row_data{delete}           = "$script_name?op=delete_confirm&amp;searchfield=" . $results->[$i]{'tagfield'} . "&amp;authtypecode=" . $authtypecode;
        push(@loop_data, \%row_data);
    }
    $template->param(loop => \@loop_data,
                    authtypecode => $authtypecode,
    );
    if ($offset>0) {
        $template->param(isprevpage => $offset,
                        searchfield => $searchfield,
         );
    }
    if ( $offset < $count ) {
        $template->param(
                        searchfield => $searchfield,
        );
    }
} #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;

#
# the sub used for searches
#
sub StringSearch  {
    my ($searchstring,$authtypecode)=@_;
    my $dbh = C4::Context->dbh;
    $searchstring=~ s/\'/\\\'/g;
    my @data=split(' ',$searchstring);
    my $sth=$dbh->prepare("Select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from auth_tag_structure where (tagfield >= ? and authtypecode=?) order by tagfield");
    $sth->execute($data[0], $authtypecode);
    my @results;
    while (my $data=$sth->fetchrow_hashref){
        push(@results,$data);
    }
    return (scalar(@results),\@results);
}

#
# the sub used to duplicate a framework from an existing one in MARC parameters tables.
#
sub duplicate_auth_framework {
    my ($newauthtype,$oldauthtype) = @_;
#   warn "TO $newauthtype FROM $oldauthtype";
    my $sth = $dbh->prepare("select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from auth_tag_structure where authtypecode=?");
    $sth->execute($oldauthtype);
    my $sth_insert = $dbh->prepare("insert into auth_tag_structure  (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, authtypecode) values (?,?,?,?,?,?,?)");
    while ( my ($tagfield,$liblibrarian,$libopac,$repeatable,$mandatory,$authorised_value) = $sth->fetchrow) {
        $sth_insert->execute($tagfield,$liblibrarian,$libopac,$repeatable,$mandatory,$authorised_value,$newauthtype);
    }

    $sth = $dbh->prepare("select tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,value_builder,seealso,hidden from auth_subfield_structure where authtypecode=?");
    $sth->execute($oldauthtype);
    $sth_insert = $dbh->prepare("insert into auth_subfield_structure (authtypecode,tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,value_builder,seealso,hidden) values (?,?,?,?,?,?,?,?,?,?,?,?,?)");
    while ( my ( $tagfield, $tagsubfield, $liblibrarian, $libopac, $repeatable, $mandatory, $kohafield,$tab, $authorised_value, $thesaurus_category, $seealso,$hidden) = $sth->fetchrow) {
        $sth_insert->execute($newauthtype, $tagfield, $tagsubfield, $liblibrarian, $libopac, $repeatable, $mandatory,$kohafield, $tab, $authorised_value, $thesaurus_category, $seealso,$hidden);
    }
}

