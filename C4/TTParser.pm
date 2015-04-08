#!/usr/bin/env perl

# Copyright Tamil 2011
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

#simple parser for HTML with Template Toolkit directives. Tokens are put into @tokens and are accesible via next_token and peep_token
package C4::TTParser;
use base qw(HTML::Parser);
use C4::TmplToken;
use strict;
use warnings;

#seems to be handled post tokenizer
##hash where key is tag we are interested in and the value is a hash of the attributes we want
#my %interesting_tags = (
#    img => { alt => 1 },
#);

#tokens found so far (used like a stack)
my ( @tokens );

#shiftnext token or undef
sub next_token{
    return shift @tokens;
}

#unshift token back on @tokens
sub unshift_token{
    my $self = shift;
    unshift @tokens, shift;
}

#have a peep at next token
sub peep_token{
    return $tokens[0];
}

#wrapper for parse
#please use this method INSTEAD of the HTML::Parser->parse_file method (and HTML::Parser->parse)
#signature build_tokens( self, filename)
sub build_tokens{
    my ($self, $filename) = @_;
    $self->{filename} = $filename;
    $self->handler(start => "start", "self, line, tagname, attr, text"); #signature is start( self, linenumber, tagname, hash of attributes, origional text )
    $self->handler(text => "text", "self, line, text, is_cdata"); #signature is text( self, linenumber, origional text, is_cdata )
    $self->handler(end => "end", "self, line, tag, attr, text"); #signature is end( self, linenumber, tagename, origional text )
    $self->handler(declaration => "declaration", "self, line, text, is_cdata"); # declaration
    $self->handler(comment => "comment", "self, line, text, is_cdata"); # comments
#    $self->handler(default => "default", "self, line, text, is_cdata"); # anything else
    $self->marked_sections(1); #treat anything inside CDATA tags as text, should really make it a C4::TmplTokenType::CDATA
    $self->unbroken_text(1); #make contiguous whitespace into a single token (can span multiple lines)
    $self->parse_file($filename);
    return $self;
}

#handle parsing of text
sub text{
    my $self = shift;
    my $line = shift;
    my $work = shift; # original text
    my $is_cdata = shift;
    while($work){
        # if there is a template_toolkit tag
        if( $work =~ m/\[%.*?%\]/ ){
            #everything before this tag is text (or possibly CDATA), add a text token to tokens if $`
            if( $` ){
                my $t = C4::TmplToken->new( $`, ($is_cdata? C4::TmplTokenType::CDATA : C4::TmplTokenType::TEXT), $line, $self->{filename} );
                push @tokens, $t;
            }

            #the match itself is a DIRECTIVE $&
            my $t = C4::TmplToken->new( $&, C4::TmplTokenType::DIRECTIVE, $line, $self->{filename} );
            push @tokens, $t;

            # put work still to do back into work
            $work = $' ? $' : 0;
        } else {
            # If there is some left over work, treat it as text token
            my $t = C4::TmplToken->new( $work, ($is_cdata? C4::TmplTokenType::CDATA : C4::TmplTokenType::TEXT), $line, $self->{filename} );
	    
            push @tokens, $t;
            last;
        }
    }
}

sub declaration {
    my $self = shift;
    my $line = shift;
    my $work = shift; #original text
    my $is_cdata = shift;
    my $t = C4::TmplToken->new( $work, ($is_cdata? C4::TmplTokenType::CDATA : C4::TmplTokenType::TEXT), $line, $self->{filename} );
    push @tokens, $t;  
}      

sub comment {
    my $self = shift;
    my $line = shift;
    my $work = shift; #original text
    my $is_cdata = shift;
    my $t = C4::TmplToken->new( $work, ($is_cdata? C4::TmplTokenType::CDATA : C4::TmplTokenType::TEXT), $line, $self->{filename} );
    push @tokens, $t;  
}      

sub default {
    my $self = shift;
    my $line = shift;
    my $work = shift; #original text
    my $is_cdata = shift;
    my $t = C4::TmplToken->new( $work, ($is_cdata? C4::TmplTokenType::CDATA : C4::TmplTokenType::TEXT), $line, $self->{filename} );
    push @tokens, $t;  
}      


#handle opening html tags
sub start{
    my $self = shift;
    my $line = shift;
    my $tag = shift;
    my $hash = shift; #hash of attr/value pairs
    my $text = shift; #origional text
    my $t = C4::TmplToken->new( $text, C4::TmplTokenType::TAG, $line, $self->{filename});
    my %attr;
    # tags seem to be uses in an 'interesting' way elsewhere..
    for my $key( %$hash ) {
        next unless defined $hash->{$key};
        if ($key eq "/"){
            $attr{+lc($key)} = [ $key, $hash->{$key}, $key."=".$hash->{$key}, 1 ];
            }
        else {
        $attr{+lc($key)} = [ $key, $hash->{$key}, $key."=".$hash->{$key}, 0 ];
            }
    }
    $t->set_attributes( \%attr );
    push @tokens, $t;
}

#handle closing html tags
sub end{
    my $self = shift;
    my $line = shift;
    my $tag = shift;
    my $hash = shift;
    my $text = shift;
    # what format should this be in?
    my $t = C4::TmplToken->new( $text, C4::TmplTokenType::TAG, $line, $self->{filename} );
    my %attr;
    # tags seem to be uses in an 'interesting' way elsewhere..
    for my $key( %$hash ) {
        next unless defined $hash->{$key};
        $attr{+lc($key)} = [ $key, $hash->{$key}, $key."=".$hash->{$key}, 0 ];
    }
    $t->set_attributes( \%attr );
    push @tokens, $t;
}

1;
