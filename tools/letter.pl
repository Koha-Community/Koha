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

=head1 tools/letter.pl

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
use warnings;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;

sub StringSearch {
    my ($searchstring) = @_;
    my $dbh = C4::Context->dbh;
    $searchstring =~ s/\'/\\\'/g;
    my @data = split( ' ', $searchstring );
    $data[0] = '' unless @data;
    my $sth = $dbh->prepare("SELECT * FROM letter WHERE (code LIKE ?) ORDER BY module, code");
    $sth->execute("$data[0]%");     # slightly bogus, only searching on first string.
    return $sth->fetchall_arrayref({});
}

our %column_map = (
    aqbooksellers => 'BOOKSELLERS',
    aqorders => 'ORDERS',
    serial => 'SERIALS',
);

sub column_picks ($) {
    # returns @array of values
    my $table = shift or return ();
    my $sth = C4::Context->dbh->prepare("SHOW COLUMNS FROM $table");
    $sth->execute;
    my @SQLfieldname = ();
    push @SQLfieldname, {'value' => "", 'text' => '---' . uc($column_map{$table} || $table) . '---'};
    while (my ($field) = $sth->fetchrow_array) {
        push @SQLfieldname, {
            value => $table . ".$field",
             text => $table . ".$field"
        };
    }
    return @SQLfieldname;
}

my $input       = new CGI;
my $searchfield = $input->param('searchfield');
$searchfield = '' unless defined($searchfield);
# my $offset      = $input->param('offset'); # pagination not implemented
my $script_name = "/cgi-bin/koha/tools/letter.pl";
my $code        = $input->param('code');
my $module      = $input->param('module');
$module = '' unless defined($module);
my $content     = $input->param('content');
my $op          = $input->param('op');
$op = '' unless defined($op);
$searchfield =~ s/\,//g;
my $dbh = C4::Context->dbh;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/letter.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'edit_notices' },
        debug           => 1,
    }
);

if ($op) {
	$template->param($op  => 1);
} else {
	$template->param(else => 1);
}
# we show only the TMPL_VAR names $op

$template->param(
	script_name => $script_name,
	action => $script_name
);
################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ( $op eq 'add_form' ) {

    #---- if primkey exists, it's a modify action, so read values to modify...
    my $letter;
    if ($code) {
        my $sth = $dbh->prepare("SELECT * FROM letter WHERE module=? AND code=?");
        $sth->execute( $module, $code );
        $letter = $sth->fetchrow_hashref;
    }

    # build field list
    my @SQLfieldname;
    foreach (qw(LibrarianFirstname LibrarianSurname LibrarianEmailaddress)) {
        push @SQLfieldname, {value => $_, text => $_};
    }
    push @SQLfieldname, column_picks('branches');

    # add acquisition specific tables
    if ( index( $module, "acquisition" ) > 0 ) {	# FIXME: imprecise comparison
        push @SQLfieldname, column_picks('aqbooksellers'), column_picks('aqorders');
        # add issues specific tables
    }
    elsif ( index( $module, "issues" ) > 0 ) {	# FIXME: imprecise comparison
        push @SQLfieldname, column_picks('aqbooksellers'),
            column_picks('serial'),
            column_picks('subscription'),
            {value => "", text => '---BIBLIO---'};
		foreach(qw(title author serial)) {
        	push @SQLfieldname, {value => "biblio.$_", text => ucfirst($_) };
		}
    }
    else {
        push @SQLfieldname, column_picks('biblio'),
            column_picks('biblioitems'),
            {value => "",              text => '---ITEMS---'  },
            {value => "items.content", text => 'items.content'},
            column_picks('borrowers');
    }
    if ($code) {
        $template->param( modify => 1 );
        $template->param( code   => $letter->{code} );
    }
    else {
        $template->param( adding => 1 );
    }
    $template->param(
        name    => $letter->{name},
        title   => $letter->{title},
        content => ( $content ? $content : $letter->{content} ),
        ( $module ? $module : $letter->{module} ) => 1,
        SQLfieldname => \@SQLfieldname,
    );
################## ADD_VALIDATE ##################################
    # called by add_form, used to insert/modify data in DB
}
elsif ( $op eq 'add_validate' ) {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "REPLACE letter (module,code,name,title,content) VALUES (?,?,?,?,?)");
    $sth->execute(
        $input->param('module'), $input->param('code'),
        $input->param('name'),   $input->param('title'),
        $input->param('content')
    );
    print $input->redirect("letter.pl");
    exit;
################## DELETE_CONFIRM ##################################
    # called by default form, used to confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirm' ) {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM letter WHERE code=?");
    $sth->execute($code);
    my $data = $sth->fetchrow_hashref;
    $template->param( code => $code );
	foreach (qw(module name content)) {
    	$template->param( $_ => $data->{$_} );
	}
################## DELETE_CONFIRMED ##################################
  # called by delete_confirm, used to effectively confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirmed' ) {
    my $dbh    = C4::Context->dbh;
    my $code   = uc( $input->param('code') );
    my $module = $input->param('module');
    my $sth    = $dbh->prepare("DELETE FROM letter WHERE module=? AND code=?");
    $sth->execute( $module, $code );
    print $input->redirect("/cgi-bin/koha/tools/letter.pl");
    exit;
################## DEFAULT ##################################
}
else {    # DEFAULT
    if ( $searchfield ne '' ) {
        $template->param( search      => 1 );
        $template->param( searchfield => $searchfield );
    }
    my ($results) = StringSearch($searchfield);
    my @loop_data = ();
    foreach my $result (@$results) {
        my %row_data;
		foreach my $key (qw(module code name)) {
        	$row_data{$key} = $result->{$key};
		}
        push(@loop_data, \%row_data );
    }
    $template->param( letter => \@loop_data );
}    #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;

