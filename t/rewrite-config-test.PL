# Copyright 2008 LibLime
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#

use strict;
use warnings;

use Sys::Hostname;
use Socket;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

# These variables get set from command line options
my ( $fname );
GetOptions( 'file=s', \$fname )
  or pod2usage();


=head1 NAME

rewrite-test-config.PL - helper for the Koha packager and installer

=head1 SYNOPSIS

	perl rewrite-test-config.PL configurationfile

=head1 DESCRIPTION

This helper script replaces keywords in the
configuration file with value either supplied through
the environment

I intend to make this part of hte normal make process eventually.

=head2 KEYWORDS

The following configuration keywords are available:

=head1 EXAMPLES

=cut

my $configfile = 'test-config.txt';
my $configuration = read_config_file( $configfile );

# Override configuration from the environment
foreach my $key (keys %$configuration) {
  if (defined($ENV{$key})) {
    $configuration->{$key} = $ENV{$key};
  }
}

$configuration = add_underscores( $configuration );
my %configuration = replace_test_params( $configuration );

my $file = read_file($fname);
$file =~ s/__.*?__/exists $configuration{$&} ? $configuration{$&} : $&/seg;

# At this point, file is in 'blib' and by default
# has mode a-w.  Therefore, must change permission
# to make it writable.  Note that stat and chmod
# (the Perl functions) should work on Win32
my $old_perm;
$old_perm = (stat $fname)[2] & 07777;
my $new_perm = $old_perm | 0200;
chmod $new_perm, $fname;

open(OUTPUT,">$fname") || die "Can't open $fname for write: $!";
print OUTPUT $file;
close(OUTPUT);

chmod $old_perm, $fname;

=head2 read_config_file

  takes the filename pointing to the configuration file that the
  top-level Makefile wrote

  returns a hashref that contains the configuration determined by
  that file.

=cut

sub read_config_file {
    my $config_file = shift;
    if ( not -e $config_file ) {
        die "unable to find configuration file: $config_file";
    }
    my $config;
    if ( open( my $confighandle, '<', $config_file ) ) {
        while ( my $line = <$confighandle> ) {
            chomp $line;
            next if ( $line eq '' );
            next if ( $line =~ /^\s*#/ );
            my ( $var, $value ) = split( /\s*=\s*/, $line );
            $config->{ $var } = $value;
        }
    } else {
        warn "unable to open configuration file: $config_file";
        return;
    }
    return $config;
}

=head2 add_underscores

=cut

sub add_underscores {
    my $config = shift;
    
    my $newconfig;
    foreach my $key ( keys %$config ) {
        $newconfig->{ '__' . $key . '__' } = $config->{ $key };
    }
    return $newconfig;
}


=head2 replace_test_params

=cut

sub replace_test_params {
    my $config = shift;

    my $testconfig;
    foreach my $key ( keys %$config ) {
        if ( $key =~ /^__TEST_/ ) {
            my $newkey = $key;
            $newkey =~ s/^__TEST_/__/;
            $testconfig->{ $newkey } = $config->{ $key };
        }
    }
    # override variables with the "TEST_" variety.
    my %newconfig = ( %$config, %$testconfig );
    return %newconfig;
}

# Idea taken from perlfaq5
sub read_file {
  local(*INPUT,$/);
  open(INPUT,$_[0]) || die "Can't open $_[0] for read";
  my $file = <INPUT>;
  return $file;
}

__END__


=head1 SEE ALSO

Makefile.PL, ExtUtils::MakeMaker(3)

=head1 ACKNOWLEDGEMENTS

based on rewrite-config.PL by MJ Ray.

=head1 AUTHOR

Andrew Moore <andrew.moore@liblime.com>

=cut

