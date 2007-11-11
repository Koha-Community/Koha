package C4::Output;

#package to deal with marking up output
#You will need to edit parts of this pm
#set the value of path to be where your html lives

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


# NOTE: I'm pretty sure this module is deprecated in favor of
# templates.

use strict;
require Exporter;

use C4::Context;
use C4::Languages qw(getTranslatedLanguages get_bidi regex_lang_subtags language_get_description);

use HTML::Template::Pro;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 3.00;

=head1 NAME

C4::Output - Functions for managing templates

=head1 FUNCTIONS

=over 2

=cut

@ISA    = qw(Exporter);
push @EXPORT, qw(
  &themelanguage &gettemplate setlanguagecookie pagination_bar
);

#Output
push @EXPORT, qw(
    &output_html_with_http_headers
);


#FIXME: this is a quick fix to stop rc1 installing broken
#Still trying to figure out the correct fix.
my $path = C4::Context->config('intrahtdocs') . "/prog/en/includes/";

#---------------------------------------------------------------------------------------------------------
# FIXME - POD
sub gettemplate {
    my ( $tmplbase, $interface, $query ) = @_;
    if ( !$query ) {
        warn "no query in gettemplate";
    }
    my $htdocs;
    if ( $interface ne "intranet" ) {
        $htdocs = C4::Context->config('opachtdocs');
    }
    else {
        $htdocs = C4::Context->config('intrahtdocs');
    }
    my $path = C4::Context->preference('intranet_includes') || 'includes';

    #    warn "PATH : $path";
    my ( $theme, $lang ) = themelanguage( $htdocs, $tmplbase, $interface, $query );
    my $opacstylesheet = C4::Context->preference('opacstylesheet');

	# if the template doesn't exist, load the English one as a last resort
	my $filename = "$htdocs/$theme/$lang/".($interface eq 'intranet'?"modules":"")."/$tmplbase";
	unless (-f $filename) {
		$lang = 'en';
		$filename = "$htdocs/$theme/$lang/".($interface eq 'intranet'?"modules":"")."/$tmplbase";
	}
    my $template       = HTML::Template::Pro->new(
		filename          => $filename,
        die_on_bad_params => 1,
        global_vars       => 1,
        case_sensitive    => 1,
        path              => ["$htdocs/$theme/$lang/$path"]
    );

    $template->param(
        themelang => ( $interface ne 'intranet' ? '/opac-tmpl' : '/intranet-tmpl' )
          . "/$theme/$lang",
        interface => ( $interface ne 'intranet' ? '/opac-tmpl' : '/intranet-tmpl' ),
        theme => $theme,
        opacstylesheet      => $opacstylesheet,
        opaccolorstylesheet => C4::Context->preference('opaccolorstylesheet'),
        opacsmallimage      => C4::Context->preference('opacsmallimage'),
        lang                => $lang
    );

	# Language, Script, and Locale
	my $language_subtags_hashref = regex_lang_subtags($lang);
	my $bidi;
	$bidi = get_bidi($language_subtags_hashref->{script}) if $language_subtags_hashref->{script};
	my @template_languages;
	my $languages_loop = getTranslatedLanguages($interface,$theme);
	for my $language_hashref (@$languages_loop) {
			$language_hashref->{'language_script_description'} = language_get_description($language_hashref->{'language_script'},$lang);
			$language_hashref->{'language_region_description'} = language_get_description($language_hashref->{'language_region'},$lang);
			$language_hashref->{'language_variant_description'} = language_get_description($language_hashref->{'language_variant'},$lang);

		if ($language_hashref->{language_code} eq $language_subtags_hashref->{language}) {
			$language_hashref->{current}++;
		}
		push @template_languages, $language_hashref;
	}
	# load the languages ( for switching from one template to another )
	$template->param(	languages_loop => \@template_languages,
						bidi => $bidi
	);

    return $template;
}

#---------------------------------------------------------------------------------------------------------
# FIXME - POD
sub themelanguage {
    my ( $htdocs, $tmpl, $section, $query ) = @_;

    #   if (!$query) {
    #     warn "no query";
    #   }

	# set some defaults for language and theme
	my $lang = $query->cookie('KohaOpacLanguage');
	$lang = 'en' unless $lang;
	my $theme = 'prog';

    my $dbh = C4::Context->dbh;
    my @languages;
    my @themes;
    if ( $section eq "intranet" ) {
        @languages = split " ", C4::Context->preference("opaclanguages");
        @themes    = split " ", C4::Context->preference("template");
        pop @languages, $lang if $lang;
    }
    else {

      # we are in the opac here, what im trying to do is let the individual user
      # set the theme they want to use.
      # and perhaps the them as well.
        #my $lang = $query->cookie('KohaOpacLanguage');
        if ($lang) {

            push @languages, $lang;
            @themes = split " ", C4::Context->preference("opacthemes");
        }
        else {
            @languages = split " ", C4::Context->preference("opaclanguages");
            @themes    = split " ", C4::Context->preference("opacthemes");
        }
    }

 # searches through the themes and languages. First template it find it returns.
 # Priority is for getting the theme right.
  THEME:
    foreach my $th (@themes) {
        foreach my $la (@languages) {
            for ( my $pass = 1 ; $pass <= 2 ; $pass += 1 ) {
                $la =~ s/([-_])/ $1 eq '-'? '_': '-' /eg if $pass == 2;
                if ( -e "$htdocs/$th/$la/modules/$tmpl" ) {
                    $theme = $th;
                    $lang  = $la;
                    last THEME;
                }
                last unless $la =~ /[-_]/;
            }
        }
    }
    return ( $theme, $lang );
}

sub setlanguagecookie {
    my ( $query, $language, $uri ) = @_;
    my $cookie = $query->cookie(
        -name    => 'KohaOpacLanguage',
        -value   => $language,
        -expires => ''
    );
    print $query->redirect(
        -uri    => $uri,
        -cookie => $cookie
    );
}

=item pagination_bar

   pagination_bar($base_url, $nb_pages, $current_page, $startfrom_name)

Build an HTML pagination bar based on the number of page to display, the
current page and the url to give to each page link.

C<$base_url> is the URL for each page link. The
C<$startfrom_name>=page_number is added at the end of the each URL.

C<$nb_pages> is the total number of pages available.

C<$current_page> is the current page number. This page number won't become a
link.

This function returns HTML, without any language dependency.

=cut

sub pagination_bar {
    my ( $base_url, $nb_pages, $current_page, $startfrom_name ) = @_;

    # how many pages to show before and after the current page?
    my $pages_around = 2;

    my $url =
      $base_url . ( $base_url =~ m/&/ ? '&amp;' : '?' ) . $startfrom_name . '=';

    my $pagination_bar = '';

    # current page detection
    if ( not defined $current_page ) {
        $current_page = 1;
    }

    # navigation bar useful only if more than one page to display !
    if ( $nb_pages > 1 ) {

        # link to first page?
        if ( $current_page > 1 ) {
            $pagination_bar .=
                "\n" . '&nbsp;'
              . '<a href="'
              . $url
              . '1" rel="start">'
              . '&lt;&lt;' . '</a>';
        }
        else {
            $pagination_bar .=
              "\n" . '&nbsp;<span class="inactive">&lt;&lt;</span>';
        }

        # link on previous page ?
        if ( $current_page > 1 ) {
            my $previous = $current_page - 1;

            $pagination_bar .=
                "\n" . '&nbsp;'
              . '<a href="'
              . $url
              . $previous
              . '" rel="prev">' . '&lt;' . '</a>';
        }
        else {
            $pagination_bar .=
              "\n" . '&nbsp;<span class="inactive">&lt;</span>';
        }

        my $min_to_display      = $current_page - $pages_around;
        my $max_to_display      = $current_page + $pages_around;
        my $last_displayed_page = undef;

        for my $page_number ( 1 .. $nb_pages ) {
            if (
                   $page_number == 1
                or $page_number == $nb_pages
                or (    $page_number >= $min_to_display
                    and $page_number <= $max_to_display )
              )
            {
                if ( defined $last_displayed_page
                    and $last_displayed_page != $page_number - 1 )
                {
                    $pagination_bar .=
                      "\n" . '&nbsp;<span class="inactive">...</span>';
                }

                if ( $page_number == $current_page ) {
                    $pagination_bar .=
                        "\n" . '&nbsp;'
                      . '<span class="currentPage">'
                      . $page_number
                      . '</span>';
                }
                else {
                    $pagination_bar .=
                        "\n" . '&nbsp;'
                      . '<a href="'
                      . $url
                      . $page_number . '">'
                      . $page_number . '</a>';
                }
                $last_displayed_page = $page_number;
            }
        }

        # link on next page?
        if ( $current_page < $nb_pages ) {
            my $next = $current_page + 1;

            $pagination_bar .= "\n"
              . '&nbsp;<a href="'
              . $url
              . $next
              . '" rel="next">' . '&gt;' . '</a>';
        }
        else {
            $pagination_bar .=
              "\n" . '&nbsp;<span class="inactive">&gt;</span>';
        }

        # link to last page?
        if ( $current_page != $nb_pages ) {
            $pagination_bar .= "\n"
              . '&nbsp;<a href="'
              . $url
              . $nb_pages
              . '" rel="last">'
              . '&gt;&gt;' . '</a>';
        }
        else {
            $pagination_bar .=
              "\n" . '&nbsp;<span class="inactive">&gt;&gt;</span>';
        }
    }

    return $pagination_bar;
}

=item output_html_with_http_headers

   &output_html_with_http_headers($query, $cookie, $html)

Outputs the HTML page $html with the appropriate HTTP headers,
with the authentication cookie $cookie and a Content-Type that
corresponds to the HTML page $html.

=cut

sub output_html_with_http_headers ($$$) {
    my($query, $cookie, $html) = @_;
    print $query->header(
        -type    => 'text/html',
        -charset => 'UTF-8',
        -cookie  => $cookie,
		-Pragma => 'no-cache',
		-'Cache-Control' => 'no-cache',
    ), $html;
}

END { }    # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
