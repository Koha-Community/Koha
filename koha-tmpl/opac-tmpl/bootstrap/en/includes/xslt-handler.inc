[% SWITCH code %]
    [% CASE 'XSLTH_ERR_NO_FILE' %]
        No XSLT file passed.
    [% CASE 'XSLTH_ERR_FILE_NOT_FOUND' %]
        XSLT file not found.
    [% CASE 'XSLTH_ERR_LOADING' %]
        Error while loading stylesheet.
    [% CASE 'XSLTH_ERR_PARSING_CODE' %]
        Error while parsing stylesheet.
    [% CASE 'XSLTH_ERR_PARSING_DATA' %]
        Error while parsing input.
    [% CASE 'XSLTH_ERR_TRANSFORMING' %]
        Error while transforming input.
    [% CASE 'XSLTH_NO_STRING_PASSED' %]
        No string to transform.
[% END %]
