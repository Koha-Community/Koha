use Modern::Perl;
use Test::More tests => 19;

use C4::Context;
use C4::Letters qw( GetLettersAvailableForALibrary DelLetter );

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

$dbh->do(q|DELETE FROM letter|);

my $letters = [
    {
        module                 => 'circulation',
        code                   => 'code1',
        branchcode             => '',
        name                   => 'B name for code1 circ',
        is_html                => 0,
        title                  => 'default title for code1 email',
        content                => 'default content for code1 email',
        message_transport_type => 'email',
    },
    {
        module                 => 'circulation',
        code                   => 'code1',
        branchcode             => '',
        name                   => 'B name for code1 circ',
        is_html                => 0,
        title                  => 'default title for code1 sms',
        content                => 'default content for code1 sms',
        message_transport_type => 'sms',
    },
    {
        module                 => 'circulation',
        code                   => 'code2',
        branchcode             => '',
        name                   => 'A name for code2 circ',
        is_html                => 0,
        title                  => 'default title for code2 email',
        content                => 'default content for code2 email',
        message_transport_type => 'email',
    },
    {
        module                 => 'circulation',
        code                   => 'code3',
        branchcode             => '',
        name                   => 'C name for code3 circ',
        is_html                => 0,
        title                  => 'default title for code3 email',
        content                => 'default content for code3 email',
        message_transport_type => 'email',
    },

    {
        module                 => 'cataloguing',
        code                   => 'code1',
        branchcode             => '',
        name                   => 'D name for code1 cat',
        is_html                => 0,
        title                  => 'default title for code1 cat email',
        content                => 'default content for code1 cat email',
        message_transport_type => 'email',
    },

    {
        module                 => 'circulation',
        code                   => 'code1',
        branchcode             => 'CPL',
        name                   => 'B name for code1 circ',
        is_html                => 0,
        title                  => 'CPL title for code1 email',
        content                => 'CPL content for code1 email',
        message_transport_type => 'email',
    },
    {
        module                 => 'circulation',
        code                   => 'code2',
        branchcode             => 'CPL',
        name                   => 'A name for code2 circ',
        is_html                => 0,
        title                  => 'CPL title for code2 sms',
        content                => 'CPL content for code2 sms',
        message_transport_type => 'sms',
    },
    {
        module                 => 'circulation',
        code                   => 'code1',
        branchcode             => 'MPL',
        name                   => 'B name for code1 circ',
        is_html                => 0,
        title                  => 'MPL title for code1 email',
        content                => 'MPL content for code1 email',
        message_transport_type => 'email',
    },
];

my $sth = $dbh->prepare(
q|INSERT INTO letter(module, code, branchcode, name, title, content, message_transport_type) VALUES (?, ?, ?, ?, ?, ?, ?)|
);
for my $l (@$letters) {
    $sth->execute( $l->{module}, $l->{code}, $l->{branchcode}, $l->{name},
        $l->{title}, $l->{content}, $l->{message_transport_type} );

    # GetLettersAvailableForALibrary does not return these fields
    delete $l->{title};
    delete $l->{content};
    delete $l->{is_html};
    delete $l->{message_transport_type};
}

my $available_letters;
$available_letters =
  C4::Letters::GetLettersAvailableForALibrary( { module => 'circulation' } );
is( scalar(@$available_letters),
    3, 'There should be 3 default letters for circulation (3 distinct codes)' );

$available_letters = C4::Letters::GetLettersAvailableForALibrary(
    { module => 'circulation', branchcode => '' } );
is( scalar(@$available_letters), 3,
'There should be 3 default letters for circulation (3 distinct codes), branchcode=""'
);
is_deeply( $available_letters->[0],
    $letters->[2], 'The letters should be sorted by name (A)' );
is_deeply( $available_letters->[1],
    $letters->[0], 'The letters should be sorted by name (B)' );
is_deeply( $available_letters->[2],
    $letters->[3], 'The letters should be sorted by name (C)' );

$available_letters = C4::Letters::GetLettersAvailableForALibrary(
    { module => 'circulation', branchcode => 'CPL' } );
is( scalar(@$available_letters), 3,
'There should be 3 default letters for circulation (3 distinct codes), branchcode="CPL"'
);
is_deeply( $available_letters->[0],
    $letters->[6], 'The letters should be sorted by name (A)' );
is_deeply( $available_letters->[1],
    $letters->[5], 'The letters should be sorted by name (B)' );
is_deeply( $available_letters->[2],
    $letters->[3], 'The letters should be sorted by name (C)' );

$available_letters = C4::Letters::GetLettersAvailableForALibrary(
    { module => 'circulation', branchcode => 'MPL' } );
is( scalar(@$available_letters), 3,
'There should be 3 default letters for circulation (3 distinct codes), branchcode="CPL"'
);
is_deeply( $available_letters->[0],
    $letters->[2], 'The letters should be sorted by name (A)' );
is_deeply( $available_letters->[1],
    $letters->[7], 'The letters should be sorted by name (B)' );
is_deeply( $available_letters->[2],
    $letters->[3], 'The letters should be sorted by name (C)' );

my $letters_by_module = C4::Letters::GetLetters( { module => 'circulation' } );
is( scalar(@$letters_by_module),
    3, '3 different letter codes exist for circulation' );

my $letters_by_branchcode = C4::Letters::GetLetters( { branchcode => 'CPL' } );
is( scalar(@$letters_by_branchcode),
    2, '2 different letter codes exist for CPL' );

# On the way, we test DelLetter
is(
    C4::Letters::DelLetter(
        { module => 'cataloguing', code => 'code1', branchcode => 'MPL' }
    ),
    '0E0',
    'No letter exist for MPL cat/code1'
);
is(
    C4::Letters::DelLetter(
        { module => 'circulation', code => 'code1', branchcode => '' }
    ),
    2,
    '2 default letters existed for circ/code1 (1 for email and 1 for sms)'
);
is(
    C4::Letters::DelLetter(
        {
            module     => 'circulation',
            code       => 'code1',
            branchcode => 'CPL',
            mtt        => 'email'
        }
    ),
    1,
    '1 letter existed for CPL circ/code1/email'
);
is(
    C4::Letters::DelLetter(
        { module => 'circulation', code => 'code1', branchcode => 'MPL' }
    ),
    1,
    '1 letter existed for MPL circ/code1'
);
