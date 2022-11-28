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
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Letters qw( GetMessageTransportTypes );
use C4::Log qw( logaction );

use Koha::Notice::Templates;
use Koha::Patron::Attribute::Types;

# $protected_letters = protected_letters()
# - return a hashref of letter_codes representing letters that should never be deleted
sub protected_letters {
    my $dbh = C4::Context->dbh;
    my $codes = $dbh->selectall_arrayref(q{SELECT DISTINCT letter_code FROM message_transports});
    return { map { $_->[0] => 1 } @{$codes} };
}

our $input       = CGI->new;
my $searchfield = $input->param('searchfield');
my $script_name = '/cgi-bin/koha/tools/letter.pl';
our $branchcode  = $input->param('branchcode');
$branchcode = '' if defined $branchcode and $branchcode eq '*';
my $code        = $input->param('code');
my $module      = $input->param('module') || '';
my $content     = $input->param('content');
my $op          = $input->param('op') || '';
my $redirect    = $input->param('redirect');
my $section     = $input->param('section');

my $dbh = C4::Context->dbh;

our ( $template, $borrowernumber, $cookie, $staffflags ) = get_template_and_user(
    {
        template_name   => 'tools/letter.tt',
        query           => $input,
        type            => 'intranet',
        flagsrequired   => { tools => 'edit_notices' },
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
    section => $section,
	action => $script_name
);

if ( $op eq 'add_validate' or $op eq 'copy_validate' ) {
    add_validate();
    if( $redirect eq "just_save" ){
        print $input->redirect("/cgi-bin/koha/tools/letter.pl?op=add_form&branchcode=$branchcode&module=$module&code=$code&redirect=done&section=$section");
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
        my $lang;
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
                updated_on => $letter->{updated_on},
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
        push @{$field_selection}, add_fields('aqbooksellers', 'serial', 'subscription', 'biblio', 'biblioitems');
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
            push @{$field_selection}, add_fields('additional_contents');

        }

        if ( $module eq 'circulation' and $code and ( $code eq "CHECKIN" or $code eq "CHECKINSLIP" ) ) {
            push @{$field_selection}, add_fields('old_issues');
        } else {
            push @{$field_selection}, add_fields('issues');
        }

        if ( $module eq 'circulation' and $code and $code =~ /^AR_/  ) {
            push @{$field_selection}, add_fields('article_requests');
        }

        if ( $module eq 'members' and $code and $code eq 'PROBLEM_REPORT' ) {
            push @{$field_selection}, add_fields('problem_reports');
        }

        if ( $module eq 'ill' ) {
            push @{$field_selection}, add_fields('illrequests');
        }
    }

    my $preview_is_available = 0;

    if ($code) {
        $preview_is_available = grep {$_ eq $code } qw( CHECKIN CHECKOUT HOLD_SLIP );
    }

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
        my $lang = shift @lang;
        my $is_html = $input->param("is_html_$mtt\_$lang");
        my $title   = shift @title;
        my $content = shift @content;
        my $letter = Koha::Notice::Templates->find(
            {
                module                 => $oldmodule,
                code                   => $code,
                branchcode             => $branchcode,
                message_transport_type => $mtt,
                lang                   => $lang
            }
        );

        unless ( $title and $content ) {
            # Delete this mtt if no title or content given
            delete_confirmed( $branchcode, $oldmodule, $code, $mtt, $lang );
            next;
        }
        elsif ( $letter ) {
            logaction( 'NOTICES', 'MODIFY', $letter->id, $content,
                'Intranet' )
              if ( C4::Context->preference("NoticesLog")
                && $content ne $letter->content );

            $letter->set(
                {
                    branchcode => $branchcode || '',
                    module     => $module,
                    name       => $name,
                    is_html    => $is_html || 0,
                    title      => $title,
                    content    => $content,
                    lang       => $lang
                }
            )->store;

        } else {
            my $letter = Koha::Notice::Template->new(
                {
                    branchcode             => $branchcode,
                    module                 => $module,
                    code                   => $code,
                    name                   => $name,
                    is_html                => $is_html,
                    title                  => $title,
                    content                => $content,
                    message_transport_type => $mtt,
                    lang                   => $lang
                }
            )->store;
            logaction( 'NOTICES', 'CREATE', $letter->id, $letter->content,
                'Intranet' )
              if C4::Context->preference("NoticesLog");
        }
    }
    # set up default display
    default_display($branchcode);
    return 1;
}

sub delete_confirm {
    my ($branchcode, $module, $code) = @_;
    my $dbh = C4::Context->dbh;
    my $letter = Koha::Notice::Templates->search(
        { module => $module, code => $code, branchcode => $branchcode } );
    $template->param(
        letter => $letter ? $letter->next : undef,
    );
    return;
}

sub delete_confirmed {
    my ( $branchcode, $module, $code, $mtt, $lang ) = @_;
    my $letters = Koha::Notice::Templates->search(
        {
            branchcode => $branchcode || '',
            module     => $module,
            code       => $code,
            ( $mtt ? ( message_transport_type => $mtt ) : () ),
            ( $lang ? ( lang => $lang ) : () ),
        }
    );
    while ( my $letter = $letters->next ) {
        logaction( 'NOTICES', 'DELETE', $letter->id, $letter->content,
            'Intranet' )
          if C4::Context->preference("NoticesLog");
        $letter->delete;
    }

    # setup default display for screen
    default_display($branchcode);
    return;
}

sub retrieve_letters {
    my ($branchcode, $searchstring) = @_;

    $branchcode = $my_branch if $branchcode && $my_branch;

    my $dbh = C4::Context->dbh;
    my ($sql, @where, @args);
    $sql = "SELECT branchcode, module, code, name, branchname, MAX(updated_on) as updated_on
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
    $sql .= " GROUP BY branchcode,module,code,name,branchname";

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
        next if $row->{'Field'} eq 'password'; # passwords can no longer be shown in notices so the password field should be removed as a template option
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
