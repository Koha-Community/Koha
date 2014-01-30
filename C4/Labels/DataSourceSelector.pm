package C4::Labels::DataSourceSelector;
# Copyright 2015 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Text::ParseWords;

use Koha::Exception::Parse;
=head SYNOPSIS

This class takes a String of directives and finds matching data elements.

=cut

=head select

@PARAM1 String, directive to parse for output
@PARAM2 ARRAYRef of HASHRefs, source data. See C4::Labels::DataSource for more information

@RETURNS String, directive result
=cut

sub select {
    my ($directive, $params) = @_;

    my $ors = _splitToLogicSegments($directive);

    ##Evaluate 'or'-segments in order.
    foreach my $or (@$ors) {
        my $payload = _evalSegment($or, $params);
        my $val = join(' ', @$payload);
        return $val if $val;
    }
}

=head isSelectorValid
@RETURNS Boolean, 1 if valid, 0 if invalid
=cut

sub isSelectorValid {
    my ($directive) = @_;

    my $ors = _splitToLogicSegments($directive);

    ##Evaluate 'or'-segments in order.
    foreach my $or (@$ors) {
        foreach my $op (@$or) {
            if (my $marcSel = _isMARCSelector($op)) {
                return 1;
            }
            elsif (my $dbSel = _isDBSelector($op)) {
                return 1;
            }
            elsif (my $text = _isText($op)) {
                return 1 if $text;
            }
            else {
                return 0;
            }
        }
    }
    return 0;
}

sub _splitToLogicSegments {
    my ($directive) = @_;

    my @tokens = Text::ParseWords::quotewords('\s+', 'keep', $directive);
    my @ors;
    my $segments = [];
    foreach my $token (@tokens) {
        if ($token =~ /^(or|\|\|)$/) { #Split using '||' or 'or'
            push(@ors, $segments);
            $segments = [];
        }
        else {
            push(@$segments, $token) if (not($token =~ /^(and|&&|\.|\+)$/));
        }
    }
    #if the last token wasn't a or-clause, add the remainder to logic segments. This way we prevent adding a trailing or two times.
    if (not($tokens[scalar(@tokens)-1] =~ /^or|\|\|$/)) {
        push(@ors, $segments);
    }

    return \@ors;
    ##First split to 'or'-segments
    #my @ors = split(/ or | \|\| /, $directive); #Split using '||' or 'or'
    #return \@ors;
}

sub _evalSegment {
    my ($or, $params) = @_;
    my @payload; #Collect results of source definition matchings here.
    foreach my $op (@$or) {
        if (my $marcSel = _isMARCSelector($op)) {
            my $val = _getMARCValue($marcSel, $params->[1]);
            push(@payload, $val) if $val;
        }
        elsif (my $dbSel = _isDBSelector($op)) {
            my $val = _getDBSelectorValue($dbSel, $params->[0]);
            push(@payload, $val) if $val;
        }
        elsif (my $text = _isText($op)) {
            push(@payload, $text) if $text;
        }
        else {
            my @cc = caller(0);
            Koha::Exception::Parse->throw(error => $cc[3]."($op):> Couldn't parse this source definition '$op'");
        }
    }
    return \@payload;
}

sub _getMARCValue {
    my ($selector, $record) = @_;

    my @fields = $record->field( $selector->{field} );
    foreach my $f (@fields) {
        my $sf = $f->subfield( $selector->{subfield} );
        return $sf if $sf;
    }
    return undef;
}

sub _isMARCSelector {
    my ($op) = @_;
    if ($op =~ /^\s*(\d{3})\$(\w)\s*$/) { #Eg. 245$a
        return {field => "$1", subfield => "$2"};
    }
    return undef;
}
sub _isDBSelector {
    my ($op) = @_;
    if ($op =~ /^\s*(\w+)\.(\w+)\s*$/) { #Eg. biblio.3_little_musketeers
        return {table => "$1", column => "$2"};
    }
    return undef;
}
sub _isText {
    my ($op) = @_;
    if ($op =~ /^"(.+)"$/) { #Eg. biblio.3_little_musketeers
        return $1;
    }
    return undef;
}

sub _getDBSelectorValue {
    my ($selector, $dbData) = @_;
    my $table = $dbData->{ $selector->{table} };
    unless ($table) {
        my @cc = caller(0);
        Koha::Exception::Parse->throw(error => $cc[3]."():> data source requests table '".$selector->{table}."', but that table is not available. Add more database sources in C4::Labels::DataSourceManager::_getDataSourceParams()");
    }
    unless (exists($table->{ $selector->{column} })) {
        my @cc = caller(0);
        Koha::Exception::Parse->throw(error => $cc[3]."():> data source requests table '".$selector->{table}."' and column '".$selector->{column}."', but that column is not available. Add more database sources in C4::Labels::DataSourceManager::_getDataSourceParams()");
    }
    return $table->{ $selector->{column} };
}

1;