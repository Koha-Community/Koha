#!/usr/bin/perl

use Modern::Perl;

use Koha::Script -cron;
use C4::Context;
use C4::SocialData;
use URI;

my $syspref_value = C4::Context->preference("Babeltheque_url_update");
my $url           = URI->new($syspref_value);

#NOTE: Both HTTP and HTTPS URLs are instances of the URI::http class
if ( $url && ref $url && $url->isa('URI::http') ) {
    my $output_dir      = qq{/tmp};
    my $output_filepath = qq{$output_dir/social_data.csv};
    system(qq{/bin/rm -f $output_filepath});
    system(qq{/bin/rm -f $output_dir/social_data.csv.bz2});
    system( '/usr/bin/wget', $url, '-O', "$output_dir/social_data.csv.bz2" ) == 0
        or die "Can't get bz2 file from url $url ($?)";
    system(qq{/bin/bunzip2 $output_dir/social_data.csv.bz2 }) == 0 or die "Can't extract bz2 file ($?)";

    C4::SocialData::update_data $output_filepath;
} else {
    print "$syspref_value is not a HTTP URL. Aborting.\n";
}
