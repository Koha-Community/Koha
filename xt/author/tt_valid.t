#!/usr/bin/perl

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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More;
use C4::TTParser;
use Array::Utils qw( array_minus );

use Koha::Devel::Files;
my $dev_files  = Koha::Devel::Files->new( { context => 'tidy' } );
my @tt_files   = $dev_files->ls_tt_files;
my @exclusions = qw(
    t/db_dependent/misc/translator/tt/en/sample-not-working.tt
    t/db_dependent/misc/translator/tt/en/sample-not-working-2.tt
    t/db_dependent/misc/translator/tt/en/sample.tt
);
@tt_files = array_minus @tt_files, @exclusions;

plan tests => scalar(@tt_files) * 2 + 1;

my @translatable_attributes = qw(alt content title value label placeholder aria-label);

my $checkers = [
    {
        description => 'TT syntax: incorrectly uses of TT tags in HTML tags',
        check       => sub {
            my ( $self, $name, $token ) = @_;
            my $attr = $token->{_attr};
            next unless $attr;
            my @errors;
            if ( $attr->{'[%'} or $attr->{'[%-'} ) {
                for my $attribute (@translatable_attributes) {

                    # The following tests come from tmpl_process3.pl sub text_replace_tag
                    next if $attribute eq 'label'   && $token->{_string} !~ /^<optgroup/;
                    next if $attribute eq 'content' && $token->{_string} !~ /^meta/;
                    next
                        if $attribute eq 'value'
                        && ( $token->{_string} !~ /^input/ );    # || additional check on checkbox|hidden|radio needed?
                    if ( exists $attr->{$attribute} ) {
                        if ( $attr->{$attribute}->[2] =~ m{$attribute=[^[]} ) {
                            push @errors, $token->{_lc};
                        }
                    } elsif ( exists $attr->{"%]$attribute"} ) {
                        push @errors, $token->{_lc};
                    }
                }
            }
            return @errors;
        },
    },
    {
        description => '<body> tag with id and class attributes',
        check       => sub {
            my ( $self, $name, $token ) = @_;
            return if $name =~ /bodytag\.inc/;
            my $tag = $token->{_string};
            return ( $tag =~ /^<body/ && ( $tag !~ /id=".+"/ || $tag !~ /class=".+"/ ) )
                ? ( $token->{_lc} )
                : ();
        },
    },
];

for my $filepath (@tt_files) {
    my $parser = C4::TTParser->new;
    $parser->build_tokens($filepath);
    my $errors = {};
    while ( my $token = $parser->next_token ) {
        my $attr = $token->{_attr};
        next unless $attr;

        for my $checker (@$checkers) {
            my @e = $checker->{check}->( $checker, $filepath, $token );
            push @{ $errors->{ $checker->{description} } }, @e if @e;
        }
    }
    for my $checker (@$checkers) {
        my @errors = @{ $errors->{ $checker->{description} } || [] };
        is( scalar(@errors), 0, $checker->{description} ) or diag( "$filepath: " . join( ', ', @errors ) );
    }
}

=head1 NAME

xt/author/tt_valid.t

=head1 DESCRIPTION

This test validates .tt files.

For the time being, two validations are done:

[1] Test if TT files contain TT directive within HTML tag. For example:

  <li[% IF

This kind of construction MUST be avoided because it breaks Koha translation
process.

[2] Test tag <body> tags have both attributes 'id' and 'class'

=cut
