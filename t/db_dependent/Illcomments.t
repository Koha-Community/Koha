#!/usr/bin/perl

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

use File::Basename qw/basename/;
use Koha::Database;
use Koha::Illrequests;
use Koha::Illrequestattributes;
use Koha::Illrequest::Config;
use Koha::Patrons;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::MockObject;
use Test::MockModule;

use Test::More tests => 9;

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
use_ok('Koha::Illcomment');
use_ok('Koha::Illcomments');

$schema->storage->txn_begin;

Koha::Illrequests->search->delete;

# Create a patron
my $patron = $builder->build({ source => 'Borrower' });

# Create an ILL request
my $illrq = $builder->build({
    source => 'Illrequest',
    value => { borrowernumber => $patron->{borrowernumber} }
});
my $illrq_obj = Koha::Illrequests->find($illrq->{illrequest_id});
isa_ok( $illrq_obj, 'Koha::Illrequest' );

# Create a librarian
my $librarian = $builder->build({ source => 'Borrower' });

# Create a comment and tie it to the request and the librarian
my $comment_text = 'xyz';
my $illcomment = $builder->build({
    source => 'Illcomment',
    value => {
        illrequest_id  => $illrq_obj->illrequest_id,
        borrowernumber => $librarian->{borrowernumber},
        comment        => $comment_text,
    }
});

# Get all the comments
my $comments = $illrq_obj->illcomments;
isa_ok( $comments, 'Koha::Illcomments', "Illcomments" );
my @comments_list = $comments->as_list();
is( scalar @comments_list, 1, "We have 1 comment" );

# Get the first (and only) comment
my $comment = $comments->next();
isa_ok( $comment, 'Koha::Illcomment', "Illcomment" );

# Check the different data in the comment
is( $comment->illrequest_id,  $illrq_obj->illrequest_id,    'illrequest_id getter works' );
is( $comment->borrowernumber, $librarian->{borrowernumber}, 'borrowernumber getter works');
is( $comment->comment,        $comment_text,                'comment getter works');

$illrq_obj->delete;

$schema->storage->txn_rollback;
