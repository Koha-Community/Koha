package C4::External::Amazon;
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


use strict;
use warnings;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
    require Exporter;
    $VERSION = 3.07.00.049;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        get_amazon_tld
    );
}


sub get_amazon_tld {
    my %tld = (
        CA => '.ca',
        DE => '.de',
        FR => '.fr',
        JP => '.jp',
        UK => '.co.uk',
        US => '.com',
    );

    my $locale = C4::Context->preference('AmazonLocale');
    my $tld = $tld{ $locale } || '.com'; # default top level domain is .com
    return $tld;
}


=head1 NAME

C4::External::Amazon - Functions for retrieving Amazon.com content in Koha

=head2 FUNCTIONS

This module provides facilities for retrieving Amazon.com content in Koha

=over

=item get_amazon_tld()

Get Amazon Top Level Domain depending on Amazon local preference: AmazonLocal.
For example, if AmazonLocal is 'UK', returns '.co.uk'.

=back

=cut

1;
__END__

=head1 NOTES

=cut

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>

=cut
