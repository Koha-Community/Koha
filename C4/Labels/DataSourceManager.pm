package C4::Labels::DataSourceManager;
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
use DateTime;
use Class::Inspector;
use Scalar::Util qw(blessed);

use C4::Labels::DataSource;
use C4::Labels::DataSourceSelector;
use C4::Labels::DataSourceFormatter;
use C4::Labels::PdfCreator;
use C4::Items;
use C4::Biblio;
use Koha::Libraries;

=head SYNOPSIS

This class is a front-end for querying DataSources capabilities

=cut

=head getAvailableDataSourceFunctions

@RETURNS ARRAYRef of data source function names

=cut

sub getAvailableDataSourceFunctions {
    return _introspectDataSourceProcessingFunctions() || [];
}

sub hasDataSourceFunction {
    my ($functionName) = @_;

    my $fullName = _getFullDataSourceFunctionName($functionName);
    if (exists &{$fullName}) {
        return 1;
    }
}

sub getAvailableDataFormatFunctions {
    return _introspectDataFormatFunctions() || [];
}

sub hasDataFormatFunction {
    my ($functionName) = @_;

    my $fullName = _getFullDataFormatFunctionName($functionName);
    if (exists &{$fullName}) {
        return 1;
    }
}

sub _getFullDataSourceFunctionName {
    my ($functionName) = @_;
    return "C4::Labels::DataSource::public_$functionName";
}

sub _getFullDataFormatFunctionName {
    my ($functionName) = @_;
    return "C4::Labels::DataSourceFormatter::public_$functionName";
}

sub executeDataSource {
    my ($element, $itemId) = @_;

    my $params = _getDataSourceParams($element, $itemId);

    if ($element->isFunction()) {
        return _executeDataSourceFunction($element, $params);
    }
    else {
        return _executeDataSourceSelector($element, $params);
    }
}

sub executeDataFormat {
    my ($element, $text) = @_;
    if ($text) {
        my $funcName = _getFullDataFormatFunctionName($element->getDataFormat());
        no strict 'refs';
        my $s = \&{$funcName};
        return $s->( {text => $text}, $element );
    }
}

sub _executeDataSourceFunction {
    my ($element, $params) = @_;

    my $funcName = _getFullDataSourceFunctionName($element->getFunctionName());
    no strict 'refs';
    my $s = \&{$funcName};
    return $s->( $params );
}

sub _executeDataSourceSelector {
    my ($element, $params) = @_;

    return C4::Labels::DataSourceSelector::select($element->getDataSource(), $params);
}

sub _getDataSourceParams {
    my ($element, $itemId) = @_;
    my $dbData = _getDatabaseData($itemId);
    my $record = C4::Biblio::GetMarcBiblio($dbData->{item}->{biblionumber}, undef);
    my $dsParams = _getDataSourceSubroutineParams($element);
    return [
        $dbData,
        $record,
        $element,
        $dsParams,
    ];
}
sub _getDatabaseData {
    my ($item) = @_;

    if (blessed($item) && $item->isa('Koha::Item')) {
        $item = $item = C4::Items::GetItem(undef,$item->barcode,undef);
    }
    elsif (not(ref $item eq 'HASH')) {
        $item = C4::Items::GetItem(undef,$item,undef);
    }
    my $biblio = C4::Biblio::GetBiblio($item->{biblionumber});
    my $biblioitem = C4::Biblio::GetBiblioItemData($item->{biblioitemnumber});
    my $homebranch = Koha::Libraries->find($item->{homebranch})->unblessed;
    return {
        biblio     => $biblio,
        biblioitem => $biblioitem,
        item       => $item,
        homebranch => $homebranch,
    };
}

sub _getDataSourceSubroutineParams {
    my ($element) = @_;

    my $ds = $element->getDataSource();
    if ($ds =~ /\((.+?)\)/) {
        my $paramString = $1;
        my @params = split(/(\s+|,)/, $paramString);
        return \@params;
    }
    return [];
}

=head _introspectDataSourceProcessingFunctions

    my $subroutines = C4::Labels::DataSource::_introspectDataSourceProcessingFunctions();

Get the dataSource processing subroutines DataSources-package provides.
@RETURNS ARRAYRef of subroutine names.
=cut

sub _introspectDataSourceProcessingFunctions {
    my $funcs = Class::Inspector->functions("C4::Labels::DataSource");
    my @funcs;
    foreach my $func (@$funcs) {
        if ($func =~ s/^public_//) { #Remove "unintended" subroutines
            push(@funcs, $func);
        }
    }
    return \@funcs;
}

=head _introspectDataFormatFunctions

    my $subroutines = C4::Labels::DataSource::_introspectDataFormatFunctions();

Get the dataSource formatting subroutines DataSourceFormatter-package provides.
@RETURNS ARRAYRef of subroutine names.
=cut

sub _introspectDataFormatFunctions {
    my $funcs = Class::Inspector->functions("C4::Labels::DataSourceFormatter");
    my @funcs;
    foreach my $func (@$funcs) {
        if ($func =~ s/^public_//) { #Remove "unintended" subroutines
            push(@funcs, $func);
        }
    }
    return \@funcs;
}

1;
