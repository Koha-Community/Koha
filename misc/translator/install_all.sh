#!/bin/sh

# DEFAULT INTRANET
./tmpl_process3.pl install -i ../../koha-tmpl/intranet-tmpl/default/en/ -r  -s po/default_intranet_fr_FR.po -o ../../koha-tmpl/intranet-tmpl/default/fr/
./tmpl_process3.pl install -i ../../koha-tmpl/intranet-tmpl/default/en/ -r  -s po/default_intranet_es_ES.po -o ../../koha-tmpl/intranet-tmpl/default/es/
./tmpl_process3.pl install -i ../../koha-tmpl/intranet-tmpl/default/en/ -r  -s po/default_intranet_it_IT.po -o ../../koha-tmpl/intranet-tmpl/default/it/
./tmpl_process3.pl install -i ../../koha-tmpl/intranet-tmpl/default/en/ -r  -s po/default_intranet_pl_PL.po -o ../../koha-tmpl/intranet-tmpl/default/pl
./tmpl_process3.pl install -i ../../koha-tmpl/intranet-tmpl/default/en/ -r  -s po/default_intranet_uk_UA.po -o ../../koha-tmpl/intranet-tmpl/default/uk_UA
# th_TW does not work (encoding problem)
#./tmpl_process3.pl install -i ../../koha-tmpl/intranet-tmpl/default/en/ -r  -s po/default_intranet_zh_TW.po -o ../../koha-tmpl/intranet-tmpl/default/zh_TW

# NPL INTRANET
./tmpl_process3.pl install -i ../../koha-tmpl/intranet-tmpl/npl/en/ -r  -s po/npl_intranet_uk_UA.po -o ../../koha-tmpl/intranet-tmpl/npl/uk_UA
./tmpl_process3.pl install -i ../../koha-tmpl/intranet-tmpl/npl/en/ -r  -s po/npl_intranet_zh_CN.po -o ../../koha-tmpl/intranet-tmpl/npl/zh_CN
./tmpl_process3.pl install -i ../../koha-tmpl/intranet-tmpl/npl/en/ -r  -s po/npl_intranet_zh_TW.po -o ../../koha-tmpl/intranet-tmpl/npl/zh_TW

# NPL OPAC
./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/npl/en/ -r  -s po/npl_opac_hu_HU.po -o ../../koha-tmpl/opac-tmpl/npl/hu_HU/
./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/npl/en/ -r  -s po/npl_opac_jp_JP.po -o ../../koha-tmpl/opac-tmpl/npl/jp_JP/
./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/npl/en/ -r  -s po/npl_opac_kr_KR.po -o ../../koha-tmpl/opac-tmpl/npl/kr_KR
./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/npl/en/ -r  -s po/npl_opac_uk_UA.po -o ../../koha-tmpl/opac-tmpl/npl/uk_UA
./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/npl/en/ -r  -s po/npl_opac_zh_CN.po -o ../../koha-tmpl/opac-tmpl/npl/zh_CN
./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/npl/en/ -r  -s po/npl_opac_zh_TW.po -o ../../koha-tmpl/opac-tmpl/npl/zh_TW

# CSS OPAC
./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/css/en/ -r  -s po/css_opac_es_ES.po -o ../../koha-tmpl/opac-tmpl/css/es/
./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/css/en/ -r  -s po/css_opac_fr_FR.po -o ../../koha-tmpl/opac-tmpl/css/fr/
./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/css/en/ -r  -s po/css_opac_pl_PL.po -o ../../koha-tmpl/opac-tmpl/css/pl
./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/css/en/ -r  -s po/css_opac_uk_UA.po -o ../../koha-tmpl/opac-tmpl/css/uk_UA
./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/css/en/ -r  -s po/css_opac_zh_CN.po -o ../../koha-tmpl/opac-tmpl/css/zh_CN
./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/css/en/ -r  -s po/css_opac_it_IT.po -o ../../koha-tmpl/opac-tmpl/css/it/

# zh_TW does not work either
# ./tmpl_process3.pl install -i ../../koha-tmpl/opac-tmpl/css/en/ -r  -s po/css_opac_zh_TW.po -o ../../koha-tmpl/opac-tmpl/css/zh_TW