#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2014 - Biblibre SARL
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

use Test::More tests => 41;

use Koha::Database;

BEGIN {
    use_ok('t::lib::TestBuilder');
}

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();

is( $builder->build(), undef, 'build without arguments returns undef' );

my @sources    = $builder->schema->sources;
my @source_in_failure;
for my $source (@sources) {
    eval { $builder->build( { source => $source } ); };
    push @source_in_failure, $source if $@;
}
is( @source_in_failure, 0, 'TestBuilder should be able to create an object for every sources' );
if ( @source_in_failure ) {
    diag ("The following sources have not been generated correctly: " . join ', ', @source_in_failure)
}

my $my_overduerules_transport_type = {
    message_transport_type => {
        message_transport_type => 'my msg_t_t',
    },
    overduerules_id => {
        branchcode   => 'codeB',
        categorycode => 'codeC',
    },
    categorycode => undef,
};
$my_overduerules_transport_type->{categorycode} = $my_overduerules_transport_type->{branchcode};
my $overduerules_transport_type = $builder->build({
    source => 'OverduerulesTransportType',
    value  => $my_overduerules_transport_type,
});
is(
    $overduerules_transport_type->{message_transport_type},
    $my_overduerules_transport_type->{message_transport_type}->{message_transport_type},
    'build stores the message_transport_type correctly'
);
is(
    $overduerules_transport_type->{branchcode},
    $my_overduerules_transport_type->{branchcode}->{branchcode},
    'build stores the branchcode correctly'
);
is(
    $overduerules_transport_type->{categorycode},
    $my_overduerules_transport_type->{categorycode}->{categorycode},
    'build stores the categorycode correctly'
);
is(
    $overduerules_transport_type->{_fk}->{message_transport_type}->{message_transport_type},
    $my_overduerules_transport_type->{message_transport_type}->{message_transport_type},
    'build stores the foreign key message_transport_type correctly'
);
is(
    $overduerules_transport_type->{_fk}->{branchcode}->{branchcode},
    $my_overduerules_transport_type->{branchcode}->{branchcode},
    'build stores the foreign key branchcode correctly'
);
is(
    $overduerules_transport_type->{_fk}->{categorycode}->{categorycode},
    $my_overduerules_transport_type->{categorycode}->{categorycode},
    'build stores the foreign key categorycode correctly'
);
is_deeply(
    $overduerules_transport_type->{_fk}->{branchcode},
    $overduerules_transport_type->{_fk}->{categorycode},
    'build links the branchcode and the categorycode correctly'
);
isnt(
    $overduerules_transport_type->{_fk}->{overduerules_id}->{letter2},
    undef,
    'build generates values if they are not given'
);

my $my_user_permission = $t::lib::TestBuilder::default_value->{UserPermission};
my $user_permission = $builder->build({
    source => 'UserPermission',
});
isnt(
    $user_permission->{borrowernumber},
    undef,
    'build generates a borrowernumber correctly'
);
is(
    $user_permission->{module_bit},
    $my_user_permission->{module_bit}->{module_bit}->{bit},
    'build stores the default value correctly'
);
is(
    $user_permission->{code},
    $my_user_permission->{module_bit}->{code},
    'build stores the default value correctly'
);
is(
    $user_permission->{borrowernumber},
    $user_permission->{_fk}->{borrowernumber}->{borrowernumber},
    'build links the foreign key correctly'
);
is(
    $user_permission->{_fk}->{borrowernumber}->{surname},
    $my_user_permission->{borrowernumber}->{surname},
    'build stores the foreign key value correctly'
);
is(
    $user_permission->{_fk}->{borrowernumber}->{address},
    $my_user_permission->{borrowernumber}->{address},
    'build stores the foreign key value correctly'
);
is(
    $user_permission->{_fk}->{borrowernumber}->{city},
    $my_user_permission->{borrowernumber}->{city},
    'build stores the foreign key value correctly'
);
is(
    $user_permission->{_fk}->{borrowernumber}->{_fk}->{branchcode}->{branchcode},
    $my_user_permission->{borrowernumber}->{branchcode}->{branchcode},
    'build stores the foreign key value correctly'
);
is(
    $user_permission->{_fk}->{borrowernumber}->{_fk}->{branchcode}->{branchname},
    $my_user_permission->{borrowernumber}->{branchcode}->{branchname},
    'build stores the foreign key value correctly'
);
is(
    $user_permission->{_fk}->{borrowernumber}->{_fk}->{categorycode}->{categorycode},
    $my_user_permission->{borrowernumber}->{categorycode}->{categorycode},
    'build stores the foreign key value correctly'
);
is(
    $user_permission->{_fk}->{borrowernumber}->{_fk}->{categorycode}->{hidelostitems},
    $my_user_permission->{borrowernumber}->{categorycode}->{hidelostitems},
    'build stores the foreign key value correctly'
);
is(
    $user_permission->{_fk}->{borrowernumber}->{_fk}->{categorycode}->{category_type},
    $my_user_permission->{borrowernumber}->{categorycode}->{category_type},
    'build stores the foreign key value correctly'
);
is(
    $user_permission->{_fk}->{borrowernumber}->{_fk}->{categorycode}->{defaultprivacy},
    $my_user_permission->{borrowernumber}->{categorycode}->{defaultprivacy},
    'build stores the foreign key value correctly'
);
is(
    $user_permission->{_fk}->{borrowernumber}->{privacy},
    $my_user_permission->{borrowernumber}->{privacy},
    'build stores the foreign key value correctly'
);
is(
    $user_permission->{_fk}->{module_bit}->{_fk}->{module_bit}->{bit},
    $my_user_permission->{module_bit}->{module_bit}->{bit},
    'build stores the foreign key value correctly'
);
is(
    $user_permission->{_fk}->{module_bit}->{code},
    $my_user_permission->{module_bit}->{code},
    'build stores the foreign key value correctly'
);
is_deeply(
    $user_permission->{_fk}->{module_bit},
    $user_permission->{_fk}->{code},
    'build links the codes correctly'
);
isnt(
    $user_permission->{_fk}->{borrowernumber}->{cardnumber},
    undef,
    'build generates values if they are not given'
);
isnt(
    $user_permission->{_fk}->{borrowernumber}->{_fk}->{branchcode}->{branchaddress1},
    undef,
    'build generates values if they are not given'
);
isnt(
    $user_permission->{_fk}->{borrowernumber}->{_fk}->{categorycode}->{description},
    undef,
    'build generates values if they are not given'
);
isnt(
    $user_permission->{_fk}->{module_bit}->{description},
    undef,
    'build generates values if they are not given'
);
isnt(
    $user_permission->{_fk}->{module_bit}->{_fk}->{module_bit}->{flag},
    undef,
    'build generates values if they are not given'
);


my $nb_basket = $builder->schema->resultset('Aqbasket')->search();
isnt( $nb_basket, 0, 'add stores the generated entries correctly' );
$builder->clear( { source => 'Aqbasket' } );
$nb_basket = $builder->schema->resultset('Aqbasket')->search();
is( $nb_basket, 0, 'clear removes all the entries correctly' );


my $rs_aqbookseller = $builder->schema->resultset('Aqbookseller');
my $bookseller = $builder->build({
    source  => 'Aqbookseller',
    only_fk => 1,
});
delete $bookseller->{_fk};
my $bookseller_from_db = $rs_aqbookseller->find($bookseller);
is( $bookseller_from_db, undef, 'build with only_fk = 1 does not store the entry' );
my $bookseller_result = $rs_aqbookseller->create($bookseller);
is( $bookseller_result->in_storage, 1, 'build with only_fk = 1 creates the foreign keys correctly' );

$bookseller = $builder->build({
    source  => 'Aqbookseller',
});
ok( length( $bookseller->{phone} ) <= 30, 'The length for a generated string should not be longer than the size of the DB field' );
delete $bookseller->{_fk};
$bookseller_from_db = $rs_aqbookseller->find($bookseller);
is( $bookseller_from_db->in_storage, 1, 'build without the parameter only_sk stores the entry correctly' );

$bookseller = $builder->build({
    source  => 'Aqbookseller',
    only_fk => 0,
});
delete $bookseller->{_fk};
$bookseller_from_db = $rs_aqbookseller->find($bookseller);
is( $bookseller_from_db->in_storage, 1, 'build with only_fk = 0 stores the entry correctly' );

subtest 'Auto-increment values tests' => sub {

    plan tests => 2;

    # Pick a table with AI PK
    my $source  = 'Biblio'; # table
    my $column  = 'biblionumber'; # ai column

    my $col_info = $schema->source( $source )->column_info( $column );
    is( $col_info->{is_auto_increment}, 1, "biblio.biblionumber is detected as autoincrement");

    # Create a biblio
    my $biblio_1 = $builder->build({ source => $source });
    # Get the AI value
    my $ai_value = $biblio_1->{ biblionumber };
    # Create a biblio
    my $biblio_2 = $builder->build({ source => $source });
    # Get the next AI value
    my $next_ai_value = $biblio_2->{ biblionumber };
    is( $ai_value + 1, $next_ai_value, "AI values are consecutive");

};

$schema->storage->txn_rollback;

1;
