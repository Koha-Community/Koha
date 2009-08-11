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
 if $op is empty or none of the values listed below,
	- the default screen is built (with all or filtered (if search string is set) records).
	- the   user can click on add, modify or delete record.
    - filtering is done on the code field
 if $op=add_form
	- if primary key (module + code) exists, this is a modification,so we read the required record
	- builds the add/modify form
 if $op=add_validate
	- the user has just send data, so we create/modify the record
 if $op=delete_form
	- we show the record selected and ask for confirmation
 if $op=delete_confirm
	- we delete the designated record

=cut
# TODO This script drives the CRUD operations on the letter table
# The DB interaction should be handled by calls to C4/Letters.pm

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;

# letter_exists($module, $code)
# - return true if a letter with the given $module and $code exists
sub letter_exists {
    my ($module, $code) = @_;
    my $dbh = C4::Context->dbh;
    my $letters = $dbh->selectall_arrayref(q{SELECT name FROM letter WHERE module = ? AND code = ?}, undef, $module, $code);
    return @{$letters};
}

# $protected_letters = protected_letters()
# - return a hashref of letter_codes representing letters that should never be deleted
sub protected_letters {
    my $dbh = C4::Context->dbh;
    my $codes = $dbh->selectall_arrayref(q{SELECT DISTINCT letter_code FROM message_transports});
    return { map { $_->[0] => 1 } @{$codes} };
}

my $input       = new CGI;
my $searchfield = $input->param('searchfield');
my $script_name = '/cgi-bin/koha/tools/letter.pl';
my $code        = $input->param('code');
my $module      = $input->param('module');
my $content     = $input->param('content');
my $op          = $input->param('op');
my $dbh = C4::Context->dbh;
if (!defined $module ) {
    $module = q{};
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => 'tools/letter.tmpl',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { tools => 'edit_notices' },
        debug           => 1,
    }
);

if (!defined $op) {
    $op = q{}; # silence errors from eq
}
# we show only the TMPL_VAR names $op

$template->param(
	script_name => $script_name,
	action => $script_name
);

if ($op eq 'add_form') {
    add_form($module, $code);
}
elsif ( $op eq 'add_validate' ) {
    add_validate();
    $op = q{}; # next operation is to return to default screen
}
elsif ( $op eq 'delete_confirm' ) {
    delete_confirm($module, $code);
}
elsif ( $op eq 'delete_confirmed' ) {
    delete_confirmed($module, $code);
    $op = q{}; # next operation is to return to default screen
}
else {
    default_display($searchfield);
}

# Do this last as delete_confirmed resets
if ($op) {
    $template->param($op  => 1);
} else {
    $template->param(no_op_set => 1);
}

output_html_with_http_headers $input, $cookie, $template->output;

sub add_form {
    my ($module, $code ) = @_;

    my $letter;
    # if code has been passed we can identify letter and its an update action
    if ($code) {
        $letter = $dbh->selectrow_hashref(q{SELECT module, code, name, title, content FROM letter WHERE module=? AND code=?},
            undef, $module, $code);
        $template->param( modify => 1 );
        $template->param( code   => $letter->{code} );
    }
    else { # initialize the new fields
        $letter = {
            module  => $module,
            code    => q{},
            name    => q{},
            title   => q{},
            content => q{},
        };
        $template->param( adding => 1 );
    }

    # build field list
    my $field_selection = [
    {
        value => 'LibrarianFirstname',
        text  => 'LibrarianFirstname',
    },
    {
        value => 'LibrarianSurname',
        text  => 'LibrarianSurname',
    },
    {
        value => 'LibrarianEmailaddress',
        text  => 'LibrarianEmailaddress',
    }
    ];
    push @{$field_selection}, add_fields('branches');
    if ($module eq 'reserves') {
        push @{$field_selection}, add_fields('borrowers', 'reserves', 'biblio', 'items');
    }
    elsif ($module eq 'claimacquisition') {
        push @{$field_selection}, add_fields('aqbooksellers', 'aqorders');
    }
    elsif ($module eq 'claimissues') {
        push @{$field_selection}, add_fields('aqbooksellers', 'serial', 'subscription');
        push @{$field_selection},
        {
            value => q{},
            text => '---BIBLIO---'
        };
        foreach(qw(title author serial)) {
            push @{$field_selection}, {value => "biblio.$_", text => ucfirst $_ };
        }
    }
    else {
        push @{$field_selection}, add_fields('biblio','biblioitems'),
            {value => q{},             text => '---ITEMS---'  },
            {value => 'items.content', text => 'items.content'},
            add_fields('borrowers');
    }

    $template->param(
        name    => $letter->{name},
        title   => $letter->{title},
        content => $letter->{content},
        $module => 1,
        SQLfieldname => $field_selection,
    );
    return;
}

sub add_validate {
    my $dbh     = C4::Context->dbh;
    my $module  = $input->param('module');
    my $code    = $input->param('code');
    my $name    = $input->param('name');
    my $title   = $input->param('title');
    my $content = $input->param('content');
    if (letter_exists($module, $code)) {
        $dbh->do(
            q{UPDATE letter SET module = ?, code = ?, name = ?, title = ?, content = ? WHERE module = ? AND code = ?},
            undef,
            $module, $code, $name, $title, $content,
            $module, $code
        );
    } else {
        $dbh->do(
            q{INSERT INTO letter (module,code,name,title,content) VALUES (?,?,?,?,?)},
            undef,
            $module, $code, $name, $title, $content
        );
    }
    # set up default display
    default_display();
    return;
}

sub delete_confirm {
    my ($module, $code) = @_;
    my $dbh = C4::Context->dbh;
    my $letter = $dbh->selectrow_hashref(q|SELECT  name FROM letter WHERE module = ? AND code = ?|,
        { Slice => {} },
        $module, $code);
    $template->param( code => $code );
    $template->param( module => $module);
    $template->param( name => $letter->{name});
    return;
}

sub delete_confirmed {
    my ($module, $code) = @_;
    my $dbh    = C4::Context->dbh;
    $dbh->do('DELETE FROM letter WHERE module=? AND code=?',{},$module,$code);
    # setup default display for screen
    default_display();
    return;
}

sub retrieve_letters {
    my $searchstring = shift;
    my $dbh = C4::Context->dbh;
    if ($searchstring) {
        if ($searchstring=~m/(\S+)/) {
            $searchstring = $1 . q{%};
            return $dbh->selectall_arrayref('SELECT module, code, name FROM letter WHERE code LIKE ? ORDER BY module, code',
                { Slice => {} }, $searchstring);
        }
    }
    else {
        return $dbh->selectall_arrayref('SELECT module, code, name FROM letter ORDER BY module, code', { Slice => {} });
    }
    return;
}

sub default_display {
    my $searchfield = shift;
    my $results;
    if ( $searchfield  ) {
        $template->param( search      => 1 );
        $template->param( searchfield => $searchfield );
        $results = retrieve_letters($searchfield);
    } else {
        $results = retrieve_letters();
    }
    my $loop_data = [];
    my $protected_letters = protected_letters();
    foreach my $row (@{$results}) {
        $row->{protected} = $protected_letters->{ $row->{code}};
        push @{$loop_data}, $row;

    }
    $template->param( letter => $loop_data );
    return;
}

sub add_fields {
    my @tables = @_;
    my @fields = ();

    for my $table (@tables) {
        push @fields, get_columns_for($table);

    }
    return @fields;
}

sub get_columns_for {
    my $table = shift;
# FIXME untranslateable
    my %column_map = (
        aqbooksellers => '---BOOKSELLERS---',
        aqorders      => '---ORDERS---',
        serial        => '---SERIALS---',
        reserves      => '---HOLDS---',
    );
    my @fields = ();
    if (exists $column_map{$table} ) {
        push @fields, {
            value => q{},
            text  => $column_map{$table} ,
        };
    }
    else {
        my $tlabel = '---' . uc $table;
        $tlabel.= '---';
        push @fields, {
            value => q{},
            text  => $tlabel,
        };
    }
    my $sql = "SHOW COLUMNS FROM $table";# TODO not db agnostic
    my $table_prefix = $table . q|.|;
    my $rows = C4::Context->dbh->selectall_arrayref($sql, { Slice => {} });
    for my $row (@{$rows}) {
        push @fields, {
            value => $table_prefix . $row->{Field},
            text  => $table_prefix . $row->{Field},
        }
    }
    return @fields;
}
