package Koha::Devel::Files;

use Modern::Perl;
our ( @ISA, @EXPORT_OK );

=head1 NAME

Koha::Devel::Files - A utility module for managing and filtering file lists in the Koha codebase

=head1 SYNOPSIS

    use Koha::Devel::Files;

    my $file_manager = Koha::Devel::Files->new({ context => 'tidy' });

    my @perl_files = $file_manager->ls_perl_files($git_range);
    my @js_files   = $file_manager->ls_js_files();
    my @tt_files   = $file_manager->ls_tt_files();

    my $filetype = $file_manager->get_filetype($filename);

=head1 DESCRIPTION

Koha::Devel::Files is a utility module designed to assist in managing and filtering lists of files in the Koha codebase. It provides methods to list Perl, JavaScript, and Template Toolkit files, with options to exclude specific files based on a given context.

=head1 EXCEPTIONS

The module defines a set of exceptions for different file types and contexts. These exceptions are used to exclude specific files or directories from the file listings.

=cut

my $exceptions = {
    pl => {
        tidy => [
            qw(
                Koha/Schema/Result
                Koha/Schema.pm
            )
        ],
        valid => [
            qw(
                Koha/Account/Credit.pm
                Koha/Account/Debit.pm
                Koha/Old/Hold.pm
                misc/translator/TmplTokenizer.pm
            )
        ],
        codespell => [
            qw(
                installer/data/mysql/updatedatabase.pl
                installer/data/mysql/update22to30.pl
                installer/data/mysql/db_revs/241200035.pl
                misc/cronjobs/build_browser_and_cloud.pl
            )
        ],
    },
    js => {
        tidy => [
            qw(
                koha-tmpl/intranet-tmpl/lib
                koha-tmpl/intranet-tmpl/js/Gettext.js
                koha-tmpl/opac-tmpl/lib
                Koha/ILL/Backend/
            )
        ],
        codespell => [
            qw(
                koha-tmpl/intranet-tmpl/lib
                koha-tmpl/intranet-tmpl/js/Gettext.js
                koha-tmpl/opac-tmpl/lib
                koha-tmpl/opac-tmpl/bootstrap/js/Gettext.js
            )
        ],
    },
    tt => {
        tidy => [
            qw(
                Koha/ILL/Backend/
                *doc-head-open.inc
                misc/cronjobs/rss
            )
        ],
        codespell => [],
    },
};

=head1 METHODS

=cut

=head2 new

    my $file_manager = Koha::Devel::Files->new({ context => 'tidy' });

Creates a new instance of Koha::Devel::Files. The constructor accepts a hash reference with a 'context' key, which specifies the context for file exclusions.

=cut

sub new {
    my ( $class, $args ) = @_;
    my $self = { context => $args->{context} };
    bless $self, $class;
    return $self;
}

=head2 build_git_exclude

    my $exclude_pattern = $file_manager->build_git_exclude($filetype);

Builds a Git exclude pattern for a given file type based on the context provided during object creation.

=cut

sub build_git_exclude {
    my ( $self, $filetype ) = @_;
    return $self->{context} && exists $exceptions->{$filetype}->{ $self->{context} }
        ? join( " ", map( "':(exclude)$_'", @{ $exceptions->{$filetype}->{ $self->{context} } } ) )
        : q{};
}

=head2 ls_perl_files

    my @perl_files = $file_manager->ls_perl_files($git_range);

Lists Perl files (with extensions .pl, .PL, .pm, .t) that have been modified within a specified Git range. If no range is provided, it lists all Perl files, excluding those specified in the exceptions.

=cut

sub ls_perl_files {
    my ($self) = @_;
    my $cmd = sprintf q{git ls-files '*.pl' '*.PL' '*.pm' '*.t' svc opac/svc debian/build-git-snapshot %s},
        $self->build_git_exclude('pl');
    my @files = qx{$cmd};
    chomp for @files;
    return @files;
}

=head2 ls_js_files

    my @js_files = $file_manager->ls_js_files();

Lists JavaScript and TypeScript files (with extensions .js, .ts, .vue) in the repository, excluding those specified in the exceptions.

=cut

sub ls_js_files {
    my ($self) = @_;
    my $cmd    = sprintf q{git ls-files '*.js' '*.ts' '*.vue' %s}, $self->build_git_exclude('js');
    my @files  = qx{$cmd};
    chomp for @files;
    return @files;
}

=head2 ls_tt_files

    my @tt_files = $file_manager->ls_tt_files();

Lists Template Toolkit files (with extensions .tt, .inc) in the repository, excluding those specified in the exceptions.

=cut

sub ls_tt_files {
    my ($self) = @_;
    my $cmd    = sprintf q{git ls-files '*.tt' '*.inc' %s}, $self->build_git_exclude('tt');
    my @files  = qx{$cmd};
    chomp for @files;
    return @files;
}

=head2 get_filetype

    my $filetype = $file_manager->get_filetype($filename);

Determines the file type of a given file based on its extension or path. Returns 'pl' for Perl files, 'js' for JavaScript/TypeScript files, and 'tt' for Template Toolkit files. Dies with an error message if the file type cannot be determined.

=cut

sub get_filetype {
    my ( $self, $file ) = @_;
    return 'pl' if $file =~ m{^svc}  || $file =~ m{^opac/svc};
    return 'pl' if $file =~ m{\.pl$} || $file =~ m{\.pm} || $file =~ m{\.t$};
    return 'pl' if $file =~ m{\.PL$};
    return 'pl' if $file =~ m{debian/build-git-snapshot};

    return 'js' if $file =~ m{\.js$} || $file =~ m{\.ts$} || $file =~ m{\.vue$};

    return 'tt' if $file =~ m{\.inc$} || $file =~ m{\.tt$};

    die sprintf 'Cannot guess filetype for %s', $file;
}

1;
