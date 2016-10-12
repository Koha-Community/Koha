package t::CataloguingCenter::ContextSysprefs;
#
# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use t::lib::TestObjects::SystemPreferenceFactory;

=head IN THIS FILE

We instantiate the BatchOverlayRules-syspref for CataloguingCenter tests.

=cut

sub createBatchOverlayRules {
my ($testContext) = @_;

my $spref = t::lib::TestObjects::SystemPreferenceFactory->createTestGroup(
                    {
                        preference => 'BatchOverlayRules',
                        value => <<VALUE,
---
default:
    remoteTargetCode: CATALOGUING_CENTER
    mergeMatcherCode: MERGER
    componentPartMergeMatcherCode: MERGER
    componentPartMatcherCode: COM_PART
    remoteFieldsDropped: [biblio.biblionumber, 952]
    diffExcludedFields: [999, items.barcode]
    searchAlgorithms: [Control_number_identifier, Standard_identifier]
    notifyOnChangeSubfields:
    notificationEmails:
    dryRun: 0

_excludeExceptions: [UnknownMatcher]

VALUE
                    }
                , undef, $testContext);

return $spref;
} #EO createBatchOverlayRules()


sub createBatchOverlayNotificationRules {
my ($testContext) = @_;

my $spref = t::lib::TestObjects::SystemPreferenceFactory->createTestGroup(
                    {
                        preference => 'BatchOverlayRules',
                        value => <<VALUE,
---
default:
    remoteTargetCode: CATALOGUING_CENTER
    mergeMatcherCode: MERGER
    componentPartMergeMatcherCode: MERGER
    componentPartMatcherCode: COM_PART
    remoteFieldsDropped: [biblio.biblionumber, 952]
    diffExcludedFields: [999, items.barcode]
    searchAlgorithms: [Control_number_identifier, Standard_identifier]
    notifyOnChangeSubfields: [biblio.title, biblio.author, biblioitems.isbn]
    notificationEmails: [koha\@example.com]
    dryRun: 0

_excludeExceptions: [UnknownMatcher]

VALUE
                    }
                , undef, $testContext);

return $spref;
} #EO createBatchOverlayRules()


sub createRemoteAPIs {
my ($testContext) = @_;

my $spref = t::lib::TestObjects::SystemPreferenceFactory->createTestGroup(
                    {
                        preference => 'RemoteAPIs',
                        value => <<VALUE,
---
Test Remote:
    host: http://testcluster.koha-suomi.fi:80
    basePath: /api/v1/
    authentication: cookies
    api: Koha-Suomi
Test Stub:
    host: http://test.example.com:80
    basePath: /apina/
    authentication: none
    api: Koha-Suomi

VALUE
                    }
                , undef, $testContext);

return $spref;
} #EO createRemoteAPIs()

1;
