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

use C4::Context;
use C4::Languages qw(getTranslatedLanguages get_bidi regex_lang_subtags language_get_description accept_language );

use HTML::Template::Pro;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
    # set the version for version checking
    $VERSION = 3.02;
    require Exporter;
    @ISA    = qw(Exporter);
	@EXPORT_OK = qw(&output_ajax_with_http_headers &is_ajax); # More stuff should go here instead
	%EXPORT_TAGS = ( all =>[qw(&themelanguage &gettemplate setlanguagecookie pagination_bar
								&output_ajax_with_http_headers &output_html_with_http_headers)],
					ajax =>[qw(&output_ajax_with_http_headers is_ajax)],
					html =>[qw(&output_html_with_http_headers)]
				);
    push @EXPORT, qw(
        &themelanguage &gettemplate setlanguagecookie pagination_bar
    );
    push @EXPORT, qw(
        &output_html_with_http_headers
    );
}

=head1 NAME

C4::Output - Functions for managing templates

=head1 FUNCTIONS

=over 2

=cut

#FIXME: this is a quick fix to stop rc1 installing broken
#Still trying to figure out the correct fix.
my $path = C4::Context->config('intrahtdocs') . "/prog/en/includes/";

#---------------------------------------------------------------------------------------------------------
# FIXME - POD
sub gettemplate {
    my ( $tmplbase, $interface, $query ) = @_;
    ($query) or warn "no query in gettemplate";
    my $htdocs;
    if ( $interface ne "intranet" ) {
        $htdocs = C4::Context->config('opachtdocs');
    }
    else {
        $htdocs = C4::Context->config('intrahtdocs');
    }
    my $path = C4::Context->preference('intranet_includes') || 'includes';

    my ( $theme, $lang ) = themelanguage( $htdocs, $tmplbase, $interface, $query );
    my $opacstylesheet = C4::Context->preference('opacstylesheet');

    # if the template doesn't exist, load the English one as a last resort
    my $filename = "$htdocs/$theme/$lang/modules/$tmplbase";
    unless (-f $filename) {
        $lang = 'en';
        $filename = "$htdocs/$theme/$lang/modules/$tmplbase";
    }
    my $template       = HTML::Template::Pro->new(
        filename          => $filename,
        die_on_bad_params => 1,
        global_vars       => 1,
        case_sensitive    => 1,
	    loop_context_vars => 1,		# enable: __first__, __last__, __inner__, __odd__, __counter__ 
        path              => ["$htdocs/$theme/$lang/$path"]
    );
    my $themelang=( $interface ne 'intranet' ? '/opac-tmpl' : '/intranet-tmpl' )
          . "/$theme/$lang";
    $template->param(
        themelang => $themelang,
        yuipath => (C4::Context->preference("yuipath") eq "local"?"$themelang/lib/yui":C4::Context->preference("yuipath")),
        interface => ( $interface ne 'intranet' ? '/opac-tmpl' : '/intranet-tmpl' ),
        theme => $theme,
        opacstylesheet      => $opacstylesheet,
        opaccolorstylesheet => C4::Context->preference('opaccolorstylesheet'),
        opacsmallimage      => C4::Context->preference('opacsmallimage'),
        lang                => $lang
    );

    # Bidirectionality
    my $current_lang = regex_lang_subtags($lang);
    my $bidi;
    $bidi = get_bidi($current_lang->{script}) if $current_lang->{script};
    # Languages
    my $languages_loop = getTranslatedLanguages($interface,$theme,$lang);
    $template->param(
            languages_loop => $languages_loop,
            bidi => $bidi
    ) unless @$languages_loop<2;

    return $template;
}

#---------------------------------------------------------------------------------------------------------
# FIXME - POD
sub themelanguage {
    my ( $htdocs, $tmpl, $interface, $query ) = @_;
    ($query) or warn "no query in themelanguage";

    # Set some defaults for language and theme
    # First, check the user's preferences
    my $lang;
    my $http_accept_language = regex_lang_subtags($ENV{HTTP_ACCEPT_LANGUAGE})->{language};
    if ($http_accept_language) {
        $lang = accept_language($http_accept_language,getTranslatedLanguages($interface,'prog'));
    } 
    # But, if there's a cookie set, obey it
    $lang = $query->cookie('KohaOpacLanguage') if $query->cookie('KohaOpacLanguage');
    # Fall back to English
    my @languages = split " ", C4::Context->preference("opaclanguages");
    if ($lang){  
        @languages=($lang,@languages);
    } else {
        $lang = $languages[0];
    }      
    my $theme = 'prog';	# in the event of theme failure default to 'prog' -fbcit
    my $dbh = C4::Context->dbh;
    my @themes;
    if ( $interface eq "intranet" ) {
        @themes    = split " ", C4::Context->preference("template");
    }
    else {
      # we are in the opac here, what im trying to do is let the individual user
      # set the theme they want to use.
      # and perhaps the them as well.
        #my $lang = $query->cookie('KohaOpacLanguage');
        @themes = split " ", C4::Context->preference("opacthemes");
    }

 # searches through the themes and languages. First template it find it returns.
 # Priority is for getting the theme right.
    THEME:
    foreach my $th (@themes) {
        foreach my $la (@languages) {
            #for ( my $pass = 1 ; $pass <= 2 ; $pass += 1 ) {
                # warn "$htdocs/$th/$la/modules/$interface-"."tmpl";
                #$la =~ s/([-_])/ $1 eq '-'? '_': '-' /eg if $pass == 2;
				if ( -e "$htdocs/$th/$la/modules/$tmpl") {
                #".($interface eq 'intranet'?"modules":"")."/$tmpl" ) {
                    $theme = $th;
                    $lang  = $la;
                    last THEME;
                }
                last unless $la =~ /[-_]/;
            #}
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
	my $base_url = (@_ ? shift : $ENV{SCRIPT_NAME} . $ENV{QUERY_STRING}) or return undef;
    my $nb_pages       = (@_) ? shift : 1;
    my $current_page   = (@_) ? shift : undef;	# delay default until later
    my $startfrom_name = (@_) ? shift : 'page';

    # how many pages to show before and after the current page?
    my $pages_around = 2;

	my $delim = qr/\&(?:amp;)?|;/;		# "non memory" cluster: no backreference
	$base_url =~ s/$delim*\b$startfrom_name=(\d+)//g; # remove previous pagination var
    unless (defined $current_page and $current_page > 0 and $current_page <= $nb_pages) {
        $current_page = ($1) ? $1 : 1;	# pull current page from param in URL, else default to 1
		# $debug and	# FIXME: use C4::Debug;
		# warn "with QUERY_STRING:" .$ENV{QUERY_STRING}. "\ncurrent_page:$current_page\n1:$1  2:$2  3:$3";
    }
	$base_url =~ s/($delim)+/$1/g;	# compress duplicate delims
	$base_url =~ s/$delim;//g;		# remove empties
	$base_url =~ s/$delim$//;		# remove trailing delim

    my $url = $base_url . ( $base_url =~ m/$delim/ ? '&amp;' : '?' ) . $startfrom_name . '=';
    my $pagination_bar = '';

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

sub output_ajax_with_http_headers ($$) {
    my ($query, $js) = @_;
    print $query->header(
        -type    => 'text/javascript',
        -charset => 'UTF-8',
        -Pragma  => 'no-cache',
        -'Cache-Control' => 'no-cache',
		-expires =>'-1d',
    ), $js;
}

sub is_ajax () {
	my $x_req = $ENV{HTTP_X_REQUESTED_WITH};
	return ($x_req and $x_req =~ /XMLHttpRequest/i) ? 1 : 0;
}

END { }    # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
