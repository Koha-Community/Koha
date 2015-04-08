package C4::OAI::Sets;

# Copyright 2011 BibLibre
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

=head1 NAME

C4::OAI::Sets - OAI Sets management functions

=head1 DESCRIPTION

C4::OAI::Sets contains functions for managing storage and editing of OAI Sets.

OAI Set description can be found L<here|http://www.openarchives.org/OAI/openarchivesprotocol.html#Set>

=cut

use Modern::Perl;
use C4::Context;

use vars qw(@ISA @EXPORT);

BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        &GetOAISets &GetOAISet &GetOAISetBySpec &ModOAISet &DelOAISet &AddOAISet
        &GetOAISetsMappings &GetOAISetMappings &ModOAISetMappings
        &GetOAISetsBiblio &ModOAISetsBiblios &AddOAISetsBiblios
        &CalcOAISetsBiblio &UpdateOAISetsBiblio
    );
}

=head1 FUNCTIONS

=head2 GetOAISets

    $oai_sets = GetOAISets;

GetOAISets return a array reference of hash references describing the sets.
The hash references looks like this:

    {
        'name'         => 'set name',
        'spec'         => 'set spec',
        'descriptions' => [
            'description 1',
            'description 2',
            ...
        ]
    }

=cut

sub GetOAISets {
    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT * FROM oai_sets
    };
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my $results = $sth->fetchall_arrayref({});

    $query = qq{
        SELECT description
        FROM oai_sets_descriptions
        WHERE set_id = ?
    };
    $sth = $dbh->prepare($query);
    foreach my $set (@$results) {
        $sth->execute($set->{'id'});
        my $desc = $sth->fetchall_arrayref({});
        foreach (@$desc) {
            push @{$set->{'descriptions'}}, $_->{'description'};
        }
    }

    return $results;
}

=head2 GetOAISet

    $set = GetOAISet($set_id);

GetOAISet returns a hash reference describing the set with the given set_id.

See GetOAISets to see what the hash looks like.

=cut

sub GetOAISet {
    my ($set_id) = @_;

    return unless $set_id;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT *
        FROM oai_sets
        WHERE id = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($set_id);
    my $set = $sth->fetchrow_hashref;

    $query = qq{
        SELECT description
        FROM oai_sets_descriptions
        WHERE set_id = ?
    };
    $sth = $dbh->prepare($query);
    $sth->execute($set->{'id'});
    my $desc = $sth->fetchall_arrayref({});
    foreach (@$desc) {
        push @{$set->{'descriptions'}}, $_->{'description'};
    }

    return $set;
}

=head2 GetOAISetBySpec

    my $set = GetOAISetBySpec($setSpec);

Returns a hash describing the set whose spec is $setSpec

=cut

sub GetOAISetBySpec {
    my $setSpec = shift;

    return unless defined $setSpec;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT *
        FROM oai_sets
        WHERE spec = ?
        LIMIT 1
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($setSpec);

    return $sth->fetchrow_hashref;
}

=head2 ModOAISet

    my $set = {
        'id' => $set_id,                 # mandatory
        'spec' => $spec,                 # mandatory
        'name' => $name,                 # mandatory
        'descriptions => \@descriptions, # optional, [] to remove descriptions
    };
    ModOAISet($set);

ModOAISet modify a set in the database.

=cut

sub ModOAISet {
    my ($set) = @_;

    return unless($set && $set->{'spec'} && $set->{'name'});

    if(!defined $set->{'id'}) {
        warn "Set ID not defined, can't modify the set";
        return;
    }

    my $dbh = C4::Context->dbh;
    my $query = qq{
        UPDATE oai_sets
        SET spec = ?,
            name = ?
        WHERE id = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($set->{'spec'}, $set->{'name'}, $set->{'id'});

    if($set->{'descriptions'}) {
        $query = qq{
            DELETE FROM oai_sets_descriptions
            WHERE set_id = ?
        };
        $sth = $dbh->prepare($query);
        $sth->execute($set->{'id'});

        if(scalar @{$set->{'descriptions'}} > 0) {
            $query = qq{
                INSERT INTO oai_sets_descriptions (set_id, description)
                VALUES (?,?)
            };
            $sth = $dbh->prepare($query);
            foreach (@{ $set->{'descriptions'} }) {
                $sth->execute($set->{'id'}, $_) if $_;
            }
        }
    }
}

=head2 DelOAISet

    DelOAISet($set_id);

DelOAISet remove the set with the given set_id

=cut

sub DelOAISet {
    my ($set_id) = @_;

    return unless $set_id;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        DELETE oai_sets, oai_sets_descriptions, oai_sets_mappings
        FROM oai_sets
          LEFT JOIN oai_sets_descriptions ON oai_sets_descriptions.set_id = oai_sets.id
          LEFT JOIN oai_sets_mappings ON oai_sets_mappings.set_id = oai_sets.id
        WHERE oai_sets.id = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($set_id);
}

=head2 AddOAISet

    my $set = {
        'id' => $set_id,                 # mandatory
        'spec' => $spec,                 # mandatory
        'name' => $name,                 # mandatory
        'descriptions => \@descriptions, # optional
    };
    my $set_id = AddOAISet($set);

AddOAISet adds a new set and returns its id, or undef if something went wrong.

=cut

sub AddOAISet {
    my ($set) = @_;

    return unless($set && $set->{'spec'} && $set->{'name'});

    my $set_id;
    my $dbh = C4::Context->dbh;
    my $query = qq{
        INSERT INTO oai_sets (spec, name)
        VALUES (?,?)
    };
    my $sth = $dbh->prepare($query);
    if( $sth->execute($set->{'spec'}, $set->{'name'}) ) {
        $set_id = $dbh->last_insert_id(undef, undef, 'oai_sets', undef);
        if($set->{'descriptions'}) {
            $query = qq{
                INSERT INTO oai_sets_descriptions (set_id, description)
                VALUES (?,?)
            };
            $sth = $dbh->prepare($query);
            foreach( @{ $set->{'descriptions'} } ) {
                $sth->execute($set_id, $_) if $_;
            }
        }
    } else {
        warn "AddOAISet failed";
    }

    return $set_id;
}

=head2 GetOAISetsMappings

    my $mappings = GetOAISetsMappings;

GetOAISetsMappings returns mappings for all OAI Sets.

Mappings define how biblios are categorized in sets.
A mapping is defined by four properties:

    {
        marcfield => 'XXX',     # the MARC field to check
        marcsubfield => 'Y',    # the MARC subfield to check
        operator => 'A',        # the operator 'equal' or 'notequal'; 'equal' if ''
        marcvalue => 'zzzz',    # the value to check
    }

If defined in a set mapping, a biblio which have at least one 'Y' subfield of
one 'XXX' field equal to 'zzzz' will belong to this set.
If multiple mappings are defined in a set, the biblio will belong to this set
if at least one condition is matched.

GetOAISetsMappings returns a hashref of arrayrefs of hashrefs.
The first hashref keys are the sets IDs, so it looks like this:

    $mappings = {
        '1' => [
            {
                marcfield => 'XXX',
                marcsubfield => 'Y',
                operator => 'A',
                marcvalue => 'zzzz'
            },
            {
                ...
            },
            ...
        ],
        '2' => [...],
        ...
    };

=cut

sub GetOAISetsMappings {
    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT * FROM oai_sets_mappings
    };
    my $sth = $dbh->prepare($query);
    $sth->execute;

    my $mappings = {};
    while(my $result = $sth->fetchrow_hashref) {
        push @{ $mappings->{$result->{'set_id'}} }, {
            marcfield => $result->{'marcfield'},
            marcsubfield => $result->{'marcsubfield'},
            operator => $result->{'operator'},
            marcvalue => $result->{'marcvalue'}
        };
    }

    return $mappings;
}

=head2 GetOAISetMappings

    my $set_mappings = GetOAISetMappings($set_id);

Return mappings for the set with given set_id. It's an arrayref of hashrefs

=cut

sub GetOAISetMappings {
    my ($set_id) = @_;

    return unless $set_id;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT *
        FROM oai_sets_mappings
        WHERE set_id = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($set_id);

    my @mappings;
    while(my $result = $sth->fetchrow_hashref) {
        push @mappings, {
            marcfield => $result->{'marcfield'},
            marcsubfield => $result->{'marcsubfield'},
            operator => $result->{'operator'},
            marcvalue => $result->{'marcvalue'}
        };
    }

    return \@mappings;
}

=head2 ModOAISetMappings {

    my $mappings = [
        {
            marcfield => 'XXX',
            marcsubfield => 'Y',
            operator => 'A',
            marcvalue => 'zzzz'
        },
        ...
    ];
    ModOAISetMappings($set_id, $mappings);

ModOAISetMappings modifies mappings of a given set.

=cut

sub ModOAISetMappings {
    my ($set_id, $mappings) = @_;

    return unless $set_id;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        DELETE FROM oai_sets_mappings
        WHERE set_id = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($set_id);

    if(scalar @$mappings > 0) {
        $query = qq{
            INSERT INTO oai_sets_mappings (set_id, marcfield, marcsubfield, operator, marcvalue)
            VALUES (?,?,?,?,?)
        };
        $sth = $dbh->prepare($query);
        foreach (@$mappings) {
            $sth->execute($set_id, $_->{'marcfield'}, $_->{'marcsubfield'}, $_->{'operator'}, $_->{'marcvalue'});
        }
    }
}

=head2 GetOAISetsBiblio

    $oai_sets = GetOAISetsBiblio($biblionumber);

Return the OAI sets where biblio appears.

Return value is an arrayref of hashref where each element of the array is a set.
Keys of hash are id, spec and name

=cut

sub GetOAISetsBiblio {
    my ($biblionumber) = @_;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT oai_sets.*
        FROM oai_sets
          LEFT JOIN oai_sets_biblios ON oai_sets_biblios.set_id = oai_sets.id
        WHERE biblionumber = ?
    };
    my $sth = $dbh->prepare($query);

    $sth->execute($biblionumber);
    return $sth->fetchall_arrayref({});
}

=head2 DelOAISetsBiblio

    DelOAISetsBiblio($biblionumber);

Remove a biblio from all sets

=cut

sub DelOAISetsBiblio {
    my ($biblionumber) = @_;

    return unless $biblionumber;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        DELETE FROM oai_sets_biblios
        WHERE biblionumber = ?
    };
    my $sth = $dbh->prepare($query);
    return $sth->execute($biblionumber);
}

=head2 CalcOAISetsBiblio

    my @sets = CalcOAISetsBiblio($record, $oai_sets_mappings);

Return a list of set ids the record belongs to. $record must be a MARC::Record
and $oai_sets_mappings (optional) must be a hashref returned by
GetOAISetsMappings

=cut

sub CalcOAISetsBiblio {
    my ($record, $oai_sets_mappings) = @_;

    return unless $record;

    $oai_sets_mappings ||= GetOAISetsMappings;

    my @biblio_sets;
    foreach my $set_id (keys %$oai_sets_mappings) {
        foreach my $mapping (@{ $oai_sets_mappings->{$set_id} }) {
            next if not $mapping;
            my $field = $mapping->{'marcfield'};
            my $subfield = $mapping->{'marcsubfield'};
            my $operator = $mapping->{'operator'};
            my $value = $mapping->{'marcvalue'};
            my @subfield_values = $record->subfield($field, $subfield);
            if ($operator eq 'notequal') {
                if(0 == grep /^$value$/, @subfield_values) {
                    push @biblio_sets, $set_id;
                    last;
                }
            }
            else {
                if(0 < grep /^$value$/, @subfield_values) {
                    push @biblio_sets, $set_id;
                    last;
                }
            }
        }
    }
    return @biblio_sets;
}

=head2 ModOAISetsBiblios

    my $oai_sets_biblios = {
        '1' => [1, 3, 4],   # key is the set_id, and value is an array ref of biblionumbers
        '2' => [],
        ...
    };
    ModOAISetsBiblios($oai_sets_biblios);

ModOAISetsBiblios truncate oai_sets_biblios table and call AddOAISetsBiblios.
This table is then used in opac/oai.pl.

=cut

sub ModOAISetsBiblios {
    my $oai_sets_biblios = shift;

    return unless ref($oai_sets_biblios) eq "HASH";

    my $dbh = C4::Context->dbh;
    my $query = qq{
        TRUNCATE TABLE oai_sets_biblios
    };
    my $sth = $dbh->prepare($query);
    $sth->execute;
    AddOAISetsBiblios($oai_sets_biblios);
}

=head2 UpdateOAISetsBiblio

    UpdateOAISetsBiblio($biblionumber, $record);

Update OAI sets for one biblio. The two parameters are mandatory.
$record is a MARC::Record.

=cut

sub UpdateOAISetsBiblio {
    my ($biblionumber, $record) = @_;

    return unless($biblionumber and $record);

    my $sets_biblios;
    my @sets = CalcOAISetsBiblio($record);
    foreach (@sets) {
        push @{ $sets_biblios->{$_} }, $biblionumber;
    }
    DelOAISetsBiblio($biblionumber);
    AddOAISetsBiblios($sets_biblios);
}

=head2 AddOAISetsBiblios

    my $oai_sets_biblios = {
        '1' => [1, 3, 4],   # key is the set_id, and value is an array ref of biblionumbers
        '2' => [],
        ...
    };
    ModOAISetsBiblios($oai_sets_biblios);

AddOAISetsBiblios insert given infos in oai_sets_biblios table.
This table is then used in opac/oai.pl.

=cut

sub AddOAISetsBiblios {
    my $oai_sets_biblios = shift;

    return unless ref($oai_sets_biblios) eq "HASH";

    my $dbh = C4::Context->dbh;
    my $query = qq{
        INSERT INTO oai_sets_biblios (set_id, biblionumber)
        VALUES (?,?)
    };
    my $sth = $dbh->prepare($query);
    foreach my $set_id (keys %$oai_sets_biblios) {
        foreach my $biblionumber (@{$oai_sets_biblios->{$set_id}}) {
            $sth->execute($set_id, $biblionumber);
        }
    }
}

1;
