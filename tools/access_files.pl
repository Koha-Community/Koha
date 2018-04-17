#!/usr/bin/perl

# Frédérick Capovilla, 2011 - Libéo
#
# Show a list of all the files in the directory specified by the option
# "access_dir" in koha-conf.xml so they can be downloaded by users with the
# "access_files" permission.
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

use C4::Auth;
use CGI;
use C4::Context;
use C4::Output;
use C4::Koha;
use File::stat qw(stat);
use Digest::MD5 qw(md5_hex);
use Encode;

my $input = new CGI;
my $file_id = $input->param("id");
my $access_dir = C4::Context->config('access_dir');
my @directories = $access_dir ? (ref $access_dir ? @{$access_dir} : ($access_dir)) : ();

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "tools/access_files.tt",
                query => $input,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => { tools => 'access_files' },
                });

unless(@directories) {
    $template->param(error_no_dir => 1);
}
else {
    #Get the files list
    my @files_list;
    foreach my $dir(@directories){
        opendir(DIR, $dir);
        foreach my $filename (readdir(DIR)) {
            my $full_path = "$dir/$filename";
            my $id = md5_hex($full_path);
            next if ($filename =~ /^\./ or -d $full_path);

            # Make sure the filename is unicode-friendly
            my $decoded_filename = decode('utf8', $filename);
            my $st = stat("$dir/$decoded_filename");

            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime($st->mtime);
            my $dt=DateTime->new(year      => $year + 1900,
                                  month    => $mon + 1,
                                  day      => $mday,
                                  hour     => $hour,
                                  minute   => $min,
                            );
            push(@files_list, {name => $decoded_filename,
                               access_dir => $dir,
                               date =>Koha::DateUtils::output_pref($dt),
                               size => $st->size,
                               id   => $id});
        }
        closedir(DIR);
    }

    my %files_hash = map { $_->{id} => $_ } @files_list;
    # If we received a file_id and it is valid, send the file to the browser
    if(defined $file_id and exists $files_hash{$file_id} ){
        my $filename = $files_hash{$file_id}->{name};
        my $dir = $files_hash{$file_id}->{access_dir};
        binmode STDOUT;
        # Open the selected file and send it to the browser
        print $input->header(-type => 'application/x-download',
                             -name => "$filename",
                             -Content_length => -s "$dir/$filename",
                             -attachment => "$filename");

        my $fh;
        open $fh, "<:encoding(UTF-8)", "$dir/$filename";
        binmode $fh;

        my $buf;
        while(read($fh, $buf, 65536)) {
            print $buf;
        }
        close $fh;

        exit(0);
    }
    else{
        # Send the file list to the template
        $template->param(files_loop => \@files_list);
    }
}

output_html_with_http_headers $input, $cookie, $template->output;
