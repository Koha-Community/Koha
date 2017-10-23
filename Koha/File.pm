package Koha::File;

use Modern::Perl;

use Fcntl;

=head1 SYNOPSIS

This package providers helper methods to work with files
Maybe even be a wrapper in Koha for working with files some day?

=cut

our @filetypes; #Save the translation table for filetypes for global access
$filetypes[Fcntl::S_IFDIR] = "d";
$filetypes[Fcntl::S_IFCHR] = "c";
$filetypes[Fcntl::S_IFBLK] = "b";
$filetypes[Fcntl::S_IFREG] = "-";
$filetypes[Fcntl::S_IFIFO] = "p";
$filetypes[Fcntl::S_IFLNK] = "l";
$filetypes[Fcntl::S_IFSOCK] = "s";

=head2 getDiagnostics

@PARAM1 String, path to a file
@RETURNS HASHRef, file properties in clear text.
         undef, if no such file found
@THROWS nothing, do not throw from here, especially not File-exceptions,
                 because this subroutine is used in File-exception diagnostics and could cause a circular recursion when no file is found.

=cut

sub getDiagnostics {
    my ($path) = @_;
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = lstat($path);
    return undef unless $dev; #No such file

    my %rv;
    $rv{user} =        getpwuid($uid);
    $rv{group} =       getgrgid($gid);
    $rv{permissions} = sprintf "%04o", Fcntl::S_IMODE($mode);
    $rv{filetype} =    $filetypes[ Fcntl::S_IFMT($mode) ];

    return \%rv;
}

our $diagnosticsStringFormat = '%s %s %s:%s';
sub getDiagnosticsString {
    my $stat = getDiagnostics(@_);
    return sprintf($diagnosticsStringFormat, $stat->{filetype}, $stat->{permissions}, $stat->{user}, $stat->{group});
}

1;
