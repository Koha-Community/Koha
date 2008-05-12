package KohaTest::Members::AttributeTypes;
#use base qw( KohaTest );
use base qw( Test::Class );

use strict;
use warnings;

use Test::More;

use C4::Members::AttributeTypes;
sub testing_class { 'C4::Members::AttributeTypes' };

sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( 
                    new
                    fetch
                    GetAttributeTypes
                    code
                    description
                    repeatable
                    unique_id
                    opac_display
                    password_allowed
                    staff_searchable
                    authorised_value_category
                    store
                    delete
                );
    
    can_ok( $self->testing_class, @methods );    
}

sub startup_50_create_types : Test( startup => 28 ) {
    my $self = shift;

    my $type1 = C4::Members::AttributeTypes->new('CAMPUSID', 'institution ID');
    isa_ok($type1,  'C4::Members::AttributeTypes');
    is($type1->code(), 'CAMPUSID', "set code in constructor");
    is($type1->description(), 'institution ID', "set description in constructor");
    ok(!$type1->repeatable(), "repeatable defaults to false");
    ok(!$type1->unique_id(), "unique_id defaults to false");
    ok(!$type1->opac_display(), "opac_display defaults to false");
    ok(!$type1->password_allowed(), "password_allowed defaults to false");
    ok(!$type1->staff_searchable(), "staff_searchable defaults to false");
    is($type1->authorised_value_category(), '', "authorised_value_category defaults to ''");

    $type1->repeatable('foobar');
    ok($type1->repeatable(), "repeatable now true");
    cmp_ok($type1->repeatable(), '==', 1, "repeatable not set to 'foobar'");
    $type1->repeatable(0);
    ok(!$type1->repeatable(), "repeatable now false");
    
    $type1->unique_id('foobar');
    ok($type1->unique_id(), "unique_id now true");
    cmp_ok($type1->unique_id(), '==', 1, "unique_id not set to 'foobar'");
    $type1->unique_id(0);
    ok(!$type1->unique_id(), "unique_id now false");
    
    $type1->opac_display('foobar');
    ok($type1->opac_display(), "opac_display now true");
    cmp_ok($type1->opac_display(), '==', 1, "opac_display not set to 'foobar'");
    $type1->opac_display(0);
    ok(!$type1->opac_display(), "opac_display now false");
    
    $type1->password_allowed('foobar');
    ok($type1->password_allowed(), "password_allowed now true");
    cmp_ok($type1->password_allowed(), '==', 1, "password_allowed not set to 'foobar'");
    $type1->password_allowed(0);
    ok(!$type1->password_allowed(), "password_allowed now false");
    
    $type1->staff_searchable('foobar');
    ok($type1->staff_searchable(), "staff_searchable now true");
    cmp_ok($type1->staff_searchable(), '==', 1, "staff_searchable not set to 'foobar'");
    $type1->staff_searchable(0);
    ok(!$type1->staff_searchable(), "staff_searchable now false");

    $type1->code('INSTID');
    is($type1->code(), 'CAMPUSID', 'code() allows retrieving but not setting');    
    $type1->description('student ID');
    is($type1->description(), 'student ID', 'set description');    
    $type1->authorised_value_category('CAT');
    is($type1->authorised_value_category(), 'CAT', 'set authorised_value_category');    
    
    $type1->repeatable(1);
    $type1->staff_searchable(1);
    $type1->store();
    is($type1->num_patrons(), 0, 'no patrons using the new attribute type yet');

    my $type2 = C4::Members::AttributeTypes->new('ABC', 'ABC ID');
    $type2->store();
}

sub shutdown_50_list_and_remove_types : Test( shutdown => 11 ) {
    my $self = shift;

    my @list = C4::Members::AttributeTypes::GetAttributeTypes();    
    is_deeply(\@list, [ { code => 'ABC', description => 'ABC ID' },
                        { code => 'CAMPUSID', description => 'student ID' } ], "retrieved list of types");

    my $type1 = C4::Members::AttributeTypes->fetch($list[1]->{code}); 
    isa_ok($type1, 'C4::Members::AttributeTypes');
    is($type1->code(), 'CAMPUSID', 'fetched code');    
    is($type1->description(), 'student ID', 'fetched description');    
    is($type1->authorised_value_category(), 'CAT', 'fetched authorised_value_category');    
    ok($type1->repeatable(), "fetched repeatable");
    ok(!$type1->unique_id(), "fetched unique_id");
    ok(!$type1->opac_display(), "fetched opac_display");
    ok(!$type1->password_allowed(), "fetched password_allowed");
    ok($type1->staff_searchable(), "fetched staff_searchable");

    $type1->delete();
    C4::Members::AttributeTypes->delete('ABC');

    my @newlist = C4::Members::AttributeTypes::GetAttributeTypes();    
    is(scalar(@newlist), 0, "no types left after deletion");   
    
}

1;
