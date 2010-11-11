#!/usr/bin/perl
#
# Tests usage of deprecated Perl syntax. Deprecated could be extended to the
# sense of 'not allowed'.
#
use warnings;
use strict;
use Test::More tests => 1;
use File::Find;
use Cwd;

my @files_with_switch = do {
    my @files;
    local $/ = undef;
    find( sub {
        my $dir = getcwd();
        return if $dir =~ /blib/;
        return unless /\.(pl|pm)$/; # Don't inspect non-Perl files
        open my $fh, "<", $_;
        my $content = <$fh>;
        push @files, "$dir/$_"  if $content =~ /switch\s*\(.*{/;
      }, ( '.' ) );
    @files;
};
ok( !@files_with_switch, "Perl syntax: no use of switch statement" )
    or diag( "Files list: " . join(', ', @files_with_switch) );

