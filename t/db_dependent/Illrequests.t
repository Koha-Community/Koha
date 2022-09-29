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

use C4::Circulation qw( AddIssue AddReturn );

use Koha::Database;
use Koha::Illrequestattributes;
use Koha::Illrequest::Config;
use Koha::Biblios;
use Koha::Patrons;
use Koha::ItemTypes;
use Koha::Items;
use Koha::Libraries;
use Koha::Patron::MessagePreference::Attributes;
use Koha::Notice::Templates;
use Koha::AuthorisedValueCategories;
use Koha::AuthorisedValues;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::MockObject;
use Test::MockModule;
use Test::Exception;
use Test::Deep qw/ cmp_deeply ignore /;
use Test::Warn;

use Test::More tests => 15;

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
use_ok('Koha::Illrequest');
use_ok('Koha::Illrequests');

subtest 'Basic object tests' => sub {

    plan tests => 24;

    $schema->storage->txn_begin;

    Koha::Illrequests->search->delete;
    my $illrq = $builder->build({ source => 'Illrequest' });
    my $illrq_obj = Koha::Illrequests->find($illrq->{illrequest_id});

    isa_ok($illrq_obj, 'Koha::Illrequest',
           "Correctly create and load an illrequest object.");
    isa_ok($illrq_obj->_config, 'Koha::Illrequest::Config',
           "Created a config object as part of Illrequest creation.");

    is($illrq_obj->illrequest_id, $illrq->{illrequest_id},
       "Illrequest_id getter works.");
    is($illrq_obj->borrowernumber, $illrq->{borrowernumber},
       "Borrowernumber getter works.");
    is($illrq_obj->biblio_id, $illrq->{biblio_id},
       "Biblio_Id getter works.");
    is($illrq_obj->branchcode, $illrq->{branchcode},
       "Branchcode getter works.");
    is($illrq_obj->status, $illrq->{status},
       "Status getter works.");
    is($illrq_obj->placed, $illrq->{placed},
       "Placed getter works.");
    is($illrq_obj->replied, $illrq->{replied},
       "Replied getter works.");
    is($illrq_obj->updated, $illrq->{updated},
       "Updated getter works.");
    is($illrq_obj->completed, $illrq->{completed},
       "Completed getter works.");
    is($illrq_obj->medium, $illrq->{medium},
       "Medium getter works.");
    is($illrq_obj->accessurl, $illrq->{accessurl},
       "Accessurl getter works.");
    is($illrq_obj->cost, $illrq->{cost},
       "Cost getter works.");
    is($illrq_obj->price_paid, $illrq->{price_paid},
       "Price_paid getter works.");
    is($illrq_obj->notesopac, $illrq->{notesopac},
       "Notesopac getter works.");
    is($illrq_obj->notesstaff, $illrq->{notesstaff},
       "Notesstaff getter works.");
    is($illrq_obj->orderid, $illrq->{orderid},
       "Orderid getter works.");
    is($illrq_obj->backend, $illrq->{backend},
       "Backend getter works.");

    is($illrq_obj->get_type, undef,
        'get_type() returns undef if no type is set');
    $builder->build({
        source => 'Illrequestattribute',
        value  => {
            illrequest_id => $illrq_obj->illrequest_id,
            type => 'type',
            value => 'book'
        }
    });
    is($illrq_obj->get_type, 'book',
        'get_type() returns correct type if set');

    isnt($illrq_obj->status, 'COMP',
         "ILL is not currently marked complete.");
    $illrq_obj->mark_completed;
    is($illrq_obj->status, 'COMP',
       "ILL is now marked complete.");

    $illrq_obj->delete;

    is(Koha::Illrequests->search->count, 0,
       "No illrequest found after delete.");

    $schema->storage->txn_rollback;
};

subtest 'store borrowernumber change also updates holds' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    Koha::Illrequests->search->delete;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $other_patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $biblio = $builder->build_object({ class => 'Koha::Biblios' });

    my $request = $builder->build_object({
        class => 'Koha::Illrequests',
        value => {
            borrowernumber => $patron->borrowernumber,
            biblio_id => $biblio->biblionumber,
        }
    });
    $builder->build({
        source => 'Reserve',
        value => {
            borrowernumber => $patron->borrowernumber,
            biblionumber => $request->biblio_id
        }
    });

    my $hold = Koha::Holds->find({
        biblionumber => $request->biblio_id,
        borrowernumber => $request->borrowernumber,
    });

    is( $hold->borrowernumber, $request->borrowernumber,
       'before change, original borrowernumber found' );

    $request->borrowernumber( $other_patron->borrowernumber )->store;

    # reload changes
    $hold->discard_changes;

    is( $hold->borrowernumber, $other_patron->borrowernumber,
       'after change, changed borrowernumber found in holds' );

    is( $request->borrowernumber, $other_patron->borrowernumber,
       'after change, changed borrowernumber found in illrequests' );

    my $new_request = Koha::Illrequest->new({
        biblio_id => $biblio->biblionumber,
        branchcode => $patron->branchcode,
    })->borrowernumber( $patron->borrowernumber )->store;

    is( $new_request->borrowernumber, $patron->borrowernumber,
       'Koha::Illrequest->new()->store() works as expected');

    my $new_holds_found = Koha::Holds->search({
        biblionumber => $new_request->biblio_id,
        borrowernumber => $new_request->borrowernumber,
    })->count;

    is( $new_holds_found, 0, 'no holds found with new()->store()' );

    $schema->storage->txn_rollback;

};

subtest 'Working with related objects' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $illrq  = $builder->build_object(
        {   class => 'Koha::Illrequests',
            value => { borrowernumber => $patron->id, biblio_id => undef }
        }
    );

    isa_ok( $illrq->patron, 'Koha::Patron', "OK accessing related patron." );

    $builder->build(
        {   source => 'Illrequestattribute',
            value  => { illrequest_id => $illrq->illrequest_id, type => 'X' }
        }
    );
    $builder->build(
        {   source => 'Illrequestattribute',
            value  => { illrequest_id => $illrq->illrequest_id, type => 'Y' }
        }
    );
    $builder->build(
        {   source => 'Illrequestattribute',
            value  => { illrequest_id => $illrq->illrequest_id, type => 'Z' }
        }
    );

    my $rs = Koha::Illrequestattributes->search( { illrequest_id => $illrq->id } );

    is( $illrq->extended_attributes->count,
        $rs->count, "Fetching expected number of Illrequestattributes for our request." );

    is( $illrq->biblio, undef, "->biblio returns undef if no biblio" );
    my $biblio  = $builder->build_object( { class => 'Koha::Biblios' } );
    my $req_bib = $builder->build_object(
        {   class => 'Koha::Illrequests',
            value => { biblio_id => $biblio->biblionumber }
        }
    );
    isa_ok( $req_bib->biblio, 'Koha::Biblio', "OK accessing related biblio" );

    $illrq->delete;
    is( $rs->count, 0, "Correct number of illrequestattributes after delete." );

    isa_ok( Koha::Patrons->find( $patron->id ), 'Koha::Patron', "Borrower was not deleted after illrq delete." );

    $schema->storage->txn_rollback;
};

subtest 'Status Graph tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $illrq = $builder->build({source => 'Illrequest'});
    my $illrq_obj = Koha::Illrequests->find($illrq->{illrequest_id});

    # _core_status_graph tests: it's just a constant, so here we just make
    # sure it returns a hashref.
    is(ref $illrq_obj->_core_status_graph, "HASH",
       "_core_status_graph returns a hash.");

    # _status_graph_union: let's try different merge operations.
    # Identity operation
    is_deeply(
        $illrq_obj->_status_graph_union($illrq_obj->_core_status_graph, {}),
        $illrq_obj->_core_status_graph,
        "core_status_graph + null = core_status_graph"
    );

    # Simple addition
    is_deeply(
        $illrq_obj->_status_graph_union({}, $illrq_obj->_core_status_graph),
        $illrq_obj->_core_status_graph,
        "null + core_status_graph = core_status_graph"
    );

    # Correct merge behaviour
    is_deeply(
        $illrq_obj->_status_graph_union({
            REQ => {
                prev_actions   => [ ],
                id             => 'REQ',
                next_actions   => [ ],
            },
        }, {
            QER => {
                prev_actions   => [ 'REQ' ],
                id             => 'QER',
                next_actions   => [ 'REQ' ],
            },
        }),
        {
            REQ => {
                prev_actions   => [ 'QER' ],
                id             => 'REQ',
                next_actions   => [ 'QER' ],
            },
            QER => {
                prev_actions   => [ 'REQ' ],
                id             => 'QER',
                next_actions   => [ 'REQ' ],
            },
        },
        "REQ atom + linking QER = cyclical status graph"
    );

    # Create a new node, with no prev_actions and no next_actions. This should
    # protect us against regressions related to bug 22280.
    my $new_node = {
        TEST => {
            prev_actions   => [ ],
            id             => 'TEST',
            next_actions   => [ ],
        },
    };
    # Add the new node to the core_status_grpah
    my $new_graph = $illrq_obj->_status_graph_union( $new_node, $illrq_obj->_core_status_graph);
    # Compare the updated graph to the expected graph
    # The structure we compare against here is just a copy of the structure found
    # in Koha::Illrequest::_core_status_graph() + the new node we created above
    cmp_deeply( $new_graph,
        {
        TEST => {
            prev_actions   => [ ],
            id             => 'TEST',
            next_actions   => [ ],
        },
        NEW => {
            prev_actions => [ ],                           # Actions containing buttons
                                                           # leading to this status
            id             => 'NEW',                       # ID of this status
            name           => 'New request',               # UI name of this status
            ui_method_name => 'New request',               # UI name of method leading
                                                           # to this status
            method         => 'create',                    # method to this status
            next_actions   => [ 'REQ', 'GENREQ', 'KILL' ], # buttons to add to all
                                                           # requests with this status
            ui_method_icon => 'fa-plus',                   # UI Style class
        },
        REQ => {
            prev_actions   => [ 'NEW', 'REQREV', 'QUEUED', 'CANCREQ' ],
            id             => 'REQ',
            name           => 'Requested',
            ui_method_name => 'Confirm request',
            method         => 'confirm',
            next_actions   => [ 'REQREV', 'COMP', 'CHK' ],
            ui_method_icon => 'fa-check',
        },
        GENREQ => {
            prev_actions   => [ 'NEW', 'REQREV' ],
            id             => 'GENREQ',
            name           => 'Requested from partners',
            ui_method_name => 'Place request with partners',
            method         => 'generic_confirm',
            next_actions   => [ 'COMP', 'CHK', 'REQREV' ],
            ui_method_icon => 'fa-send-o',
        },
        REQREV => {
            prev_actions   => [ 'REQ', 'GENREQ' ],
            id             => 'REQREV',
            name           => 'Request reverted',
            ui_method_name => 'Revert request',
            method         => 'cancel',
            next_actions   => [ 'REQ', 'GENREQ', 'KILL' ],
            ui_method_icon => 'fa-times',
        },
        QUEUED => {
            prev_actions   => [ ],
            id             => 'QUEUED',
            name           => 'Queued request',
            ui_method_name => 0,
            method         => 0,
            next_actions   => [ 'REQ', 'KILL' ],
            ui_method_icon => 0,
        },
        CANCREQ => {
            prev_actions   => [ 'NEW' ],
            id             => 'CANCREQ',
            name           => 'Cancellation requested',
            ui_method_name => 0,
            method         => 0,
            next_actions   => [ 'KILL', 'REQ' ],
            ui_method_icon => 0,
        },
        COMP => {
            prev_actions   => [ 'REQ' ],
            id             => 'COMP',
            name           => 'Completed',
            ui_method_name => 'Mark completed',
            method         => 'mark_completed',
            next_actions   => [ 'CHK' ],
            ui_method_icon => 'fa-check',
        },
        KILL => {
            prev_actions   => [ 'QUEUED', 'REQREV', 'NEW', 'CANCREQ' ],
            id             => 'KILL',
            name           => 0,
            ui_method_name => 'Delete request',
            method         => 'delete',
            next_actions   => [ ],
            ui_method_icon => 'fa-trash',
        },
        CHK => {
            prev_actions   => [ 'REQ', 'GENREQ', 'COMP' ],
            id             => 'CHK',
            name           => 'Checked out',
            ui_method_name => 'Check out',
            needs_prefs    => [ 'CirculateILL' ],
            needs_perms    => [ 'user_circulate_circulate_remaining_permissions' ],
            needs_all      => ignore(),
            method         => 'check_out',
            next_actions   => [ ],
            ui_method_icon => 'fa-upload',
        },
        RET => {
            prev_actions   => [ 'CHK' ],
            id             => 'RET',
            name           => 'Returned to library',
            ui_method_name => 'Check in',
            method         => 'check_in',
            next_actions   => [ 'COMP' ],
            ui_method_icon => 'fa-download',
        }
    },
        "new node + core_status_graph = bigger status graph"
    ) || diag explain $new_graph;

    # Create a duplicate node
    my $dupe_node = {
        REQ => {
            prev_actions   => [ 'NEW', 'REQREV', 'QUEUED', 'CANCREQ' ],
            id             => 'REQ',
            name           => 'Requested',
            ui_method_name => 'Confirm request dupe',
            method         => 'confirm',
            next_actions   => [ 'REQREV', 'COMP', 'CHK' ],
            ui_method_icon => 'fa-check',
        }
    };
    # Add the dupe node to the core_status_grpah
    my $dupe_graph = $illrq_obj->_status_graph_union( $illrq_obj->_core_status_graph, $dupe_node);
    # Compare the updated graph to the expected graph
    # The structure we compare against here is just a copy of the structure found
    # in Koha::Illrequest::_core_status_graph() + the new node we created above
    cmp_deeply( $dupe_graph,
        {
        NEW => {
            prev_actions => [ ],                           # Actions containing buttons
                                                           # leading to this status
            id             => 'NEW',                       # ID of this status
            name           => 'New request',               # UI name of this status
            ui_method_name => 'New request',               # UI name of method leading
                                                           # to this status
            method         => 'create',                    # method to this status
            next_actions   => [ 'REQ', 'GENREQ', 'KILL' ], # buttons to add to all
                                                           # requests with this status
            ui_method_icon => 'fa-plus',                   # UI Style class
        },
        REQ => {
            prev_actions   => [ 'NEW', 'REQREV', 'QUEUED', 'CANCREQ' ],
            id             => 'REQ',
            name           => 'Requested',
            ui_method_name => 'Confirm request dupe',
            method         => 'confirm',
            next_actions   => [ 'REQREV', 'COMP', 'CHK' ],
            ui_method_icon => 'fa-check',
        },
        GENREQ => {
            prev_actions   => [ 'NEW', 'REQREV' ],
            id             => 'GENREQ',
            name           => 'Requested from partners',
            ui_method_name => 'Place request with partners',
            method         => 'generic_confirm',
            next_actions   => [ 'COMP', 'CHK', 'REQREV' ],
            ui_method_icon => 'fa-send-o',
        },
        REQREV => {
            prev_actions   => [ 'REQ', 'GENREQ' ],
            id             => 'REQREV',
            name           => 'Request reverted',
            ui_method_name => 'Revert request',
            method         => 'cancel',
            next_actions   => [ 'REQ', 'GENREQ', 'KILL' ],
            ui_method_icon => 'fa-times',
        },
        QUEUED => {
            prev_actions   => [ ],
            id             => 'QUEUED',
            name           => 'Queued request',
            ui_method_name => 0,
            method         => 0,
            next_actions   => [ 'REQ', 'KILL' ],
            ui_method_icon => 0,
        },
        CANCREQ => {
            prev_actions   => [ 'NEW' ],
            id             => 'CANCREQ',
            name           => 'Cancellation requested',
            ui_method_name => 0,
            method         => 0,
            next_actions   => [ 'KILL', 'REQ' ],
            ui_method_icon => 0,
        },
        COMP => {
            prev_actions   => [ 'REQ' ],
            id             => 'COMP',
            name           => 'Completed',
            ui_method_name => 'Mark completed',
            method         => 'mark_completed',
            next_actions   => [ 'CHK' ],
            ui_method_icon => 'fa-check',
        },
        KILL => {
            prev_actions   => [ 'QUEUED', 'REQREV', 'NEW', 'CANCREQ' ],
            id             => 'KILL',
            name           => 0,
            ui_method_name => 'Delete request',
            method         => 'delete',
            next_actions   => [ ],
            ui_method_icon => 'fa-trash',
        },
        CHK => {
            prev_actions   => [ 'REQ', 'GENREQ', 'COMP' ],
            id             => 'CHK',
            name           => 'Checked out',
            ui_method_name => 'Check out',
            needs_prefs    => [ 'CirculateILL' ],
            needs_perms    => [ 'user_circulate_circulate_remaining_permissions' ],
            needs_all      => ignore(),
            method         => 'check_out',
            next_actions   => [ ],
            ui_method_icon => 'fa-upload',
        },
        RET => {
            prev_actions   => [ 'CHK' ],
            id             => 'RET',
            name           => 'Returned to library',
            ui_method_name => 'Check in',
            method         => 'check_in',
            next_actions   => [ 'COMP' ],
            ui_method_icon => 'fa-download',
        }
    },
        "new node + core_status_graph = bigger status graph"
    ) || diag explain $dupe_graph;

    $schema->storage->txn_rollback;
};

subtest 'Backend testing (mocks)' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    # testing load_backend & available_backends requires that we have at least
    # the Dummy plugin installed.  load_backend & available_backends don't
    # currently have tests as a result.

    t::lib::Mocks->mock_config('interlibrary_loans', { backend_dir => 'a_dir' }  );
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always('name', 'Mock');

    my $patron = $builder->build({ source => 'Borrower' });
    my $illrq = $builder->build_object({
        class => 'Koha::Illrequests',
    });

    $illrq->_backend($backend);

    isa_ok($illrq->_backend, 'Koha::Illbackends::Mock',
           "OK accessing mocked backend.");

    # _backend_capability tests:
    # We need to test whether this optional feature of a mocked backend
    # behaves as expected.
    # 3 scenarios: feature not implemented, feature implemented, but requested
    # capability is not provided by backend, & feature is implemented &
    # capability exists.  This method can be used to implement custom backend
    # functionality, such as unmediated in the BLDSS backend (also see
    # bugzilla 18837).
    $backend->set_always('capabilities', undef);
    is($illrq->_backend_capability('Test'), 0,
       "0 returned on Mock not implementing capabilities.");

    $backend->set_always('capabilities', 0);
    is($illrq->_backend_capability('Test'), 0,
       "0 returned on Mock not implementing Test capability.");

    $backend->set_always('capabilities', sub { return 'bar'; } );
    is($illrq->_backend_capability('Test'), 'bar',
       "'bar' returned on Mock implementing Test capability.");

    # metadata test: we need to be sure that we return the arbitrary values
    # from the backend.
    $backend->mock(
        'metadata',
        sub {
            my ( $self, $rq ) = @_;
            return {
                ID => $rq->illrequest_id,
                Title => $rq->patron->borrowernumber
            }
        }
    );

    is_deeply(
        $illrq->metadata,
        {
            ID => $illrq->illrequest_id,
            Title => $illrq->patron->borrowernumber
        },
        "Test metadata."
    );

    # capabilities:

    # No backend graph extension
    $backend->set_always('status_graph', {});
    is_deeply($illrq->capabilities('COMP'),
              {
                  prev_actions   => [ 'REQ' ],
                  id             => 'COMP',
                  name           => 'Completed',
                  ui_method_name => 'Mark completed',
                  method         => 'mark_completed',
                  next_actions   => [ 'CHK' ],
                  ui_method_icon => 'fa-check',
              },
              "Dummy status graph for COMP.");
    is($illrq->capabilities('UNKNOWN'), undef,
       "Dummy status graph for UNKNOWN.");
    is_deeply($illrq->capabilities(),
              $illrq->_core_status_graph,
              "Dummy full status graph.");
    # Simple backend graph extension
    $backend->set_always('status_graph',
                         {
                             QER => {
                                 prev_actions   => [ 'REQ' ],
                                 id             => 'QER',
                                 next_actions   => [ 'REQ' ],
                             },
                         });
    is_deeply($illrq->capabilities('QER'),
              {
                  prev_actions   => [ 'REQ' ],
                  id             => 'QER',
                  next_actions   => [ 'REQ' ],
              },
              "Simple status graph for QER.");
    is($illrq->capabilities('UNKNOWN'), undef,
       "Simple status graph for UNKNOWN.");
    is_deeply($illrq->capabilities(),
              $illrq->_status_graph_union(
                  $illrq->_core_status_graph,
                  {
                      QER => {
                          prev_actions   => [ 'REQ' ],
                          id             => 'QER',
                          next_actions   => [ 'REQ' ],
                      },
                  }
              ),
              "Simple full status graph.");

    # custom_capability:

    # No backend graph extension
    $backend->set_always('status_graph', {});
    is($illrq->custom_capability('unknown', {}), 0,
       "Unknown candidate.");

    # Simple backend graph extension
    $backend->set_always('status_graph',
                         {
                             ID => {
                                 prev_actions   => [ 'REQ' ],
                                 id             => 'ID',
                                 method         => 'identity',
                                 next_actions   => [ 'REQ' ],
                             },
                         });
    $backend->mock('identity',
                   sub { my ( $self, $params ) = @_; return $params->{other}; });
    is($illrq->custom_capability('identity', { test => 1, method => 'blah' })->{test}, 1,
       "Resolve identity custom_capability");

    $schema->storage->txn_rollback;
};


subtest 'Backend core methods' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    # Build infrastructure
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always('name', 'Mock');
    $backend->mock('capabilities', sub { return 'Mock'; });

    my $config = Test::MockObject->new;
    $config->set_always('backend_dir', "/tmp");
    $config->set_always('getLimitRules',
                        { default => { count => 0, method => 'active' } });

    my $illrq = $builder->build_object({
        class => 'Koha::Illrequests',
        value => { backend => undef }
    });
    $illrq->_config($config);

    # Test error conditions (no backend)
    throws_ok { $illrq->load_backend; }
        'Koha::Exceptions::Ill::InvalidBackendId',
        'Exception raised correctly';

    throws_ok { $illrq->load_backend(''); }
        'Koha::Exceptions::Ill::InvalidBackendId',
        'Exception raised correctly';

    # Now load the mocked backend
    $illrq->_backend($backend);

    # expandTemplate:
    is_deeply($illrq->expandTemplate({ test => 1, method => "bar" }),
              {
                  test => 1,
                  method => "bar",
                  template => "/tmp/Mock/intra-includes/bar.inc",
                  opac_template => "/tmp/Mock/opac-includes/bar.inc",
              },
              "ExpandTemplate");

    # backend_create
    # we are testing simple cases.
    $backend->set_series('create',
                         { stage => 'bar', method => 'create' },
                         { stage => 'commit', method => 'create' },
                         { stage => 'commit', method => 'create' },
                         { stage => 'commit', method => 'create' },
                         { stage => 'commit', method => 'create' });
    # Test non-commit
    is_deeply($illrq->backend_create({test => 1}),
              {
                  stage => 'bar', method => 'create',
                  template => "/tmp/Mock/intra-includes/create.inc",
                  opac_template => "/tmp/Mock/opac-includes/create.inc",
              },
              "Backend create: arbitrary stage.");
    # Test commit
    is_deeply($illrq->backend_create({test => 1}),
              {
                  stage => 'commit', method => 'create', permitted => 0,
                  template => "/tmp/Mock/intra-includes/create.inc",
                  opac_template => "/tmp/Mock/opac-includes/create.inc",
              },
              "Backend create: arbitrary stage, not permitted.");
    is($illrq->status, "QUEUED", "Backend create: queued if restricted.");
    $config->set_always('getLimitRules', {});
    $illrq->status('NEW');
    is_deeply($illrq->backend_create({test => 1}),
              {
                  stage => 'commit', method => 'create', permitted => 1,
                  template => "/tmp/Mock/intra-includes/create.inc",
                  opac_template => "/tmp/Mock/opac-includes/create.inc",
              },
              "Backend create: arbitrary stage, permitted.");
    is($illrq->status, "NEW", "Backend create: not-queued.");

    # Test that enabling the unmediated workflow causes the backend's
    # 'unmediated_ill' method to be called
    t::lib::Mocks::mock_preference('ILLModuleUnmediated', '1');
    $backend->mock(
        'capabilities',
        sub {
            my ($self, $name) = @_;
            if ($name eq 'unmediated_ill') {
                return sub {
                    return { unmediated_ill => 1 };
                };
            }
        }
    );
    $illrq->status('NEW');
    is_deeply(
        $illrq->backend_create({test => 1}),
        {
            'opac_template' => '/tmp/Mock/opac-includes/.inc',
            'template' => '/tmp/Mock/intra-includes/.inc',
            'unmediated_ill' => 1
        },
        "Backend create: commit stage, permitted, ILLModuleUnmediated enabled."
    );

    # Test that disabling the unmediated workflow causes the backend's
    # 'unmediated_ill' method to be NOT called
    t::lib::Mocks::mock_preference('ILLModuleUnmediated', '0');
    $illrq->status('NEW');
    is_deeply(
        $illrq->backend_create({test => 1}),
        {
            stage => 'commit', method => 'create', permitted => 1,
            template => "/tmp/Mock/intra-includes/create.inc",
            opac_template => "/tmp/Mock/opac-includes/create.inc",
        },
        "Backend create: commit stage, permitted, ILLModuleUnmediated disabled."
    );

    # backend_renew
    $backend->set_series('renew', { stage => 'bar', method => 'renew' });
    is_deeply($illrq->backend_renew({test => 1}),
              {
                  stage => 'bar', method => 'renew',
                  template => "/tmp/Mock/intra-includes/renew.inc",
                  opac_template => "/tmp/Mock/opac-includes/renew.inc",
              },
              "Backend renew: arbitrary stage.");

    # backend_cancel
    $backend->set_series('cancel', { stage => 'bar', method => 'cancel' });
    is_deeply($illrq->backend_cancel({test => 1}),
              {
                  stage => 'bar', method => 'cancel',
                  template => "/tmp/Mock/intra-includes/cancel.inc",
                  opac_template => "/tmp/Mock/opac-includes/cancel.inc",
              },
              "Backend cancel: arbitrary stage.");

    # backend_illview
    $backend->set_series('illview', { stage => '', method => 'illview' });
    is_deeply($illrq->backend_illview({test => 1}), 0,
              "Backend illview optional method.");

    # backend_update_status
    $backend->set_series('update_status', { stage => 'bar', method => 'update_status' });
    is_deeply($illrq->backend_update_status({test => 1}),
              {
                  stage => 'bar', method => 'update_status',
                  template => "/tmp/Mock/intra-includes/update_status.inc",
                  opac_template => "/tmp/Mock/opac-includes/update_status.inc",
              },
              "Backend update_status: arbitrary stage.");

    # backend_confirm
    $backend->set_series('confirm', { stage => 'bar', method => 'confirm' });
    is_deeply($illrq->backend_confirm({test => 1}),
              {
                  stage => 'bar', method => 'confirm',
                  template => "/tmp/Mock/intra-includes/confirm.inc",
                  opac_template => "/tmp/Mock/opac-includes/confirm.inc",
              },
              "Backend confirm: arbitrary stage.");

    # backend_get_update
    $backend->mock(
        'get_supplier_update',
        sub {
            my ( $self, $options ) = @_;
            return $options;
        }
    );
    $backend->mock('capabilities', sub { return sub { return 1; } });
    is_deeply($illrq->backend_get_update({}), 1,
              "Backend get_update method.");

    $config->set_always('partner_code', "ILLTSTLIB");
    $backend->set_always('metadata', { Test => "Foobar" });
    my $illbrn = $builder->build({
        source => 'Branch',
        value => { branchemail => "", branchreplyto => "" }
    });
    my $partner1 = $builder->build({
        source => 'Borrower',
        value => { categorycode => "ILLTSTLIB" },
    });
    my $partner2 = $builder->build({
        source => 'Borrower',
        value => { categorycode => "ILLTSTLIB" },
    });
    my $gen_conf = $illrq->generic_confirm({
        current_branchcode => $illbrn->{branchcode}
    });
    isnt(index($gen_conf->{value}->{draft}->{body}, $backend->metadata->{Test}), -1,
         "Generic confirm: draft contains metadata."
    );
    is($gen_conf->{value}->{partners}->next->borrowernumber, $partner1->{borrowernumber},
       "Generic cofnirm: partner 1 is correct."
    );
    is($gen_conf->{value}->{partners}->next->borrowernumber, $partner2->{borrowernumber},
       "Generic confirm: partner 2 is correct."
    );

    dies_ok { $illrq->generic_confirm({
        current_branchcode => $illbrn->{branchcode},
        stage => 'draft'
    }) }
        "Generic confirm: missing to dies OK.";

    $schema->storage->txn_rollback;
};


subtest 'Helpers' => sub {

    plan tests => 25;

    $schema->storage->txn_begin;

    # Build infrastructure
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always('name', 'Mock');
    $backend->mock(
        'metadata',
        sub {
            my ( $self, $rq ) = @_;
            return {
                title => 'mytitle',
                author => 'myauthor'
            }
        }
    );

    my $config = Test::MockObject->new;
    $config->set_always('backend_dir', "/tmp");

    my $patron = $builder->build({
        source => 'Borrower',
        value => { categorycode => "A" }
    });
    # Create a mocked branch with no email addressed defined
    my $illbrn = $builder->build({
        source => 'Branch',
        value => {
            branchcode => 'HDE',
            branchemail => "",
            branchillemail => "",
            branchreplyto => ""
        }
    });
    my $illrq = $builder->build({
        source => 'Illrequest',
        value => { branchcode => "HDE", borrowernumber => $patron->{borrowernumber} }
    });
    my $illrq_obj = Koha::Illrequests->find($illrq->{illrequest_id});
    $illrq_obj->_config($config);
    $illrq_obj->_backend($backend);

    #attach_processors
    my $type = 'test_type_1';
    my $name = 'test_name_1';
    my $update = Test::MockObject->new;
    $update->set_isa('Koha::Illrequest::SupplierUpdate');
    $update->{source_type} = $type;
    $update->{source_name} = $name;
    $update->{processors} = [];
    $update->mock('attach_processor', sub {
        my ( $self, $to_attach ) = @_;
        push @{$self->{processors}}, $to_attach;
    });
    my $processor = Test::MockObject->new;
    $processor->{target_source_type} = $type;
    $processor->{target_source_name} = $name;
    $illrq_obj->init_processors();
    $illrq_obj->push_processor($processor);
    $illrq_obj->attach_processors($update);
    is_deeply(
        scalar @{$update->{processors}},
        1,
        'attaching processors as appropriate works'
    );

    # getPrefix
    $config->set_series('getPrefixes',
                        { HDE => "TEST", TSL => "BAR", default => "DEFAULT" },
                        { A => "ATEST", C => "CBAR", default => "DEFAULT" });
    is($illrq_obj->getPrefix({ brw_cat => "UNKNOWN", branch => "HDE" }), "TEST",
       "getPrefix: branch");
    $config->set_series('getPrefixes',
                        { HDE => "TEST", TSL => "BAR", default => "DEFAULT" },
                        { A => "ATEST", C => "CBAR", default => "DEFAULT" });
    is($illrq_obj->getPrefix({ branch => "UNKNOWN" }), "",
       "getPrefix: default");
    $config->set_always('getPrefixes', {});
    is($illrq_obj->getPrefix({ branch => "UNKNOWN" }), "",
       "getPrefix: the empty prefix");

    # id_prefix
    $config->set_series('getPrefixes',
                        { HDE => "TEST", TSL => "BAR", default => "DEFAULT" },
                        { AB => "ATEST", CD => "CBAR", default => "DEFAULT" });
    is($illrq_obj->id_prefix, "TEST-", "id_prefix: branch");
    $config->set_series('getPrefixes',
                        { HDET => "TEST", TSLT => "BAR", default => "DEFAULT" },
                        { AB => "ATEST", CD => "CBAR", default => "DEFAULT" });
    is($illrq_obj->id_prefix, "", "id_prefix: default");

    # requires_moderation
    $illrq_obj->status('NEW')->store;
    is($illrq_obj->requires_moderation, undef, "requires_moderation: No.");
    $illrq_obj->status('CANCREQ')->store;
    is($illrq_obj->requires_moderation, 'CANCREQ', "requires_moderation: Yes.");

    #send_patron_notice
    my $attr = Koha::Patron::MessagePreference::Attributes->find({ message_name => 'Ill_ready' });
    C4::Members::Messaging::SetMessagingPreference({
        borrowernumber => $patron->{borrowernumber},
        message_attribute_id => $attr->message_attribute_id,
        message_transport_types => ['email']
    });
    my $return_patron = $illrq_obj->send_patron_notice('ILL_PICKUP_READY');
    my $notice = $schema->resultset('MessageQueue')->search({
            letter_code => 'ILL_PICKUP_READY',
            message_transport_type => 'email',
            borrowernumber => $illrq_obj->borrowernumber
        })->next()->letter_code;
    is_deeply(
        $return_patron,
        { result => { success => ['email'], fail => [] } },
        "Correct return when notice created"
    );
    is($notice, 'ILL_PICKUP_READY' ,"Notice is correctly created");

    # ill update notice, passes additional text parameter
    my $attr_update = Koha::Patron::MessagePreference::Attributes->find({ message_name => 'Ill_update' });
    C4::Members::Messaging::SetMessagingPreference({
        borrowernumber => $patron->{borrowernumber},
        message_attribute_id => $attr_update->message_attribute_id,
        message_transport_types => ['email']
    });
    my $return_patron_update = $illrq_obj->send_patron_notice('ILL_REQUEST_UPDATE', 'Some additional text');
    my $notice_update = $schema->resultset('MessageQueue')->search({
            letter_code => 'ILL_REQUEST_UPDATE',
            message_transport_type => 'email',
            borrowernumber => $illrq_obj->borrowernumber
        })->next()->letter_code;
    is_deeply(
        $return_patron_update,
        { result => { success => ['email'], fail => [] } },
        "Correct return when notice created"
    );
    is($notice_update, 'ILL_REQUEST_UPDATE' ,"Notice is correctly created");


    my $return_patron_fail = $illrq_obj->send_patron_notice();
    is_deeply(
        $return_patron_fail,
        { error => 'notice_no_type' },
        "Correct error when missing type"
    );

    #send_staff_notice
    # Specify that no staff notices should be send
    t::lib::Mocks::mock_preference('ILLSendStaffNotices', '');
    my $return_staff_cancel_fail =
        $illrq_obj->send_staff_notice('ILL_REQUEST_CANCEL');
    is_deeply(
        $return_staff_cancel_fail,
        { error => 'notice_not_enabled' },
        "Does not send notices that are not enabled"
    );
    my $queue = $schema->resultset('MessageQueue')->search({
            letter_code => 'ILL_REQUEST_CANCEL'
        });
    is($queue->count, 0, "Notice is not queued");

    # Specify that the cancel notice can be sent
    t::lib::Mocks::mock_preference('ILLSendStaffNotices', 'ILL_REQUEST_CANCEL');
    my $return_staff_cancel = $illrq_obj->send_staff_notice(
        'ILL_REQUEST_CANCEL'
    );
    is_deeply(
        $return_staff_cancel,
        { success => 'notice_queued' },
        "Correct return when staff notice created"
    );
    $queue = $schema->resultset('MessageQueue')->search({
            letter_code => 'ILL_REQUEST_CANCEL'
        });
    is($queue->count, 1, "Notice queued as expected");

    my $return_staff_fail = $illrq_obj->send_staff_notice();
    is_deeply(
        $return_staff_fail,
        { error => 'notice_no_type' },
        "Correct error when missing type"
    );
    $queue = $schema->resultset('MessageQueue')->search({
            letter_code => 'ILL_REQUEST_CANCEL'
        });
    is($queue->count, 1, "Notice is not queued");

    my $attribute = $builder->build({
        source => 'Illrequestattribute',
        value  => { illrequest_id => $illrq_obj->illrequest_id, type => 'pages', value => '42' }
    });

    my $ILL_REQUEST_CANCEL_content =
        q{The patron for interlibrary loans request [% illrequest.illrequest_id %], with the following details, has requested cancellation of this ILL request:

[% ill_full_metadata %]

Attribute: Pages=[% illrequestattributes.pages %]
};
    my $dbh = C4::Context->dbh;
    $dbh->do(q{UPDATE letter
        SET content=?
        WHERE code="ILL_REQUEST_CANCEL"
    }, undef, $ILL_REQUEST_CANCEL_content);

    #get_notice
    my $not = $illrq_obj->get_notice({
        notice_code => 'ILL_REQUEST_CANCEL',
        transport   => 'email'
    });

    # We test the properties of the hashref separately because the random
    # hash ordering of the metadata means we can't test the entire thing
    # with is_deeply
    ok(
        $not->{module} eq 'ill',
        'Correct module return from get_notice'
    );
    ok(
        $not->{name} eq 'ILL request cancelled',
        'Correct name return from get_notice'
    );
    ok(
        $not->{message_transport_type} eq 'email',
        'Correct message_transport_type return from get_notice'
    );
    ok(
        $not->{title} eq 'Interlibrary loan request cancelled',
        'Correct title return from get_notice'
    );
    $not->{content} =~ s/\s//g;

    is(
        $not->{content},"Thepatronforinterlibraryloansrequest" . $illrq_obj->id . ",withthefollowingdetails,hasrequestedcancellationofthisILLrequest:-author:myauthor-title:mytitleAttribute:Pages=42",
        'Correct content returned from get_notice with metadata correctly ordered'
    );

    $illrq_obj->append_to_note('Some text');
    like(
        $illrq_obj->notesstaff,
        qr/Some text$/,
        'appending to a note works'
    );

    $schema->storage->txn_rollback;
};


subtest 'Censorship' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # Build infrastructure
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always('name', 'Mock');

    my $config = Test::MockObject->new;
    $config->set_always('backend_dir', "/tmp");

    my $illrq = $builder->build({source => 'Illrequest'});
    my $illrq_obj = Koha::Illrequests->find($illrq->{illrequest_id});
    $illrq_obj->_config($config);
    $illrq_obj->_backend($backend);

    $config->set_always('censorship', { censor_notes_staff => 1, censor_reply_date => 0 });

    my $censor_out = $illrq_obj->_censor({ foo => 'bar', baz => 564 });
    is_deeply($censor_out, { foo => 'bar', baz => 564, display_reply_date => 1 },
              "_censor: not OPAC, reply_date = 1");

    $censor_out = $illrq_obj->_censor({ foo => 'bar', baz => 564, opac => 1 });
    is_deeply($censor_out, {
        foo => 'bar', baz => 564, censor_notes_staff => 1,
        display_reply_date => 1, opac => 1
    }, "_censor: notes_staff = 0, reply_date = 0");

    $schema->storage->txn_rollback;
};

subtest 'Checking out' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    my $itemtype = $builder->build_object({
        class => 'Koha::ItemTypes',
        value => {
            notforloan => 1
        }
    });
    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    my $biblio = $builder->build_sample_biblio();
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $request = $builder->build_object({
        class => 'Koha::Illrequests',
        value => {
            borrowernumber => $patron->borrowernumber,
            biblio_id      => $biblio->biblionumber
        }
    });

    # First test that calling check_out without a stage param returns
    # what's required to build the form
    my $no_stage = $request->check_out();
    is($no_stage->{method}, 'check_out');
    is($no_stage->{stage}, 'form');
    isa_ok($no_stage->{value}, 'HASH');
    isa_ok($no_stage->{value}->{itemtypes}, 'Koha::ItemTypes');
    isa_ok($no_stage->{value}->{libraries}, 'Koha::Libraries');
    isa_ok($no_stage->{value}->{statistical}, 'Koha::Patrons');
    isa_ok($no_stage->{value}->{biblio}, 'Koha::Biblio');

    # Now test that form validation works when we supply a 'form' stage
    #
    # No item_type
    my $form_stage_missing_params = $request->check_out({
        stage => 'form'
    });
    is_deeply($form_stage_missing_params->{value}->{errors}, {
        item_type => 1
    });
    # inhouse passed but not a valid patron
    my $form_stage_bad_patron = $request->check_out({
        stage     => 'form',
        item_type => $itemtype->itemtype,
        inhouse   => 'I_DONT_EXIST'
    });
    is_deeply($form_stage_bad_patron->{value}->{errors}, {
        inhouse => 1
    });
    # Too many items attached to biblio
    my $item1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $form_stage_two_items = $request->check_out({
        stage     => 'form',
        item_type => $itemtype->itemtype,
    });
    is_deeply($form_stage_two_items->{value}->{errors}, {
        itemcount => 1
    });

    # Delete the items we created, so we can test that we can create one
    $item1->delete;
    $item2->delete;

    # We need to mock the user environment for AddIssue
    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode });
    #

    # First we pass bad parameters to the item creation to test we're
    # catching the failure of item creation
    my $form_stage_bad_branchcode;
    warning_like {
        $form_stage_bad_branchcode = $request->check_out({
            stage     => 'form',
            item_type => $itemtype->itemtype,
            branchcode => '---'
        });
    } qr/DBD::mysql::st execute failed: Cannot add or update a child row: a foreign key constraint fails/,
    "Item creation fails on bad parameters";

    is_deeply($form_stage_bad_branchcode->{value}->{errors}, {
        item_creation => 1
    },"We get expected failure of item creation");

    # Now create a proper item
    my $form_stage_good_branchcode = $request->check_out({
        stage      => 'form',
        item_type  => $itemtype->itemtype,
        branchcode => $library->branchcode
    });
    # By default, this item should not be loanable, so check that we're
    # informed of that fact
    is_deeply(
        $form_stage_good_branchcode->{value}->{check_out_errors},
        {
            error => {
                NOT_FOR_LOAN => 1,
                itemtype_notforloan => $itemtype->itemtype
            }
        },
        "We get expected error on notforloan of item"
    );
    # Delete the item that was created
    $biblio->items->delete;
    # Now create an itemtype that is loanable
    my $itemtype_loanable = $builder->build_object({
        class => 'Koha::ItemTypes',
        value => {
            notforloan => 0
        }
    });
    # We need to mock the user environment for AddIssue
    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode });
    my $form_stage_loanable = $request->check_out({
        stage      => 'form',
        item_type  => $itemtype_loanable->itemtype,
        branchcode => $library->branchcode
    });
    is($form_stage_loanable->{stage}, 'done_check_out');
    isa_ok($patron->checkouts, 'Koha::Checkouts');
    is($patron->checkouts->count, 1);
    is($request->status, 'CHK');

    $schema->storage->txn_rollback;
};

subtest 'Checking out with custom due date' => sub {
    plan tests => 1;
    $schema->storage->txn_begin;

    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $biblio = $builder->build_sample_biblio();
    my $itemtype_loanable = $builder->build_object({
        class => 'Koha::ItemTypes',
        value => {
            notforloan => 0
        }
    });
    my $request = $builder->build_object({
        class => 'Koha::Illrequests',
        value => {
            borrowernumber => $patron->borrowernumber,
            biblio_id      => $biblio->biblionumber
        }
    });

    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode });
    my $duedate = '2099-05-21 00:00:00';
    my $form_stage_loanable = $request->check_out({
        stage      => 'form',
        item_type  => $itemtype_loanable->itemtype,
        branchcode => $library->branchcode,
        duedate    => $duedate
    });
    is($patron->checkouts->next->date_due, $duedate, "Custom due date was used");

    $schema->storage->txn_rollback;
};

subtest 'Checking Limits' => sub {

    plan tests => 30;

    $schema->storage->txn_begin;

    # Build infrastructure
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always('name', 'Mock');

    my $config = Test::MockObject->new;
    $config->set_always('backend_dir', "/tmp");

    my $illrq = $builder->build({source => 'Illrequest'});
    my $illrq_obj = Koha::Illrequests->find($illrq->{illrequest_id});
    $illrq_obj->_config($config);
    $illrq_obj->_backend($backend);

    # getLimits
    $config->set_series('getLimitRules',
                        { CPL => { count => 1, method => 'test' } },
                        { default => { count => 0, method => 'active' } });
    is_deeply($illrq_obj->getLimits({ type => 'branch', value => "CPL" }),
              { count => 1, method => 'test' },
              "getLimits: by value.");
    is_deeply($illrq_obj->getLimits({ type => 'branch' }),
              { count => 0, method => 'active' },
              "getLimits: by default.");
    is_deeply($illrq_obj->getLimits({ type => 'branch', value => "CPL" }),
              { count => -1, method => 'active' },
              "getLimits: by hard-coded.");

    #_limit_counter
    is($illrq_obj->_limit_counter('annual', { branchcode => $illrq_obj->branchcode }),
       1, "_limit_counter: Initial branch annual count.");
    is($illrq_obj->_limit_counter('active', { branchcode => $illrq_obj->branchcode }),
       1, "_limit_counter: Initial branch active count.");
    is($illrq_obj->_limit_counter('annual', { borrowernumber => $illrq_obj->borrowernumber }),
       1, "_limit_counter: Initial patron annual count.");
    is($illrq_obj->_limit_counter('active', { borrowernumber => $illrq_obj->borrowernumber }),
       1, "_limit_counter: Initial patron active count.");
    $builder->build({
        source => 'Illrequest',
        value => {
            branchcode => $illrq_obj->branchcode,
            borrowernumber => $illrq_obj->borrowernumber,
        }
    });
    is($illrq_obj->_limit_counter('annual', { branchcode => $illrq_obj->branchcode }),
       2, "_limit_counter: Add a qualifying request for branch annual count.");
    is($illrq_obj->_limit_counter('active', { branchcode => $illrq_obj->branchcode }),
       2, "_limit_counter: Add a qualifying request for branch active count.");
    is($illrq_obj->_limit_counter('annual', { borrowernumber => $illrq_obj->borrowernumber }),
       2, "_limit_counter: Add a qualifying request for patron annual count.");
    is($illrq_obj->_limit_counter('active', { borrowernumber => $illrq_obj->borrowernumber }),
       2, "_limit_counter: Add a qualifying request for patron active count.");
    $builder->build({
        source => 'Illrequest',
        value => {
            branchcode => $illrq_obj->branchcode,
            borrowernumber => $illrq_obj->borrowernumber,
            placed => "2005-05-31",
        }
    });
    is($illrq_obj->_limit_counter('annual', { branchcode => $illrq_obj->branchcode }),
       2, "_limit_counter: Add an out-of-date branch request.");
    is($illrq_obj->_limit_counter('active', { branchcode => $illrq_obj->branchcode }),
       3, "_limit_counter: Add a qualifying request for branch active count.");
    is($illrq_obj->_limit_counter('annual', { borrowernumber => $illrq_obj->borrowernumber }),
       2, "_limit_counter: Add an out-of-date patron request.");
    is($illrq_obj->_limit_counter('active', { borrowernumber => $illrq_obj->borrowernumber }),
       3, "_limit_counter: Add a qualifying request for patron active count.");
    $builder->build({
        source => 'Illrequest',
        value => {
            branchcode => $illrq_obj->branchcode,
            borrowernumber => $illrq_obj->borrowernumber,
            status => "COMP",
        }
    });
    is($illrq_obj->_limit_counter('annual', { branchcode => $illrq_obj->branchcode }),
       3, "_limit_counter: Add a qualifying request for branch annual count.");
    is($illrq_obj->_limit_counter('active', { branchcode => $illrq_obj->branchcode }),
       3, "_limit_counter: Add a completed request for branch active count.");
    is($illrq_obj->_limit_counter('annual', { borrowernumber => $illrq_obj->borrowernumber }),
       3, "_limit_counter: Add a qualifying request for patron annual count.");
    is($illrq_obj->_limit_counter('active', { borrowernumber => $illrq_obj->borrowernumber }),
       3, "_limit_counter: Add a completed request for patron active count.");

    # check_limits:

    # We've tested _limit_counter, so all we need to test here is whether the
    # current counts of 3 for each work as they should against different
    # configuration declarations.

    # No limits
    $config->set_always('getLimitRules', undef);
    is($illrq_obj->check_limits({patron => $illrq_obj->patron,
                                 librarycode => $illrq_obj->branchcode}),
       1, "check_limits: no configuration => no limits.");

    # Branch tests
    $config->set_always('getLimitRules',
                        { $illrq_obj->branchcode => { count => 1, method => 'active' } });
    is($illrq_obj->check_limits({patron => $illrq_obj->patron,
                                 librarycode => $illrq_obj->branchcode}),
       0, "check_limits: branch active limit exceeded.");
    $config->set_always('getLimitRules',
                        { $illrq_obj->branchcode => { count => 1, method => 'annual' } });
    is($illrq_obj->check_limits({patron => $illrq_obj->patron,
                                 librarycode => $illrq_obj->branchcode}),
       0, "check_limits: branch annual limit exceeded.");
    $config->set_always('getLimitRules',
                        { $illrq_obj->branchcode => { count => 4, method => 'active' } });
    is($illrq_obj->check_limits({patron => $illrq_obj->patron,
                                 librarycode => $illrq_obj->branchcode}),
       1, "check_limits: branch active limit OK.");
    $config->set_always('getLimitRules',
                        { $illrq_obj->branchcode => { count => 4, method => 'annual' } });
    is($illrq_obj->check_limits({patron => $illrq_obj->patron,
                                 librarycode => $illrq_obj->branchcode}),
       1, "check_limits: branch annual limit OK.");

    # Patron tests
    $config->set_always('getLimitRules',
                        { $illrq_obj->patron->categorycode => { count => 1, method => 'active' } });
    is($illrq_obj->check_limits({patron => $illrq_obj->patron,
                                 librarycode => $illrq_obj->branchcode}),
       0, "check_limits: patron category active limit exceeded.");
    $config->set_always('getLimitRules',
                        { $illrq_obj->patron->categorycode => { count => 1, method => 'annual' } });
    is($illrq_obj->check_limits({patron => $illrq_obj->patron,
                                 librarycode => $illrq_obj->branchcode}),
       0, "check_limits: patron category annual limit exceeded.");
    $config->set_always('getLimitRules',
                        { $illrq_obj->patron->categorycode => { count => 4, method => 'active' } });
    is($illrq_obj->check_limits({patron => $illrq_obj->patron,
                                 librarycode => $illrq_obj->branchcode}),
       1, "check_limits: patron category active limit OK.");
    $config->set_always('getLimitRules',
                        { $illrq_obj->patron->categorycode => { count => 4, method => 'annual' } });
    is($illrq_obj->check_limits({patron => $illrq_obj->patron,
                                 librarycode => $illrq_obj->branchcode}),
       1, "check_limits: patron category annual limit OK.");

    # One rule cancels the other
    $config->set_series('getLimitRules',
                        # Branch rules allow request
                        { $illrq_obj->branchcode => { count => 4, method => 'active' } },
                        # Patron rule forbids it
                        { $illrq_obj->patron->categorycode => { count => 1, method => 'annual' } });
    is($illrq_obj->check_limits({patron => $illrq_obj->patron,
                                 librarycode => $illrq_obj->branchcode}),
       0, "check_limits: patron category veto overrides branch OK.");
    $config->set_series('getLimitRules',
                        # Branch rules allow request
                        { $illrq_obj->branchcode => { count => 1, method => 'active' } },
                        # Patron rule forbids it
                        { $illrq_obj->patron->categorycode => { count => 4, method => 'annual' } });
    is($illrq_obj->check_limits({patron => $illrq_obj->patron,
                                 librarycode => $illrq_obj->branchcode}),
       0, "check_limits: branch veto overrides patron category OK.");

    $schema->storage->txn_rollback;
};

subtest 'Custom statuses' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $cat = Koha::AuthorisedValueCategories->search(
        {
            category_name => 'ILL_STATUS_ALIAS'
        }
    );

    if ($cat->count == 0) {
        $cat  = $builder->build_object(
            {
                class => 'Koha::AuthorisedValueCategory',
                value => {
                    category_name => 'ILL_STATUS_ALIAS'
                }
            }
        );
    };

    my $av = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                category => 'ILL_STATUS_ALIAS'
            }
        }
    );

    is($av->category, 'ILL_STATUS_ALIAS',
       "Successfully created authorised value for custom status");

    my $ill_req = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                status_alias => $av->authorised_value
            }
        }
    );
    isa_ok($ill_req->statusalias, 'Koha::AuthorisedValue',
           "statusalias correctly returning Koha::AuthorisedValue object");

    $ill_req->status("COMP");
    is($ill_req->statusalias, undef,
        "Koha::Illrequest->status overloading resetting status_alias");

    $schema->storage->txn_rollback;
};

subtest 'Checking in hook' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # Build infrastructure
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always('name', 'Mock');

    my $config = Test::MockObject->new;
    $config->set_always('backend_dir', "/tmp");

    my $item   = $builder->build_sample_item();
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });

    t::lib::Mocks::mock_userenv(
        {
            patron     => $patron,
            branchcode => $patron->branchcode
        }
    );

    my $illrq = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                biblio_id => $item->biblio->biblionumber,
                status    => 'NEW'
            }
        }
    );

    $illrq->_config($config);
    $illrq->_backend($backend);

    t::lib::Mocks::mock_preference('CirculateILL', 1);

    # Add an issue
    AddIssue( $patron, $item->barcode );
    # Make the item withdrawn so checking-in is rejected
    t::lib::Mocks::mock_preference('BlockReturnOfWithdrawnItems', 1);
    $item->set({ withdrawn => 1 })->store;
    AddReturn( $item->barcode, $patron->branchcode );
    # refresh request
    $illrq->discard_changes;
    isnt( $illrq->status, 'RET' );

    # allow the check-in
    $item->set({ withdrawn => 0 })->store;
    AddReturn( $item->barcode, $patron->branchcode );
    # refresh request
    $illrq->discard_changes;
    is( $illrq->status, 'RET' );

    $schema->storage->txn_rollback;
};
