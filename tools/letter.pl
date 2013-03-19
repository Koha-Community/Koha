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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
use C4::Branch; # GetBranches
use C4::Members::Attributes;

# _letter_from_where($branchcode,$module, $code)
# - return FROM WHERE clause and bind args for a letter
sub _letter_from_where {
    my ($branchcode, $module, $code) = @_;
    my $sql = q{FROM letter WHERE branchcode = ? AND module = ? AND code = ?};
    my @args = ($branchcode || '', $module, $code);
# Mysql is retarded. cause branchcode is part of the primary key it cannot be null. How does that
# work with foreign key constraint I wonder...

#   if ($branchcode) {
#       $sql .= " AND branchcode = ?";
#       push @args, $branchcode;
#   } else {
#       $sql .= " AND branchcode IS NULL";
#   }

    return ($sql, \@args);
}

# letter_exists($branchcode,$module, $code)
# - return true if a letter with the given $branchcode, $module and $code exists
sub letter_exists {
    my ($sql, $args) = _letter_from_where(@_);
    my $dbh = C4::Context->dbh;
    my $letter = $dbh->selectrow_hashref("SELECT * $sql", undef, @$args);
    return $letter;
}

# $protected_letters = protected_letters()
# - return a hashref of letter_codes representing letters that should never be deleted
sub protected_letters {
    my $dbh = C4::Context->dbh;
    my $codes = $dbh->selectall_arrayref(q{SELECT DISTINCT letter_code FROM message_transports});
    return { map { $_->[0] => 1 } @{$codes} };
}

our $input       = new CGI;
my $searchfield = $input->param('searchfield');
my $script_name = '/cgi-bin/koha/tools/letter.pl';
our $branchcode  = $input->param('branchcode');
my $code        = $input->param('code');
my $module      = $input->param('module');
my $content     = $input->param('content');
my $op          = $input->param('op') || '';
my $dbh = C4::Context->dbh;

our ( $template, $borrowernumber, $cookie, $staffflags ) = get_template_and_user(
    {
        template_name   => 'tools/letter.tmpl',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { tools => 'edit_notices' },
        debug           => 1,
    }
);

our $my_branch = C4::Context->preference("IndependantBranches") && !$staffflags->{'superlibrarian'}
  ?  C4::Context->userenv()->{'branch'}
  : undef;
# we show only the TMPL_VAR names $op

$template->param(
    independant_branch => $my_branch,
	script_name => $script_name,
  searchfield => $searchfield,
    branchcode => $branchcode,
	action => $script_name
);

if ($op eq 'copy') {
    add_copy();
    $op = 'add_form';
}

if ($op eq 'add_form') {
    add_form($branchcode, $module, $code);
}
elsif ( $op eq 'add_validate' ) {
    add_validate();
    $op = q{}; # next operation is to return to default screen
}
elsif ( $op eq 'delete_confirm' ) {
    delete_confirm($branchcode, $module, $code);
}
elsif ( $op eq 'delete_confirmed' ) {
    delete_confirmed($branchcode, $module, $code);
    $op = q{}; # next operation is to return to default screen
}
else {
    default_display($branchcode,$searchfield);
}

# Do this last as delete_confirmed resets
if ($op) {
    $template->param($op  => 1);
} else {
    $template->param(no_op_set => 1);
}

output_html_with_http_headers $input, $cookie, $template->output;

sub add_form {
    my ($branchcode,$module, $code ) = @_;

    my $letter;
    # if code has been passed we can identify letter and its an update action
    if ($code) {
        $letter = letter_exists($branchcode,$module, $code);
    }
    if ($letter) {
        $template->param( modify => 1 );
        $template->param( code   => $letter->{code} );
    }
    else { # initialize the new fields
        $letter = {
            branchcode => $branchcode,
            module     => $module,
        };
        $template->param( adding => 1 );
    }

    my $field_selection;
    push @{$field_selection}, add_fields('branches');
    if ($module eq 'reserves') {
        push @{$field_selection}, add_fields('borrowers', 'reserves', 'biblio', 'items');
    }
    elsif ($module eq 'claimacquisition') {
        push @{$field_selection}, add_fields('aqbooksellers', 'aqorders', 'biblio', 'biblioitems');
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
    elsif ($module eq 'suggestions') {
        push @{$field_selection}, add_fields('suggestions', 'borrowers', 'biblio');
    }
    else {
        push @{$field_selection}, add_fields('biblio','biblioitems'),
            add_fields('items'),
            {value => 'items.content', text => 'items.content'},
            {value => 'items.fine',    text => 'items.fine'},
            add_fields('borrowers');
        if ($module eq 'circulation') {
            push @{$field_selection}, add_fields('opac_news');

        }

        if ( $module eq 'circulation' && $code eq "CHECKIN" ) {
            push @{$field_selection}, add_fields('old_issues');
        } else {
            push @{$field_selection}, add_fields('issues');
        }
    }

    $template->param(
        branchcode => $letter->{branchcode},
        name       => $letter->{name},
        is_html    => $letter->{is_html},
        title      => $letter->{title},
        content    => $letter->{content},
        module     => $module,
        $module    => 1,
        branchloop => _branchloop($branchcode),
        SQLfieldname => $field_selection,
    );
    return;
}

sub add_validate {
    my $dbh        = C4::Context->dbh;
    my $oldbranchcode = $input->param('oldbranchcode');
    my $branchcode    = $input->param('branchcode') || '';
    my $module        = $input->param('module');
    my $oldmodule     = $input->param('oldmodule');
    my $code          = $input->param('code');
    my $name          = $input->param('name');
    my $is_html       = $input->param('is_html');
    my $title         = $input->param('title');
    my $content       = $input->param('content');
    if (letter_exists($oldbranchcode,$oldmodule, $code)) {
        $dbh->do(
            q{UPDATE letter SET branchcode = ?, module = ?, name = ?, is_html = ?, title = ?, content = ? WHERE branchcode = ? AND module = ? AND code = ?},
            undef,
            $branchcode, $module, $name, $is_html || 0, $title, $content,
            $oldbranchcode, $oldmodule, $code
        );
    } else {
        $dbh->do(
            q{INSERT INTO letter (branchcode,module,code,name,is_html,title,content) VALUES (?,?,?,?,?,?,?)},
            undef,
            $branchcode, $module, $code, $name, $is_html || 0, $title, $content
        );
    }
    # set up default display
    default_display($branchcode);
}

sub add_copy {
    my $dbh        = C4::Context->dbh;
    my $oldbranchcode = $input->param('oldbranchcode');
    my $branchcode    = $input->param('branchcode');
    my $module        = $input->param('module');
    my $code          = $input->param('code');

    return if letter_exists($branchcode,$module, $code);

    my $old_letter = letter_exists($oldbranchcode,$module, $code);

    $dbh->do(
        q{INSERT INTO letter (branchcode,module,code,name,is_html,title,content) VALUES (?,?,?,?,?,?,?)},
        undef,
        $branchcode, $module, $code, $old_letter->{name}, $old_letter->{is_html}, $old_letter->{title}, $old_letter->{content}
    );
}

sub delete_confirm {
    my ($branchcode, $module, $code) = @_;
    my $dbh = C4::Context->dbh;
    my $letter = letter_exists($branchcode, $module, $code);
    $template->param( branchcode => $branchcode, branchname => GetBranchName($branchcode) );
    $template->param( code => $code );
    $template->param( module => $module);
    $template->param( name => $letter->{name});
    return;
}

sub delete_confirmed {
    my ($branchcode, $module, $code) = @_;
    my ($sql, $args) = _letter_from_where($branchcode, $module, $code);
    my $dbh    = C4::Context->dbh;
    $dbh->do("DELETE $sql", undef, @$args);
    # setup default display for screen
    default_display($branchcode);
    return;
}

sub retrieve_letters {
    my ($branchcode, $searchstring) = @_;

    $branchcode = $my_branch if $branchcode && $my_branch;

    my $dbh = C4::Context->dbh;
    my ($sql, @where, @args);
    $sql = "SELECT branchcode, module, code, name, branchname
            FROM letter
            LEFT OUTER JOIN branches USING (branchcode)";
    if ($searchstring && $searchstring=~m/(\S+)/) {
        $searchstring = $1 . q{%};
        push @where, 'code LIKE ?';
        push @args, $searchstring;
    }
    elsif ($branchcode) {
        push @where, 'branchcode = ?';
        push @args, $branchcode || '';
    }
    elsif ($my_branch) {
        push @where, "(branchcode = ? OR branchcode = '')";
        push @args, $my_branch;
    }

    $sql .= " WHERE ".join(" AND ", @where) if @where;
    $sql .= " ORDER BY module, code, branchcode";
#   use Data::Dumper; die Dumper($sql, \@args);
    return $dbh->selectall_arrayref($sql, { Slice => {} }, @args);
}

sub default_display {
    my ($branchcode, $searchfield) = @_;

    if ( $searchfield  ) {
        $template->param( search      => 1 );
    }
    my $results = retrieve_letters($branchcode,$searchfield);

    my $loop_data = [];
    my $protected_letters = protected_letters();
    foreach my $row (@{$results}) {
        $row->{protected} = !$row->{branchcode} && $protected_letters->{ $row->{code} };
        push @{$loop_data}, $row;

    }

    $template->param(
        letter => $loop_data,
        branchloop => _branchloop($branchcode),
    );
}

sub _branchloop {
    my ($branchcode) = @_;

    my $branches = GetBranches();
    my @branchloop;
    for my $thisbranch (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches) {
        push @branchloop, {
            value      => $thisbranch,
            selected   => $branchcode && $thisbranch eq $branchcode,
            branchname => $branches->{$thisbranch}->{'branchname'},
        };
    }

    return \@branchloop;
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
        suggestions   => '---SUGGESTIONS---',
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
        next if $row->{'Field'} eq 'timestamp'; # this is really an irrelevant field and there may be other common fields that should be excluded from the list
        push @fields, {
            value => $table_prefix . $row->{Field},
            text  => $table_prefix . $row->{Field},
        }
    }
    if ($table eq 'borrowers') {
        if ( my $attributes = C4::Members::Attributes::GetAttributes() ) {
            foreach (@$attributes) {
                push @fields, {
                    value => "borrower-attribute:$_",
                    text  => "attribute:$_",
                }
            }
        }
    }
    return @fields;
}
