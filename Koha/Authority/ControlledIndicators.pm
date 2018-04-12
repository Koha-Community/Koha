package Koha::Authority::ControlledIndicators;

# Copyright 2018 Rijksmuseum
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
use C4::Context;

=head1 NAME

Koha::Authority::ControlledIndicators - Obtain biblio indicators, controlled by authority record

=head1 API

=head2 METHODS

=head3 new

    Instantiate new object.

=cut

sub new {
    my ( $class, $params ) = @_;
    $params = {} if ref($params) ne 'HASH';
    return bless $params, $class;
}

=head3 get

    Obtain biblio indicators for given authority record and biblio field tag

    $self->get({
        auth_record => $record,
        report_tag  => $authtype->auth_tag_to_report,
        biblio_tag  => $tag,
        flavour     => $flavour,
    });

=cut

sub get {
    my ( $self, $params ) = @_;
    my $flavour = $params->{flavour} // q{};
    my $tag = $params->{biblio_tag} // q{};
    my $record = $params->{auth_record};
    my $report_tag = $params->{report_tag} // q{};

    $flavour = uc($flavour);
    $flavour = 'UNIMARC' if $flavour eq 'UNIMARCAUTH';

    $self->{_parsed} //= _load_pref();
    my $result = {};
    return $result if !exists $self->{_parsed}->{$flavour};
    my $rule = $self->{_parsed}->{$flavour}->{$tag} //
        $self->{_parsed}->{$flavour}->{'*'} //
        {};
    my $report_fld = $record ? $record->field( $report_tag ) : undef;

    foreach my $ind ( 'ind1', 'ind2' ) {
        if( exists $rule->{$ind} ) {
            if( !$rule->{$ind} ) {
                $result->{$ind} = $rule->{$ind}; # undef or empty string
            } elsif( $rule->{$ind} eq 'auth1' ) {
                $result->{$ind} = $report_fld->indicator(1) if $report_fld;
            } elsif( $rule->{$ind} eq 'auth2' ) {
                $result->{$ind} = $report_fld->indicator(2) if $report_fld;
            } elsif( $rule->{$ind} eq 'thesaurus' ) {
                my @info = _thesaurus_info( $record );
                $result->{$ind} = $info[0];
                $result->{sub2} = $info[1];
            } else {
                $result->{$ind} = substr( $rule->{$ind}, 0, 1);
            }
        }
    }

    return $result;
}

sub _load_pref {
    my $pref = C4::Context->preference('AuthorityControlledIndicators') // q{};
    my @lines = split /\r?\n/, $pref;

    my $res = {};
    foreach my $line (@lines) {
        $line =~ s/^\s*|\s*$//g;
        next if $line =~ /^#/;
        # line should be of the form: marcflavour,fld,ind1:val,ind2:val
        my @temp = split /\s*,\s*/, $line;
        next if @temp < 3;
        my $flavour = uc($temp[0]);
        $flavour = 'UNIMARC' if $flavour eq 'UNIMARCAUTH';
        next if $temp[1] !~ /(\d{3}|\*)/;
        my $tag = $1;
        if( $temp[2] =~ /ind1\s*:\s*(.*)/ ) {
            $res->{$flavour}->{$tag}->{ind1} = $1;
        }
        if( $temp[3] && $temp[3] =~ /ind2\s*:\s*(.*)/ ) {
            $res->{$flavour}->{$tag}->{ind2} = $1;
        }
    }
    return $res;
}

sub _thesaurus_info {
    # This sub is triggered by the term 'thesaurus' in the controlling pref.
    # The indicator of some MARC21 fields (like 600 ind2) is controlled by
    # authority field 008/11 and 040$f. Additionally, it may also control $2.
    my ( $record ) = @_;
    my $code = $record->field('008')
        ? substr($record->field('008')->data, 11, 1)
        : q{};
    my %thes_mapping = ( a => 0, b => 1, c => 2, d => 3, k => 5, n => 4, r => 7, s => 7, v => 6, z => 7, '|' => 4 );
    my $ind = $thes_mapping{ $code } // '4';

    # Determine optional subfield $2
    my $sub2;
    if( $ind eq '7' ) {
        # Important now to return a defined value
        $sub2 = $code eq 'r'
            ? 'aat'
            : $code eq 's'
            ? 'sears'
            : $code eq 'z' # pick from 040$f
            ? $record->subfield( '040', 'f' ) // q{}
            : q{};
    }
    return ( $ind, $sub2 );
}

=head1 AUTHOR

    Marcel de Rooy, Rijksmuseum Amsterdam, The Netherlands
    Janusz Kaczmarek
    Koha Development Team

=cut

1;
