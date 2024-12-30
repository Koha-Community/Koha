#!/usr/bin/perl
use Modern::Perl;
use Git;
use Getopt::Long;
use Data::Dumper;
my $ver;
my $instance;
GetOptions("ver=s" => \$ver, "instance=s" => \$instance);
die "Parameters -ver and -instance are both mandatory\n" unless $ver && $instance;

my $koha_home = '/usr/share/koha';
my %paths = (
    'misc' => "$koha_home/bin",
    'opac' => "$koha_home/opac/cgi-bin/opac",
    'C4' => "$koha_home/lib/C4",
    'Koha' => "$koha_home/lib/Koha",
    'koha-tmpl/opac-tmpl' => "$koha_home/opac/htdocs/opac-tmpl",
    'koha-tmpl/intranet-tmpl' => "$koha_home/intranet/htdocs/intranet-tmpl",
    'etc/zebradb' => "/etc/koha/zebradb",
    'debian/templates' => '/etc/koha',
);


my $repo = Git->repository(Directory => '/home/dbadmin/git/koha/');

my $curr_branch = $repo->command_oneline('branch', '--show-current');
die "Current branch ($curr_branch) does not seem to be descendant of version $ver\n" unless $curr_branch =~ /$ver/;
my $filename = "copy-diff-$curr_branch-$instance.sh";
open my $fh, ">", $filename;
say $fh "#!/bin/bash\n";
my @resp = $repo->command('diff', "--stat=1000", "v${ver}..HEAD");
for my $file (@resp) {
    next if $file =~ /\d+ files changed/;
    $file =~ s/^\s+//;
    $file =~ s/\s+\|\s+.*//;
    my $dest = '';
    for my $path (keys %paths) {
        if (index($file, $path) == 0) {
            $dest = $file;
            $dest =~ s/^$path/$paths{$path}/;
            last;
        }
    }
    unless ($dest) {
            $dest = $file;
            $dest =~ s@^@$koha_home/intranet/cgi-bin/@;
    }
    say $fh "cp $file $dest";
}
close $fh;
chmod 0755, $filename;
