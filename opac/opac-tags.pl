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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

opac-tags.pl

=head1 DESCRIPTION

TODO :: Description here

C4::Scrubber is used to remove all markup content from the sumitted text.

=cut

use Modern::Perl;

use CGI qw ( -utf8 );
use CGI::Cookie;    # need to check cookies before having CGI parse the POST request
use Array::Utils qw( array_minus );

use C4::Auth qw( check_cookie_auth get_template_and_user );
use C4::Context;
use C4::Output qw( output_with_http_headers is_ajax output_html_with_http_headers );
use C4::Scrubber;
use C4::Tags qw(
    add_tag
    get_approval_rows
    get_tag_rows
    remove_tag
    stratify_tags
);
use C4::XSLT qw( XSLTParse4Display );
use Koha::Biblios;

use Koha::Logger;
use Koha::Biblios;
use Koha::CirculationRules;

my %newtags       = ();
my @deltags       = ();
my %counts        = ();
my @errors        = ();
my $perBibResults = {};

# Indexes of @errors that do not apply to a particular biblionumber.
my @globalErrorIndexes = ();

sub ajax_auth_cgi {    # returns CGI object
    my $needed_flags  = shift;
    my %cookies       = CGI::Cookie->fetch;
    my $input         = CGI->new;
    my $sessid        = $cookies{'CGISESSID'}->value;
    my ($auth_status) = check_cookie_auth( $sessid, $needed_flags );
    if ( $auth_status ne "ok" ) {
        output_with_http_headers $input, undef,
            "window.alert('Your CGI session cookie ($sessid) is not current.  "
            . "Please refresh the page and try again.');\n", 'js';
        exit 0;
    }
    return $input;
}

# The trick here is to support multiple tags added to multiple biblios in one POST.
# The HTML might not use this, but it makes it more web-servicey from the start.
# So the name of param has to have biblionumber built in.
# For lack of anything more compelling, we just use "newtag[biblionumber]"
# We split the value into tags at comma and semicolon

my $is_ajax  = is_ajax();
my $openadds = C4::Context->preference('TagsModeration') ? 0                    : 1;
my $query    = ($is_ajax)                                ? &ajax_auth_cgi( {} ) : CGI->new();
foreach ( $query->param ) {
    if (/^newtag(.*)/) {
        my $biblionumber = $1;
        unless ( $biblionumber =~ /^\d+$/ ) {
            push @errors, { +'badparam' => $_ };
            push @globalErrorIndexes, $#errors;
            next;
        }
        $newtags{$biblionumber} = $query->param($_);
    } elsif (/^del(\d+)$/) {
        push @deltags, $1;
    }
}

my $add_op = ( scalar( keys %newtags ) + scalar(@deltags) ) ? 1 : 0;
my ( $template, $loggedinuser, $cookie );
if ($is_ajax) {
    $loggedinuser = C4::Context->userenv->{'number'};    # must occur AFTER auth
} else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-tags.tt",
            query           => $query,
            type            => "opac",
            authnotrequired => ( $add_op ? 0 : 1 ),    # auth required to add tags
        }
    );
}

unless ( C4::Context->preference('TagsEnabled') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

if ($add_op) {
    unless ($loggedinuser) {
        push @errors, { +'cud-login' => 1 };
        push @globalErrorIndexes, $#errors;
        %newtags = ();    # zero out any attempted additions
        @deltags = ();    # zero out any attempted deletions
    }
}

my $op   = $query->param('op') || q{};
my $dels = 0;
if ( $op eq 'cud-add' ) {
    my $scrubber;
    my @newtags_keys = ( keys %newtags );
    if ( scalar @newtags_keys ) {
        $scrubber = C4::Scrubber->new();
        foreach my $biblionumber (@newtags_keys) {
            my $bibResults = { adds => 0, errors => [] };
            my @values     = split /[;,]/, $newtags{$biblionumber};
            foreach (@values) {
                s/^\s*(.+)\s*$/$1/;
                my $clean_tag = $scrubber->scrub($_);
                unless ( $clean_tag eq $_ ) {
                    if ( $clean_tag =~ /\S/ ) {
                        push @errors,                    { scrubbed => $clean_tag };
                        push @{ $bibResults->{errors} }, { scrubbed => $clean_tag };
                    } else {
                        push @errors,                    { scrubbed_all_bad => 1 };
                        push @{ $bibResults->{errors} }, { scrubbed_all_bad => 1 };
                        next;    # we don't add it if there's nothing left!
                    }
                }
                my $result =
                    ($openadds) ? add_tag( $biblionumber, $clean_tag, $loggedinuser, $loggedinuser ) :    # pre-approved
                    add_tag( $biblionumber, $clean_tag, $loggedinuser );
                if ($result) {
                    $counts{$biblionumber}++;
                    $bibResults->{adds}++;
                } else {
                    push @errors,                    { failed_add_tag => $clean_tag };
                    push @{ $bibResults->{errors} }, { failed_add_tag => $clean_tag };
                    Koha::Logger->get->warn( "add_tag($biblionumber,$clean_tag,$loggedinuser...) returned bad result ("
                            . ( defined $result ? $result : 'UNDEF' )
                            . ")" );
                }
            }
            $perBibResults->{$biblionumber} = $bibResults;
        }
    }
} elsif ( $op eq 'cud-del' ) {
    foreach (@deltags) {
        if ( remove_tag( $_, $loggedinuser ) ) {
            $dels++;
        } else {
            push @errors, { failed_delete => $_ };
        }
    }
}

if ($is_ajax) {
    my $sum = 0;
    foreach ( values %counts ) { $sum += $_; }
    my $js_reply = sprintf( "response = {\n\tadded: %d,\n\tdeleted: %d,\n\terrors: %d", $sum, $dels, scalar @errors );

    # If no add attempts were made, flag global errors.
    if (@globalErrorIndexes) {
        $js_reply .= ",\n\tglobal_errors: [";
        my $first = 1;
        foreach (@globalErrorIndexes) {
            $js_reply .= "," unless $first;
            $first = 0;
            $js_reply .= "\n\t\t$_";
        }
        $js_reply .= "\n\t]";
    }

    my $err_string = '';
    if ( scalar @errors ) {
        $err_string = ",\n\talerts: [";    # open response_function
        my $i = 1;
        foreach (@errors) {
            my $key = ( keys %$_ )[0];
            ( my $quote_escaped = $_->{$key} ) =~ s|"|\\"|g;
            $err_string .= sprintf qq{\n\t\t KOHA.Tags.tag_message.%s("%s")}, $key, $quote_escaped;
            if ( $i < scalar @errors ) { $err_string .= ","; }
            $i++;
        }
        $err_string .= "\n\t]\n";          # close response_function
    }

    # Add per-biblionumber results for use on results page
    my $js_perbib = "";
    for my $bib ( keys %$perBibResults ) {
        my $bibResult = $perBibResults->{$bib};
        my $js_bibres = ",\n\t$bib: {\n\t\tadded: $bibResult->{adds}";
        $js_bibres .= ",\n\t\terrors: [";
        my $i = 0;
        foreach ( @{ $bibResult->{errors} } ) {
            $js_bibres .= "," if ($i);
            my $key = ( keys %$_ )[0];
            ( my $quote_escaped = $_->{$key} ) =~ s|"|\\"|g;
            $js_bibres .= sprintf qq{\n\t\t\t KOHA.Tags.tag_message.%s("%s")}, $key, $quote_escaped;
            $i++;
        }
        $js_bibres .= "\n\t\t]\n\t}";
        $js_perbib .= $js_bibres;
    }

    output_with_http_headers( $query, undef, "$js_reply\n$err_string\n$js_perbib\n};", 'js' );
    exit;
}

my $results = [];
my $my_tags = [];

if ($loggedinuser) {
    my $patron      = Koha::Patrons->find( { borrowernumber => $loggedinuser } );
    my $rules       = C4::Context->yaml_preference('OpacHiddenItems');
    my $should_hide = ($rules) ? 1 : 0;
    $my_tags = get_tag_rows( { borrowernumber => $loggedinuser } );
    my $my_approved_tags = get_approval_rows( { approved => 1 } );

    my $art_req_itypes;
    if ( C4::Context->preference('ArticleRequests') ) {
        $art_req_itypes = Koha::CirculationRules->guess_article_requestable_itemtypes(
            { $patron ? ( categorycode => $patron->categorycode ) : () } );
    }

    # get biblionumbers stored in the cart
    my @cart_list;

    if ( $query->cookie("bib_list") ) {
        my $cart_list = $query->cookie("bib_list");
        @cart_list = split( /\//, $cart_list );
    }

    foreach my $tag (@$my_tags) {
        $tag->{visible} = 0;
        my $biblio = Koha::Biblios->find( $tag->{biblionumber} );
        my $record = $biblio->metadata_record(
            {
                embed_items => 1,
                interface   => 'opac',
                patron      => $patron,
            }
        );
        next unless $record;
        my @hidden_items;
        if ($should_hide) {
            my $items           = $biblio->items->search_ordered;
            my @all_itemnumbers = $items->get_column('itemnumber');
            my @items_to_show   = $items->filter_by_visible_in_opac( { opac => 1, patron => $patron } )->as_list;
            @hidden_items = array_minus( @all_itemnumbers, @items_to_show );
        }
        next
            if (
            (
                !$patron
                or ( $patron and !$patron->category->override_hidden_items )
            )
            and $biblio->hidden_in_opac( { rules => $rules } )
            );
        $tag->{title}       = $biblio->title;
        $tag->{subtitle}    = $biblio->subtitle;
        $tag->{medium}      = $biblio->medium;
        $tag->{part_number} = $biblio->part_number;
        $tag->{part_name}   = $biblio->part_name;
        $tag->{author}      = $biblio->author;

        # BZ17530: 'Intelligent' guess if result can be article requested
        $tag->{artreqpossible} = ( $art_req_itypes->{ $tag->{itemtype} // q{} } || $art_req_itypes->{'*'} ) ? 1 : q{};

        my $variables = { anonymous_session => ($loggedinuser) ? 0 : 1 };
        $tag->{XSLTBloc} = XSLTParse4Display(
            {
                biblionumber   => $tag->{biblionumber},
                record         => $record,
                xsl_syspref    => 'OPACXSLTResultsDisplay',
                fix_amps       => 1,
                hidden_items   => \@hidden_items,
                xslt_variables => $variables,
            }
        );

        my $date = $tag->{date_created} || '';
        $date =~ /\s+(\d{2}\:\d{2}\:\d{2})/;
        $tag->{time_created_display} = $1;
        $tag->{approved}             = ( grep { $_->{term} eq $tag->{term} and $_->{approved} } @$my_approved_tags );
        $tag->{visible}              = 1;

        # while we're checking each line, see if item is in the cart
        if ( grep { $_ eq $biblio->biblionumber } @cart_list ) {
            $tag->{incart} = 1;
        }
    }
}

$template->param( tagsview => 1 );

if ($add_op) {
    my $adds = 0;
    for ( values %counts ) { $adds += $_; }
    $template->param(
        add_op        => 1,
        added_count   => $adds,
        deleted_count => $dels,
    );
} else {
    my ( $arg, $limit, $mine );
    my $hardmax = 100;    # you might disagree what this value should be, but there definitely should be a max
    $limit = $query->param('limit') || $hardmax;
    $mine  = $query->param('mine')  || 0;          # set if the patron want to see only his own tags.
    ( $limit =~ /^\d+$/ and $limit <= $hardmax ) or $limit = $hardmax;
    $template->param( limit => $limit );
    my $arghash = { approved => 1, limit => $limit, 'sort' => '-weight_total' };
    $arghash->{'borrowernumber'} = $loggedinuser if $mine;

    # ($openadds) or $arghash->{approved} = 1;
    if ( $arg = $query->param('tag') ) {
        $arghash->{term} = $arg;
    }

    # Bug 36785: Do not pass biblionumber: get_approval_rows does not 'recognize' biblionumber
    $results = get_approval_rows($arghash);
    stratify_tags( 10, $results );    # work out the different sizes for things
    my $count = scalar @$results;
    $template->param( TAGLOOP_COUNT => $count, mine => $mine );
}
( scalar @errors ) and $template->param( ERRORS => \@errors );
my @orderedresult = sort { uc( $a->{'term'} ) cmp uc( $b->{'term'} ) } @$results;
( scalar @$results ) and $template->param( TAGLOOP => \@orderedresult );
( scalar @$my_tags ) and $template->param( MY_TAGS => $my_tags );

output_html_with_http_headers $query, $cookie, $template->output;
__END__

=head1 EXAMPLE AJAX POST PARAMETERS

CGISESSID    7c6288263107beb320f70f78fd767f56
newtag396    fire,+<a+href="foobar.html">foobar</a>,+<img+src="foo.jpg"+/>

So this request is trying to add 3 tags to biblio #396.  The CGISESSID is the same as that the browser would
typically communicate using cookies.  If it is valid, the server will split the value of "newtag396" and 
process the components for addition.  In this case the intended tags are:
    fire
    <a+href="foobar.html">foobar</a>
    <img src="foo.jpg" />

The first tag is acceptable.  The second will be scrubbed of markup, resulting in the tag "foobar".  
The third tag is all markup, and will be rejected.  

=head1 EXAMPLE AJAX JSON response

response = {
    added: 2,
    deleted: 0,
    errors: 2,
    alerts: [
         KOHA.Tags.tag_message.scrubbed("foobar"),
          KOHA.Tags.tag_message.scrubbed_all_bad("1"),
     ],
};

=cut
