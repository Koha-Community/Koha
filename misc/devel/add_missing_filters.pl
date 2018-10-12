#!/usr/bin/perl

use Modern::Perl;

use File::Slurp;
use Pod::Usage;
use Getopt::Long;

use t::lib::QA::TemplateFilters;

my ( $help, $verbose, @files );
GetOptions(
    'h|help'                 => \$help,
    'v|verbose'              => \$verbose,
) || pod2usage(1);

@files = @ARGV;

pod2usage(1) if $help or not @files;

my $i;
my $total = scalar @files;
my $num_width = length $total;
for my $file ( @ARGV ) {
    if ( $verbose ) {
        print sprintf "|%-25s| %${num_width}s / %s (%.2f%%)\r",
            '=' x (24*$i++/$total). '>',
            $i, $total, 100*$i/+$total;
        flush STDOUT;
    }

    my $content = read_file( $file );
    my $new_content = t::lib::QA::TemplateFilters::fix_filters($content);
    $new_content .= "\n";
    if ( $content ne $new_content ) {
        say "$file -- Modified";
        write_file($file, $new_content);
    }
}


=head1 NAME

add_missing_filters.pl - Will add the missing filters to the template files given in parameters.

=head1 SYNOPSIS

perl misc/devel/add_missing_filters.pl **/*.tt

/!\ It is highly recommended to execute this script on a clean git install, with all your files and changes committed.

 Options:
   -?|--help        brief help message
   -v|--verbose     verbose mode

=head1 OPTIONS

=over 8

=item B<--help|-?>

Print a brief help message and exits

=item B<-v|--verbose>

Verbose mode.

=back

=head1 AUTHOR

Jonathan Druart <jonathan.druart@bugs.koha-community.org>

=head1 COPYRIGHT

Copyright 2018 Koha Development Team

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <http://www.gnu.org/licenses>.
