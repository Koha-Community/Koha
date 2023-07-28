#!/usr/bin/perl

# This file is part of Koha.
#
# Script to manage the opac news.
# written 11/04
# Casta�eda, Carlos Sebastian - seba3c@yahoo.com.ar - Physics Library UNLP Argentina
# Modified to include news to KOHA intranet - tgarip@neu.edu.tr NEU library -Cyprus
# Copyright 2000-2002 Katipo Communications
# Copyright (C) 2013    Mark Tompsett
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
use CGI qw ( -utf8 );
use C4::Auth qw(get_template_and_user);
use C4::Koha;
use C4::Context;
use C4::Log qw( logaction );
use C4::Output qw(output_html_with_http_headers output_and_exit_if_error);
use C4::Languages qw(getTranslatedLanguages);
use Koha::DateUtils qw( dt_from_string output_pref );

use Koha::AdditionalContents;

my $cgi = CGI->new;

my $op             = $cgi->param('op') || 'list';
my $id             = $cgi->param('id');
my $category       = $cgi->param('category') || 'news';
my $wysiwyg;
my $redirect       = $cgi->param('redirect');
my $editmode;

if( $cgi->param('editmode') ){
    $wysiwyg = $cgi->param('editmode') eq "wysiwyg" ? 1 : 0;
} else {
    $wysiwyg = C4::Context->preference("AdditionalContentsEditor") eq "tinymce" ? 1 : 0;
}

$editmode = $wysiwyg eq 1 ? "wysiwyg" : "text";

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/additional-contents.tt",
        query           => $cgi,
        type            => "intranet",
        flagsrequired   => { tools => 'edit_additional_contents' },
    }
);

my @messages;
if ( $op eq 'add_form' ) {

    my $additional_content = Koha::AdditionalContents->find($id);
    my $translated_contents;
    if ( $additional_content ) {
        $translated_contents = {
            map { $_->lang => $_ } Koha::AdditionalContents->search(
                {
                    category   => $additional_content->category,
                    code       => $additional_content->code,
                    location   => $additional_content->location,
                    branchcode => $additional_content->branchcode,
                }
            )
        };
        $category = $additional_content->category;
    }
    $template->param(
        additional_content => $additional_content,
        translated_contents => $translated_contents,
    );
}
elsif ( $op eq 'add_validate' ) {
    output_and_exit_if_error($cgi, $cookie, $template, { check => 'csrf_token' });
    my $location   = $cgi->param('location');
    my $code       = $cgi->param('code');
    my $branchcode = $cgi->param('branchcode') || undef;

    my @lang       = $cgi->multi_param('lang');

    my $expirationdate;
    if ( $cgi->param('expirationdate') ) {
        $expirationdate = dt_from_string( scalar $cgi->param('expirationdate') );
    }
    my $published_on = dt_from_string( scalar $cgi->param('published_on') );
    my $number = $cgi->param('number');

    my $success = 1;
    for my $lang ( sort {$a ne 'default'} @lang ) { # Process 'default' first
        my $title   = $cgi->param( 'title_' . $lang );
        my $content = $cgi->param( 'content_' . $lang );
        # Force a default record
        $content ||= '<!-- no_content -->' if $lang eq 'default';

        my $additional_content = Koha::AdditionalContents->find(
            {
                category   => $category,
                code       => $code,
                branchcode => $branchcode,
                lang       => $lang,
            }
        );
        # Delete if title or content is empty
        if( $lang ne 'default' && !$title && !$content ) {
            if ( $additional_content ) {
                eval { $additional_content->delete };
                unless ($@) {
                    logaction('NEWS', 'DELETE' , undef, sprintf("%s|%s|%s|%s", $additional_content->code, $additional_content->title, $additional_content->lang, $additional_content->content));
                }
            }
            next;
        } elsif ( $additional_content ) {
            my $updated;
            eval {
                $additional_content->set(
                    {
                        category       => $category,
                        code           => $code,
                        location       => $location,
                        branchcode     => $branchcode,
                        title          => $title,
                        content        => $content,
                        lang           => $lang,
                        expirationdate => $expirationdate,
                        published_on   => $published_on,
                        number         => $number,
                        borrowernumber => $borrowernumber,
                    }
                );
                $updated = $additional_content->_result->get_dirty_columns;
                $additional_content->store;
                $id = $additional_content->idnew;
            };
            if ($@) {
                $success = 0;
                push @messages, { type => 'error', code => 'error_on_update' };
                last;
            }

            logaction('NEWS', 'MODIFY' , undef, sprintf("%s|%s|%s|%s", $code, $title, $lang, $content))
                if C4::Context->preference("NewsLog") && $updated;
        }
        else {
            my $additional_content = Koha::AdditionalContent->new(
                {
                    category       => $category,
                    code           => $code || 'tmp_code',
                    location       => $location,
                    branchcode     => $branchcode,
                    title          => $title,
                    content        => $content,
                    lang           => $lang,
                    expirationdate => $expirationdate,
                    published_on   => $published_on,
                    number         => $number,
                    borrowernumber => $borrowernumber,
                }
            )->store;
            eval {
                $additional_content->store;
                unless ($code) {
                    $additional_content->discard_changes;
                    $code = $category eq 'news'
                      ? 'News_' . $additional_content->idnew
                      : $location . '_' . $additional_content->idnew;
                    $additional_content->code($code)->store;
                    $id = $additional_content->idnew;
                }
            };
            if ($@) {
                $success = 0;
                push @messages, { type => 'error', code => 'error_on_insert' };
                last;
            }

            logaction('NEWS', 'ADD' , undef, sprintf("%s|%s|%s|%s", $code, $title, $lang, $content))
                if C4::Context->preference("NewsLog");
        }

    }

    if( $redirect eq "just_save" ){
        print $cgi->redirect("/cgi-bin/koha/tools/additional-contents.pl?op=add_form&id=$id&category=$category&editmode=$editmode&redirect=done");
        exit;
    } else {
        $op = 'list';
    }
}
elsif ( $op eq 'delete_confirmed' ) {
    output_and_exit_if_error($cgi, $cookie, $template, { check => 'csrf_token' });
    my @ids = $cgi->multi_param('ids');
    my $deleted = eval {

        my $schema = Koha::Database->new->schema;
        $schema->txn_do(
            sub {
                my $contents =
                  Koha::AdditionalContents->search( { idnew => \@ids } );

                while ( my $c = $contents->next ) {
                    Koha::AdditionalContents->search( { code => $c->code } )->delete;
                    if ( C4::Context->preference("NewsLog") ) {
                        logaction('NEWS', 'DELETE' , undef, sprintf("%s|%s|%s|%s", $c->code, $c->title, $c->lang, $c->content));
                    }
                }
            }
        );
    };

    if ( $@ or not $deleted ) {
        push @messages, { type => 'error', code => 'error_on_delete' };
    }
    else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }

    $op = 'list';
}

if ( $op eq 'list' ) {
    my $additional_contents = Koha::AdditionalContents->search(
        { category => $category, lang => 'default' },
        { order_by => { -desc => 'published_on' } }
    );
    $template->param( additional_contents => $additional_contents );
}

my $translated_languages = C4::Languages::getTranslatedLanguages;
my @languages;
for my $language (@$translated_languages) {
    for my $sublanguage ( @{ $language->{sublanguages_loop} } ) {
        if ( $language->{plural} ) {
            push @languages,
              {
                lang        => $sublanguage->{rfc4646_subtag},
                description => $sublanguage->{native_description} . ' '
                  . $sublanguage->{region_description} . ' ('
                  . $sublanguage->{rfc4646_subtag} . ')',
              };
        }
        else {
            push @languages,
              {
                lang        => $sublanguage->{rfc4646_subtag},
                description => $sublanguage->{native_description} . ' ('
                  . $sublanguage->{rfc4646_subtag} . ')',
              };
        }
    }
}
unshift @languages, {lang => 'default'} if @languages;

$template->param(
    op        => $op,
    category  => $category,
    wysiwyg   => $wysiwyg,
    editmode  => $editmode,
    languages => \@languages,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
