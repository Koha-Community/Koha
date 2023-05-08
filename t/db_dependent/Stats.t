#!/usr/bin/perl

# Copyright 2013, 2023 Koha Development team
#
# This file is part of Koha
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
use Test::More tests => 1;
use Test::Exception;

use C4::Context;
use C4::Stats qw( UpdateStats );
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

subtest 'UpdateStats' => sub {
    plan tests => 16;

    throws_ok { UpdateStats() } 'Koha::Exceptions::BadParameter', 'UpdateStats called without params';

    my $params = {
                  branch => "BRA",
                  itemnumber => 31,
                  borrowernumber => 5,
                  amount => 5.1,
                  other => "bla",
                  itemtype => "BK",
                  location => "LOC",
                  ccode => "CODE",
                  interface => "INTERFACE",
    };
    my $return_error;

    # returns undef and croaks if type is not allowed
    $params -> {type} = "bla";
    eval {UpdateStats($params)};
    $return_error = $@;
    isnt ($return_error,'',"UpdateStats returns undef and croaks if type is not allowed");

    delete $params->{type};
    # returns undef and croaks if type is missing
    eval {UpdateStats($params)};
    $return_error = $@;
    isnt ($return_error,'',"UpdateStats returns undef and croaks if no type given");

    $params -> {type} = undef;
    # returns undef and croaks if type is undef
    eval {UpdateStats($params)};
    $return_error = $@;
    isnt ($return_error,'',"UpdateStats returns undef and croaks if type is undef");

    # returns undef and croaks if mandatory params are missing
    my @allowed_circulation_types  = @Koha::Statistic::allowed_circulation_types;
    my @allowed_accounts_types     = @Koha::Statistic::allowed_accounts_types;
    my @circulation_mandatory_keys = @Koha::Statistic::mandatory_circulation_keys;
    my @accounts_mandatory_keys    = @Koha::Statistic::mandatory_accounts_keys;

    my @missing_errors = ();
    foreach my $key (@circulation_mandatory_keys) {
        next if $key eq 'type';
        my $value = $params->{$key};
        delete $params->{$key};
        foreach my $type (@allowed_circulation_types) {
            $params->{type} = $type;
            eval {UpdateStats($params)};
            $return_error = $@;
            push @missing_errors, "key:$key for type:$type" unless $return_error;
        }
        $params->{$key} = $value;
    }
    foreach my $key (@accounts_mandatory_keys) {
        next if $key eq 'type';
        my $value = $params->{$key};
        delete $params->{$key};
        foreach my $type (@allowed_accounts_types) {
            $params->{type} = $type;
            eval {UpdateStats($params)};
            $return_error = $@;
            push @missing_errors, "key:$key for type:$type" unless $return_error;
        }
        $params->{$key} = $value;

    }
    is (join (", ", @missing_errors),'',"UpdateStats returns undef and croaks if mandatory params are missing");

    # save the params in the right database fields
    $dbh->do(q|DELETE FROM statistics|);
    $params = {
                  branch => "BRA",
                  itemnumber => 31,
                  borrowernumber => 5,
                  amount =>5.1,
                  other => "bla",
                  itemtype => "BK",
                  location => "LOC",
                  ccode => "CODE",
                  type => "return",
                  interface => "INTERFACE",
    };
    UpdateStats ($params);
    my $sth = $dbh->prepare("SELECT * FROM statistics");
    $sth->execute();
    my $line = ${ $sth->fetchall_arrayref( {} ) }[0];
    is ($params->{branch},         $line->{branch},         "UpdateStats save branch param in branch field of statistics table");
    is ($params->{type},           $line->{type},           "UpdateStats save type param in type field of statistics table");
    is ($params->{borrowernumber}, $line->{borrowernumber}, "UpdateStats save borrowernumber param in borrowernumber field of statistics table");
    is ($params->{value},          $line->{value},          "UpdateStats save amount param in value field of statistics table");
    is ($params->{other},          $line->{other},          "UpdateStats save other param in other field of statistics table");
    is ($params->{itemtype},       $line->{itemtype},       "UpdateStats save itemtype param in itemtype field of statistics table");
    is ($params->{location},       $line->{location},       "UpdateStats save location param in location field of statistics table");
    is ($params->{ccode},          $line->{ccode},          "UpdateStats save ccode param in ccode field of statistics table");
    is ($params->{interface},      $line->{interface},      "UpdateStats save interface param in interface field of statistics table");

    $dbh->do(q|DELETE FROM statistics|);
    $params = {
        branch         => "BRA",
        itemnumber     => 31,
        borrowernumber => 5,
        amount         => 5.1,
        other          => "bla",
        itemtype       => "BK",
        ccode          => "CODE",
        type           => "return",
        interface      => "INTERFACE",
    };
    UpdateStats($params);
    $sth = $dbh->prepare("SELECT * FROM statistics");
    $sth->execute();
    $line = ${ $sth->fetchall_arrayref( {} ) }[0];
    is( $line->{location}, undef,
        "UpdateStats sets location to NULL if no location is passed in." );

    $dbh->do(q|DELETE FROM statistics|);
    $params = {
        branch         => "BRA",
        itemnumber     => 31,
        borrowernumber => 5,
        amount         => 5.1,
        other          => "bla",
        itemtype       => "BK",
        location       => undef,
        ccode          => "CODE",
        type           => "return",
        interface      => "interface"
    };
    UpdateStats($params);
    $sth = $dbh->prepare("SELECT * FROM statistics");
    $sth->execute();
    $line = ${ $sth->fetchall_arrayref( {} ) }[0];
    is( $line->{location}, undef,
        "UpdateStats sets location to NULL if undef is passed in." );
};

$schema->storage->txn_rollback;
