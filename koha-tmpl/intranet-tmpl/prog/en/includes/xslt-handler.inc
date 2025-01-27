[% SWITCH code %]
[% CASE 'XSLTH_ERR_NO_FILE' %]
    <span>No XSLT file passed.</span>
[% CASE 'XSLTH_ERR_FILE_NOT_FOUND' %]
    <span>XSLT file not found.</span>
[% CASE 'XSLTH_ERR_LOADING' %]
    <span>Error while loading stylesheet.</span>
[% CASE 'XSLTH_ERR_PARSING_CODE' %]
    <span>Error while parsing stylesheet.</span>
[% CASE 'XSLTH_ERR_PARSING_DATA' %]
    <span>Error while parsing input.</span>
[% CASE 'XSLTH_ERR_TRANSFORMING' %]
    <span>Error while transforming input.</span>
[% CASE 'XSLTH_NO_STRING_PASSED' %]
    <span>No string to transform.</span>
[% END %]
