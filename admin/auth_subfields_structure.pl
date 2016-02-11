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

use Modern::Perl;
use C4::Output;
use C4::Auth;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Koha;

use Koha::Authority::Types;
use Koha::AuthorisedValues;

use List::MoreUtils qw( uniq );

sub string_search  {
	my ($searchstring,$authtypecode)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $sth=$dbh->prepare("Select * from auth_subfield_structure where (tagfield like ? and authtypecode=?) order by tagfield");
	$sth->execute("$searchstring%",$authtypecode);
	my $results = $sth->fetchall_arrayref({});
	return (scalar(@$results), $results);
}

sub auth_subfield_structure_exists {
	my ($authtypecode, $tagfield, $tagsubfield) = @_;
	my $dbh  = C4::Context->dbh;
	my $sql  = "select tagfield from auth_subfield_structure where authtypecode = ? and tagfield = ? and tagsubfield = ?";
	my $rows = $dbh->selectall_arrayref($sql, {}, $authtypecode, $tagfield, $tagsubfield);
	return @$rows > 0;
}

my $input        = new CGI;
my $tagfield     = $input->param('tagfield');
my $tagsubfield  = $input->param('tagsubfield');
my $authtypecode = $input->param('authtypecode');
my $offset       = $input->param('offset') || 0;
my $op           = $input->param('op') || '';
my $script_name  = "/cgi-bin/koha/admin/auth_subfields_structure.pl";

my ($template, $borrowernumber, $cookie) = get_template_and_user(
    {   template_name   => "admin/auth_subfields_structure.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
        debug           => 1,
    }
);
my $pagesize = 30;
$tagfield =~ s/\,//g;

if ($op) {
$template->param(script_name => $script_name,
						tagfield =>$tagfield,
						authtypecode => $authtypecode,
						$op              => 1); # we show only the TMPL_VAR names $op
} else {
$template->param(script_name => $script_name,
						tagfield =>$tagfield,
						authtypecode => $authtypecode,
						else              => 1); # we show only the TMPL_VAR names $op
}

my $dbh = C4::Context->dbh;
################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	# builds kohafield tables
	my @kohafields;
	push @kohafields, "";
	my $sth2=$dbh->prepare("SHOW COLUMNS from auth_header");
	$sth2->execute;
	while ((my $field) = $sth2->fetchrow_array) {
		push @kohafields, "auth_header.".$field;
	}
	
        # build authorised value category list
        my @authorised_value_categories = Koha::AuthorisedValues->new->categories;
        unshift @authorised_value_categories, '';
        push @authorised_value_categories, 'branches';
        push @authorised_value_categories, 'itemtypes';

        # build thesaurus categories list
        my @authtypes = uniq( "", map { $_->authtypecode } Koha::Authority::Types->search );

	# build value_builder list
	my @value_builder=('');

	# read value_builder directory.
	# 2 cases here : on CVS install, $cgidir does not need a /cgi-bin
	# on a standard install, /cgi-bin need to be added. 
	# test one, then the other
    my $cgidir = C4::Context->config('intranetdir') ."/cgi-bin";
	unless (opendir(DIR, "$cgidir/cataloguing/value_builder")) {
        $cgidir = C4::Context->config('intranetdir');
		opendir(DIR, "$cgidir/cataloguing/value_builder") || die "can't opendir $cgidir/value_builder: $!";
	} 
	while (my $line = readdir(DIR)) {
        if ( $line =~ /\.pl$/ &&
             $line !~ /EXAMPLE\.pl$/ ) { # documentation purposes
            push (@value_builder,$line);
		}
	}
        @value_builder= sort {$a cmp $b} @value_builder;
	closedir DIR;

	# build values list
	my $sth=$dbh->prepare("select * from auth_subfield_structure where tagfield=? and authtypecode=?"); # and tagsubfield='$tagsubfield'");
	$sth->execute($tagfield,$authtypecode);
	my @loop_data = ();
	my $i=0;
    while ( my $data = $sth->fetchrow_hashref ) {
        my %row_data;    # get a fresh hash for the row data
        $row_data{defaultvalue}      = $data->{defaultvalue};
        $row_data{tab}               = $data->{tab};
        $row_data{ohidden}           = $data->{'hidden'};
        $row_data{tagsubfield}       = $data->{'tagsubfield'};
        $row_data{liblibrarian}      = $data->{'liblibrarian'};
        $row_data{libopac}           = $data->{'libopac'};
        $row_data{seealso}           = $data->{'seealso'};
        $row_data{kohafields}        = \@kohafields;
        $row_data{kohafield}         = $data->{'kohafield'};
        $row_data{authorised_values} = \@authorised_value_categories;
        $row_data{authorised_value}  = $data->{'authorised_value'};
        $row_data{frameworkcodes}    = \@authtypes;
        $row_data{frameworkcode}     = $data->{'frameworkcode'};
        $row_data{value_builders}    = \@value_builder;
        $row_data{value_builder}     = $data->{'value_builder'};
        $row_data{repeatable}        = $data->{repeatable};
        $row_data{mandatory}         = $data->{mandatory};
        $row_data{hidden}            = $data->{hidden};
        $row_data{isurl}             = $data->{isurl};
        $row_data{row}               = $i;
        push( @loop_data, \%row_data );
        $i++;
    }

    # Add a new row for the "New" tab
    my %row_data;    # get a fresh hash for the row data
    $row_data{'new_subfield'} = 1;
    $row_data{tab} = -1; # ignore
    $row_data{ohidden} = 0; # show all
    $row_data{tagsubfield}      = "";
    $row_data{liblibrarian}     = "";
    $row_data{libopac}          = "";
    $row_data{seealso}          = "";
    $row_data{hidden}           = "000";
    $row_data{repeatable}       = 0;
    $row_data{mandatory}        = 0;
    $row_data{isurl}            = 0;
    $row_data{kohafields} = \@kohafields,
    $row_data{authorised_values} = \@authorised_value_categories;
    $row_data{frameworkcodes} = \@authtypes;
    $row_data{value_builders} = \@value_builder;
    $row_data{row} = $i;
    push( @loop_data, \%row_data );

	$template->param('use_heading_flags_p' => 1);
	$template->param('heading_edit_subfields_p' => 1);
	$template->param(action => "Edit subfields",
							tagfield => $tagfield,
							tagfieldinput => "<input type=\"hidden\" name=\"tagfield\" value=\"$tagfield\" />",
							loop => \@loop_data,
							more_tag => $tagfield);

												# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	$template->param(tagfield => "$input->param('tagfield')");
#	my $sth=$dbh->prepare("replace auth_subfield_structure (authtypecode,tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,seealso,authorised_value,frameworkcode,value_builder,hidden,isurl)
#									values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
    my $sth_insert = $dbh->prepare("insert into auth_subfield_structure (authtypecode,tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,seealso,authorised_value,frameworkcode,value_builder,hidden,isurl,defaultvalue)
                                    values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
    my $sth_update = $dbh->prepare("update auth_subfield_structure set authtypecode=?, tagfield=?, tagsubfield=?, liblibrarian=?, libopac=?, repeatable=?, mandatory=?, kohafield=?, tab=?, seealso=?, authorised_value=?, frameworkcode=?, value_builder=?, hidden=?, isurl=?, defaultvalue=?
                                    where authtypecode=? and tagfield=? and tagsubfield=?");
	my @tagsubfield	= $input->multi_param('tagsubfield');
	my @liblibrarian	= $input->multi_param('liblibrarian');
	my @libopac		= $input->multi_param('libopac');
	my @kohafield		= ''.$input->param('kohafield');
	my @tab				= $input->multi_param('tab');
	my @seealso		= $input->multi_param('seealso');
    my @ohidden             = $input->multi_param('ohidden');
    my @authorised_value_categories = $input->multi_param('authorised_value');
	my $authtypecode	= $input->param('authtypecode');
	my @frameworkcodes	= $input->multi_param('frameworkcode');
	my @value_builder	=$input->multi_param('value_builder');
    my @defaultvalue = $input->multi_param('defaultvalue');
	for (my $i=0; $i<= $#tagsubfield ; $i++) {
		my $tagfield			=$input->param('tagfield');
		my $tagsubfield		=$tagsubfield[$i];
		$tagsubfield="@" unless $tagsubfield ne '';
		my $liblibrarian		=$liblibrarian[$i];
		my $libopac			=$libopac[$i];
		my $repeatable		=$input->param("repeatable$i")?1:0;
		my $mandatory		=$input->param("mandatory$i")?1:0;
		my $kohafield		=$kohafield[$i];
		my $tab				=$tab[$i];
		my $seealso				=$seealso[$i];
        my $authorised_value = $authorised_value_categories[$i];
		my $frameworkcode		=$frameworkcodes[$i];
		my $value_builder=$value_builder[$i];
        my $defaultvalue = $defaultvalue[$i];
		my $hidden = $ohidden[$i]; #collate from 3 hiddens;
		my $isurl = $input->param("isurl$i")?1:0;
		if ($liblibrarian) {
			unless (C4::Context->config('demo') or C4::Context->config('demo') eq 1) {
				if (auth_subfield_structure_exists($authtypecode, $tagfield, $tagsubfield)) {
					$sth_update->execute(
						$authtypecode,
						$tagfield,
						$tagsubfield,
						$liblibrarian,
						$libopac,
						$repeatable,
						$mandatory,
						$kohafield,
						$tab,
						$seealso,
						$authorised_value,
						$frameworkcode,
						$value_builder,
						$hidden,
						$isurl,
                        $defaultvalue,
						(
							$authtypecode,
							$tagfield,
							$tagsubfield
						),
					);
				} else {
					$sth_insert->execute(
						$authtypecode,
						$tagfield,
						$tagsubfield,
						$liblibrarian,
						$libopac,
						$repeatable,
						$mandatory,
						$kohafield,
						$tab,
						$seealso,
						$authorised_value,
						$frameworkcode,
						$value_builder,
						$hidden,
						$isurl,
                        $defaultvalue,
					);
				}
			}
		}
	}
    print $input->redirect("/cgi-bin/koha/admin/auth_subfields_structure.pl?tagfield=$tagfield&amp;authtypecode=$authtypecode");
    exit;

													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $sth=$dbh->prepare("select * from auth_subfield_structure where tagfield=? and tagsubfield=? and authtypecode=?");
	$sth->execute($tagfield,$tagsubfield,$authtypecode);
	my $data=$sth->fetchrow_hashref;
	$template->param(liblibrarian => $data->{'liblibrarian'},
							tagsubfield => $data->{'tagsubfield'},
							delete_link => $script_name,
							tagfield      =>$tagfield,
							tagsubfield => $tagsubfield,
							authtypecode => $authtypecode,
							);
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	unless (C4::Context->config('demo') or C4::Context->config('demo') eq 1) {
		my $sth=$dbh->prepare("delete from auth_subfield_structure where tagfield=? and tagsubfield=? and authtypecode=?");
		$sth->execute($tagfield,$tagsubfield,$authtypecode);
	}
    print $input->redirect("/cgi-bin/koha/admin/auth_subfields_structure.pl?tagfield=$tagfield&amp;authtypecode=$authtypecode");
    exit;
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	my ($count,$results)=string_search($tagfield,$authtypecode);
	my @loop_data = ();
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
		my %row_data;  # get a fresh hash for the row data
		$row_data{tagfield} = $results->[$i]{'tagfield'};
		$row_data{tagsubfield} = $results->[$i]{'tagsubfield'};
		$row_data{liblibrarian} = $results->[$i]{'liblibrarian'};
		$row_data{kohafield} = $results->[$i]{'kohafield'};
		$row_data{repeatable} = $results->[$i]{'repeatable'};
		$row_data{mandatory} = $results->[$i]{'mandatory'};
		$row_data{tab} = $results->[$i]{'tab'};
		$row_data{seealso} = $results->[$i]{'seealso'};
		$row_data{authorised_value} = $results->[$i]{'authorised_value'};
		$row_data{authtypecode}	= $results->[$i]{'authtypecode'};
		$row_data{value_builder}	= $results->[$i]{'value_builder'};
		$row_data{hidden}	= $results->[$i]{'hidden'} if($results->[$i]{'hidden'} gt "000") ;
		$row_data{isurl}	= $results->[$i]{'isurl'};
		$row_data{delete} = "$script_name?op=delete_confirm&amp;tagfield=$tagfield&amp;tagsubfield=".$results->[$i]{'tagsubfield'}."&amp;authtypecode=$authtypecode";
		if ($row_data{tab} eq -1) {
			$row_data{subfield_ignored} = 1;
		}

		push(@loop_data, \%row_data);
	}
	$template->param(loop => \@loop_data);
	$template->param(edit_tagfield => $tagfield,
		edit_authtypecode => $authtypecode);
	
	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$template->param(prev =>"<a href=\"$script_name?offset=$prevpage\">");
	}
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		$template->param(next => "<a href=\"$script_name?offset=$nextpage\">");
	}
} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;
