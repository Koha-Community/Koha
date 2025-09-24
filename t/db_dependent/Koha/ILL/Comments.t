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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use File::Basename qw/basename/;
use Koha::Database;
use Koha::ILL::Requests;
use Koha::ILL::Request::Attributes;
use Koha::ILL::Request::Config;
use Koha::Patrons;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::MockObject;
use Test::MockModule;

use Test::NoWarnings;
use Test::More tests => 9;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
use_ok('Koha::ILL::Comment');
use_ok('Koha::ILL::Comments');

$schema->storage->txn_begin;

# Create a patron
my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

# Create a librarian
my $librarian = $builder->build_object( { class => 'Koha::Patrons' } );

# Create an ILL request
my $illrq = $builder->build_object(
    {
        class => 'Koha::ILL::Requests',
        value => { borrowernumber => $patron->{borrowernumber} }
    }
);

# Create a comment and tie it to the request and the librarian
my $comment_text = 'xyz';
my $illcomment   = $builder->build_object(
    {
        class => 'Koha::ILL::Comments',
        value => {
            illrequest_id  => $illrq->id,
            borrowernumber => $librarian->id,
            comment        => $comment_text,
        }
    }
);

# Get all the comments
my $comments = $illrq->illcomments;
isa_ok( $comments, 'Koha::ILL::Comments' );
my @comments_list = $comments->as_list();
is( scalar @comments_list, 1, "We have 1 comment" );

# Get the first (and only) comment
my $comment = $comments->next();
isa_ok( $comment, 'Koha::ILL::Comment' );

# Check the different data in the comment
is( $comment->illrequest_id,  $illrq->id,     'illrequest_id getter works' );
is( $comment->borrowernumber, $librarian->id, 'borrowernumber getter works' );
is( $comment->comment,        $comment_text,  'comment getter works' );

$schema->storage->txn_rollback;
