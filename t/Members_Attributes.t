#!/usr/bin/perl
#
#

use strict;
use warnings;

use Test::More tests => 11;

BEGIN {
    use_ok('C4::Members::Attributes', qw(:all));
}

INIT {
    $C4::Members::Attributes::AttributeTypes = {
          'grade' => {
                       'opac_display' => '1',
                       'staff_searchable' => '1',
                       'description' => 'Grade level',
                       'password_allowed' => '0',
                       'authorised_value_category' => '',
                       'repeatable' => '0',
                       'code' => 'grade',
                       'unique_id' => '0'
                     },
          'deanslist' => {
                           'opac_display' => '0',
                           'staff_searchable' => '1',
                           'description' => 'Deans List (annual)',
                           'password_allowed' => '0',
                           'authorised_value_category' => '',
                           'repeatable' => '1',
                           'code' => 'deanslist',
                           'unique_id' => '0'
                         },
          'somedata' => {
                           'opac_display' => '0',
                           'staff_searchable' => '0',
                           'description' => 'Some Ext. Attribute',
                           'password_allowed' => '0',
                           'authorised_value_category' => '',
                           'repeatable' => '0',
                           'code' => 'somedata',
                           'unique_id' => '0'
                         },
          'extradata' => {
                           'opac_display' => '0',
                           'staff_searchable' => '0',
                           'description' => 'Another Ext. Attribute',
                           'password_allowed' => '0',
                           'authorised_value_category' => '',
                           'repeatable' => '0',
                           'code' => 'extradata',
                           'unique_id' => '0'
                         },
          'school_id' => {
                           'opac_display' => '1',
                           'staff_searchable' => '1',
                           'description' => 'School ID Number',
                           'password_allowed' => '0',
                           'authorised_value_category' => '',
                           'repeatable' => '0',
                           'code' => 'school_id',
                           'unique_id' => '1'
                         },
          'homeroom' => {
                          'opac_display' => '1',
                          'staff_searchable' => '1',
                          'description' => 'Homeroom',
                          'password_allowed' => '0',
                          'authorised_value_category' => '',
                          'repeatable' => '0',
                          'code' => 'homeroom',
                          'unique_id' => '0'
                        }
    };  # This is important to prevent extended_attributes_merge from touching DB.
}


my @merge_tests = (
    {
        line1 => "homeroom:501",
        line2 => "grade:01",
        merge => "homeroom:501,grade:01",
    },
    {
        line1 => "homeroom:224,grade:04,deanslist:2008,deanslist:2007,somedata:xxx",
        line2 => "homeroom:115,grade:05,deanslist:2009,extradata:foobar",
        merge => "homeroom:115,grade:05,deanslist:2008,deanslist:2007,deanslist:2009,extradata:foobar,somedata:xxx",
    },
);

can_ok('C4::Members::Attributes', qw(extended_attributes_merge extended_attributes_code_value_arrayref));

ok(ref($C4::Members::Attributes::AttributeTypes) eq 'HASH', '$C4::Members::Attributes::AttributeTypes is a hashref');

diag scalar(@merge_tests) . " tests for extended_attributes_merge";

foreach my $test (@merge_tests) {
    my ($old, $new, $merged);
    ok($old = extended_attributes_code_value_arrayref($test->{line1}), "extended_attributes_code_value_arrayref('$test->{line1}')");
    foreach (@$old) { diag "old attribute: $_->{code} = $_->{value}"; }
    ok($new = extended_attributes_code_value_arrayref($test->{line2}), "extended_attributes_code_value_arrayref('$test->{line2}')");
    foreach (@$new) { diag "new attribute: $_->{code} = $_->{value}"; }
    ok($merged = extended_attributes_merge($old, $new),                "extended_attributes_merge(\$old, \$new)");
    foreach (@$merged) { diag "merge (overwrite) attribute: $_->{code} = $_->{value}"; }
    ok($merged = extended_attributes_merge($old, $new, 1),             "extended_attributes_merge(\$old, \$new, 1)");
    foreach (@$merged) { diag "merge (preserve) attribute: $_->{code} = $_->{value}"; }
}

