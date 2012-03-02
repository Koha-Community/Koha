#!/usr/bin/perl

use Modern::Perl;
use C4::Context;
use C4::SocialData;

my $url = C4::Context->preference( "Babeltheque_url_update" );
my $output_dir = qq{/tmp};
my $output_filepath = qq{$output_dir/social_data.csv};
system( qq{/bin/rm -f $output_filepath} );
system( qq{/bin/rm -f $output_dir/social_data.csv.bz2} );
system( qq{/usr/bin/wget $url -O $output_dir/social_data.csv.bz2 } ) == 0 or die "Can't get bz2 file from url $url ($?)";
system( qq{/bin/bunzip2 $output_dir/social_data.csv.bz2 } ) == 0 or die "Can't extract bz2 file ($?)";


C4::SocialData::update_data $output_filepath;
