//package RemoteAPIs.Driver.KohaSuomi
if (typeof RemoteAPIs == "undefined") {
    this.RemoteAPIs = {}; //Set the global package
}
if (typeof RemoteAPIs.Driver == "undefined") {
    this.RemoteAPIs.Driver = {}; //Set the global package
}
if (typeof RemoteAPIs.Driver.KohaSuomi == "undefined") {
    this.RemoteAPIs.Driver.KohaSuomi = {}; //Set the global package
}

RemoteAPIs.Driver.KohaSuomi._getDefaultAPIConfig = function () {
    return {
        id: "local",
        name: "Local",
        host: "",
        basePath: "api/v1",
        api: "Koha-Suomi",
        authentication: "cookies"
    };
};
RemoteAPIs.Driver.KohaSuomi._getErrorMsg = function (jqXHR) {
    var code = jqXHR.status;
    var e;
    if (jqXHR.responseJSON) {
        if (jqXHR.responseJSON.error) {
            e = jqXHR.responseJSON.error;
        }
        else if (jqXHR.responseJSON.errors instanceof Array) {
            jqXHR.responseJSON.errors.forEach(function (v,i,a) {
                a[i] = JSON.stringify(v);
            });
            e = jqXHR.responseJSON.errors.join(" ; ");
        }
        else {
            e = jqXHR.responseJSON.errors;
        }
    }
    else if (jqXHR.responseTEXT) {
        e = jqXHR.responseTEXT;
    }
    else {
        e = jqXHR.statusText;
    }
    return code+" - "+e;
};
RemoteAPIs.Driver.KohaSuomi._maybeUseDefaultConfig = function(remoteAPI) {
    if (remoteAPI == 'local') {
        return RemoteAPIs.Driver.KohaSuomi._getDefaultAPIConfig();
    }
    return remoteAPI;
}

RemoteAPIs.Driver.KohaSuomi.records_get = function(remoteAPI, biblio, callback) {
    remoteAPI = RemoteAPIs.Driver.KohaSuomi._maybeUseDefaultConfig(remoteAPI);
    $.ajax({
        "url": remoteAPI.host+'/'+remoteAPI.basePath+"/records/"+biblio.biblionumber,
        "method": "GET",
        "async": true,
        "dataType": "json",
        "contentType": "application/json; charset=utf8",
        "xhrFields": {
            withCredentials: (remoteAPI.authentication != "none") ? true : false
        },
        "success": function (jqXHR, textStatus, errorThrown) {
            callback(remoteAPI, null, jqXHR);
        },
        "error": function (jqXHR, textStatus, errorThrown) {
            callback(remoteAPI, RemoteAPIs.Driver.KohaSuomi._getErrorMsg(jqXHR), jqXHR);
        }
    });
};
RemoteAPIs.Driver.KohaSuomi.records_add = function(remoteAPI, recordXml, callback) {
    remoteAPI = RemoteAPIs.Driver.KohaSuomi._maybeUseDefaultConfig(remoteAPI);
    $.ajax({
        url: remoteAPI.host+'/'+remoteAPI.basePath+"/records",
        method: "POST",
        async: true,
        dataType: "json",
        contentType: "application/x-www-form-urlencoded",
        data: {marcxml: recordXml},
        xhrFields: {
            withCredentials: (remoteAPI.authentication != "none") ? true : false
        },
        success: function (jqXHR, textStatus, errorThrown) {
            callback(remoteAPI, null, jqXHR);
        },
        error: function (jqXHR, textStatus, errorThrown) {
            callback(remoteAPI, RemoteAPIs.Driver.KohaSuomi._getErrorMsg(jqXHR), jqXHR);
        }
    });
};
RemoteAPIs.Driver.KohaSuomi.records_delete = function(remoteAPI, biblionumber, callback) {
    remoteAPI = RemoteAPIs.Driver.KohaSuomi._maybeUseDefaultConfig(remoteAPI);
    $.ajax({
        "url": remoteAPI.host+'/'+remoteAPI.basePath+"/records/"+biblionumber,
        "method": "DELETE",
        "async": true,
        "accepts": "application/json",
        "contentType": "application/json; charset=utf8",
        "xhrFields": {
            withCredentials: (remoteAPI.authentication != "none") ? true : false
        },
        "success": function (jqXHR, textStatus, errorThrown) {
            callback(remoteAPI, null, jqXHR);
        },
        "error": function (jqXHR, textStatus, errorThrown) {
            callback(remoteAPI, RemoteAPIs.Driver.KohaSuomi._getErrorMsg(jqXHR), jqXHR);
        }
    });
};



RemoteAPIs.Driver.KohaSuomi.mock_records_get = function(remoteAPI, biblio, callback) {
    callback(remoteAPI, null, {
            marcxml:
                '<record>'+
                '  <datafield tag="100" ind1="1" ind2=" ">'+
                '    <subfield code="a">Amery, Heather.</subfield>'+
                '  </datafield>'+
                '  <datafield tag="245" ind1="1" ind2="0">'+
                '    <subfield code="a">Tuhat sanaa ruotsiksi /</subfield>'+
                '  </datafield>'+
                '</record>',
            biblionumber: 9999999999,
            links: [
              {
                ref: "remote.details",
                verb: "GET",
                href: "http://www.example.com/cgi-bin/koha/catalogue/detail.pl?biblionumber=9999999999",
              },
              {
                ref: "remote.delete",
                verb: "DELETE",
                href: "http://www.example.com/api/v1/records/9999999999",
              },
            ]
    });
};
RemoteAPIs.Driver.KohaSuomi.mock_records_delete = function(remoteAPI, biblio, callback) {
    callback(remoteAPI, null, null);
};