#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2016 Koha Development Team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );
use Try::Tiny    qw(catch try);

use Koha::Database;
use Koha::Exceptions::Object;
use Koha::Libraries;
use Koha::Patron::Categories;
use Koha::Patrons;

use Koha::Script;

my ( $help, $surname, $userid, $password, $branchcode, $categorycode, $cardnumber );
GetOptions(
    'help|?'         => \$help,
    'userid=s'       => \$userid,
    'password=s'     => \$password,
    'branchcode=s'   => \$branchcode,
    'categorycode=s' => \$categorycode,
    'cardnumber=s'   => \$cardnumber,
);

pod2usage(1) if $help;
pod2usage("userid is mandatory")       unless $userid;
pod2usage("password is mandatory")     unless $password;
pod2usage("branchcode is mandatory")   unless $branchcode;
pod2usage("categorycode is mandatory") unless $categorycode;
pod2usage("cardnumber is mandatory")   unless $cardnumber;

try {
    Koha::Database->new->schema->txn_do(
        sub {
            Koha::Exceptions::Object::FKConstraint->throw(
                error     => 'Broken FK constraint',
                broken_fk => 'branchcode'
            ) unless Koha::Libraries->find($branchcode);

            Koha::Exceptions::Object::DuplicateID->throw( duplicate_id => 'userid' )
                if Koha::Patrons->find( { userid => $userid } );

            Koha::Exceptions::Object::DuplicateID->throw( duplicate_id => 'cardnumber' )
                if Koha::Patrons->find( { cardnumber => $cardnumber } );

            my $patron = Koha::Patron->new(
                {
                    surname      => $surname,
                    userid       => $userid,
                    cardnumber   => $cardnumber,
                    branchcode   => $branchcode,
                    categorycode => $categorycode,
                    flags        => 1,               # superlibrarian
                }
            )->store;

            # password is set on a separate step (store would set the hashed password)
            $patron->set_password( { password => $password, skip_validation => 1 } );
        }
    );
} catch {
    if ( ref($_) eq 'Koha::Exceptions::Object::FKConstraint' ) {

        my $value =
              $_->broken_fk eq 'branchcode'   ? $branchcode
            : $_->broken_fk eq 'categorycode' ? $categorycode
            :                                   'ERROR';

        my @valid_values =
              $_->broken_fk eq 'branchcode'   ? Koha::Libraries->new->get_column('branchcode')
            : $_->broken_fk eq 'categorycode' ? Koha::Patron::Categories->new->get_column('categorycode')
            :                                   ('UNEXPECTED');

        printf STDERR "ERROR: '%s' is not valid for the '%s' field\n", $value, $_->broken_fk;
        printf STDERR "Possible values are: " . join( ', ', @valid_values ) . "\n";

    } elsif ( ref($_) eq 'Koha::Exceptions::Object::DuplicateID' ) {

        my $value =
              $_->duplicate_id eq 'cardnumber' ? $cardnumber
            : $_->duplicate_id eq 'userid'     ? $userid
            :                                    'ERROR';

        printf STDERR "Field '%s' must be unique. Value '%s' is used already.\n", $_->duplicate_id, $value;
    } else {
        print STDERR "Uncaught exception: $_\n";
    }

    exit 1;
};

=head1 NAME

create_superlibrarian.pl - create a user in Koha with superlibrarian permissions

=head1 SYNOPSIS

create_superlibrarian.pl
  --userid <userid> --password <password> --branchcode <branchcode> --categorycode <categorycode> --cardnumber <cardnumber>

 Options:
   -?|--help        brief help message
   --userid         specify the userid to be set
   --password       specify the password to be set
   --branchcode     specify the library code
   --categorycode   specify the patron category code
   --cardnumber     specify the cardnumber to be set

=head1 OPTIONS

=over 8

=item B<--help|-?>

Print a brief help message and exits

=item B<--userid>

To specify the userid to be set in the database

=item B<--password>

To specify the password to be set in the database

=item B<--branchcode>

Library code

=item B<--categorycode>

Patron category's code

=item B<--cardnumber>

Patron's cardnumber

=back

=head1 DESCRIPTION

A simple script to create a user in the Koha database with superlibrarian permissions

=cut
