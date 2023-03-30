package Koha::Notice::Util;

# Copyright Rijksmuseum 2023
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

use Modern::Perl;
use Data::Dumper qw/Dumper/;

use C4::Context;
use Koha::DateUtils qw/dt_from_string/;
use Koha::Notice::Messages;

=head1 NAME

Koha::Notice::Util - Utility class related to Koha notice messages

=head1 CLASS METHODS

=head2 load_domain_limits

    my $domain_limits = Koha::Notice::Util->load_domain_limits;

=cut

sub load_domain_limits {
    my ( $class ) = @_;

    my $domain_limits;
    my $entry = C4::Context->config('message_domain_limits');
    if( ref($entry) eq 'HASH' ) {
        if( exists $entry->{domain} ) {
            # Turn single hash entry into array
            $domain_limits = ref($entry->{domain}) eq 'HASH'
                ? [ $entry->{domain} ]
                : $entry->{domain};
            # Convert to hash structure by domain name
            $domain_limits = { map { lc $_->{name}, { limit => $_->{limit}, unit => $_->{unit}, count => 0 }} @$domain_limits };
        }
    }
    return _fill_domain_counts($domain_limits);
}

=head2 exceeds_limit

    my $boolean = Koha::Notice::Util->exceeds_limit( $to_address, $domain_limits );

=cut

sub exceeds_limit {
    my ( $class, $to_address, $domain_limits ) = @_;
    return 0 if !$domain_limits;
    my $domain = q{};
    $domain = lc $1 if $to_address && $to_address =~ /@(.*)/;
    return 0 if !exists $domain_limits->{$domain};
    return 1 if $domain_limits->{$domain}->{count} >= $domain_limits->{$domain}->{limit};
    $domain_limits->{$domain}->{count}++;
    warn "Sending messages: domain $domain reached limit of ".
        $domain_limits->{$domain}->{limit}. '/'. $domain_limits->{$domain}->{unit}
        if $domain_limits->{$domain}->{count} == $domain_limits->{$domain}->{limit};
    return 0;
}

=head1 PRIVATE METHODS

=cut

sub _fill_domain_counts {
    my ( $limits ) = @_;
    return $limits if !$limits;
    my $dt_parser = Koha::Database->new->schema->storage->datetime_parser;
    foreach my $domain ( keys %$limits ) {
        my $start_dt = _convert_unit( undef, $limits->{$domain}->{unit} );
        $limits->{$domain}->{count} = Koha::Notice::Messages->search({
            message_transport_type => 'email',
            status => 'sent',
            to_address => { 'LIKE', '%'.$domain },
            updated_on => { '>=', $dt_parser->format_datetime($start_dt) }, # FIXME Would be nice if possible via filter_by_last_update
        })->count;
    }
    return $limits;
}

sub _convert_unit { # unit should be like \d+(m|h|d)
    my ( $dt, $unit ) = @_;
    $dt //= dt_from_string();
    if( $unit && $unit =~ /(\d+)([mhd])/ ) {
        my $abbrev = { m => 'minutes', h => 'hours', d => 'days' };
        foreach my $h ( 0, 1 ) { # try hour before too when subtract fails (like: change to summertime)
            eval { $dt->subtract( hours => $h )->subtract( $abbrev->{$2} => $1 ) } and last;
        }
    }
    return $dt;
}

1;
