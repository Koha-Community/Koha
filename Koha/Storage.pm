use utf8;
package Koha::Storage;

use strict;
use warnings;

use base 'DBIx::Class::Storage::DBI';
sub DESTROY {
    my $self = shift;

    # destroy just the object if not native to this process/thread
    $self->_preserve_foreign_dbh;

    $self->_dbh(undef);
}
1;
