package C4::BatchOverlay::CandidateFinder;

# Copyright (C) 2017 KohaSuomi
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
use Scalar::Util qw(blessed);
use Try::Tiny;
use Data::Dumper;

use C4::Biblio;
use Koha::Validation;

use Koha::Exception::SubroutineCall;

=head1 NAME

C4::BatchOverlay::CandidateFinder

=synopsis

CandidateFinder looks for search criteria configured in the BatchOverlayRules-syspref
and prepares the CCL-query string the configuration represents.

=cut

=head2 new

@PARAM1 C4::BatchOverlay::Rule, typically the default rule

=cut

sub new {
    my ($class, $rule) = @_;

    my $self = {};
    bless($self, $class);
    $self->{rule} = $rule;
    return $self;
}

=head2 getSearchTerms

@RETURNS String, search terms the BatchOverlayRules-configuration asks for.
                 or an empty string.

=cut

sub getSearchTerms {
    my ($self) = @_;

    my @searches;

    my $criteria = $self->{rule}->getCandidateCriteria();
    while (my ($criterion, $arguments) = each(%$criteria)) {
        my $subroutineName = "criterion_$criterion";
        unless ($self->can($subroutineName)) {
            my @cc1 = caller(1);
            Koha::Exception::SubroutineCall->throw(error => $cc1[3]."():> Subroutine '$subroutineName' matching candidateCriteria '$criterion' doesn't exist. Your candidate criterion is unsupported.");
        }
        my $searchString = $self->$subroutineName($arguments);
        push(@searches, $searchString) if $searchString;
    }

    return join(" and ", @searches) if @searches;
    return '';
}

sub criterion_publicationDates {
    my ($self, $pubdates) = @_;
    Koha::Exception::BadParameter->throw(error => "\$pubdates '$pubdates' is not an arrayref.") unless ref($pubdates) eq 'ARRAY';

    my @sq;
    foreach my $pubdate (@$pubdates) {
        push(@sq, "pubdate='$pubdate'");
    }
    return '( '.join(' or ', @sq).' )';
}

=head2 criterion_monthsPast

The reason we have to fiddle with years and months like this, is due to the goddamn
Zebra-indexes not knowing heads or tails about dates and date searching.

@RETURNS String, CCL query

=cut

sub criterion_monthsPast {
    my ($self, $monthsPast) = @_;
    unless ($monthsPast && $monthsPast =~ /^(.+?)[, ]+(\d+)$/) {
        Koha::Exception::BadParameter->throw(error => "\$monthsPast '$monthsPast' is not valid. See syspref 'BatchOverlayRules' for proper monthsPast-criterion arguments.");
    }
    my ($index, $months) = ($1, $2);

    my $now = DateTime->now(time_zone => C4::Context->tz());
    my @pastMonths;
    foreach my $i (0..$months) {
        my $before = $now->clone()->subtract(months => $i);
        push(@pastMonths, "$index,rtrn='".$before->year().'-'.sprintf("%02d",$before->month())."'");
    }
    return '( '.join(' or ', @pastMonths). ' )';
}

=head2 criterion_lowlyCatalogued

This is just a stub for mandatory criterion lowlyCatalogued and currently has no purpose, other than follow an existing pattern.

=cut

sub criterion_lowlyCatalogued {
    my ($self, $hocusPocus) = @_;
    return undef;
}


1; #Satisfying the compiler, we aim to please!
