use Modern::Perl;

use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );

use JSON qw( from_json to_json );
use HTTP::Request;
use LWP::UserAgent;

use Koha::Acquisition::Booksellers;
use Koha::ERM::EHoldings::Packages;
use Koha::ERM::EHoldings::Titles;
use Koha::ERM::EHoldings::Resources;

our ( $custid, $api_key );
my( $help, $verbose );
GetOptions(
    'help|h' => \$help,
    'verbose|v' => \$verbose,
    'custid:s' => \$custid,
    'api-key:s' => \$api_key,
) || podusage(1);

pod2usage(1) if $help;
pod2usage("Parameters 'custid' and 'api-key' are mandatory") unless $custid && $api_key;

#my $status = get_status();
#say "Status of the snapshot: $status";
#if ( $status ne 'Completed' && $status ne 'In Progress' ) {
#    say "Populate holdings...";
#    populate_holdings();
#}
#
#while ($status ne 'Completed') {
#    sleep(60);
#    $status = get_status();
#    say "Status: " . $status;
#}

sub get_status {
    my $response= request(GET => '/holdings/status');
    my $result = from_json( $response->decoded_content );
    return $result->{status};
}

sub populate_holdings {
    my $response = request( POST => '/holdings' );
    if ( $response->code != 202 && $response->code != 409 ) {
        my $result = from_json( $response->decoded_content );
        die sprintf "ERROR - code %s: %s\n", $response->code,
          $result->{message};
    }
}

sub request {
    my ( $method, $url ) = @_;

    my $base_url = 'https://api.ebsco.io/rm/rmaccounts/' . $custid;
    my $request = HTTP::Request->new( $method => $base_url . $url);
    $request->header( 'x-api-key' => $api_key );
    my $ua = LWP::UserAgent->new;
    return $ua->simple_request($request);
}

my @lines;
while(my $line = <DATA>){chomp $line;push @lines, $line}
my $json = join "", @lines;
my $result = from_json($json);
for my $h ( @{$result->{holdings}} ) {
    say $h->{publication_title};
    my $vendor = Koha::Acquisition::Booksellers->search({name => $h->{vendor_name}});
    if ($vendor->count) {
        $vendor = $vendor->next;
        if ( !$vendor->external_id ) {
            $vendor->external_id( $h->{vendor_id} )->store;
        }
        elsif ( $vendor->external_id != $h->{vendor_id} ) {
            die "Cannot update external vendor id for " . $h->{vendor_name};
        }
    }
    else {
        $vendor = Koha::Acquisition::Bookseller->new(
            { name => $h->{vendor_name}, external_id => $h->{vendor_id} } )
          ->store;
    }

    my $package =
      Koha::ERM::EHoldings::Packages->search( { name => $h->{package_name} } );
    if ($package->count) {
        $package = $package->next;
        if ( !$package->external_id ) {
            $package->external_id( $h->{package_id} );
        }
        elsif ( $package->external_id != $h->{package_id} ) {
            die "Cannot update external package id for " . $h->{package_name};
        }

    }
    else {
        $package = Koha::ERM::EHoldings::Package->new(
            { name => $h->{package_name}, external_id => $h->{package_id} } );
    }
    $package->vendor_id($vendor->id);
    $package->store;

    my $title = Koha::ERM::EHoldings::Titles->search(
        { publication_title => $h->{publication_title} } );
    if ($title->count) {
        $title = $title->next;
        if ( !$title->external_id ) {
            $title->external_id( $h->{title_id} )->store;
        }
        elsif ( $title->external_id != $h->{title_id} ) {
            die "Cannot update external title id for "
              . $h->{publication_title};
        }
    }
    else {
        $title = Koha::ERM::EHoldings::Title->new(
            {
                publication_title => $h->{publication_title},
                external_id       => $h->{title_id}
            }
        )->store;
    }

    $title->update(
        {
            print_identifier        => $h->{print_identifier},
            online_identifier       => $h->{online_identifier},
            date_first_issue_online => $h->{date_first_issue_online},
            num_first_vol_online    => $h->{num_first_vol_online},
            num_first_issue_online  => $h->{num_first_issue_online},
            date_last_issue_online  => $h->{date_last_issue_online},
            num_last_vol_online     => $h->{num_last_vol_online},
            num_last_issue_online   => $h->{num_last_issue_online},
            title_url               => $h->{title_url},
            first_author            => $h->{first_author},
            title_id                => $h->{title_id},
            embargo_info            => $h->{embargo_info},
            coverage_depth          => $h->{coverage_depth},
            notes                   => $h->{notes},
            publisher_name          => $h->{publisher_name},
            publication_type        => $h->{publication_type},
            date_monograph_published_print =>
              $h->{date_monograph_published_print},
            date_monograph_published_online =>
              $h->{date_monograph_published_online},
            monograph_volume            => $h->{monograph_volume},
            monograph_edition           => $h->{monograph_edition},
            first_editor                => $h->{first_editor},
            parent_publication_title_id => $h->{parent_publication_title_id},
            preceeding_publication_title_id =>
              $h->{preceeding_publication_title_id},
            access_type => $h->{access_type},

            # "resource_type": "Database" ?
        }
    );

    Koha::ERM::EHoldings::Resource->new({title_id => $title->title_id, package_id => $package->package_id})->store;
}

__DATA__
{
  "offset": 1,
  "format": "kbart2",
  "holdings": [
    {
      "publication_title": "PsycFIRST",
      "print_identifier": "",
      "online_identifier": "",
      "date_first_issue_online": "",
      "num_first_vol_online": "",
      "num_first_issue_online": "",
      "date_last_issue_online": "",
      "num_last_vol_online": "",
      "num_last_issue_online": "",
      "title_url": "http://firstsearch.oclc.org/FSIP?db=PsycFIRST",
      "first_author": "",
      "title_id": "482857",
      "embargo_info": "",
      "coverage_depth": "abstract",
      "notes": "",
      "publisher_name": "Unspecified",
      "publication_type": "monograph",
      "date_monograph_published_print": "2000",
      "date_monograph_published_online": "2000",
      "monograph_volume": "",
      "monograph_edition": "",
      "first_editor": "",
      "parent_publication_title_id": "",
      "preceeding_publication_title_id": "",
      "access_type": "P",
      "package_name": "PsycFIRST",
      "package_id": "2976",
      "vendor_name": "OCLC",
      "vendor_id": "21",
      "resource_type": "Database"
    },
    {
      "publication_title": "PsycFIRST",
      "print_identifier": "",
      "online_identifier": "",
      "date_first_issue_online": "",
      "num_first_vol_online": "",
      "num_first_issue_online": "",
      "date_last_issue_online": "",
      "num_last_vol_online": "",
      "num_last_issue_online": "",
      "title_url": "http://firstsearch.oclc.org/FSIP?db=PsycFIRST",
      "first_author": "",
      "title_id": "482857",
      "embargo_info": "",
      "coverage_depth": "abstract",
      "notes": "",
      "publisher_name": "Unspecified",
      "publication_type": "monograph",
      "date_monograph_published_print": "2001",
      "date_monograph_published_online": "2001",
      "monograph_volume": "",
      "monograph_edition": "",
      "first_editor": "",
      "parent_publication_title_id": "",
      "preceeding_publication_title_id": "",
      "access_type": "P",
      "package_name": "PsycFIRST",
      "package_id": "2976",
      "vendor_name": "OCLC",
      "vendor_id": "21",
      "resource_type": "Database"
    },
    {
      "publication_title": "Idea Engineering: Creative Thinking and Innovation",
      "print_identifier": "978-1-60650-472-7",
      "online_identifier": "978-1-60650-473-4",
      "date_first_issue_online": "",
      "num_first_vol_online": "",
      "num_first_issue_online": "",
      "date_last_issue_online": "",
      "num_last_vol_online": "",
      "num_last_issue_online": "",
      "title_url": "",
      "first_author": "Harris, La Verne Abe.",
      "title_id": "2461469",
      "embargo_info": "",
      "coverage_depth": "fulltext",
      "notes": "",
      "publisher_name": "Momentum Press, LLC",
      "publication_type": "monograph",
      "date_monograph_published_print": "2014",
      "date_monograph_published_online": "2014",
      "monograph_volume": "",
      "monograph_edition": "",
      "first_editor": "",
      "parent_publication_title_id": "",
      "preceeding_publication_title_id": "",
      "access_type": "P",
      "package_name": "Ebrary Business Expert Press Digital Library 2014",
      "package_id": "22589",
      "vendor_name": "Ebrary",
      "vendor_id": "269",
      "resource_type": "Book"
    }
  ]
}
