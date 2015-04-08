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
use C4::Letters;
use C4::Members::Attributes;

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
my $module      = $input->param('module') || '';
my $content     = $input->param('content');
my $op          = $input->param('op') || '';
my $dbh = C4::Context->dbh;

our ( $template, $borrowernumber, $cookie, $staffflags ) = get_template_and_user(
    {
        template_name   => 'tools/letter.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { tools => 'edit_notices' },
        debug           => 1,
    }
);

our $my_branch = C4::Context->preference("IndependentBranches") && !$staffflags->{'superlibrarian'}
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

if ( $op eq 'add_validate' or $op eq 'copy_validate' ) {
    add_validate();
    $op = q{}; # we return to the default screen for the next operation
}
if ($op eq 'copy_form') {
    my $oldbranchcode = $input->param('oldbranchcode') || q||;
    my $branchcode = $input->param('branchcode') || q||;
    add_form($oldbranchcode, $module, $code);
    $template->param(
        oldbranchcode => $oldbranchcode,
        branchcode => $branchcode,
        branchloop => _branchloop($branchcode),
        copying => 1,
        modify => 0,
    );
}
elsif ( $op eq 'add_form' ) {
    add_form($branchcode, $module, $code);
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
    my ( $branchcode,$module, $code ) = @_;

    my $letters;
    # if code has been passed we can identify letter and its an update action
    if ($code) {
        $letters = C4::Letters::GetLetterTemplates(
            {
                branchcode => $branchcode,
                module     => $module,
                code       => $code,
            }
        );
    }

    my $message_transport_types = GetMessageTransportTypes();
    my @letter_loop;
    if ($letters) {
        $template->param(
            modify     => 1,
            code       => $code,
            branchcode => $branchcode,
        );
        my $first_flag = 1;
        # The letter name is contained into each mtt row.
        # So we can only sent the first one to the template.
        for my $mtt ( @$message_transport_types ) {
            # The letter_name
            if ( $first_flag and $letters->{$mtt}{name} ) {
                $template->param(
                    letter_name=> $letters->{$mtt}{name},
                );
                $first_flag = 0;
            }

            push @letter_loop, {
                message_transport_type => $mtt,
                is_html    => $letters->{$mtt}{is_html},
                title      => $letters->{$mtt}{title},
                content    => $letters->{$mtt}{content}//'',
            };
        }
    }
    else { # initialize the new fields
        for my $mtt ( @$message_transport_types ) {
            push @letter_loop, {
                message_transport_type => $mtt,
            }
        }
        $template->param(
            branchcode => $branchcode,
            module     => $module,
        );
        $template->param( adding => 1 );
    }

    $template->param(
        letters => \@letter_loop,
    );

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
        module     => $module,
        branchloop => _branchloop($branchcode),
        SQLfieldname => $field_selection,
    );
    return;
}

sub add_validate {
    my $dbh        = C4::Context->dbh;
    my $branchcode    = $input->param('branchcode') || '';
    my $module        = $input->param('module');
    my $oldmodule     = $input->param('oldmodule');
    my $code          = $input->param('code');
    my $name          = $input->param('name');
    my @mtt           = $input->param('message_transport_type');
    my @title         = $input->param('title');
    my @content       = $input->param('content');
    for my $mtt ( @mtt ) {
        my $is_html = $input->param("is_html_$mtt");
        my $title   = shift @title;
        my $content = shift @content;
        my $letter = C4::Letters::getletter( $oldmodule, $code, $branchcode, $mtt);

        # getletter can return the default letter even if we pass a branchcode
        # If we got the default one and we needed the specific one, we didn't get the one we needed!
        if ( $letter and $branchcode ne $letter->{branchcode} ) {
            $letter = undef;
        }
        unless ( $title and $content ) {
            # Delete this mtt if no title or content given
            delete_confirmed( $branchcode, $oldmodule, $code, $mtt );
            next;
        }
        elsif ( $letter and $letter->{message_transport_type} eq $mtt ) {
            $dbh->do(
                q{
                    UPDATE letter
                    SET branchcode = ?, module = ?, name = ?, is_html = ?, title = ?, content = ?
                    WHERE branchcode = ? AND module = ? AND code = ? AND message_transport_type = ?
                },
                undef,
                $branchcode, $module, $name, $is_html || 0, $title, $content,
                $branchcode, $oldmodule, $code, $mtt
            );
        } else {
            $dbh->do(
                q{INSERT INTO letter (branchcode,module,code,name,is_html,title,content,message_transport_type) VALUES (?,?,?,?,?,?,?,?)},
                undef,
                $branchcode, $module, $code, $name, $is_html || 0, $title, $content, $mtt
            );
        }
    }
    # set up default display
    default_display($branchcode);
    return 1;
}

sub delete_confirm {
    my ($branchcode, $module, $code) = @_;
    my $dbh = C4::Context->dbh;
    my $letter = C4::Letters::getletter($module, $code, $branchcode);
    my @values = values %$letter;
    $template->param(
        letter => $letter,
    );
    return;
}

sub delete_confirmed {
    my ($branchcode, $module, $code, $mtt) = @_;
    C4::Letters::DelLetter(
        {
            branchcode => $branchcode,
            module     => $module,
            code       => $code,
            mtt        => $mtt
        }
    );
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
            LEFT OUTER JOIN branches USING (branchcode)
    ";
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
    $sql .= " GROUP BY branchcode,module,code";
    $sql .= " ORDER BY module, code, branchcode";

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
