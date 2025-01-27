(function () {
    var params = {
        domain: "Koha",
    };
    if (typeof json_locale_data !== "undefined") {
        params.locale_data = json_locale_data;
    }

    Koha.i18n = {
        gt: new Gettext(params),

        expand: function (text, vars) {
            var replace_callback = function (match, name) {
                return name in vars ? vars[name] : match;
            };
            return text.replace(/\{(.*?)\}/g, replace_callback);
        },
    };
})();

function __(msgid) {
    return Koha.i18n.gt.gettext(msgid);
}

function __x(msgid, vars) {
    return Koha.i18n.expand(__(msgid), vars);
}

function __n(msgid, msgid_plural, count) {
    return Koha.i18n.gt.ngettext(msgid, msgid_plural, count);
}

function __nx(msgid, msgid_plural, count, vars) {
    return Koha.i18n.expand(__n(msgid, msgid_plural, count), vars);
}

function __p(msgctxt, msgid) {
    return Koha.i18n.gt.pgettext(msgctxt, msgid);
}

function __px(msgctxt, msgid, vars) {
    return Koha.i18n.expand(__p(msgctxt, msgid), vars);
}

function __np(msgctxt, msgid, msgid_plural, count) {
    return Koha.i18n.gt.npgettext(msgctxt, msgid, msgid_plural, count);
}

function __npx(msgctxt, msgid, msgid_plural, count, vars) {
    return Koha.i18n.expand(__np(msgctxt, msgid, msgid_plural, count), vars);
}
