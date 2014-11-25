use Modern::Perl;
use Test::More tests => 7;

use C4::Context;
use C4::Letters qw( GetLetterTemplates );

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

$dbh->do(q|DELETE FROM letter|);

my $letters = [
    {
        module                 => 'circulation',
        code                   => 'code1',
        branchcode             => '',
        name                   => 'B default name for code1 circ',
        is_html                => 0,
        title                  => 'default title for code1 email',
        content                => 'default content for code1 email',
        message_transport_type => 'email',
    },
    {
        module                 => 'circulation',
        code                   => 'code1',
        branchcode             => '',
        name                   => 'B default name for code1 circ',
        is_html                => 0,
        title                  => 'default title for code1 sms',
        content                => 'default content for code1 sms',
        message_transport_type => 'sms',
    },
    {
        module                 => 'circulation',
        code                   => 'code2',
        branchcode             => '',
        name                   => 'A default name for code2 circ',
        is_html                => 0,
        title                  => 'default title for code2 email',
        content                => 'default content for code2 email',
        message_transport_type => 'email',
    },
    {
        module                 => 'circulation',
        code                   => 'code3',
        branchcode             => '',
        name                   => 'C default name for code3 circ',
        is_html                => 0,
        title                  => 'default title for code3 email',
        content                => 'default content for code3 email',
        message_transport_type => 'email',
    },

    {
        module                 => 'cataloguing',
        code                   => 'code1',
        branchcode             => '',
        name                   => 'default name for code1 cat',
        is_html                => 0,
        title                  => 'default title for code1 cat email',
        content                => 'default content for code1 cat email',
        message_transport_type => 'email',
    },

    {
        module                 => 'circulation',
        code                   => 'code1',
        branchcode             => 'CPL',
        name                   => 'B CPL name for code1 circ',
        is_html                => 0,
        title                  => 'CPL title for code1 email',
        content                => 'CPL content for code1 email',
        message_transport_type => 'email',
    },
    {
        module                 => 'circulation',
        code                   => 'code2',
        branchcode             => 'CPL',
        name                   => 'A CPL name for code1 circ',
        is_html                => 0,
        title                  => 'CPL title for code1 sms',
        content                => 'CPL content for code1 sms',
        message_transport_type => 'sms',
    },
    {
        module                 => 'circulation',
        code                   => 'code1',
        branchcode             => 'MPL',
        name                   => 'B MPL name for code1 circ',
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
}

my $letter_templates;
$letter_templates = C4::Letters::GetLetterTemplates;
is_deeply( $letter_templates, {},
    'GetLetterTemplates should not return templates if not param is given' );

$letter_templates = C4::Letters::GetLetterTemplates(
    { module => 'circulation', code => 'code1', branchcode => '' } );
is( scalar( keys %$letter_templates ),
    2, '2 default templates should exist for circulation code1' );
is( exists( $letter_templates->{email} ),
    1, 'The mtt email should exist for circulation code1' );
is( exists( $letter_templates->{sms} ),
    1, 'The mtt sms should exist for circulation code1' );

$letter_templates = C4::Letters::GetLetterTemplates(
    { module => 'circulation', code => 'code1', branchcode => 'CPL' } );
is( scalar( keys %$letter_templates ),
    1, '1 template should exist for circulation CPL code1' );
is( exists( $letter_templates->{email} ),
    1, 'The mtt should be email for circulation CPL code1' );

$letter_templates = C4::Letters::GetLetterTemplates(
    { module => 'circulation', code => 'code1' } );
is( scalar( keys %$letter_templates ),
    2, '2 default templates should exist for circulation code1 (even if branchcode is not given)' );
