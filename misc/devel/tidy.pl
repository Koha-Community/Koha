#!/usr/bin/env perl
use Modern::Perl;
use Getopt::Long;
use Pod::Usage;
use Try::Tiny;
use File::Slurp         qw( edit_file );
use IPC::System::Simple qw( capture );
use IPC::Cmd            qw( run );
use Parallel::ForkManager;

my ( $perl_files, $js_files, $tt_files, $nproc, $verbose, $help );

our $perltidyrc = '.perltidyrc';

GetOptions(
    'perl'       => \$perl_files,
    'js'         => \$js_files,
    'tt'         => \$tt_files,
    'perltidyrc' => \$perltidyrc,
    'nproc:s'    => \$nproc,
    'verbose|v'  => \$verbose,
    'help|?'     => \$help,
) or pod2usage(2);

pod2usage(1) if $help;

$nproc ||= capture q{nproc};

my @files = @ARGV;

push @files, get_perl_files() if $perl_files;
push @files, get_js_files()   if $js_files;
push @files, get_tt_files()   if $tt_files;

unless (@files) {
    push @files, get_perl_files();
    push @files, get_js_files();
    push @files, get_tt_files();
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

    say sprintf "Tidying file %s/%s (%s)", $index + 1, $nb_files, $file;
    my $error;
    my ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf ) = tidy($file);
    unless ($success) {
        $error = join( '', @$stderr_buf );
        chomp $error;
        say $error;
    }

    $pm->finish( 0, { error => $error, file => $file } );
}
$pm->wait_all_children;

if (@errors) {
    say "\nSome files cannot be tidied:";
    say sprintf( "\t* %s\n%s", $_->{file}, $_->{error} ) for @errors;
}

sub tidy {
    my ($file) = @_;

    my $filetype = get_filetype($file);

    if ( $filetype eq 'perl' ) {
        return tidy_perl($file);
    } elsif ( $filetype eq 'js' ) {
        return tidy_js($file);
    } elsif ( $filetype eq 'vue' ) {
        return tidy_vue($file);
    } elsif ( $filetype eq 'tt' ) {
        return tidy_tt($file);
    } else {
        die sprintf 'Cannot process file with filetype "%s"', $filetype;
    }
}

sub get_perl_files {
    my @files;
    push @files, capture q{git ls-files '*.pl' '*.pm' '*.t' ':(exclude)Koha/Schema/Result'};
    push @files, capture q{git ls-files svc opac/svc};                                         # Files without extension
    chomp for @files;
    return @files;
}

sub get_js_files {
    my @files = capture
        q{git ls-files '*.js' '*.ts' '*.vue' ':(exclude)koha-tmpl/intranet-tmpl/lib' ':(exclude)koha-tmpl/intranet-tmpl/js/Gettext.js' ':(exclude)koha-tmpl/opac-tmpl/lib' ':(exclude)Koha/ILL/Backend/'};
    chomp for @files;
    return @files;
}

sub get_tt_files {
    my @files = capture q{git ls-files '*.tt' '*.inc' ':(exclude)Koha/ILL/Backend/'};
    chomp for @files;
    return @files;
}

sub tidy_perl {
    my ($file) = @_;
    run(
        command => sprintf q{perltidy --backup-and-modify-in-place --nostandard-output -pro=%s %s}, $perltidyrc,
        $file
    );
}

sub tidy_js {
    my ($file) = @_;
    run( command => sprintf q{yarn --silent run prettier --trailing-comma es5 --arrow-parens avoid --write %s}, $file );
}

sub tidy_vue {
    my ($file) = @_;
    run( command => sprintf
            q{yarn --silent run prettier --trailing-comma es5 --semi false --arrow-parens avoid --write %s}, $file );
}

sub tidy_tt {
    my ($file) = @_;
    my ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf );
    for ( 1 .. 2 ) {
        ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf ) =
            run( command => sprintf q{yarn --silent run prettier --write %s}, $file );
        if ($success) {

            # Revert the substitutions done by the prettier plugin
            edit_file sub {
                s#<!--</head>-->#</head>#g;
                s#<!--<body(.*)-->#<body$1#g;
                s#<!--</body>-->#</body>#g;
            }, $file;
        }
    }
    return ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf );
}

sub get_filetype {
    my ($file) = @_;
    return 'perl' if $file =~ m{^svc} || $file =~ m{^opac/svc};
    return 'perl' if $file =~ m{\.pl$} || $file =~ m{\.pm} || $file =~ m{\.t$};

    return 'js' if $file =~ m{\.js$} || $file =~ m{\.ts$};
    return 'vue' if $file =~ m{\.vue$};

    return 'tt' if $file =~ m{\.inc$} || $file =~ m{\.tt$};

    die sprintf 'Cannot guess filetype for %s', $file;
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
   --nproc           Number of processes to use (default to all available)
   --verbose         Verbose mode (not implemented yet)
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

=head1 AUTHOR

Jonathan Druart <jonathan.druart@bugs.koha-community.org>

=cut
