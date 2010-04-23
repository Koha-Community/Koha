package C4::Numberpattern;

# Copyright 2000-2002 Biblibre SARL
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
#use warnings; FIXME - Bug 2505
use C4::Context;
use C4::SQLHelper qw<:all>;
use C4::Debug;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
	$VERSION = 3.01;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(

        &GetNumberpatterns
        &GetNumberpattern
		&new
		&all
	    &AddNumberpattern
        &ModNumberpattern
        &DelNumberpattern

	);
}

# -------------------------------------------------------------------
sub new {
    my ($class, $opts) = @_;
    bless $opts => $class;
}


sub AddNumberpattern {
    my ($class,$numberpattern) = @_;
	return InsertInTable("subscription_numberpattern",$numberpattern);
}

# -------------------------------------------------------------------
sub ModNumberpattern {
    my ($class,$numberpattern) = @_;
	return UpdateInTable("subscription_numberpattern",$numberpattern);
}

# -------------------------------------------------------------------
sub DelNumberpattern {
	my ($class,$numberpattern) = @_;
	return DeleteInTable("subscription_numberpattern",$numberpattern);
}

sub all {
    my ($class) = @_;
    my $dbh = C4::Context->dbh;
    return    map { $class->new($_) }    @{$dbh->selectall_arrayref(
        # The subscription_numberpattern table is small enough for
        # `SELECT *` to be harmless.
        "SELECT * FROM subscription_numberpattern ORDER BY description",
        { Slice => {} },
    )};
}

=head3 GetNumberpattern

=over 4

&GetNumberpattern($freq_id);

gets numberpattern where $freq_id is the identifier

=back

=cut

# -------------------------------------------------------------------
sub GetNumberpattern {
    my ($numpattern_id) = @_;
	return undef unless $num_patternid;
    my $results= SearchInTable("subscription_numberpattern",{numberpattern_id=>$freq_id}, undef, undef,undef, undef, "wide");
	return undef unless ($results);
	return $$results[0];
}

=head3 GetFrequencies

=over 4

&GetFrequencies($filter, $order_by);

gets frequencies restricted on filters

=back

=cut

# -------------------------------------------------------------------
sub GetNumberPatterns {
    my ($filters,$orderby) = @_;
    return SearchInTable("subscription_numberpattern",$filters, $orderby, undef,undef, undef, "wide");
}

END { }    # module clean-up code here (global destructor)

1;
__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
