package Koha::Overdues::OverdueRule;

# Copyright 2015 Vaara-kirjastot
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

use Modern::Perl;

use base qw(Koha::Object);

use Koha::Database;
use Data::Dumper;

=head new

    my ($overdueRule, $error) = Koha::Overdues::OverdueRule->new({
                                    branchCode => 'CPL',
                                    borrowerCategory => 'STAFF',
                                    letterNumber => 2,
                                    delay => 20,
                                    letter => 'ODUE1',
                                    debarred => 1,
                                    fine => 2.5,
                                    messageTransportTypes => { print => 1,
                                                                 sms => 1,
                                                                 ...
                                    },
                                });

@PARAM1, HASH
@RETURN, Koha::Overdues::OverdueRule-object,
         and a String errorCode, if something bad hapened. Errorcodes as follows:
             'NOBRANCHCODE', 'NOBORROWERCATEGORY', 'BADLETTERNUMBER', 'BADDELAY',
             'NOLETTER', 'BADDEBARRED', 'BADFINE', 'NOTRANSPORTTYPES'

=cut

sub new {
    my ($class, $params) = @_;

    $params->{branchCode} = '' unless $params->{branchCode}; #Empty string branchCode means the default for all branches.
    $params->{fine}       = 0 unless $params->{fine}; #Fine can be 0
    my $error = Koha::Overdues::OverdueRule::ValidateParams($params);

    bless($params, $class);
    return ($params, $error); #Error should be undef. This way we can use the toString() with error cases.
}

=head ValidateParams, Static subroutine

    my $error = Koha::Overdues::OverdueRule::ValidateParams($params);

@PARAM1, HASH, see new() for valid values.
@RETURN, undef if everything succeeded,
         String errorCode, if something bad hapened. Errorcodes as follows:
         See Koha::Overdues::OverdueRule->new() for error code definitions.
=cut

sub ValidateParams {
    my ($params) = @_;
    return 'NOBRANCHCODE'         if (not(defined($params->{branchCode}))); #branchCode can be ''
    return 'NOBORROWERCATEGORY'   if (not($params->{borrowerCategory}));
    return 'BADLETTERNUMBER'      if (not($params->{letterNumber}) || $params->{letterNumber} !~ /^\d+$/);
    return 'BADDELAY'             if (not(defined($params->{delay})) || $params->{delay} !~ /^\d+$/); #delay can be 0
    return 'NOLETTER'             if (not($params->{letterCode}));
    return 'BADDEBARRED'          if (not(defined($params->{debarred})) || $params->{debarred} !~ /^\d+$/); #debarred can be 0
    return 'BADFINE'              if (not(defined($params->{fine})) || $params->{fine} !~ /^\d+\.?\d*$/); #debarred can be 0.00
    my $mtts = $params->{messageTransportTypes};
    return 'NOTRANSPORTTYPES'     if (not($mtts) || ref $mtts ne 'HASH' || not(scalar(%$mtts))); #Empty HASH is not OK, because these overdues need to be sent somehow.
    #Now that we have sanitated the input, we can rest assured that bad input won't crash this Object :)
    return undef; #all is ok.
}

=head replace

    my $overdueRule->replace( $replacementOverdueRule );

Replaces the calling overdue rule's keys with the given parameters'.
=cut

sub replace {
    my ($overdueRule, $replacementOverdueRule) = @_;

    foreach my $key (keys %$replacementOverdueRule) {
        $overdueRule->{$key} = $replacementOverdueRule->{$key};
    }
}

=head toString

    my $stringRepresentationOfThisObject = $overdueRule->toString();
    print $stringRepresentationOfThisObject."\n";

=cut

sub toString {
    my ($overdueRule) = @_;

    return Data::Dumper::Dump($overdueRule);
}

=head store
@OVERLOADS Koha::Object->store()
Because the OverdueRule is a representation of two tables, we cannot use the core Koha::Object methods,
but must provide our own. Maybe some day the overduerules and overduerules_transport_types-tables can
be modernized.
=cut

sub store {
    my ($overdueRule) = @_;

    my $overdueRuleId = $overdueRule->_storeOverduerule();
    $overdueRule->{overduerules_id} = $overdueRuleId;
    $overdueRule->_storeOverduerule_transport_types();
#    my $schema = Koha::Database->new()->schema();
#    $self->_result()->update_or_insert() ? $self : undef;
#          ->resultset( $self->type() )->new({});
}

sub _storeOverduerule {
    my $overdueRule = shift;
    my $schema = Koha::Database->new()->schema();

    my $params = $overdueRule->_buildOverdueruleColumns();
    my $oldOverdueruleRow = $schema->resultset( 'Overduerule' )->find({branchcode => $overdueRule->{branchCode}, categorycode => $overdueRule->{borrowerCategory}});
    my $return;
    if ($oldOverdueruleRow) {
        $oldOverdueruleRow->update( $params );
        $return = $oldOverdueruleRow->id;
    }
    else {
        my $newOverduerule = $schema->resultset( 'Overduerule' )->create( $params );
        $return = $newOverduerule->id;

    }

    return $return;

}
sub _buildOverdueruleColumns {
    my ($overdueRule) = @_;

    my $columns = {};
    my $i = $overdueRule->{letterNumber};
    $columns->{"branchcode"} = $overdueRule->{branchCode};
    $columns->{"categorycode"} = $overdueRule->{borrowerCategory};
    $columns->{"delay$i"} = $overdueRule->{delay};
    $columns->{"letter$i"} = $overdueRule->{letterCode};
    $columns->{"debarred$i"} = $overdueRule->{debarred};
    $columns->{"fine$i"} = $overdueRule->{fine};

    return $columns;
}

sub _storeOverduerule_transport_types {
    my $overdueRule = shift;
    my $schema = Koha::Database->new()->schema();
    my $branchCode = $overdueRule->{branchCode};
    my $borrowerCategory = $overdueRule->{borrowerCategory};
    my $letterNumber = $overdueRule->{letterNumber};
    my $overdueRuleId = $overdueRule->{overduerules_id};
    #Collect the unique message transport types for insertion
    my %insertableMessageTransportTypes = %{$overdueRule->{messageTransportTypes}}; #Clone them, so we can safely slice the HASH

    my @usedOverdueruleTransportTypes = $schema->resultset( 'OverduerulesTransportType' )->search({
                                        letternumber => $letterNumber,
                                        overduerules_id =>   $overdueRuleId,
                                    });
    foreach my $usedTransportType (@usedOverdueruleTransportTypes) {
        if ($insertableMessageTransportTypes{ $usedTransportType->message_transport_type }) {
            #This message_transport_Type needs no inserting as it is already there
            delete $insertableMessageTransportTypes{ $usedTransportType->message_transport_type };
            #We already have this transport type stored, currently nothing needs updating.
            #$usedTransportType->update( {message_transport_type => ???} );
        }
        else {
            #this is missing from the new mesage_transport_types
            $usedTransportType->delete();
        }
    }

    #insert what hasn't been matched
    foreach my $ott (sort keys %insertableMessageTransportTypes) {
        my $columns = { letternumber => $letterNumber,
                        message_transport_type => $ott, #overduerules_transport_type
                        overduerules_id =>   $overdueRuleId,
        };
        my $newOverduerule = $schema->resultset( 'OverduerulesTransportType' )->create( $columns );
    }
}

1;