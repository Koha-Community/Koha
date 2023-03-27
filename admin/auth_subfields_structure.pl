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
use C4::Output qw( output_html_with_http_headers );
use C4::Auth qw( get_template_and_user );
use CGI qw ( -utf8 );
use C4::Context;

use Koha::Authority::Types;
use Koha::AuthorisedValues;
use Koha::Authority::Subfields;

use List::MoreUtils qw( uniq );

my $input        = CGI->new;
my $tagfield     = $input->param('tagfield');
my $tagsubfield  = $input->param('tagsubfield');
my $authtypecode = $input->param('authtypecode');
my $op           = $input->param('op') || '';
my $script_name  = "/cgi-bin/koha/admin/auth_subfields_structure.pl";

my ($template, $borrowernumber, $cookie) = get_template_and_user(
    {   template_name   => "admin/auth_subfields_structure.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_marc_frameworks' },
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
    my $cgidir = C4::Context->config('intranetdir') . "/cgi-bin";
    my $dir_h;
    unless ( opendir( $dir_h, "$cgidir/cataloguing/value_builder" ) ) {
        $cgidir = C4::Context->config('intranetdir');
        opendir( $dir_h, "$cgidir/cataloguing/value_builder" ) || die "can't opendir $cgidir/value_builder: $!";
    }
    while ( my $line = readdir($dir_h) ) {
        if (   $line =~ /\.pl$/
            && $line !~ /EXAMPLE\.pl$/ ) {    # documentation purposes
            push( @value_builder, $line );
        }
    }
    @value_builder = sort { $a cmp $b } @value_builder;
    closedir $dir_h;

    my @loop_data;
    my $asses = Koha::Authority::Subfields->search({ tagfield => $tagfield, authtypecode => $authtypecode}, {order_by => 'display_order'})->unblessed;
    my $i;
    for my $ass ( @$asses ) {
        my %row_data = %$ass;
        $row_data{kohafields}        = \@kohafields;
        $row_data{authorised_values} = \@authorised_value_categories;
        $row_data{frameworkcodes}    = \@authtypes;
        $row_data{value_builders}    = \@value_builder;
        $row_data{row}               = $i++;
        push( @loop_data, \%row_data );
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

    my $display_order;
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
            my $ass = Koha::Authority::Subfields->find(
                {
                    authtypecode => $authtypecode,
                    tagfield     => $tagfield,
                    tagsubfield  => $tagsubfield
                }
            );
            my $attributes = {
                liblibrarian     => $liblibrarian,
                libopac          => $libopac,
                repeatable       => $repeatable,
                mandatory        => $mandatory,
                kohafield        => $kohafield,
                tab              => $tab,
                seealso          => $seealso,
                authorised_value => $authorised_value,
                frameworkcode    => $frameworkcode,
                value_builder    => $value_builder,
                hidden           => $hidden,
                isurl            => $isurl,
                defaultvalue     => $defaultvalue,
                display_order    => $display_order->{$tagfield} || 0,
            };

            if ($ass) {
                $ass->update($attributes);
            }
            else {
                Koha::Authority::Subfield->new(
                    {
                        authtypecode => $authtypecode,
                        tagfield     => $tagfield,
                        tagsubfield  => $tagsubfield,
                        %$attributes
                    }
                )->store;
            }
            $display_order->{$tagfield}++;
        }
	}
    print $input->redirect("/cgi-bin/koha/admin/auth_subfields_structure.pl?tagfield=$tagfield&amp;authtypecode=$authtypecode");
    exit;

													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirm' ) {
  my $ass = Koha::Authority::Subfields->find(
      {
          authtypecode => $authtypecode,
          tagfield     => $tagfield,
          tagsubfield  => $tagsubfield
      }
  );
  $template->param(
      ass         => $ass,
      delete_link => $script_name,
  );
}
elsif ( $op eq 'delete_confirmed' ) {
    Koha::Authority::Subfields->find(
        {
            authtypecode => $authtypecode,
            tagfield     => $tagfield,
            tagsubfield  => $tagsubfield
        }
    )->delete;
    print $input->redirect("/cgi-bin/koha/admin/auth_subfields_structure.pl?tagfield=$tagfield&amp;authtypecode=$authtypecode");
    exit;
}
else {    # DEFAULT
    my $ass = Koha::Authority::Subfields->search(
        {
            tagfield      => { -like => "$tagfield%" },
            authtypecode  => $authtypecode,
        },
        { order_by => [ 'tagfield', 'display_order' ] }
    )->unblessed;

    $template->param( loop => $ass );
    $template->param(
        edit_tagfield      => $tagfield,
        edit_authtypecode  => $authtypecode,
    );

} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;
