package Koha::CodeList::Unimarc::MediumOfPerformance;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use utf8;

use Koha::I18N;

use parent 'Exporter';
our @EXPORT = qw(
    brass
    choruses
    conductors
    electronic
    keyboard
    misc
    number_of_hands_or_keys
    orchestras
    other
    other_performers
    other2
    percussion
    strings_bowed
    strings_plucked
    tessitura
    voices
    woodwinds
);

sub voices {
    return {
        'val' => N__('alto'),
        'vbr' => N__('baritone'),
        'vbs' => N__('bass'),
        'vca' => N__('child alto'),
        'vcs' => N__('child soprano'),
        'vct' => N__('countertenor'),
        'vcv' => N__('child voice'),
        'vma' => N__('man\'s voice'),
        'vms' => N__('mezzo-soprano'),
        'vrc' => N__('reciting child\'s voice'),
        'vre' => N__('reciting voice'),
        'vrm' => N__('reciting man\'s voice'),
        'vrw' => N__('reciting woman\'s voice'),
        'vso' => N__('soprano'),
        'vte' => N__('tenor'),
        'vun' => N__('voice - unspecified'),
        'vwo' => N__('woman\'s voice'),
        'vzz' => N__('voice - other'),
    };
}

sub woodwinds {
    return {
        'wba' => N__('bassoon'),
        'wbh' => N__('basset-horn'),
        'wbp' => N__('bagpipe'),
        'wcl' => N__('clarinet'),
        'wcr' => N__('cromorne'),
        'wdb' => N__('double bassoon'),
        'wdi' => N__('didjeridu'),
        'wdu' => N__('dulcian'),
        'wdv' => N__('dvojnice'),
        'weh' => N__('english horn'),
        'wfg' => N__('flageolet'),
        'wfi' => N__('fife'),
        'wfl' => N__('flute'),
        'wga' => N__('tabor pipe'),
        'wge' => N__('gemshorn'),
        'whp' => N__('hornpipe'),
        'wmo' => N__('mouth organ'),
        'wmu' => N__('musette'),
        'wna' => N__('ney'),
        'woa' => N__('oboe d\'amore'),
        'wob' => N__('oboe'),
        'woh' => N__('oboe da caccia'),
        'wpi' => N__('piccolo'),
        'wpo' => N__('pommer'),
        'wpp' => N__('panpipes'),
        'wra' => N__('racket'),
        'wre' => N__('recorder'),
        'wro' => N__('rothophone'),
        'wsa' => N__('saxophone'),
        'wsh' => N__('shakuhachi'),
        'wsn' => N__('zurna'),
        'wsr' => N__('sarrusophone'),
        'wsu' => N__('sordun'),
        'wun' => N__('woodwind - unspecified'),
        'wvu' => N__('vox humana'),
        'wzz' => N__('woodwind - other'),
    };
}

sub brass {
    return {
        'bah' => N__('alphorn'),
        'bbd' => N__('bombardon'),
        'bbh' => N__('bersag horn'),
        'bbu' => N__('bugle'),
        'bca' => N__('carnyx'),
        'bch' => N__('cow horn'),
        'bcl' => N__('clarion'),
        'bco' => N__('cornet'),
        'bct' => N__('cornett'),
        'bdx' => N__('duplex'),
        'beu' => N__('euphonium'),
        'bhh' => N__('hunting horn'),
        'bho' => N__('horn'),
        'bht' => N__('herald\'s trumpet'),
        'bkb' => N__('keyed bugle'),
        'bol' => N__('oliphant'),
        'bop' => N__('ophicleide'),
        'bph' => N__('post horn'),
        'brh' => N__('russian horn'),
        'bse' => N__('serpent'),
        'bsh' => N__('shofar'),
        'bsr' => N__('sarrusophone'),
        'btb' => N__('trombone'),
        'btr' => N__('trumpet'),
        'btu' => N__('tuba'),
        'bun' => N__('brass - unspecified'),
        'bvb' => N__('valved bugle'),
        'bwt' => N__('wagner tuba'),
        'bzz' => N__('brass - other'),
    };
}

sub strings_bowed {
    return {
        'sar' => N__('arpeggione'),
        'sba' => N__('baryton'),
        'sbt' => N__('bassett'),
        'sbu' => N__('bumbass'),
        'scr' => N__('crwth'),
        'sdb' => N__('double bass'),
        'sdf' => N__('five-string double bass'),
        'sfi' => N__('fiddle, viol (family)'),
        'sli' => N__('lira da braccio'),
        'sln' => N__('lirone'),
        'sny' => N__('keyed fiddle'),
        'sob' => N__('octobass'),
        'spo' => N__('kit'),
        'sps' => N__('psalmodicon'),
        'sre' => N__('rebec'),
        'stm' => N__('trumpet marine'),
        'sun' => N__('strings, bowed - unspecified'),
        'sva' => N__('viola'),
        'svc' => N__('cello'),
        'sve' => N__('violone'),
        'svg' => N__('viol'),
        'svl' => N__('violin'),
        'szz' => N__('strings, bowed - other'),
    };
}

sub strings_plucked {
    return {
        'tal' => N__('archlute'),
        'tat' => N__('harp-psaltery'),
        'tbb' => N__('barbitos'),
        'tbi' => N__('biwa'),
        'tbj' => N__('banjo'),
        'tbl' => N__('balalaika'),
        'tbo' => N__('bouzouki'),
        'tci' => N__('cittern'),
        'tct' => N__('citole'),
        'tcz' => N__('cobza'),
        'tgu' => N__('guitar'),
        'tha' => N__('harp'),
        'thg' => N__('hawaiian guitar'),
        'tih' => N__('Irish harp'),
        'tkh' => N__('kithara'),
        'tko' => N__('kora'),
        'tkt' => N__('koto'),
        'tlf' => N__('lute (family)'),
        'tlg' => N__('lyre-guitar'),
        'tlu' => N__('lute'),
        'tma' => N__('mandolin'),
        'tmd' => N__('mandore'),
        'tpi' => N__('pipa'),
        'tps' => N__('psaltery'),
        'tpx' => N__('phorminx'),
        'tqa' => N__('qānūn'),
        'tsh' => N__('shamisen'),
        'tsi' => N__('sitār'),
        'tth' => N__('theorbo'),
        'ttn' => N__('tanbur'),
        'tud' => N__('oud'),
        'tuk' => N__('ukulele'),
        'tun' => N__('strings, plucked - unspecified'),
        'tzi' => N__('zither'),
        'tzz' => N__('strings, plucked - other'),
    };
}

sub keyboard {
    return {
        'kac' => N__('accordion'),
        'kce' => N__('celesta'),
        'kcl' => N__('clavichord'),
        'kco' => N__('claviorgan'),
        'kcy' => N__('clavicytherium'),
        'kfp' => N__('fortepiano'),
        'kgl' => N__('glockenspiel'),
        'khm' => N__('harmonium'),
        'khp' => N__('harpsichord'),
        'kmp' => N__('melopiano'),
        'kor' => N__('organ'),
        'kpf' => N__('piano'),
        'kps' => N__('plucked string keyboard'),
        'kre' => N__('regals'),
        'ksi' => N__('sirenion'),
        'ksp' => N__('sostenente piano'),
        'kst' => N__('spinet'),
        'kun' => N__('keyboard - unspecified'),
        'kvg' => N__('virginal'),
        'kzz' => N__('keyboard - other'),
    };
}

sub percussion {
    return {
        'pab' => N__('aeolian bells'),
        'pad' => N__('arabian drum'),
        'pag' => N__('agogo'),
        'pan' => N__('anvil'),
        'pbb' => N__('boobams'),
        'pbd' => N__('bass drum'),
        'pbl' => N__('bells'),
        'pbo' => N__('bongos'),
        'pbp' => N__('metal bells plate'),
        'pca' => N__('castanets'),
        'pcb' => N__('cabaca'),
        'pcc' => N__('chinese cymbals'),
        'pcg' => N__('conga'),
        'pch' => N__('chains'),
        'pci' => N__('dulcimer'),
        'pcr' => N__('crash cymbal'),
        'pct' => N__('crotales'),
        'pcv' => N__('claves'),
        'pcw' => N__('cowbell'),
        'pcy' => N__('cymbal'),
        'pdr' => N__('drum'),
        'pds' => N__('drums'),
        'pfc' => N__('finger cymbals'),
        'pfd' => N__('friction drum'),
        'pfl' => N__('flexatone'),
        'pgn' => N__('gun'),
        'pgo' => N__('gong'),
        'pgu' => N__('güiro'),
        'pha' => N__('hammer'),
        'phb' => N__('handbell'),
        'phh' => N__('hi-hat'),
        'pje' => N__('jembe'),
        'pji' => N__('jingles'),
        'pli' => N__('lithophone'),
        'plj' => N__('lujon'),
        'pmb' => N__('marimba'),
        'pmd' => N__('military drum'),
        'pme' => N__('metallophone'),
        'pnv' => N__('nail violin'),
        'pra' => N__('ratchet'),
        'prs' => N__('rain stick'),
        'prt' => N__('roto-toms'),
        'psc' => N__('sizzle cymbals'),
        'pse' => N__('sound-effect instrument'),
        'psl' => N__('slit-drum'),
        'psm' => N__('sistrum'),
        'psn' => N__('siren'),
        'psp' => N__('sandpaper'),
        'pss' => N__('sound sculpture'),
        'pst' => N__('steel drum'),
        'psw' => N__('switch whip'),
        'ptb' => N__('tabor'),
        'ptc' => N__('turkish crescent'),
        'pte' => N__('temple block'),
        'ptg' => N__('tuned gong'),
        'pti' => N__('timpani'),
        'ptl' => N__('triangle'),
        'ptm' => N__('thunder machine'),
        'pto' => N__('tarol'),
        'ptr' => N__('tambourine'),
        'ptt' => N__('tom-tom'),
        'pun' => N__('percussion - unspecified'),
        'pvi' => N__('vibraphone'),
        'pvs' => N__('vibra-slap'),
        'pwh' => N__('whip'),
        'pwm' => N__('wind machine'),
        'pwo' => N__('woodblocks'),
        'pxr' => N__('xylorimba'),
        'pxy' => N__('xylophone'),
        'pzz' => N__('percussion - other'),
    };
}

sub electronic {
    return {
        'eco' => N__('computer'),
        'ecs' => N__('computerized musical station'),
        'ect' => N__('computerized tape'),
        'eds' => N__('digital space device'),
        'eea' => N__('electro-acoustic device'),
        'eli' => N__('live electronic'),
        'ely' => N__('lyricon'),
        'eme' => N__('meta-instrument'),
        'emu' => N__('multimedial device'),
        'eos' => N__('oscillator'),
        'esp' => N__('space device'),
        'esy' => N__('synthesizer'),
        'eta' => N__('tape'),
        'eth' => N__('theremin'),
        'eun' => N__('electronic - non specified'),
        'ezz' => N__('electronic - other'),
    };
}

sub misc {
    return {
        'mah' => N__('aeolian harp'),
        'mbo' => N__('barrel organ'),
        'mbr' => N__('bullroarer'),
        'mbs' => N__('bass'),
        'mbw' => N__('musical bow'),
        'mbx' => N__('musical box'),
        'mck' => N__('chekker'),
        'mcl' => N__('musical clock'),
        'mco' => N__('continuo'),
        'mgh' => N__('glassharmonika'),
        'mgt' => N__('glass trumpet'),
        'mha' => N__('harmonica'),
        'mhg' => N__('hurdy-gurdy'),
        'mjh' => N__('jew\'s harp'),
        'mla' => N__('lamellaphone'),
        'mmc' => N__('monochord'),
        'mme' => N__('melodica'),
        'mmi' => N__('mirliton'),
        'mml' => N__('melodic instrument'),
        'mms' => N__('musical saw'),
        'moc' => N__('ocarina'),
        'mpo' => N__('polyphonic instrument'),
        'mpp' => N__('player piano'),
        'mra' => N__('rabāb'),
        'mss' => N__('sound sculpture'),
        'msw' => N__('swanee whistle'),
        'mtf' => N__('tuning-fork'),
        'mui' => N__('instrument - non specified'),
        'mun' => N__('instrument or voice - non specified'),
        'mwd' => N__('wind instrument'),
        'mwh' => N__('whistle'),
        'mzz' => N__('other'),
    };
}

sub choruses {
    return {
        'cch' => N__('children\'s choir'),
        'cme' => N__('men\'s choir'),
        'cmi' => N__('mixed choir'),
        'cre' => N__('reciting choir'),
        'cun' => N__('choir - unspecified'),
        'cve' => N__('vocal ensemble'),
        'cwo' => N__('women\'s choir'),
        'czz' => N__('choir - other'),
    };
}

sub orchestras {
    return {
        'oba' => N__('band'),
        'obi' => N__('big band'),
        'obr' => N__('brass band'),
        'och' => N__('chamber orchestra'),
        'oco' => N__('combo'),
        'odo' => N__('dance orchestra'),
        'ofu' => N__('full orchestra'),
        'oga' => N__('gamelan'),
        'oie' => N__('instrumental ensemble'),
        'oiv' => N__('vocal and instrumental ensemble'),
        'oja' => N__('jazz band'),
        'ope' => N__('percussion orchestra'),
        'orb' => N__('ragtime band'),
        'osb' => N__('steel band'),
        'ost' => N__('string orchestra'),
        'oun' => N__('orchestra - unspecified'),
        'owi' => N__('wind orchestra'),
        'ozz' => N__('orchestra - other'),
    };
}

sub conductors {
    return {
        'qce' => N__('live electronic conductor'),
        'qch' => N__('choir conductor, chorus master'),
        'qco' => N__('conductor'),
        'qlc' => N__('light conductor'),
        'qzz' => N__('conductor - other'),
    };
}

sub other_performers {
    return {
        'zab' => N__('acrobat'),
        'zac' => N__('child actor'),
        'zas' => N__('silent actor'),
        'zat' => N__('actor'),
        'zaw' => N__('actress'),
        'zda' => N__('dancer'),
        'zel' => N__('light engineer'),
        'zes' => N__('sound engineer'),
        'zju' => N__('juggler'),
        'zmi' => N__('mime'),
        'zwp' => N__('walk-on part'),
        'zzz' => N__('performer - other'),
    };
}

sub tessitura {
    return {
        'a' => N__p( 'tessitura', 'sopranino' ),
        'b' => N__p( 'tessitura', 'soprano' ),
        'c' => N__p( 'tessitura', 'alto' ),
        'd' => N__p( 'tessitura', 'tenor' ),
        'e' => N__p( 'tessitura', 'baritone' ),
        'f' => N__p( 'tessitura', 'bass' ),
        'g' => N__p( 'tessitura', 'contrabass' ),
        'h' => N__p( 'tessitura', 'sub-contrabass' ),
        'i' => N__p( 'tessitura', 'sopracute' ),
        'j' => N__p( 'tessitura', 'high' ),
        'k' => N__p( 'tessitura', 'medium' ),
        'l' => N__p( 'tessitura', 'low' ),
        'm' => N__p( 'tessitura', 'prepared' ),
    };
}

sub number_of_hands_or_keys {
    return {
        '1' => N__p( 'music', 'one hand' ),
        '2' => N__p( 'music', 'two players on one instrument' ),
        '3' => N__p( 'music', 'three hands' ),
        '4' => N__p( 'music', 'four hands' ),
        '6' => N__p( 'music', 'six hands' ),
        '8' => N__p( 'music', 'eight hands' ),
        'a' => N__p( 'music', 'A' ),
        'b' => N__p( 'music', 'B flat' ),
        'c' => N__p( 'music', 'C' ),
        'd' => N__p( 'music', 'D' ),
        'e' => N__p( 'music', 'E' ),
        'f' => N__p( 'music', 'F' ),
        'g' => N__p( 'music', 'G' ),
        'h' => N__p( 'music', 'B' ),
        'i' => N__p( 'music', 'E flat' ),
        'j' => N__p( 'music', 'A flat' ),
        'k' => N__p( 'music', 'D flat' ),
        'l' => N__p( 'music', 'F sharp' ),
        'n' => N__p( 'music', 'Instrument played in non standard way' ),
        's' => N__p( 'music', 'non standard string number' ),
    };
}

sub other {
    return {
        'r' => N__('electric'),
        's' => N__('electronic'),
        't' => N__('midi'),
        'v' => N__('amplified'),
        'w' => N__('recorded'),
        'q' => N__('antiquity'),
        'y' => N__('ethnic, traditional'),
    };
}

sub other2 {
    return {
        'b' => N__('ad libitum'),
        'c' => N__('may take place of the preceding code / alternative'),
        'd' => N__('used by the same player as the preceding code'),
    };
}

1;
