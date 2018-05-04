package Koha::AdditionalFields;

use Modern::Perl;

use base 'Koha::Objects';

use Koha::AdditionalField;

sub _type { 'AdditionalField' }
sub object_class { 'Koha::AdditionalField' }

1;
