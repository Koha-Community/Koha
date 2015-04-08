package C4::Output;

#package to deal with marking up output
#You will need to edit parts of this pm
#set the value of path to be where your html lives

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


# NOTE: I'm pretty sure this module is deprecated in favor of
# templates.

use strict;
#use warnings; FIXME - Bug 2505

use URI::Escape;

use C4::Context;
use C4::Dates qw(format_date);
use C4::Budgets qw(GetCurrency);
use C4::Templates;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
    # set the version for version checking
    $VERSION = 3.07.00.049;
    require Exporter;

 @ISA    = qw(Exporter);
    @EXPORT_OK = qw(&is_ajax ajax_fail); # More stuff should go here instead
    %EXPORT_TAGS = ( all =>[qw(setlanguagecookie pagination_bar parametrized_url
                                &output_with_http_headers &output_ajax_with_http_headers &output_html_with_http_headers)],
                    ajax =>[qw(&output_with_http_headers &output_ajax_with_http_headers is_ajax)],
                    html =>[qw(&output_with_http_headers &output_html_with_http_headers)]
                );
    push @EXPORT, qw(
        setlanguagecookie getlanguagecookie pagination_bar parametrized_url
    );
    push @EXPORT, qw(
        &output_html_with_http_headers &output_ajax_with_http_headers &output_with_http_headers FormatData
    );

}

=head1 NAME

C4::Output - Functions for managing output, is slowly being deprecated

=head1 FUNCTIONS

=over 2
=cut

=item FormatData

FormatData($data_hashref)
C<$data_hashref> is a ref to data to format

Format dates of data those dates are assumed to contain date in their noun
Could be used in order to centralize all the formatting for HTML output
=cut

sub FormatData{
		my $data_hashref=shift;
        $$data_hashref{$_} = format_date( $$data_hashref{$_} ) for grep{/date/} keys (%$data_hashref);
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
	my $base_url = (@_ ? shift : $ENV{SCRIPT_NAME} . $ENV{QUERY_STRING}) or return;
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

    my $url = $base_url . (($base_url =~ m/$delim/ or $base_url =~ m/\?/) ? '&amp;' : '?' ) . $startfrom_name . '=';
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

=item output_with_http_headers

   &output_with_http_headers($query, $cookie, $data, $content_type[, $status[, $extra_options]])

Outputs $data with the appropriate HTTP headers,
the authentication cookie $cookie and a Content-Type specified in
$content_type.

If applicable, $cookie can be undef, and it will not be sent.

$content_type is one of the following: 'html', 'js', 'json', 'xml', 'rss', or 'atom'.

$status is an HTTP status message, like '403 Authentication Required'. It defaults to '200 OK'.

$extra_options is hashref.  If the key 'force_no_caching' is present and has
a true value, the HTTP headers include directives to force there to be no
caching whatsoever.

=cut

sub output_with_http_headers {
    my ( $query, $cookie, $data, $content_type, $status, $extra_options ) = @_;
    $status ||= '200 OK';

    $extra_options //= {};

    my %content_type_map = (
        'html' => 'text/html',
        'js'   => 'text/javascript',
        'json' => 'application/json',
        'xml'  => 'text/xml',
        # NOTE: not using application/atom+xml or application/rss+xml because of
        # Internet Explorer 6; see bug 2078.
        'rss'  => 'text/xml',
        'atom' => 'text/xml'
    );

    die "Unknown content type '$content_type'" if ( !defined( $content_type_map{$content_type} ) );
    my $cache_policy = 'no-cache';
    $cache_policy .= ', no-store, max-age=0' if $extra_options->{force_no_caching};
    my $options = {
        type    => $content_type_map{$content_type},
        status  => $status,
        charset => 'UTF-8',
        Pragma          => 'no-cache',
        'Cache-Control' => $cache_policy,
    };
    $options->{expires} = 'now' if $extra_options->{force_no_caching};

    $options->{cookie} = $cookie if $cookie;
    if ($content_type eq 'html') {  # guaranteed to be one of the content_type_map keys, else we'd have died
        $options->{'Content-Style-Type' } = 'text/css';
        $options->{'Content-Script-Type'} = 'text/javascript';
    }

# We can't encode here, that will double encode our templates, and xslt
# We need to fix the encoding as it comes out of the database, or when we pass the variables to templates
 
#    utf8::encode($data) if utf8::is_utf8($data);

    $data =~ s/\&amp\;amp\; /\&amp\; /g;
    print $query->header($options), $data;
}

sub output_html_with_http_headers {
    my ( $query, $cookie, $data, $status, $extra_options ) = @_;
    output_with_http_headers( $query, $cookie, $data, 'html', $status, $extra_options );
}


sub output_ajax_with_http_headers {
    my ( $query, $js ) = @_;
    print $query->header(
        -type            => 'text/javascript',
        -charset         => 'UTF-8',
        -Pragma          => 'no-cache',
        -'Cache-Control' => 'no-cache',
        -expires         => '-1d',
    ), $js;
}

sub is_ajax {
    my $x_req = $ENV{HTTP_X_REQUESTED_WITH};
    return ( $x_req and $x_req =~ /XMLHttpRequest/i ) ? 1 : 0;
}

sub parametrized_url {
    my $url = shift || ''; # ie page.pl?ln={LANG}
    my $vars = shift || {}; # ie { LANG => en }
    my $ret = $url;
    while ( my ($key,$val) = each %$vars) {
        my $val_url = URI::Escape::uri_escape_utf8($val);
        $ret =~ s/\{$key\}/$val_url/g;
    }
    $ret =~ s/\{[^\{]*\}//g; # remove not defined vars
    return $ret;
}

END { }    # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
