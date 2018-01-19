#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (c) 2016   Mark Tompsett -- is_testable()
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

use Test::More;
use File::Spec;
use File::Find;
use English qw( -no_match_vars );

=head1 DESCRIPTION

00-load.t: This script is called by the pre-commit git hook to test modules compile

=cut

# Loop through the C4:: modules
my $lib = File::Spec->rel2abs('C4');
find({
    bydepth => 1,
    no_chdir => 1,
    wanted => sub {
        my $m = $_;
        return unless $m =~ s/[.]pm$//;

        $m =~ s{^.*/C4/}{C4/};
        $m =~ s{/}{::}g;
        return if $m =~ /Auth_with_ldap/; # Dont test this, it will fail on use
        return if $m =~ /SIPServer/; # SIP Server module has old package usage
        use_ok($m) || BAIL_OUT("***** PROBLEMS LOADING FILE '$m'");
    },
}, $lib);

# Loop through the Koha:: modules
$lib = File::Spec->rel2abs('Koha');
find(
    {
        bydepth  => 1,
        no_chdir => 1,
        wanted   => sub {
            my $m = $_;
            return unless $m =~ s/[.]pm$//;
            $m =~ s{^.*/Koha/}{Koha/};
            $m =~ s{/}{::}g;
            if ( is_testable($m) ) {
                use_ok($m) || BAIL_OUT("***** PROBLEMS LOADING FILE '$m'");
            }
        },
    },
    $lib
);

# Optional modules are causing checks to fail
# This checks for the particular modules to determine
# if the testing is possible or not.
#
# Returns 1 if possible, 0 if not.
sub is_testable {
    my ($module_name) = @_;
    my @needed_module_names;
    my $return_value = 1;
    if ( $module_name =~ /Koha::NorwegianPatronDB/xsm ) {
        @needed_module_names =
          ( 'SOAP::Lite', 'Crypt::GCrypt', 'Digest::SHA', 'Convert::BaseN' );
    }
    elsif ( $module_name =~ /Koha::SearchEngine::Elasticsearch::Indexer/xsm ) {
        @needed_module_names =
          ( 'Catmandu::Importer::MARC', 'Catmandu::Store::ElasticSearch' );
    }
    elsif ( $module_name =~ /Koha::SearchEngine::Elasticsearch::Search/xsm ) {
        @needed_module_names = ( 'Catmandu::Store::ElasticSearch' );
    }
    elsif ( $module_name =~ /Koha::SearchEngine::Elasticsearch/xsm ) {
        @needed_module_names = ( 'Search::Elasticsearch' );
    }
    elsif ( $module_name =~ /^Koha::ExternalContent/xsm ) {
        @needed_module_names = ( 'WebService::ILS' );
    }
    foreach my $current_name (@needed_module_names) {
        my $relative_pathname = $current_name;
        $relative_pathname =~ s/::/\//gxsm;
        $relative_pathname .= '.pm';
        my $check_result = eval { require "$relative_pathname"; 1; };
        if ($EVAL_ERROR) {
            diag(
"Skipping testing of $module_name, because $current_name is not installed."
            );
            $return_value = 0;
        }
    }
    return $return_value;
}

done_testing();

