package UsageStats;

# Copyright 2000-2003 Katipo Communications
# Copyright 2010 BibLibre
# Parts Copyright 2010 Catalyst IT
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use C4::Context;
use POSIX qw(strftime);
use LWP::UserAgent;
use JSON;

sub NeedUpdate {
    my $lastupdated = C4::Context->preference('UsageStatsLastUpdateTime') || 0;
    my $now = strftime("%s", localtime);

    # Need to launch cron.
    return 1 if $now - $lastupdated >= 2592000;

    # Cron no need to be launched.
    return 0;
}

sub LaunchCron {
    if (!C4::Context->preference('UsageStatsShare')) {
      die ("UsageStats is not configured");
    }
    if (NeedUpdate) {
        C4::Context->set_preference('UsageStatsLastUpdateTime', strftime("%s", localtime));
        my $data = BuildReport();
        ReportToComunity($data);
    }
}

sub BuildReport {
    my $report = {
        'library' => {
            'name' => C4::Context->preference('UsageStatsLibraryName'),
            'id' => C4::Context->preference('UsageStatsID') || 0,
        },
    };

    # Get database volumetry.
    foreach (qw/biblio auth_header old_issues old_reserves borrowers aqorders subscription/) {
        $report->{volumetry}{$_} = _count($_);
    }

    # Get systempreferences.
    foreach (qw/IntranetBiblioDefaultView marcflavour/) {
        $report->{systempreferences}{$_} = C4::Context->preference($_);
    }
    return $report;
}

sub ReportToComunity {
    my $data = shift;
    my $json = to_json($data);

    my $url = C4::Context->config('mebaseurl');

    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new(POST => "$url/upload.pl");
    $req->content_type('application/x-www-form-urlencoded');
    $req->content("data=$json");
    my $res = $ua->request($req);
    my $content = from_json($res->decoded_content);
    C4::Context->set_preference('UsageStatsID', $content->{library}{library_id});
}

sub _count {
    my $table = shift;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT count(*) from $table");
    $sth->execute;
    return $sth->fetchrow_array;
}

&LaunchCron;
1;
