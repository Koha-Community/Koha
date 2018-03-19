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

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Letters;

use Koha::Patron::Attribute::Types;

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
$branchcode = '' if defined $branchcode and $branchcode eq '*';
my $code        = $input->param('code');
my $module      = $input->param('module') || '';
my $content     = $input->param('content');
my $op          = $input->param('op') || '';
my $redirect      = $input->param('redirect');
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
    if( $redirect eq "just_save" ){
        print $input->redirect("/cgi-bin/koha/tools/letter.pl?op=add_form&branchcode=$branchcode&module=$module&code=$code&redirect=done");
        exit;
    } else {
        $op = q{}; # we return to the default screen for the next operation
    }
}
if ($op eq 'copy_form') {
    my $oldbranchcode = $input->param('oldbranchcode') || q||;
    my $branchcode = $input->param('branchcode');
    add_form($oldbranchcode, $module, $code);
    $template->param(
        oldbranchcode => $oldbranchcode,
        branchcode => $branchcode,
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
    my $templates = { map { $_ => { message_transport_type => $_ } } sort @$message_transport_types };
    my %letters = ( default => { templates => $templates } );

    if ( C4::Context->preference('TranslateNotices') ) {
        my $translated_languages =
          C4::Languages::getTranslatedLanguages( 'opac',
            C4::Context->preference('template') );
        for my $language (@$translated_languages) {
            for my $sublanguage( @{ $language->{sublanguages_loop} } ) {
                if ( $language->{plural} ) {
                    $letters{ $sublanguage->{rfc4646_subtag} } = {
                        description => $sublanguage->{native_description}
                          . ' '
                          . $sublanguage->{region_description} . ' ('
                          . $sublanguage->{rfc4646_subtag} . ')',
                        templates => { %$templates },
                    };
                }
                else {
                    $letters{ $sublanguage->{rfc4646_subtag} } = {
                        description => $sublanguage->{native_description}
                          . ' ('
                          . $sublanguage->{rfc4646_subtag} . ')',
                        templates => { %$templates },
                    };
                }
            }
        }
        $template->param( languages => $translated_languages );
    }
    if ($letters) {
        $template->param(
            modify     => 1,
            code       => $code,
        );
        my $first_flag_name = 1;
        my ( $lang, @templates );
        # The letter name is contained into each mtt row.
        # So we can only sent the first one to the template.
        for my $letter ( @$letters ) {
            # The letter_name
            if ( $first_flag_name and $letter->{name} ) {
                $template->param(
                    letter_name=> $letter->{name},
                );
                $first_flag_name = 0;
            }

            my $lang = $letter->{lang};
            my $mtt = $letter->{message_transport_type};
            $letters{ $lang }{templates}{$mtt} = {
                message_transport_type => $letter->{message_transport_type},
                is_html    => $letter->{is_html},
                title      => $letter->{title},
                content    => $letter->{content} // '',
            };
        }
    }
    else {
        $template->param( adding => 1 );
    }

    $template->param(
        letters => \%letters,
    );

    my $field_selection;
    push @{$field_selection}, add_fields('branches');
    if ($module eq 'reserves') {
        push @{$field_selection}, add_fields('borrowers', 'reserves', 'biblio', 'biblioitems', 'items');
    }
    elsif ( $module eq 'acquisition' ) {
        push @{$field_selection}, add_fields('aqbooksellers', 'aqorders', 'biblio', 'items');
    }
    elsif ($module eq 'claimacquisition' || $module eq 'orderacquisition') {
        push @{$field_selection}, add_fields('aqbooksellers', 'aqbasket', 'aqorders', 'biblio', 'biblioitems');
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
    elsif ($module eq 'serial') {
        push @{$field_selection}, add_fields('branches', 'biblio', 'biblioitems', 'borrowers', 'subscription', 'serial');
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

        if ( $module eq 'circulation' and $code and $code eq "CHECKIN" ) {
            push @{$field_selection}, add_fields('old_issues');
        } else {
            push @{$field_selection}, add_fields('issues');
        }

        if ( $module eq 'circulation' and $code =~ /^AR_/  ) {
            push @{$field_selection}, add_fields('article_requests');
        }
    }

    my $preview_is_available = grep {/^$code$/} qw(
        CHECKIN CHECKOUT HOLD_SLIP
    );
    $template->param(
        module     => $module,
        SQLfieldnames => $field_selection,
        branchcode => $branchcode,
        preview_is_available => $preview_is_available,
    );
    return;
}

sub add_validate {
    my $dbh        = C4::Context->dbh;
    my $branchcode    = $input->param('branchcode');
    my $module        = $input->param('module');
    my $oldmodule     = $input->param('oldmodule');
    my $code          = $input->param('code');
    my $name          = $input->param('name');
    my @mtt           = $input->multi_param('message_transport_type');
    my @title         = $input->multi_param('title');
    my @content       = $input->multi_param('content');
    my @lang          = $input->multi_param('lang');
    for my $mtt ( @mtt ) {
        my $is_html = $input->param("is_html_$mtt");
        my $title   = shift @title;
        my $content = shift @content;
        my $lang = shift @lang;
        my $letter = C4::Letters::getletter( $oldmodule, $code, $branchcode, $mtt, $lang );

        # getletter can return the default letter even if we pass a branchcode
        # If we got the default one and we needed the specific one, we didn't get the one we needed!
        if ( $letter and $branchcode and $branchcode ne $letter->{branchcode} ) {
            $letter = undef;
        }
        unless ( $title and $content ) {
            # Delete this mtt if no title or content given
            delete_confirmed( $branchcode, $oldmodule, $code, $mtt, $lang );
            next;
        }
        elsif ( $letter and $letter->{message_transport_type} eq $mtt and $letter->{lang} eq $lang ) {
            $dbh->do(
                q{
                    UPDATE letter
                    SET branchcode = ?, module = ?, name = ?, is_html = ?, title = ?, content = ?, lang = ?
                    WHERE branchcode = ? AND module = ? AND code = ? AND message_transport_type = ? AND lang = ?
                },
                undef,
                $branchcode || '', $module, $name, $is_html || 0, $title, $content, $lang,
                $branchcode, $oldmodule, $code, $mtt, $lang
            );
        } else {
            $dbh->do(
                q{INSERT INTO letter (branchcode,module,code,name,is_html,title,content,message_transport_type, lang) VALUES (?,?,?,?,?,?,?,?,?)},
                undef,
                $branchcode || '', $module, $code, $name, $is_html || 0, $title, $content, $mtt, $lang
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
    my ($branchcode, $module, $code, $mtt, $lang) = @_;
    C4::Letters::DelLetter(
        {
            branchcode => $branchcode || '',
            module     => $module,
            code       => $code,
            mtt        => $mtt,
            lang       => $lang,
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

    unless ( defined $branchcode ) {
        if ( C4::Context->preference('DefaultToLoggedInLibraryNoticesSlips') ) {
            $branchcode = C4::Context::mybranch();
        }
    }

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
        branchcode => $branchcode,
    );
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
# FIXME untranslatable
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
        my $attribute_types = Koha::Patron::Attribute::Types->search(
            {},
            { order_by => 'code' },
        );
        while ( my $at = $attribute_types->next ) {
            push @fields, {
                value => "borrower-attribute:" . $at->code,
                text  => "attribute:" . $at->code,
            }
        }
    }
    return @fields;
}
