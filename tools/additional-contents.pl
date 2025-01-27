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
use Try::Tiny;
use Array::Utils qw( array_minus );
use C4::Auth     qw(get_template_and_user);
use C4::Koha;
use C4::Context;
use C4::Log         qw( logaction );
use C4::Output      qw(output_html_with_http_headers output_and_exit_if_error);
use C4::Languages   qw(getTranslatedLanguages);
use Koha::DateUtils qw( dt_from_string output_pref );

use Koha::AdditionalContents;

my $cgi = CGI->new;

my $op       = $cgi->param('op') || 'list';
my $id       = $cgi->param('id');
my $category = $cgi->param('category') || 'news';
my $wysiwyg;
my $redirect = $cgi->param('redirect');
my $editmode;

if ( $cgi->param('editmode') ) {
    $wysiwyg = $cgi->param('editmode') eq "wysiwyg" ? 1 : 0;
} else {
    $wysiwyg = C4::Context->preference("AdditionalContentsEditor") eq "tinymce" ? 1 : 0;
}

$editmode = $wysiwyg eq 1 ? "wysiwyg" : "text";

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "tools/additional-contents.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { tools => 'edit_additional_contents' },
    }
);

my @messages;
if ( $op eq 'add_form' ) {

    my $additional_content = Koha::AdditionalContents->find($id);
    my $translated_contents;
    if ($additional_content) {
        $translated_contents = { map { $_->lang => $_ } $additional_content->translated_contents->as_list };
        $category            = $additional_content->category;
    }
    $template->param(
        additional_content  => $additional_content,
        translated_contents => $translated_contents,
    );
} elsif ( $op eq 'cud-add_validate' ) {
    output_and_exit_if_error( $cgi, $cookie, $template, { check => 'csrf_token' } );
    my $location   = $cgi->param('location');
    my $code       = $cgi->param('code');
    my $branchcode = $cgi->param('branchcode') || undef;

    my @lang = $cgi->multi_param('lang');

    my $expirationdate = $cgi->param('expirationdate');
    my $published_on   = $cgi->param('published_on');
    my $number         = $cgi->param('number');

    try {
        Koha::Database->new->schema->txn_do(
            sub {
                my $additional_content;
                my $params = {
                    location       => $location,
                    branchcode     => $branchcode,
                    expirationdate => $expirationdate,
                    published_on   => $published_on,
                    number         => $number,
                    borrowernumber => $borrowernumber,
                };

                if ($id) {
                    $additional_content = Koha::AdditionalContents->find($id);
                    $additional_content->set($params)->store;
                } else {
                    $additional_content = Koha::AdditionalContent->new(
                        {
                            category   => $category,
                            code       => $code,
                            branchcode => $branchcode,
                            %$params,
                        }
                    )->store;
                }
                unless ($code) {
                    $additional_content->discard_changes;
                    $code =
                        $category eq 'news'
                        ? 'News_' . $additional_content->id
                        : $location . '_' . $additional_content->id;
                    $additional_content->code($code)->store;
                    $id = $additional_content->id;
                }
                my @translated_contents;
                my $existing_contents = $additional_content->translated_contents;
                my @seen_ids;
                for my $lang (@lang) {
                    my $id      = $cgi->param( 'id_' . $lang );
                    my $title   = $cgi->param( 'title_' . $lang );
                    my $content = $cgi->param( 'content_' . $lang );
                    $content ||= '<!-- no_content -->' if $lang eq 'default';

                    next unless $title || $content;

                    push @seen_ids, $id;
                    my $translated_content = {
                        title   => $title,
                        content => $content,
                        lang    => $lang,
                    };

                    my $existing_content = $existing_contents->find($id);
                    if ($existing_content) {
                        if ( $existing_content->title ne $title || $existing_content->content ne $content ) {
                            if ( C4::Context->preference("NewsLog") ) {
                                logaction(
                                    'NEWS', 'MODIFY', undef,
                                    sprintf( "%s|%s|%s|%s", $code, $title, $lang, $content )
                                );
                            }
                        } else {
                            $translated_content->{updated_on} = $existing_content->updated_on;
                        }
                    } elsif ( C4::Context->preference("NewsLog") ) {
                        logaction( 'NEWS', 'ADD', undef, sprintf( "%s|%s|%s|%s", $code, $title, $lang, $content ) );
                    }

                    push @translated_contents, $translated_content;
                }

                if ( C4::Context->preference("NewsLog") ) {
                    my @existing_ids = $existing_contents->get_column('id');
                    my @deleted_ids  = array_minus( @existing_ids, @seen_ids );
                    for my $id (@deleted_ids) {
                        my $c = $existing_contents->find($id);
                        logaction( 'NEWS', 'DELETE', undef, sprintf( "%s|%s|%s", $code, $c->lang, $c->content ) );
                    }
                }

                $additional_content->translated_contents( \@translated_contents );
            }
        );
    } catch {
        warn $_;
        if ($id) {
            push @messages, { type => 'error', code => 'error_on_update' };
        } else {
            push @messages, { type => 'error', code => 'error_on_insert' };
        }
    };

    if ( $redirect eq "just_save" ) {
        print $cgi->redirect(
            "/cgi-bin/koha/tools/additional-contents.pl?op=add_form&id=$id&category=$category&editmode=$editmode&redirect=done"
        );
        exit;
    } else {
        $op = 'list';
    }
} elsif ( $op eq 'cud-delete_confirmed' ) {
    output_and_exit_if_error( $cgi, $cookie, $template, { check => 'csrf_token' } );
    my @ids = $cgi->multi_param('ids');

    try {
        Koha::Database->new->schema->txn_do(
            sub {
                my $contents = Koha::AdditionalContents->search( { id => \@ids } );

                if ( C4::Context->preference("NewsLog") ) {
                    while ( my $c = $contents->next ) {
                        my $translated_contents = $c->translated_contents;
                        while ( my $translated_content = $translated_contents->next ) {
                            logaction(
                                'NEWS', 'DELETE', undef,
                                sprintf(
                                    "%s|%s|%s|%s", $c->code, $translated_content->lang, $translated_content->content
                                )
                            );
                        }
                    }
                }
                $contents->delete;
            }
        );
        push @messages, { type => 'message', code => 'success_on_delete' };
    } catch {
        warn $_;
        push @messages, { type => 'error', code => 'error_on_delete' };
    };

    $op = 'list';
}

if ( $op eq 'list' ) {
    my $additional_contents = Koha::AdditionalContents->search(
        { category => $category,                   'additional_contents_localizations.lang' => 'default' },
        { order_by => { -desc => 'published_on' }, join => 'additional_contents_localizations' }
    );
    $template->param( additional_contents => $additional_contents );
}

my $translated_languages = C4::Languages::getTranslatedLanguages();
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
        } else {
            push @languages,
                {
                lang        => $sublanguage->{rfc4646_subtag},
                description => $sublanguage->{native_description} . ' (' . $sublanguage->{rfc4646_subtag} . ')',
                };
        }
    }
}
unshift @languages, { lang => 'default' } if @languages;

$template->param(
    op        => $op,
    category  => $category,
    wysiwyg   => $wysiwyg,
    editmode  => $editmode,
    languages => \@languages,
    messages  => \@messages,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
