#!/usr/bin/perl

# This file is part of Koha.
#

use Modern::Perl;
use Try::Tiny;
use Scalar::Util qw(blessed);

use Test::More;

use Koha::AtomicUpdate;



subtest "Check allowed atomicupdate file naming conventions", \&fileNamingConventions;
sub fileNamingConventions {
    my ();

    my @goodTests = (
        [ 'Bug.1234-2:Trollollollol.perl',
            'Bug', '1234', '2',   'Trollollollol',   'perl', ],
        [ 'KD-257-Mahtava_patchi.sql',
            'KD',  '257',  undef, 'Mahtava_patchi',  'sql', ],
        [ 'bug_666_lazy_Koha_man_cant_type_proper_atomicupdate_filename.sql',
            'bug', '666',  undef, 'lazy_Koha_man_cant_type_proper_atomicupdate_filename', 'sql', ],
        [ 'G-8-Banksters.pl',
            'G',   '8',    undef, 'Banksters',       'pl', ],
        [ 'B-12-6:Is_important.cpp',
            'B',   '12',   '6',   'Is_important',    'cpp', ],
    );

    my @forbiddenCharacters = (
        [ '#:445-HashTagForbidden', 'Koha::Exception::File' ],
    );

    eval {

    foreach my $t (@goodTests) {
        testName('fileName', @$t);
    }

    foreach my $t (@forbiddenCharacters) {
        my ($fileName, $exception) = @$t;
        try {
            Koha::AtomicUpdate::getFileNameElements($fileName);
            ok(0, "$fileName should have crashed with $exception");
        } catch {
            is(ref($_), $exception, "$fileName crashed with $exception");
        };
    }

    };
    ok(0, $@) if $@;
}



subtest "Check allowed atomicupdate Git title naming conventions", \&gitNamingConventions;
sub gitNamingConventions {
    my ();

    my @goodTests = (
        [ 'Bug 1234-2 : Trollollollol',
            'Bug', '1234', '2',   'Trollollollol', ],
        [ 'KD-257-Mahtava_patchi.sql',
            'KD',  '257',  undef, 'Mahtava_patchi.sql', ],
        [ 'G - 8 - Banksters:Hip.Top',
            'G',   '8',    undef, 'Banksters:Hip.Top', ],
        [ 'B -12- 6:Is_important.like.no.other',
            'B',   '12',   undef, '6:Is_important.like.no.other', ],
        [ 'HSH-12412-1: Remove any # of characters',
            'HSH', '12412', 1,   'Remove any # of characters', ],
    );

    my @forbiddenCharacters = (
        [ '#:445-HashTagForbidden', 'Koha::Exception::File' ],
        [ 'bug_666_lazy_Koha_man_cant_type_proper_atomicupdate_filename', 'Koha::Exception::Parse', ],
    );

    eval {

    foreach my $t (@goodTests) {
        testName('git', @$t);
    }

    foreach my $t (@forbiddenCharacters) {
        my ($title, $exception) = @$t;
        try {
            Koha::AtomicUpdate::getGitCommitTitleElements($title);
            ok(0, "$title should have crashed with $exception");
        } catch {
            is(ref($_), $exception, "$title crashed with $exception");
        };
    }

    };
    ok(0, $@) if $@;
}



done_testing;

###################
##  TEST HELPERS ##

sub testName {
    my ($type, $nameTitle, $e_prefix, $e_issueNumber, $e_followupNumber, $e_issueDescription, $e_fileType) = @_;

    subtest "testName($nameTitle)", sub {

    my ($prefix, $issueNumber, $followupNumber, $issueDescription, $fileType);
    ($prefix, $issueNumber, $followupNumber, $issueDescription, $fileType) =
            Koha::AtomicUpdate::getFileNameElements($nameTitle)
                if $type eq 'fileName';
    ($prefix, $issueNumber, $followupNumber, $issueDescription) =
            Koha::AtomicUpdate::getGitCommitTitleElements($nameTitle)
                if $type eq 'git';

    is($prefix, $e_prefix, 'prefix');
    is($issueNumber, $e_issueNumber, 'issue number');
    is($followupNumber, $e_followupNumber, 'followup number');
    is($issueDescription, $e_issueDescription, 'issue description');
    is($fileType, $e_fileType, 'file type') if $type eq 'fileName';

    };
}
