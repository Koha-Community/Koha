use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39418",
    description => "Adds RDA Carrier, Content, & Media Vocabularies",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Carrier terms
        my $category = 'RDACARRIER';
        my ($result) = $dbh->selectrow_array(
            q|SELECT category_name FROM authorised_value_categories WHERE category_name = ?|,
            undef, $category
        );
        if ($result) {
            say_warning( $out, "$category auth value category already exists, new values will not be inserted" );
        } else {
            $dbh->do( q|INSERT INTO authorised_value_categories (category_name) VALUES (?)|, undef, $category );
            say $out "Added new authorised value category $category";
            $dbh->do(
                qq|
                INSERT INTO authorised_values (category, authorised_value, lib, lib_opac)
                VALUES
                ('$category', 'audio cartridge', 'audio cartridge', 'audio cartridge'),
                ('$category', 'audio belt', 'audio belt', 'audio belt'),
                ('$category', 'audio cylinder', 'audio cylinder', 'audio cylinder'),
                ('$category', 'audio disc', 'audio disc', 'audio disc'),
                ('$category', 'sound track reel', 'sound track reel', 'sound track reel'),
                ('$category', 'audio roll', 'audio roll', 'audio roll'),
                ('$category', 'audio wire reel', 'audio wire reel', 'audio wire reel'),
                ('$category', 'audiocassette', 'audiocassette', 'audiocassette'),
                ('$category', 'audiotape reel', 'audiotape reel', 'audiotape reel'),
                ('$category', 'computer card', 'computer card', 'computer card'),
                ('$category', 'computer chip cartridge', 'computer chip cartridge', 'computer chip cartridge'),
                ('$category', 'computer disc', 'computer disc', 'computer disc'),
                ('$category', 'computer disc cartridge', 'computer disc cartridge', 'computer disc cartridge'),
                ('$category', 'computer tape cartridge', 'computer tape cartridge', 'computer tape cartridge'),
                ('$category', 'computer tape cassette', 'computer tape cassette', 'computer tape cassette'),
                ('$category', 'computer tape reel', 'computer tape reel', 'computer tape reel'),
                ('$category', 'online resource', 'online resource', 'online resource'),
                ('$category', 'aperture card', 'aperture card', 'aperture card'),
                ('$category', 'microfiche', 'microfiche', 'microfiche'),
                ('$category', 'microfiche cassette', 'microfiche cassette', 'microfiche cassette'),
                ('$category', 'microfilm cartridge', 'microfilm cartridge', 'microfilm cartridge'),
                ('$category', 'microfilm cassette', 'microfilm cassette', 'microfilm cassette'),
                ('$category', 'microfilm reel', 'microfilm reel', 'microfilm reel'),
                ('$category', 'microfilm roll', 'microfilm roll', 'microfilm roll'),
                ('$category', 'microfilm slip', 'microfilm slip', 'microfilm slip'),
                ('$category', 'microopaque', 'microopaque', 'microopaque'),
                ('$category', 'microscope slide', 'microscope slide', 'microscope slide'),
                ('$category', 'film cartridge', 'film cartridge', 'film cartridge'),
                ('$category', 'film cassette', 'film cassette', 'film cassette'),
                ('$category', 'film reel', 'film reel', 'film reel'),
                ('$category', 'film roll', 'film roll', 'film roll'),
                ('$category', 'filmslip', 'filmslip', 'filmslip'),
                ('$category', 'filmstrip', 'filmstrip', 'filmstrip'),
                ('$category', 'filmstrip cartridge', 'filmstrip cartridge', 'filmstrip cartridge'),
                ('$category', 'overhead transparency', 'overhead transparency', 'overhead transparency'),
                ('$category', 'slide', 'slide', 'slide'),
                ('$category', 'stereograph card', 'stereograph card', 'stereograph card'),
                ('$category', 'stereograph disc', 'stereograph disc', 'stereograph disc'),
                ('$category', 'card', 'card', 'card'),
                ('$category', 'flipchart', 'flipchart', 'flipchart'),
                ('$category', 'roll', 'roll', 'roll'),
                ('$category', 'sheet', 'sheet', 'sheet'),
                ('$category', 'volume', 'volume', 'volume'),
                ('$category', 'object', 'object', 'object'),
                ('$category', 'video cartridge', 'video cartridge', 'video cartridge'),
                ('$category', 'videocassette', 'videocassette', 'videocassette'),
                ('$category', 'videodisc', 'videodisc', 'videodisc'),
                ('$category', 'videotape reel', 'videotape reel', 'videotape reel'),
                ('$category', 'unspecified', 'unspecified', 'unspecified'),
                ('$category', 'other', 'other', 'other')
            |
            );
            say $out "Added new authorised values for $category category";
        }

        # Carrier codes
        $category = 'RDACARRIER_CODE';
        ($result) = $dbh->selectrow_array(
            q|SELECT category_name FROM authorised_value_categories WHERE category_name = ?|,
            undef, $category
        );
        if ($result) {
            say_warning( $out, "$category auth value category already exists, new values will not be inserted" );
        } else {
            $dbh->do( q|INSERT INTO authorised_value_categories (category_name) VALUES (?)|, undef, $category );
            say $out "Added new authorised value category $category";
            $dbh->do(
                qq|
                INSERT INTO authorised_values(category, authorised_value, lib, lib_opac)
                VALUES
                ('$category', 'sg', 'audio cartridge', 'audio cartridge'),
                ('$category', 'sb', 'audio belt', 'audio belt'),
                ('$category', 'se', 'audio cylinder', 'audio cylinder'),
                ('$category', 'sd', 'audio disc', 'audio disc'),
                ('$category', 'si', 'sound track reel', 'sound track reel'),
                ('$category', 'sq', 'audio roll', 'audio roll'),
                ('$category', 'sw', 'audio wire reel', 'audio wire reel'),
                ('$category', 'ss', 'audiocassette', 'audiocassette'),
                ('$category', 'st', 'audiotape reel', 'audiotape reel'),
                ('$category', 'sz', 'other (audio)', 'other (audio)'),
                ('$category', 'ck', 'computer card', 'computer card'),
                ('$category', 'cb', 'computer chip cartridge', 'computer chip cartridge'),
                ('$category', 'cd', 'computer disc', 'computer disc'),
                ('$category', 'ce', 'computer disc cartridge', 'computer disc cartridge'),
                ('$category', 'ca', 'computer tape cartridge', 'computer tape cartridge'),
                ('$category', 'cf', 'computer tape cassette', 'computer tape cassette'),
                ('$category', 'ch', 'computer tape reel', 'computer tape reel'),
                ('$category', 'cr', 'online resource', 'online resource'),
                ('$category', 'cz', 'other (computer)', 'other (computer)'),
                ('$category', 'ha', 'aperture card', 'aperture card'),
                ('$category', 'he', 'microfiche', 'microfiche'),
                ('$category', 'hf', 'microfiche cassette', 'microfiche cassette'),
                ('$category', 'hb', 'microfilm cartridge', 'microfilm cartridge'),
                ('$category', 'hc', 'microfilm cassette', 'microfilm cassette'),
                ('$category', 'hd', 'microfilm reel', 'microfilm reel'),
                ('$category', 'hj', 'microfilm roll', 'microfilm roll'),
                ('$category', 'hh', 'microfilm slip', 'microfilm slip'),
                ('$category', 'hg', 'microopaque', 'microopaque'),
                ('$category', 'hz', 'other (microform)', 'other (microform)'),
                ('$category', 'pp', 'microscope slide', 'microscope slide'),
                ('$category', 'pz', 'other (microscopic)', 'other (microscopic)'),
                ('$category', 'mc', 'film cartridge', 'film cartridge'),
                ('$category', 'mf', 'film cassette', 'film cassette'),
                ('$category', 'mr', 'film reel', 'film reel'),
                ('$category', 'mo', 'film roll', 'film roll'),
                ('$category', 'gd', 'filmslip', 'filmslip'),
                ('$category', 'gf', 'filmstrip', 'filmstrip'),
                ('$category', 'gc', 'filmstrip cartridge', 'filmstrip cartridge'),
                ('$category', 'gt', 'overhead transparency', 'overhead transparency'),
                ('$category', 'gs', 'slide', 'slide'),
                ('$category', 'mz', 'other (projected image)', 'other (projected image)'),
                ('$category', 'eh', 'stereograph card', 'stereograph card'),
                ('$category', 'es', 'stereograph disc', 'stereograph disc'),
                ('$category', 'ez', 'other (stereographic carriers)', 'other (stereographic carriers)'),
                ('$category', 'no', 'card', 'card'),
                ('$category', 'nn', 'flipchart', 'flipchart'),
                ('$category', 'na', 'roll', 'roll'),
                ('$category', 'nb', 'sheet', 'sheet'),
                ('$category', 'nc', 'volume', 'volume'),
                ('$category', 'nr', 'object', 'object'),
                ('$category', 'nz', 'other (unmediated)', 'other (unmediated)'),
                ('$category', 'vc', 'video cartridge', 'video cartridge'),
                ('$category', 'vf', 'videocassette', 'videocassette'),
                ('$category', 'vd', 'videodisc', 'videodisc'),
                ('$category', 'vr', 'videotape reel', 'videotape reel'),
                ('$category', 'vz', 'other (video)', 'other (video)'),
                ('$category', 'zu', 'unspecified', 'unspecified')
            |
            );
            say $out "Added new authorised values for $category category";
        }

        # Content terms
        $category = 'RDACONTENT';
        ($result) = $dbh->selectrow_array(
            q|SELECT category_name FROM authorised_value_categories WHERE category_name = ?|,
            undef, $category
        );
        if ($result) {
            say_warning( $out, "$category auth value category already exists, new values will not be inserted" );
        } else {
            $dbh->do( q|INSERT INTO authorised_value_categories (category_name) VALUES (?)|, undef, $category );
            say $out "Added new authorised value category $category";
            $dbh->do(
                qq|
                INSERT INTO authorised_values (category, authorised_value, lib, lib_opac)
                VALUES
                ('$category', 'cartographic dataset', 'cartographic dataset', 'cartographic dataset'),
                ('$category', 'cartographic image', 'cartographic image', 'cartographic image'),
                ('$category', 'cartographic moving image', 'cartographic moving image', 'cartographic moving image'),
                ('$category', 'cartographic tactile image', 'cartographic tactile image', 'cartographic tactile image'),
                ('$category', 'cartographic tactile three-dimensional form', 'cartographic tactile three-dimensional form', 'cartographic tactile three-dimensional form'),
                ('$category', 'cartographic three-dimensional form', 'cartographic three-dimensional form', 'cartographic three-dimensional form'),
                ('$category', 'computer dataset', 'computer dataset', 'computer dataset'),
                ('$category', 'computer program', 'computer program', 'computer program'),
                ('$category', 'notated movement', 'notated movement', 'notated movement'),
                ('$category', 'notated music', 'notated music', 'notated music'),
                ('$category', 'performed music', 'performed music', 'performed music'),
                ('$category', 'sounds', 'sounds', 'sounds'),
                ('$category', 'spoken word', 'spoken word', 'spoken word'),
                ('$category', 'still image', 'still image', 'still image'),
                ('$category', 'tactile image', 'tactile image', 'tactile image'),
                ('$category', 'tactile notated music', 'tactile notated music', 'tactile notated music'),
                ('$category', 'tactile notated movement', 'tactile notated movement', 'tactile notated movement'),
                ('$category', 'tactile text', 'tactile text', 'tactile text'),
                ('$category', 'tactile three-dimensional form', 'tactile three-dimensional form', 'tactile three-dimensional form'),
                ('$category', 'text', 'text', 'text'),
                ('$category', 'three-dimensional form', 'three-dimensional form', 'three-dimensional form'),
                ('$category', 'three-dimensional moving image', 'three-dimensional moving image', 'three-dimensional moving image'),
                ('$category', 'two-dimensional moving image', 'two-dimensional moving image', 'two-dimensional moving image'),
                ('$category', 'other', 'other', 'other'),
                ('$category', 'unspecified', 'unspecified', 'unspecified')
            |
            );
            say $out "Added new authorised values for $category category";
        }

        # Content codes
        $category = 'RDACONTENT_CODE';
        ($result) = $dbh->selectrow_array(
            q|SELECT category_name FROM authorised_value_categories WHERE category_name = ?|,
            undef, $category
        );
        if ($result) {
            say_warning( $out, "$category auth value category already exists, new values will not be inserted" );
        } else {
            $dbh->do( q|INSERT INTO authorised_value_categories (category_name) VALUES (?)|, undef, $category );
            say $out "Added new authorised value category $category";
            $dbh->do(
                qq|
                INSERT INTO authorised_values (category, authorised_value, lib, lib_opac)
                VALUES
                ('$category', 'crd', 'cartographic dataset', 'cartographic dataset'),
                ('$category', 'cri', 'cartographic image', 'cartographic image'),
                ('$category', 'crm', 'cartographic moving image', 'cartographic moving image'),
                ('$category', 'crt', 'cartographic tactile image', 'cartographic tactile image'),
                ('$category', 'crn', 'cartographic tactile three-dimensional form', 'cartographic tactile three-dimensional form'),
                ('$category', 'crf', 'cartographic three-dimensional form', 'cartographic three-dimensional form'),
                ('$category', 'cod', 'computer dataset', 'computer dataset'),
                ('$category', 'cop', 'computer program', 'computer program'),
                ('$category', 'ntv', 'notated movement', 'notated movement'),
                ('$category', 'ntm', 'notated music', 'notated music'),
                ('$category', 'prm', 'performed music', 'performed music'),
                ('$category', 'snd', 'sounds', 'sounds'),
                ('$category', 'spw', 'spoken word', 'spoken word'),
                ('$category', 'sti', 'still image', 'still image'),
                ('$category', 'tci', 'tactile image', 'tactile image'),
                ('$category', 'tcm', 'tactile notated music', 'tactile notated music'),
                ('$category', 'tcn', 'tactile notated movement', 'tactile notated movement'),
                ('$category', 'tct', 'tactile text', 'tactile text'),
                ('$category', 'tcf', 'tactile three-dimensional form', 'tactile three-dimensional form'),
                ('$category', 'txt', 'text', 'text'),
                ('$category', 'tdf', 'three-dimensional form', 'three-dimensional form'),
                ('$category', 'tdm', 'three-dimensional moving image', 'three-dimensional moving image'),
                ('$category', 'tdi', 'two-dimensional moving image', 'two-dimensional moving image'),
                ('$category', 'xxx', 'other', 'other'),
                ('$category', 'zzz', 'unspecified', 'unspecified')
            |
            );
            say $out "Added new authorised values for $category category";
        }

        # Media terms
        $category = 'RDAMEDIA';
        ($result) = $dbh->selectrow_array(
            q|SELECT category_name FROM authorised_value_categories WHERE category_name = ?|,
            undef, $category
        );
        if ($result) {
            say_warning( $out, "$category auth value category already exists, new values will not be inserted" );
        } else {
            $dbh->do( q|INSERT INTO authorised_value_categories (category_name) VALUES (?)|, undef, $category );
            say $out "Added new authorised value category $category";
            $dbh->do(
                qq|
                INSERT INTO authorised_values (category, authorised_value, lib, lib_opac)
                VALUES
                ('$category', 'audio', 'audio', 'audio'),
                ('$category', 'computer', 'computer', 'computer'),
                ('$category', 'microform', 'microform', 'microform'),
                ('$category', 'microscopic', 'microscopic', 'microscopic'),
                ('$category', 'projected', 'projected', 'projected'),
                ('$category', 'stereographic', 'stereographic', 'stereographic'),
                ('$category', 'unmediated', 'unmediated', 'unmediated'),
                ('$category', 'video', 'video', 'video'),
                ('$category', 'other', 'other', 'other'),
                ('$category', 'unspecified', 'unspecified', 'unspecified')
            |
            );
            say $out "Added new authorised values for $category category";
        }

        # Media codes
        $category = 'RDAMEDIA_CODE';
        ($result) = $dbh->selectrow_array(
            q|SELECT category_name FROM authorised_value_categories WHERE category_name = ?|,
            undef, $category
        );
        if ($result) {
            say_warning( $out, "$category auth value category already exists, new values will not be inserted" );
        } else {
            $dbh->do( q|INSERT INTO authorised_value_categories (category_name) VALUES (?)|, undef, $category );
            say $out "Added new authorised value category $category";
            $dbh->do(
                qq|
                INSERT INTO authorised_values (category, authorised_value, lib, lib_opac)
                VALUES
                ('$category', 's', 'audio', 'audio'),
                ('$category', 'c', 'computer', 'computer'),
                ('$category', 'h', 'microform', 'microform'),
                ('$category', 'p', 'microscopic', 'microscopic'),
                ('$category', 'g', 'projected', 'projected'),
                ('$category', 'e', 'stereographic', 'stereographic'),
                ('$category', 'n', 'unmediated', 'unmediated'),
                ('$category', 'v', 'video', 'video'),
                ('$category', 'x', 'other', 'other'),
                ('$category', 'z', 'unspecified', 'unspecified')
            |
            );
            say $out "Added new authorised values for $category category";
        }

        say_success( $out, "Successfully added authorised values for RDA Carrier, Content, & Media vocabularies." );
    },
};
