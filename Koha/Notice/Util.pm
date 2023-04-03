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
            $domain_limits = { map { _init_domain_entry($_); } @$domain_limits };
        }
    }
    return $domain_limits;
}

sub _init_domain_entry {
    my ( $config_entry ) = @_;
    # Return either a hash like ( name => { limit => , unit =>, count => } ) for regular entries
    # or return a hash like ( name => { belongs_to => } ) for a domain that is part of a group

    return if ref($config_entry) ne 'HASH' || !exists $config_entry->{name};
    my $elements;
    if( $config_entry->{belongs_to} ) {
        $elements = { belongs_to => lc $config_entry->{belongs_to} };
    } else {
        $elements = { limit => $config_entry->{limit}, unit => $config_entry->{unit}, count => undef };
    }
    return ( lc $config_entry->{name}, $elements );
}

=head2 exceeds_limit

    my $boolean = Koha::Notice::Util->exceeds_limit({ to => $to_address, limits => $domain_limits, incr => 1|0 });

=cut

sub exceeds_limit {
    my ( $class, $params ) = @_;
    my $domain_limits = $params->{limits} or return 0; # no limits at all
    my $to_address = $params->{to} or return 0; # no address, no limit exceeded
    my $incr = $params->{incr} // 1; # by default we increment

    my $domain = q{};
    $domain = lc $1 if $to_address && $to_address =~ /@(\H+)/;
    return 0 if !$domain || !exists $domain_limits->{$domain};

    # Keep in mind that domain may be part of group count
    my $group = $domain_limits->{$domain}->{belongs_to} // $domain;
    _get_domain_count( $domain, $group, $domain_limits ) if !defined $domain_limits->{$group}->{count};
    return 1 if $domain_limits->{$group}->{count} >= $domain_limits->{$group}->{limit};

    if( $incr ) {
        $domain_limits->{$group}->{count}++;
        warn "Sending messages: domain $group reached limit of ".
          $domain_limits->{$group}->{limit}. '/'. $domain_limits->{$group}->{unit}
            if $domain_limits->{$group}->{count} == $domain_limits->{$group}->{limit};
    }
    return 0;
}

=head1 PRIVATE METHODS

=cut

sub _get_domain_count {
    my ( $domain, $group, $limits ) = @_;

    # Check if there are group members too
    my @domains;
    push @domains, $domain if $domain eq $group;
    push @domains, map
    {
        my $belongs = $limits->{$_}->{belongs_to} // q{};
        $belongs eq $group ? $_ : ();
    } keys %$limits;

    my $sum = 0;
    my $dt_parser = Koha::Database->new->schema->storage->datetime_parser;
    my $start_dt = _convert_unit( undef, $limits->{$group}->{unit} );
    foreach my $domain ( @domains ) {
        $sum += Koha::Notice::Messages->search({
            message_transport_type => 'email',
            status => 'sent',
            to_address => { 'LIKE', '%'.$domain },
            updated_on => { '>=', $dt_parser->format_datetime($start_dt) }, # FIXME Would be nice if possible via filter_by_last_update
        })->count;
    }
    $limits->{$group}->{count} = $sum;
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
