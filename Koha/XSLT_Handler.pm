package Koha::XSLT_Handler;
# This is just a stub; will be removed later on
use Modern::Perl;
use base qw(Koha::XSLT::Base);
use constant XSLTH_ERR_1    => 'XSLTH_ERR_NO_FILE';
use constant XSLTH_ERR_2    => 'XSLTH_ERR_FILE_NOT_FOUND';
use constant XSLTH_ERR_3    => 'XSLTH_ERR_LOADING';
use constant XSLTH_ERR_4    => 'XSLTH_ERR_PARSING_CODE';
use constant XSLTH_ERR_5    => 'XSLTH_ERR_PARSING_DATA';
use constant XSLTH_ERR_6    => 'XSLTH_ERR_TRANSFORMING';
use constant XSLTH_ERR_7    => 'XSLTH_NO_STRING_PASSED';
1;
