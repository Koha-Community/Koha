package t::CataloguingCenter::Reports;
#
# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#

use Modern::Perl;

use t::lib::TestObjects::BiblioFactory;

use C4::BatchOverlay::RuleManager;
use C4::BatchOverlay::Report::Report;

sub createReports {
    my ($testContext, $ruleManager) = @_;

    $ruleManager = C4::BatchOverlay::RuleManager->new() unless $ruleManager;

    my $records = t::lib::TestObjects::BiblioFactory->createTestGroup([
                        {'biblio.title'     => 'I wish I met your mother',
                         'biblio.author'    => 'Pertti Kurikka',
                         'biblioitems.isbn' => '123456789-10',
                        },
                        {'biblio.title'     => 'I wished I knew your mother',
                         'biblio.author'    => 'Kurtti Perikka',
                         'biblioitems.isbn' => '123456789-11',
                        },
                        {'biblio.title'     => 'Here we go again',
                         'biblioitems.isbn' => '123456789-20',
                        },
                        {'biblio.title'     => 'Again go we here',
                         'biblioitems.isbn' => '123456789-21',
                        },
                        {'biblio.title'     => 'NO CHANGE HERE',
                         'biblioitems.isbn' => '123456789-30',
                        },
                        {'biblio.title'     => 'NO CHANGE HERE',
                         'biblioitems.isbn' => '123456789-30',
                        },
    ], undef, $testContext);

    my @reports;
    push(@reports, C4::BatchOverlay::Report::Report->new(
        {   localRecord => $records->{'123456789-10'},
            newRecord => $records->{'123456789-11'},
            mergedRecord => $records->{'123456789-11'}->clone(),
            operation => 'test report',
            timestamp => DateTime->now( time_zone => C4::Context->tz() ),
            overlayRule => $ruleManager->getRuleFromRuleName('default'),
        }
    ));
    push(@reports, C4::BatchOverlay::Report::Report->new(
        {   localRecord => $records->{'123456789-20'},
            newRecord => $records->{'123456789-21'},
            mergedRecord => $records->{'123456789-21'}->clone(),
            operation => 'test report',
            timestamp => DateTime->now( time_zone => C4::Context->tz() ),
            overlayRule => $ruleManager->getRuleFromRuleName('default'),
        }
    ));
    push(@reports, C4::BatchOverlay::Report::Report->new(
        {   localRecord => $records->{'123456789-30'},
            newRecord => $records->{'123456789-30'},
            mergedRecord => $records->{'123456789-30'}->clone(),
            operation => 'test report',
            timestamp => DateTime->now( time_zone => C4::Context->tz() ),
            overlayRule => $ruleManager->getRuleFromRuleName('default'),
        }
    ));
    return \@reports;
}

1;
