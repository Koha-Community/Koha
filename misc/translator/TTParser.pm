#!/usr/bin/env perl
#simple parser for HTML with Template Toolkit directives. Tokens are put into @tokens and are accesible via next_token and peep_token
package TTParser;
use base qw(HTML::Parser);
use TmplToken;
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
#    $self->handler(comment => "comment", "self, line, text, is_cdata"); # comments
#    $self->handler(default => "default", "self, line, text, is_cdata"); # anything else
    $self->marked_sections(1); #treat anything inside CDATA tags as text, should really make it a TmplTokenType::CDATA
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
        if( $work =~ m/\[%.*?\]/ ){
            #everything before this tag is text (or possibly CDATA), add a text token to tokens if $`
            if( $` ){
                my $t = TmplToken->new( $`, ($is_cdata? TmplTokenType::CDATA : TmplTokenType::TEXT), $line, $self->{filename} );
                push @tokens, $t;
            }

            #the match itself is a DIRECTIVE $&
            my $t = TmplToken->new( $&, TmplTokenType::DIRECTIVE, $line, $self->{filename} );
            push @tokens, $t;

            # put work still to do back into work
            $work = $' ? $' : 0;
        } else {
            # If there is some left over work, treat it as text token
            my $t = TmplToken->new( $work, ($is_cdata? TmplTokenType::CDATA : TmplTokenType::TEXT), $line, $self->{filename} );
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
    my $t = TmplToken->new( $work, ($is_cdata? TmplTokenType::CDATA : TmplTokenType::TEXT), $line, $self->{filename} );
    push @tokens, $t;  
}      

sub comment {
    my $self = shift;
    my $line = shift;
    my $work = shift; #original text
    my $is_cdata = shift;
    my $t = TmplToken->new( $work, ($is_cdata? TmplTokenType::CDATA : TmplTokenType::TEXT), $line, $self->{filename} );
    push @tokens, $t;  
}      

sub default {
    my $self = shift;
    my $line = shift;
    my $work = shift; #original text
    my $is_cdata = shift;
    my $t = TmplToken->new( $work, ($is_cdata? TmplTokenType::CDATA : TmplTokenType::TEXT), $line, $self->{filename} );
    push @tokens, $t;  
}      


#handle opening html tags
sub start{
    my $self = shift;
    my $line = shift;
    my $tag = shift;
    my $hash = shift; #hash of attr/value pairs
    my $text = shift; #origional text
    my $t = TmplToken->new( $text, TmplTokenType::TAG, $line, $self->{filename});
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
    my $t = TmplToken->new( $text, TmplTokenType::TAG, $line, $self->{filename} );
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
