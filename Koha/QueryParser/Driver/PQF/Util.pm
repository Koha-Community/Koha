package Koha::QueryParser::Driver::PQF::Util;
use Scalar::Util qw(looks_like_number);

use strict;
use warnings;

=head1 NAME

    Koha::QueryParser::Driver::PQF::Util - Utility module for PQF QueryParser driver

=head1 FUNCTIONS

=head2 attributes_to_attr_string

    Koha::QueryParser::Driver::PQF::Util(%attributes);

    Koha::QueryParser::Driver::PQF::Util({ '1' => '1003', '4' => '6' });

Convert a hashref with a Bib-1 mapping into its PQF string representation.

=cut

sub attributes_to_attr_string {
    my ($attributes) = @_;
    my $attr_string = '';
    my $key;
    my $value;
    while (($key, $value) = each(%$attributes)) {
        next unless looks_like_number($key);
        $attr_string .= ' @attr ' . $key . '=' . $value . ' ';
    }
    $attr_string =~ s/^\s*//;
    $attr_string =~ s/\s*$//;
    $attr_string .= ' ' . $attributes->{''} if defined $attributes->{''};
    return $attr_string;
}

1;
