package t::db_dependent::KohaSuomi::RemoteBiblioPackageImporter::Context;

use t::lib::TestObjects::SystemPreferenceFactory;
use t::lib::TestObjects::MatcherFactory;

sub prepareContext {
    my ($class, $testContext) = @_;

    t::lib::TestObjects::SystemPreferenceFactory->createTestGroup([{
        preference => 'VaaraAcqVendorConfigurations',
        value => <<SYSPREF}], undef, $testContext);
---
BTJBiblios:
    host: testcluster.koha-suomi.fi
    port: 7621
    username: btjtest
    password: testcluster
    protocol: passive ftp
    basedir: /
    encoding: UTF-8
    format: MARCXML
    fileRegexp: 'B(\\d{4})(\\d{2})(\\d{2})xm[ak]'
    localStorageDir: /tmp/testImportedMARC
    stageFiles: 1
    commitFiles: 1
    matcher: ALLFONS

SYSPREF


    my $matchers = t::lib::TestObjects::MatcherFactory->createTestGroup([
                    {}, #Create default matcher to take the first id position, so default is not what we need
                    {
                        code => 'ALLFONS', #Matches 001 to Control-number and makes sure 003's match
                        description => 'I match BTJ\'s allfons records',
                        threshold => 1000,
                        matchpoints => [
                           {
                              index       => 'Control-number',
                              score       => 1000,
                              components => [{
                                   tag         => '001',
                                   subfields   => '',
                                   offset      => 0,
                                   length      => 0,
                                   norms       => [''],
                              }]
                           },
                        ],
                        required_checks => [{
                            source => [{
                                tag         => '003',
                                subfields   => '',
                                offset      => 0,
                                length      => 0,
                                norms       => [''],
                            }],
                            target => [{
                                tag         => '003',
                                subfields   => '',
                                offset      => 0,
                                length      => 0,
                                norms       => [''],
                            }],
                        }],
                    },
                ], undef, $testContext);
    return $matchers;
} #EO prepareContext()

1;
