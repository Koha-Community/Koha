package C4::Templates;

use strict;
use warnings;
use Carp;
use CGI qw ( -utf8 );
use List::MoreUtils qw/ any uniq /;

# Copyright 2009 Chris Cormack and The Koha Dev Team
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

=head1 NAME 

C4::Templates - Object for manipulating templates for use with Koha

=cut

use base qw(Class::Accessor);
use Template;
use Template::Constants qw( :debug );
use C4::Languages qw(getTranslatedLanguages get_bidi regex_lang_subtags language_get_description accept_language );

use C4::Context;

use Koha::Cache::Memory::Lite;
use Koha::Exceptions;

__PACKAGE__->mk_accessors(qw( theme activethemes preferredtheme lang filename htdocs interface vars));



sub new {
    my $class     = shift;
    my $interface = shift;
    my $filename  = shift;
    my $tmplbase  = shift;
    my $query     = @_? shift: undef;
    my $htdocs;
    if ( $interface ne "intranet" ) {
        $htdocs = C4::Context->config('opachtdocs');
    }
    else {
        $htdocs = C4::Context->config('intrahtdocs');
    }
    my ($theme, $lang, $activethemes)= themelanguage( $htdocs, $tmplbase, $interface, $query);
    my @includes;
    foreach (@$activethemes) {
        push @includes, "$htdocs/$_/$lang/includes";
        push @includes, "$htdocs/$_/en/includes" unless $lang eq 'en';
    }
    # Do not use template cache if script is called from commandline
    my $use_template_cache = C4::Context->config('template_cache_dir') && defined $ENV{GATEWAY_INTERFACE};
    my $template = Template->new(
        {   EVAL_PERL    => 1,
            ABSOLUTE     => 1,
            PLUGIN_BASE => 'Koha::Template::Plugin',
            COMPILE_EXT => $use_template_cache ? '.ttc' : '',
            COMPILE_DIR => $use_template_cache ? C4::Context->config('template_cache_dir') : '',
            INCLUDE_PATH => \@includes,
            FILTERS => {},
            ENCODING => 'UTF-8',
        }
    ) or die Template->error();
    my $self = {
        TEMPLATE => $template,
        VARS     => {},
    };
    bless $self, $class;
    $self->theme($theme);
    $self->lang($lang);
    $self->activethemes($activethemes);
    $self->preferredtheme($activethemes->[0]);
    $self->filename($filename);
    $self->htdocs($htdocs);
    $self->interface($interface);
    $self->{VARS}->{"test"} = "value";
    return $self;

}

sub output {
    my $self = shift;
    my $vars = shift;

#    my $file = $self->htdocs . '/' . $self->theme .'/'.$self->lang.'/'.$self->filename;
    my $template = $self->{TEMPLATE};
    if ( $self->interface eq 'intranet' ) {
        $vars->{themelang} = '/intranet-tmpl';
    }
    else {
        $vars->{themelang} = '/opac-tmpl';
    }
    $vars->{lang} = $self->lang;
    $vars->{themelang} .= '/' . $self->preferredtheme . '/' . $self->lang;
    $vars->{interface} =
      ( $self->{interface} ne 'intranet' ? '/opac-tmpl' : '/intranet-tmpl' );
    $vars->{theme} = $self->theme;
    $vars->{OpacAdditionalStylesheet} =
        C4::Context->preference('OpacAdditionalStylesheet');
    $vars->{opaclayoutstylesheet} =
        C4::Context->preference('opaclayoutstylesheet');

    # add variables set via param to $vars for processing
    $vars = { %$vars, %{ $self->{VARS} } };

    my $data;
    binmode( STDOUT, ":utf8" );
    $template->process( $self->filename, $vars, \$data )
      || die "Template process failed: ", $template->error();
    return $data;
}

# wrapper method to allow easier transition from HTML template pro to Template Toolkit
sub param {
    my $self = shift;
    while (@_) {
        my $key = shift;
        my $val = shift;
        if    ( ref($val) eq 'ARRAY' && !scalar @$val ) { $val = undef; }
        elsif ( ref($val) eq 'HASH'  && !scalar %$val ) { $val = undef; }
        if ( $key ) {
            $self->{VARS}->{$key} = $val;
        } else {
            warn "Problem = a value of $val has been passed to param without key";
        }
    }
}


=head1 NAME

C4::Templates - Functions for managing templates

=head1 FUNCTIONS

=cut

# FIXME: this is a quick fix to stop rc1 installing broken
# Still trying to figure out the correct fix.
my $path = C4::Context->config('intrahtdocs') . "/prog/en/includes/";

#---------------------------------------------------------------------------------------------------------
# FIXME - POD

sub _get_template_file {
    my ($tmplbase, $interface, $query) = @_;

    my $is_intranet = $interface eq 'intranet';
    my $htdocs = C4::Context->config($is_intranet ? 'intrahtdocs' : 'opachtdocs');
    my ($theme, $lang, $availablethemes) = themelanguage($htdocs, $tmplbase, $interface, $query);
    $lang //= 'en';
    $theme //= '';
    $tmplbase = "$htdocs/$theme/$lang/modules/$tmplbase" if $tmplbase !~ /^\//;
        # do not prefix an absolute path

    return ( $htdocs, $theme, $lang, $tmplbase );
}

=head2 badtemplatecheck

    badtemplatecheck( $template_path );

    The sub will throw an exception if the template path is not allowed.

    Note: At this moment the sub is actually a helper routine for
    sub gettemplate.

=cut

sub badtemplatecheck {
    my ( $template ) = @_;
    if( !$template || $template !~ m/^[a-zA-Z0-9_\-\/]+\.(tt|pref)$/ ) {
        # This also includes two dots
        Koha::Exceptions::NoPermission->throw( 'bad template path' );
    } else {
        # Check allowed dirs
        my $dirs = C4::Context->config("pluginsdir");
        $dirs = [ $dirs ] if !ref($dirs);
        unshift @$dirs, C4::Context->config('opachtdocs'), C4::Context->config('intrahtdocs');
        my $found = 0;
        foreach my $dir ( @$dirs ) {
            $dir .= '/' if $dir !~ m/\/$/;
            $found++ if $template =~ m/^$dir/;
            last if $found;
        }
        Koha::Exceptions::NoPermission->throw( 'bad template path' ) if !$found;
    }
}

sub gettemplate {
    my ( $tmplbase, $interface, $query ) = @_;
    ($query) or warn "no query in gettemplate";
    my ($htdocs, $theme, $lang, $filename)
       =  _get_template_file($tmplbase, $interface, $query);
    badtemplatecheck( $filename ); # single trip for bad templates
    my $template = C4::Templates->new($interface, $filename, $tmplbase, $query);

# NOTE: Commenting these out rather than deleting them so that those who need
# to know how we previously shimmed these directories will be able to understand.
#    my $is_intranet = $interface eq 'intranet';
#    my $themelang =
#        ($is_intranet ? '/intranet-tmpl' : '/opac-tmpl') .
#        "/$theme/$lang";
#    $template->param(
#        themelang => $themelang,
#        interface => $is_intranet ? '/intranet-tmpl' : '/opac-tmpl',
#        theme     => $theme,
#        lang      => $lang
#    );

    # Bidirectionality, must be sent even if is the only language
    my $current_lang = regex_lang_subtags($lang);
    my $bidi;
    $bidi = get_bidi($current_lang->{script}) if $current_lang->{script};
    $template->param(
            bidi                 => $bidi,
    );
    # Languages
    my $languages_loop = getTranslatedLanguages($interface,$theme,$lang);
    my $num_languages_enabled = 0;
    foreach my $lang (@$languages_loop) {
        foreach my $sublang (@{ $lang->{'sublanguages_loop'} }) {
            $num_languages_enabled++ if $sublang->{enabled};
         }
    }
    my $one_language_enabled = ($num_languages_enabled <= 1) ? 1 : 0; # deal with zero enabled langs as well
    $template->param(
            languages_loop       => $languages_loop,
            one_language_enabled => $one_language_enabled,
    ) unless $one_language_enabled;

    return $template;
}


=head2 themelanguage

    my ($theme,$lang,\@themes) = themelanguage($htdocs,$tmpl,$interface,query);

This function returns the theme and language to be used for rendering the UI.
It also returns the list of themes that should be applied as a fallback. This is
used for the theme overlay feature (i.e. if a file doesn't exist on the requested
theme, fallback to the configured fallback).

Important: this function is used on the webinstaller too, so always consider
the use case where the DB is not populated already when rewriting/fixing.

=cut

sub themelanguage {
    my ($htdocs, $tmpl, $interface, $query) = @_;
    ($query) or warn "no query in themelanguage";

    # Select a language based on cookie, syspref available languages & browser
    my $lang = C4::Languages::getlanguage($query);

    # Get theme
    my @themes;
    my $theme_syspref    = ($interface eq 'intranet') ? 'template' : 'opacthemes';
    my $fallback_syspref = ($interface eq 'intranet') ? 'template' : 'OPACFallback';
    # Yeah, hardcoded, last resort if the DB is not populated
    my $hardcoded_theme = ($interface eq 'intranet') ? 'prog' : 'bootstrap';

    # Configured theme is the first one
    push @themes, C4::Context->preference( $theme_syspref )
        if C4::Context->preference( $theme_syspref );
    # Configured fallback next
    push @themes, C4::Context->preference( $fallback_syspref )
        if C4::Context->preference( $fallback_syspref );
    # The hardcoded fallback theme is the last one
    push @themes, $hardcoded_theme;

    # Try to find first theme for the selected theme/lang, then for fallback/lang
    my $where = $tmpl =~ /xsl$/ ? 'xslt' : 'modules';
    for my $theme (@themes) {
        if ( -e "$htdocs/$theme/$lang/$where/$tmpl" ) {
            return ( $theme, $lang, [ uniq(@themes) ] );
        }
    }
    # Otherwise return theme/'en', last resort fallback/'en'
    for my $theme (@themes) {
        if ( -e "$htdocs/$theme/en/$where/$tmpl" ) {
            return ( $theme, 'en', [ uniq(@themes) ] );
        }
    }
    # tmpl is a full path, so this is a template for a plugin
    if ( $tmpl =~ /^\// && -e $tmpl ) {
        return ( $themes[0], $lang, [ uniq(@themes) ] );
    }
}


sub setlanguagecookie {
    my ( $query, $language, $uri ) = @_;

    my $cookie = getlanguagecookie( $query, $language );

    # We do not want to set getlanguage in cache, some additional checks are
    # done in C4::Languages::getlanguage
    Koha::Cache::Memory::Lite->get_instance()->clear_from_cache( 'getlanguage' );

    print $query->redirect(
        -uri    => $uri,
        -cookie => $cookie
    );
}

=head2 getlanguagecookie

    my $cookie = getlanguagecookie($query,$language);

Returns a cookie object containing the calculated language to be used.

=cut

sub getlanguagecookie {
    my ( $query, $language ) = @_;
    my $cookie = $query->cookie(
        -name    => 'KohaOpacLanguage',
        -value   => $language,
        -HttpOnly => 1,
        -expires => '+3y'
    );

    return $cookie;
}

=head2 GetColumnDefs

    my $columns = GetColumnDefs( $cgi )

It is passed a CGI object and returns a hash of hashes containing
the column names and descriptions for each table defined in the
columns.def file corresponding to the CGI object.

=cut

sub GetColumnDefs {

    my $query = shift;

    my $columns = {};

    my $htdocs = C4::Context->config('intrahtdocs');
    my $columns_file = 'columns.def';

    # Get theme and language to build the path to columns.def
    my ($theme, $lang, $availablethemes) =
        themelanguage($htdocs, 'about.tt', 'intranet', $query);
    # Build columns.def path
    my $path = "$htdocs/$theme/$lang/$columns_file";
    my $fh;
    if ( ! open ( $fh, q{<:encoding(utf-8)}, $path ) )  {
        carp "Error opening $path. Check your templates.";
        return;
    }
    # Loop through the columns.def file
    while ( my $input = <$fh> ){
        chomp $input;
        if ( $input =~ m|<field name="(.*)">(.*)</field>| ) {
            my ( $table, $column ) =  split( '\.', $1);
            my $description        = $2;
            # Initialize the table array if needed.
            @{$columns->{ $table }} = () if ! defined $columns->{ $table };
            # Push field and description
            push @{$columns->{ $table }},
                { field => $column, description => $description };
        }
    }
    close $fh;

    return $columns;
}

1;
