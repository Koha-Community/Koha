#!/usr/bin/env perl
use Modern::Perl;
use Getopt::Long;
use Pod::Usage;
use Try::Tiny;
use Array::Utils qw( array_minus );
use File::Slurp  qw( read_file write_file );
use IPC::Cmd     qw( run );
use Parallel::ForkManager;

use Koha::Devel::Files;

my ( $perl_files, $js_files, $tt_files, $nproc, $no_write, $silent, $help );

our $perltidyrc = '.perltidyrc';

GetOptions(
    'perl'         => \$perl_files,
    'js'           => \$js_files,
    'tt'           => \$tt_files,
    'perltidyrc:s' => \$perltidyrc,
    'no-write'     => \$no_write,
    'nproc:s'      => \$nproc,
    'silent'       => \$silent,
    'help|?'       => \$help,
) or pod2usage(2);

pod2usage(1) if $help;

$nproc ||= qx{nproc};

my @files = @ARGV;

pod2usage("--no-write can only be passed with a single file") if $no_write && @files != 1;

pod2usage("--perl, --js and --tt can only be passed without any other files in parameter")
    if @files && ( $perl_files || $js_files || $tt_files );

my $dev_files = Koha::Devel::Files->new( { context => 'tidy' } );

my @original_files = @files;
if (@files) {

    # This is inefficient if the list of files is long but most of the time we will have only one
    @files = map {
        my $file     = $_;
        my $filetype = $dev_files->get_filetype($file);
        my $cmd      = sprintf q{git ls-files %s | grep %s}, $dev_files->build_git_exclude($filetype), $file;
        my $output   = qx{$cmd};
        chomp $output;
        $output ? $file : ();
    } @files;

    if ( scalar @files != scalar @original_files ) {
        my @diff = array_minus( @original_files, @files );
        for my $file (@diff) {
            my $cmd    = sprintf q{git ls-files %s}, $file;
            my $output = qx{$cmd};
            chomp $output;
            unless ($output) {
                l( sprintf "File '%s' not in the index, will be tidy anyway", $file );
                push @files, $file
                    ; # At the end of the index so the original order will be modified. This is not a feature and could be fixed later.
            }
        }
    }
} else {
    push @files, $dev_files->ls_perl_files() if $perl_files;
    push @files, $dev_files->ls_js_files()   if $js_files;
    push @files, $dev_files->ls_tt_files()   if $tt_files;

    unless (@files) {
        push @files, $dev_files->ls_perl_files();
        push @files, $dev_files->ls_js_files();
        push @files, $dev_files->ls_tt_files();
    }
}

if ( $no_write && !@files ) {

    # File should not be tidy, but we need to return the content or we risk data loss
    print read_file( $original_files[0] );
    exit;
}

my $nb_files = scalar @files;
my $pm       = Parallel::ForkManager->new($nproc);
my @errors;
$pm->run_on_finish(
    sub {
        my ( $pid, $exit_code, $ident, $exit_signal, $core_dump, $data_ref ) = @_;
        if ( defined $data_ref && $data_ref->{error} ) {
            push @errors, { error => $data_ref->{error}, file => $data_ref->{file} };
        }
    }
);

for my $index ( 0 .. $#files ) {
    my $file = $files[$index];
    $pm->start and next;

    l( sprintf "Tidying file %s/%s (%s)", $index + 1, $nb_files, $file );
    my $error;
    my ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf ) = tidy($file);
    unless ($success) {
        $error = join( '', @$stderr_buf ) || $error_message;
        chomp $error;
        warn $error;
    }

    $pm->finish( 0, { error => $error, file => $file } );
}
$pm->wait_all_children;

if (@errors) {
    l("\nSome files cannot be tidied:");
    l( sprintf( "\t* %s\n%s", $_->{file}, $_->{error} ) ) for @errors;
}

sub tidy {
    my ($file) = @_;

    my $filetype = $dev_files->get_filetype($file);

    if ( $filetype eq 'pl' ) {
        return tidy_perl($file);
    } elsif ( $filetype eq 'js' ) {
        return tidy_js($file);
    } elsif ( $filetype eq 'tt' ) {
        return tidy_tt($file);
    } else {
        die sprintf 'Cannot process file with filetype "%s"', $filetype;
    }
}

sub tidy_perl {
    my ($file) = @_;
    my $cmd =
        $no_write
        ? sprintf q{perltidy --standard-output -pro=%s %s}, $perltidyrc, $file
        : sprintf q{perltidy --backup-and-modify-in-place --nostandard-output -pro=%s %s}, $perltidyrc, $file;

    print qx{$cmd};
}

sub tidy_js {
    my ($file) = @_;
    my $cmd    = sprintf q{yarn --silent run prettier %s%s}, ( $no_write ? '' : '--write ' ), $file;
    print qx{$cmd};
}

sub tidy_tt {
    my ($original_file) = @_;
    my ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf );

    my ( $file_fh, $file );    # Keep this scope for $file_fh, or the file will be deleted after the following block
    $file_fh = File::Temp->new( CLEANUP => 1, SUFFIX => '.tt', DIR => '.' );
    $file    = $file_fh->filename;
    write_file( $file, read_file($original_file) );

    for my $pass ( 1 .. 2 ) {
        ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf ) =
            run( command => sprintf( q{yarn --silent run prettier --write %s}, $file ) );

        if ($success) {

            # Revert the substitutions done by the prettier plugin
            my $content = read_file($file);
            $content =~ s#<!--</head>-->#</head>#g;
            $content =~ s#<!--<body(.*)-->#<body$1#g;
            $content =~ s#<!--</body>-->#</body>#g;
            $content =~ s#\n*( *)<script>\n*#\n$1<script>\n#g;
            $content =~ s#\n*( *)</script>\n*#\n$1</script>\n#g;
            $content =~ s#(\[%\s*SWITCH[^\]]*\]\n)\n#$1#g;

            unless ($content) {
                return (
                    0,  "Something went wrong, Prettier generated an empty file. The original file was kept", [],
                    [], []
                );
            }
            if ( $no_write && $pass == 2 ) {
                print $content;
            } elsif ( $pass == 2 ) {
                write_file( $original_file, $content );
            } else {
                write_file( $file, $content );
            }
        }
    }
    return ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf );
}

sub l {
    say shift unless $silent;
}

=head1 NAME

tidy.pl - Tidy Perl, Javascript, Vue and Template::Toolkit files.

=head1 SYNOPSIS

tidy.pl [options] [files]

 Options:
   --perl            Tidy the Perl files (.t, .pm, .pl)
   --js              Tidy the JavaScript files (.js, .ts, .vue)
   --tt              Tidy the Template::Tolkit files (.inc, .tt)
   --perltidyrc      .perltidyrc files to use for perltidy (default: .perltidyrc)
   --no-write        Do not modify the file, output the tidy version to STDOUT
   --nproc           Number of processes to use (default to all available)
   --silent          Silent mode
   --help            Show this help message

=head1 DESCRIPTION

This script will tidy the different files present in the git repository.

If the file is an exception and should be tidy, it will be skipped.
However if only one file is passed with --no-write then the content of the file will be print to STDOUT.

=head1 EXAMPLES

Tidy everything:

  ./tidy.pl

Tidy only the Perl files:

  ./tidy.pl --perl

Tidy only the JavaScript files:

  ./tidy.pl --js

Tidy only the Template::Toolkit files:

  ./tidy.pl --tt

Tidy only some specific files:

  ./tidy.pl list of files

Output the tidy version of a file:

  ./tidy.pl --no-write /path/to/file

Output the tidy version of a file without other information:

  ./tidy.pl --silent --no-write /path/to/file

=head1 AUTHOR

Jonathan Druart <jonathan.druart@bugs.koha-community.org>

=cut
