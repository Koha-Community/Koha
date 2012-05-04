package Koha::I18N;

use base qw(Locale::Maketext);

use C4::Templates;
use C4::Context;

use Locale::Maketext::Lexicon {
    'en' => ['Auto'],
    '*' => [
        Gettext =>
            C4::Context->config('intranetdir')
            . '/misc/translator/po/*-messages.po'
    ],
    '_AUTO' => 1,
};

sub get_handle_from_context {
    my ($class, $cgi, $interface) = @_;

    my $lh;
    my $lang = C4::Templates::getlanguage($cgi, $interface);
    if ($lang) {
        $lh = $class->get_handle($lang)
            or die "No language handle for '$lang'";
    } else {
        $lh = $class->get_handle()
            or die "Can't get a language handle";
    }

    return $lh;
}

1;
