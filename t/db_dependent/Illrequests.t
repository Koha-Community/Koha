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
use Koha::Illrequestattributes;
use Koha::Illrequest::Config;
use Koha::Patrons;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::MockObject;
use Test::MockModule;
use Test::Exception;

use Test::More tests => 11;

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
use_ok('Koha::Illrequest');
use_ok('Koha::Illrequests');

subtest 'Basic object tests' => sub {

    plan tests => 22;

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

subtest 'Working with related objects' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    Koha::Illrequests->search->delete;

    my $patron = $builder->build({ source => 'Borrower' });
    my $illrq = $builder->build({
        source => 'Illrequest',
        value => { borrowernumber => $patron->{borrowernumber} }
    });
    my $illrq_obj = Koha::Illrequests->find($illrq->{illrequest_id});

    isa_ok($illrq_obj->patron, 'Koha::Patron',
           "OK accessing related patron.");

    $builder->build({
        source => 'Illrequestattribute',
        value  => { illrequest_id => $illrq_obj->illrequest_id, type => 'X' }
    });
    $builder->build({
        source => 'Illrequestattribute',
        value  => { illrequest_id => $illrq_obj->illrequest_id, type => 'Y' }
    });
    $builder->build({
        source => 'Illrequestattribute',
        value  => { illrequest_id => $illrq_obj->illrequest_id, type => 'Z' }
    });

    is($illrq_obj->illrequestattributes->count, Koha::Illrequestattributes->search->count,
       "Fetching expected number of Illrequestattributes for our request.");

    my $illrq1 = $builder->build({ source => 'Illrequest' });
    $builder->build({
        source => 'Illrequestattribute',
        value  => { illrequest_id => $illrq1->{illrequest_id}, type => 'X' }
    });

    is($illrq_obj->illrequestattributes->count + 1, Koha::Illrequestattributes->search->count,
       "Fetching expected number of Illrequestattributes for our request.");

    $illrq_obj->delete;
    is(Koha::Illrequestattributes->search->count, 1,
       "Correct number of illrequestattributes after delete.");

    isa_ok(Koha::Patrons->find($patron->{borrowernumber}), 'Koha::Patron',
           "Borrower was not deleted after illrq delete.");

    $schema->storage->txn_rollback;
};

subtest 'Status Graph tests' => sub {

    plan tests => 4;

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
        value => { borrowernumber => $patron->{borrowernumber} }
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
                  next_actions   => [ ],
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

    plan tests => 17;

    $schema->storage->txn_begin;

    # Build infrastructure
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always('name', 'Mock');

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

    dies_ok { $illrq->generic_confirm({
        current_branchcode => $illbrn->{branchcode},
        partners => $partner1->{email},
        stage => 'draft'
    }) }
        "Generic confirm: missing from dies OK.";

    $schema->storage->txn_rollback;
};


subtest 'Helpers' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    # Build infrastructure
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always('name', 'Mock');

    my $config = Test::MockObject->new;
    $config->set_always('backend_dir', "/tmp");

    my $patron = $builder->build({
        source => 'Borrower',
        value => { categorycode => "A" }
    });
    my $illrq = $builder->build({
        source => 'Illrequest',
        value => { branchcode => "CPL", borrowernumber => $patron->{borrowernumber} }
    });
    my $illrq_obj = Koha::Illrequests->find($illrq->{illrequest_id});
    $illrq_obj->_config($config);
    $illrq_obj->_backend($backend);

    # getPrefix
    $config->set_series('getPrefixes',
                        { CPL => "TEST", TSL => "BAR", default => "DEFAULT" },
                        { A => "ATEST", C => "CBAR", default => "DEFAULT" });
    is($illrq_obj->getPrefix({ brw_cat => "C", branch => "CPL" }), "CBAR",
       "getPrefix: brw_cat");
    $config->set_series('getPrefixes',
                        { CPL => "TEST", TSL => "BAR", default => "DEFAULT" },
                        { A => "ATEST", C => "CBAR", default => "DEFAULT" });
    is($illrq_obj->getPrefix({ brw_cat => "UNKNOWN", branch => "CPL" }), "TEST",
       "getPrefix: branch");
    $config->set_series('getPrefixes',
                        { CPL => "TEST", TSL => "BAR", default => "DEFAULT" },
                        { A => "ATEST", C => "CBAR", default => "DEFAULT" });
    is($illrq_obj->getPrefix({ brw_cat => "UNKNOWN", branch => "UNKNOWN" }), "DEFAULT",
       "getPrefix: default");
    $config->set_always('getPrefixes', {});
    is($illrq_obj->getPrefix({ brw_cat => "UNKNOWN", branch => "UNKNOWN" }), "",
       "getPrefix: the empty prefix");

    # id_prefix
    $config->set_series('getPrefixes',
                        { CPL => "TEST", TSL => "BAR", default => "DEFAULT" },
                        { A => "ATEST", C => "CBAR", default => "DEFAULT" });
    is($illrq_obj->id_prefix, "ATEST-", "id_prefix: brw_cat");
    $config->set_series('getPrefixes',
                        { CPL => "TEST", TSL => "BAR", default => "DEFAULT" },
                        { AB => "ATEST", CD => "CBAR", default => "DEFAULT" });
    is($illrq_obj->id_prefix, "TEST-", "id_prefix: branch");
    $config->set_series('getPrefixes',
                        { CPLT => "TEST", TSLT => "BAR", default => "DEFAULT" },
                        { AB => "ATEST", CD => "CBAR", default => "DEFAULT" });
    is($illrq_obj->id_prefix, "DEFAULT-", "id_prefix: default");

    # requires_moderation
    $illrq_obj->status('NEW')->store;
    is($illrq_obj->requires_moderation, undef, "requires_moderation: No.");
    $illrq_obj->status('CANCREQ')->store;
    is($illrq_obj->requires_moderation, 'CANCREQ', "requires_moderation: Yes.");

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

subtest 'TO_JSON() tests' => sub {

    plan tests => 10;

    my $illreqmodule = Test::MockModule->new('Koha::Illrequest');

    # Mock ->capabilities
    $illreqmodule->mock( 'capabilities', sub { return 'capable'; } );

    # Mock ->metadata
    $illreqmodule->mock( 'metadata', sub { return 'metawhat?'; } );

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $illreq  = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                branchcode     => $library->branchcode,
                borrowernumber => $patron->borrowernumber
            }
        }
    );
    my $illreq_json = $illreq->TO_JSON;
    is( $illreq_json->{patron},
        undef, '%embed not passed, no \'patron\' attribute' );
    is( $illreq_json->{metadata},
        undef, '%embed not passed, no \'metadata\' attribute' );
    is( $illreq_json->{capabilities},
        undef, '%embed not passed, no \'capabilities\' attribute' );
    is( $illreq_json->{library},
        undef, '%embed not passed, no \'library\' attribute' );

    $illreq_json = $illreq->TO_JSON(
        { patron => 1, metadata => 1, capabilities => 1, library => 1 } );
    is( $illreq_json->{patron}->{firstname},
        $patron->firstname,
        '%embed passed, \'patron\' attribute correct (firstname)' );
    is( $illreq_json->{patron}->{surname},
        $patron->surname,
        '%embed passed, \'patron\' attribute correct (surname)' );
    is( $illreq_json->{patron}->{cardnumber},
        $patron->cardnumber,
        '%embed passed, \'patron\' attribute correct (cardnumber)' );
    is( $illreq_json->{metadata},
        'metawhat?', '%embed passed, \'metadata\' attribute correct' );
    is( $illreq_json->{capabilities},
        'capable', '%embed passed, \'capabilities\' attribute correct' );
    is( $illreq_json->{library}->{branchcode},
        $library->branchcode, '%embed not passed, no \'library\' attribute' );

    $schema->storage->txn_rollback;
};
