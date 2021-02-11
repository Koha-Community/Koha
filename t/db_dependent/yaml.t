use Modern::Perl;
use Test::More;

use YAML::Syck;
use Template;
use utf8;

$YAML::Syck::ImplicitTyping = 1;
$YAML::Syck::ImplicitUnicode = 1;

my $template = Template->new( ENCODING => 'UTF-8' );

my $vars;
my $output;
$template->process( 't/db_dependent/data/syspref.pref', $vars, \$output );

use Data::Printer colored => 1; warn p $output;

my $yaml = YAML::Syck::Load( $output );
my $syspref_1 = $yaml->{Test}->{Testing}->[0];
my $syspref_2 = $yaml->{Test}->{Testing}->[1];
my $syspref_3 = $yaml->{Test}->{Testing}->[2];
my $syspref_4 = $yaml->{Test}->{Testing}->[3];
is_deeply(
    $syspref_1,
    [
        "Do it",
        {
            choices => {
                1  => "certainly",
                '' => "I don't think so"
            },
            pref => "syspref_1"
        }
    ]
);
is_deeply(
    $syspref_2,
    [
        {
            choices => {
                0    => "really don't do",
                ''   => "Do",
                dont => "Don't do"
            },
            pref => "syspref_2"
        },
        "it."
    ]
);
is_deeply(
    $syspref_3,
    [
        "We love unicode",
        {
            choices => {
                ''    => "Not really",
                '★' => "❤️"
            },
            pref => "syspref_3"
        }
    ],
);
is_deeply(
    $syspref_4,
    [
        "List of fields",
        {
            choices => {
                16    => 16,
                "020" => "020",
                123   => 123
            },
            pref => "syspref_4"
        }
    ]
);
done_testing;
