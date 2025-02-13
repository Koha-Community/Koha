#!/usr/bin/env perl
use Modern::Perl;
use Getopt::Long;
use Pod::Usage;
use Try::Tiny;
use Array::Utils qw( array_minus );
use File::Slurp  qw( read_file write_file );
use IPC::Cmd     qw( run );
use Parallel::ForkManager;

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

pod2usage("--no-write can only be passed with a single file") if $no_write && @files > 1;

pod2usage("--perl, --js and --tt can only be passed without any other files in parameter")
    if @files && ( $perl_files || $js_files || $tt_files );

push @files, get_perl_files() if $perl_files;
push @files, get_js_files()   if $js_files;
push @files, get_tt_files()   if $tt_files;

unless (@files) {
    push @files, get_perl_files();
    push @files, get_js_files();
    push @files, get_tt_files();
}

my @exceptions = qw(
    misc/cronjobs/rss/lastAcquired.tt
    misc/cronjobs/rss/lastAcquired-1.0.tt
    misc/cronjobs/rss/lastAcquired-2.0.tt
    misc/cronjobs/rss/longestUnseen.tt
    misc/cronjobs/rss/mostReserved.tt
);

@files = array_minus( @files, @exceptions );

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

    my $filetype = get_filetype($file);

    if ( $filetype eq 'perl' ) {
        return tidy_perl($file);
    } elsif ( $filetype eq 'js' ) {
        return tidy_js($file);
    } elsif ( $filetype eq 'tt' ) {
        return tidy_tt($file);
    } else {
        die sprintf 'Cannot process file with filetype "%s"', $filetype;
    }
}

sub get_perl_files {
    my @files;
    push @files, qx{git ls-files '*.pl' '*.pm' '*.t' ':(exclude)Koha/Schema/Result'};
    push @files, qx{git ls-files svc opac/svc};                                         # Files without extension
    chomp for @files;
    return @files;
}

sub get_js_files {
    my @files =
        qx{git ls-files '*.js' '*.ts' '*.vue' ':(exclude)koha-tmpl/intranet-tmpl/lib' ':(exclude)koha-tmpl/intranet-tmpl/js/Gettext.js' ':(exclude)koha-tmpl/opac-tmpl/lib' ':(exclude)Koha/ILL/Backend/'};
    chomp for @files;
    return @files;
}

sub get_tt_files {
    my @files = qx{git ls-files '*.tt' '*.inc' ':(exclude)Koha/ILL/Backend/' ':(exclude)*doc-head-open.inc'};
    chomp for @files;
    return @files;
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
    if ($no_write) {
        $file_fh = File::Temp->new( CLEANUP => 1, SUFFIX => '.tt', DIR => '.' );
        $file    = $file_fh->filename;
        write_file( $file, read_file($original_file) );
    } else {
        $file = $original_file;
    }

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

            if ( $no_write && $pass == 2 ) {
                print $content;
            } else {
                write_file( $file, $content );
            }
        }
    }
    return ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf );
}

sub get_filetype {
    my ($file) = @_;
    return 'perl' if $file =~ m{^svc} || $file =~ m{^opac/svc};
    return 'perl' if $file =~ m{\.pl$} || $file =~ m{\.pm} || $file =~ m{\.t$};

    return 'js' if $file =~ m{\.js$} || $file =~ m{\.ts$} || $file =~ m{\.vue$};

    return 'tt' if $file =~ m{\.inc$} || $file =~ m{\.tt$};

    die sprintf 'Cannot guess filetype for %s', $file;
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
