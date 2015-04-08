package C4::External::Syndetics;
# Copyright (C) 2006 LibLime
# <jmf at liblime dot com>
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

use XML::Simple;
use XML::LibXML;
use LWP::Simple;
use LWP::UserAgent;
use HTTP::Request::Common;

use strict;
use warnings;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
    require Exporter;
    $VERSION = 3.07.00.049;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        &get_syndetics_index
        &get_syndetics_summary
        &get_syndetics_toc
        &get_syndetics_editions
        &get_syndetics_excerpt
        &get_syndetics_reviews
        &get_syndetics_anotes
    );
}

# package-level variable
my $parser = XML::LibXML->new();

=head1 NAME

C4::External::Syndetics - Functions for retrieving Syndetics content in Koha

=head1 FUNCTIONS

This module provides facilities for retrieving Syndetics.com content in Koha

=head2 get_syndetics_summary

  my $syndetics_summary= &get_syndetics_summary( $isbn );

Get Summary data from Syndetics

=cut

sub get_syndetics_index {
    my ( $isbn, $upc, $oclc ) = @_;

    return unless ( $isbn || $upc || $oclc );

    my $response = _fetch_syndetics_content('INDEX.XML', $isbn, $upc, $oclc);
    unless ($response->content_type =~ /xml/) {
        return;
    }

    my $content = $response->content;
    my $xmlsimple = XML::Simple->new();
    $response = $xmlsimple->XMLin(
        $content,
    ) unless !$content;

    my $syndetics_elements;
    for my $available_type ('SUMMARY','TOC','FICTION','AWARDS1','SERIES1','SPSUMMARY','SPREVIEW', 'AVPROFILE', 'AVSUMMARY','DBCHAPTER','LJREVIEW','PWREVIEW','SLJREVIEW','CHREVIEW','BLREVIEW','HBREVIEW','KIREVIEW','CRITICASREVIEW','ANOTES') {
        if (exists $response->{$available_type} && $response->{$available_type} =~ /$available_type/) {
            $syndetics_elements->{$available_type} = $available_type;
        }
    }

    return $syndetics_elements if $syndetics_elements;
}

sub get_syndetics_summary {
    my ( $isbn, $upc, $oclc, $syndetics_elements ) = @_;

    my $summary_type = exists($syndetics_elements->{'AVSUMMARY'}) ? 'AVSUMMARY.XML' : 'SUMMARY.XML';
    my $response = _fetch_syndetics_content($summary_type, $isbn, $upc, $oclc);
    unless ($response->content_type =~ /xml/) {
        return;
    }  

    my $content = $response->content;

    my $summary;
    eval { 
        my $doc = $parser->parse_string($content);
        $summary = $doc->findvalue('//Fld520');
    };
    if ($@) {
        warn "Error parsing Syndetics $summary_type";
    }
    return $summary if $summary;
}

sub get_syndetics_toc {
    my ( $isbn,$upc,$oclc ) = @_;

    my $response = _fetch_syndetics_content('TOC.XML', $isbn, $upc, $oclc);
    unless ($response->content_type =~ /xml/) {
        return;
    }  

    my $content = $response->content;
    my $xmlsimple = XML::Simple->new();
    $response = $xmlsimple->XMLin(
        $content,
        forcearray => [ qw(Fld970) ],
    ) unless !$content;
    # manipulate response USMARC VarFlds VarDFlds Notes Fld520 a
    my $toc;
    $toc = \@{$response->{VarFlds}->{VarDFlds}->{SSIFlds}->{Fld970}} if $response;
    return $toc if $toc;
}

sub get_syndetics_excerpt {
    my ( $isbn,$upc,$oclc ) = @_;

    my $response = _fetch_syndetics_content('DBCHAPTER.XML', $isbn, $upc, $oclc);
    unless ($response->content_type =~ /xml/) {
        return;
    }  
        
    my $content = $response->content;
    my $xmlsimple = XML::Simple->new();
    $response = $xmlsimple->XMLin(
        $content,
        forcearray => [ qw(Fld520) ],
    ) unless !$content;
    # manipulate response USMARC VarFlds VarDFlds Notes Fld520 a
    my $excerpt;
    $excerpt = \@{$response->{VarFlds}->{VarDFlds}->{Notes}->{Fld520}} if $response;
    return XMLout($excerpt, NoEscape => 1) if $excerpt;
}

sub get_syndetics_reviews {
    my ( $isbn,$upc,$oclc,$syndetics_elements ) = @_;

    my @reviews;
    my $review_sources = [
    {title => 'Library Journal Review', file => 'LJREVIEW.XML', element => 'LJREVIEW'},
    {title => 'Publishers Weekly Review', file => 'PWREVIEW.XML', element => 'PWREVIEW'},
    {title => 'School Library Journal Review', file => 'SLJREVIEW.XML', element => 'SLJREVIEW'},
    {title => 'CHOICE Review', file => 'CHREVIEW.XML', element => 'CHREVIEW'},
    {title => 'Booklist Review', file => 'BLREVIEW.XML', element => 'BLREVIEW'},
    {title => 'Horn Book Review', file => 'HBREVIEW.XML', element => 'HBREVIEW'},
    {title => 'Kirkus Book Review', file => 'KIREVIEW.XML', element => 'KIREVIEW'},
    {title => 'Criticas Review', file => 'CRITICASREVIEW.XML', element => 'CRITICASREVIEW'},
    {title => 'Spanish Review', file => 'SPREVIEW.XML', element => 'SPREVIEW'},
    ];

    for my $source (@$review_sources) {
        if ($syndetics_elements->{$source->{element}} and $source->{element} =~ $syndetics_elements->{$source->{element}}) {

        } else {
            #warn "Skipping $source->{element} doesn't match $syndetics_elements->{$source->{element}} \n";
            next;
        }
        my $response = _fetch_syndetics_content($source->{file}, $isbn, $upc, $oclc);
        unless ($response->content_type =~ /xml/) {
            next;
        }

        my $content = $response->content;
       
        eval { 
            my $doc = $parser->parse_string($content);

            # note that using findvalue strips any HTML elements embedded
            # in that review.  That helps us handle slight differences
            # in the output provided by Syndetics 'old' and 'new' versions
            # of their service and cleans any questionable HTML that
            # may be present in the reviews, but does mean that any
            # <B> and <I> tags used to format the review are also gone.
            my $result = $doc->findvalue('//Fld520');
            push @reviews, {title => $source->{title}, reviews => [ { content => $result } ]} if $result;
        };
        if ($@) {
            warn "Error parsing Syndetics $source->{title} review";
        }
    }
    return \@reviews;
}

sub get_syndetics_editions {
    my ( $isbn,$upc,$oclc ) = @_;

    my $response = _fetch_syndetics_content('FICTION.XML', $isbn, $upc, $oclc);
    unless ($response->content_type =~ /xml/) {
        return;
    }  

    my $content = $response->content;

    my $xmlsimple = XML::Simple->new();
    $response = $xmlsimple->XMLin(
        $content,
        forcearray => [ qw(Fld020) ],
    ) unless !$content;
    # manipulate response USMARC VarFlds VarDFlds Notes Fld520 a
    my $similar_items;
    $similar_items = \@{$response->{VarFlds}->{VarDFlds}->{NumbCode}->{Fld020}} if $response;
    return $similar_items if $similar_items;
}

sub get_syndetics_anotes {
    my ( $isbn,$upc,$oclc) = @_;

    my $response = _fetch_syndetics_content('ANOTES.XML', $isbn, $upc, $oclc);
    unless ($response->content_type =~ /xml/) {
        return;
    }

    my $content = $response->content;

    my $xmlsimple = XML::Simple->new();
    $response = $xmlsimple->XMLin(
        $content,
        forcearray => [ qw(Fld980) ],
        ForceContent => 1,
    ) unless !$content;
    my @anotes;
    for my $fld980 (@{$response->{VarFlds}->{VarDFlds}->{SSIFlds}->{Fld980}}) {
        # this is absurd, but sometimes this data serializes differently
        if(ref($fld980->{a}->{content}) eq 'ARRAY') {
            for my $content (@{$fld980->{a}->{content}}) {
                push @anotes, {content => $content};
                
            }
        }
        else {
            push @anotes, {content => $fld980->{a}->{content}};
        }
    }
    return \@anotes;
}

sub _fetch_syndetics_content {
    my ( $element, $isbn, $upc, $oclc ) = @_;

    $isbn = '' unless defined $isbn;
    $upc  = '' unless defined $upc;
    $oclc = '' unless defined $oclc;

    my $syndetics_client_code = C4::Context->preference('SyndeticsClientCode');

    my $url = "http://www.syndetics.com/index.aspx?isbn=$isbn/$element&client=$syndetics_client_code&type=xw10&upc=$upc&oclc=$oclc";
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;
    my $response = $ua->get($url);

    warn "could not retrieve $url" unless $response->content;
    return $response;

}
1;
__END__

=head1 NOTES

=cut

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>

=cut
