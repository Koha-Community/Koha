#!/usr/bin/perl

# Copyright 2021 Koha Development team
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

use Test::NoWarnings;
use Test::More tests => 2;
use Test::MockModule;

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::BatchUpdateBiblio;
use Koha::Exception;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;

my $builder = t::lib::TestBuilder->new;

subtest "Exceptions must be stringified" => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $C4_biblio_module = Test::MockModule->new('C4::Biblio');
    $C4_biblio_module->mock(
        'ModBiblio',
        sub { Koha::Exception->throw("It didn't work"); }
    );

    my $biblio = $builder->build_sample_biblio;
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $job    = Koha::BackgroundJob::BatchUpdateBiblio->new(
        {
            status         => 'new',
            size           => 1,
            borrowernumber => $patron->borrowernumber,
            type           => 'batch_biblio_record_modification',
        }
    );
    my $data = $job->json->encode( { record_ids => [ $biblio->biblionumber ] } );
    $job->data($data)->store;
    $job = Koha::BackgroundJobs->find( $job->id );
    $job->process( { job_id => $job->id, record_ids => [ $biblio->biblionumber ] } );

    $data = $job->json->decode( $job->get_from_storage->data );
    is_deeply(
        $data->{messages}->[0],
        {
            biblionumber => $biblio->biblionumber,
            code         => 'biblio_not_modified',
            error        => qq{Exception 'Koha::Exception' thrown 'It didn't work'\n},
            type         => "error"
        }
    );

    $schema->storage->txn_rollback;
};
