$(document).ready(function(){
    $("#printData").click(function(){
		$("#patrondata").find(".buttons").addClass("hidden");
		$("#patrondata").find(".spinner-wrapper").removeClass("hidden");
        var userValues = {borrowernumber: borrowernumber};
		var logValues = {object: borrowernumber};
		var logs;
		if (logUrl) {
			var logcallback = function(log) {
				logs = log;
			}
			fetchJson(logUrl, logValues, logcallback);
		}
		var callback = function(json, textStatus, jqXHR) {
            if (userUrl) {
				if (logs) {
					json['logs'] = logs;
				}
				var userLang = navigator.language || navigator.userLanguage;
				moment.locale(userLang);
	
				var now = moment().format('Y-M-D');
				PDFTemplate(json, now, "Patron");
				var postValues = {module: "MEMBERS", action: "Print", object: borrowernumber, info: "Printed patron's data"};
				addLogRecord("/api/v1/logs/", postValues);
			} else {
				alert("Missing preferences PersonalInterfaceUrl");
				$("#patrondata").find(".buttons").removeClass("hidden");
				$("#patrondata").find(".spinner-wrapper").addClass("hidden");
			}
        };
		fetchJson(userUrl, userValues, callback);
    });
});

function MyDataView(){
	var self = this;

	self.logs = ko.observableArray();
	self.user = ko.observableArray();
	self.dataurl = ko.observable(false);
	var json;
	var filename;
	var templatesection;

	var userLang = navigator.language || navigator.userLanguage;
	moment.locale(userLang);

	var now = moment().format('Y-M-D');

	self.JsonData = function(url, name, section) {
		var dataValues;
		if (name == "logs") {dataValues = {object: borrowernumber};}
		if (name == "user") {dataValues = {borrowernumber: borrowernumber, section: section};}
		var callback = function(data, textStatus, jqXHR) {
			if (data) {
				if (name == "logs") {self.logs(dataParser(data)); filename = 'logdata_'; json = data; templatesection = 'logs'}
				if (name == "user") {
					for (var i in data) if (data.hasOwnProperty(i)) {
						self.user(dataParser(data[i]));
						if (section != 'personal') {
							json = data[i];
						}
					}
					filename = section+'data_';
					if (section == 'personal') {
						json = data
					}
					templatesection = section;
	
				}
				TrimJson(json);
				var filedata = "text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(json));
				$("#loadJSON").attr('href', 'data:' + filedata).attr('download',filename+now+'.json');
				$("#mydata").find(".spinner-wrapper").addClass("hidden");
				$('.'+section).removeClass("hidden");
				if (name == "logs") {$('#logList').removeClass("hidden")};
			} else {
				$(".nodata, .dataurl").removeClass("hidden");
			}
		}
		fetchJson(url, dataValues, callback);
	}

	if (userurl.length > 0) {
		self.dataurl(true);
		self.JsonData(userurl, 'user', 'personal');
	}

	self.logData = function(data, event) {
		activateLoading(event);
		$('#userList').addClass("hidden");
		$("#loadJSON").removeAttr("href").removeAttr("download");
		self.dataurl(false);
		if (userurl.length > 0) {
			self.user.removeAll();
		}
		if (logurl.length > 0) {
			self.dataurl(true);
			self.JsonData(logurl, 'logs');
		}

    }


     self.userData = function(data, event) {
		var section = $(event.currentTarget).attr("section-value");
		activateLoading(event);
		$('#userList').removeClass();
		$('#logList').addClass("hidden");
		$("#userList").addClass("hidden");
		$("#userList").addClass(section);
		$("#loadJSON").removeAttr("href").removeAttr("download");
		self.dataurl(false);
		if (logurl.length > 0) {
			self.logs.removeAll();
		}
		if (userurl.length > 0) {
			self.dataurl(true);
			self.JsonData(userurl, 'user', section);
		}
    }

	self.loadPDF = function(data, event) {
		if (self.logs().length > 0) {
			PDFTemplate(json, now, 'log');
		}

		if (self.user().length > 0) {
			PDFTemplate(json, now, templatesection);
		}
		$("#mydata").find(".spinner-wrapper").removeClass("hidden");
		var postValues = {module: "MEMBERS", action: "Print", object: borrowernumber, info: "Printed "+templatesection+" data"};
		addLogRecord("/api/v1/logs/", postValues);

	}
	self.loadJSON = function(data, event) {
		$("#mydata").find(".spinner-wrapper").removeClass("hidden");
		var postValues = {module: "MEMBERS", action: "Download", object: borrowernumber, info: "Downloaded "+templatesection+" data"};
		addLogRecord("/api/v1/logs/", postValues);
	}
}

function fetchJson(url, dataValues, callback) {
    var response;
    $.ajax({
        url: url,
        type: "GET",
        data: dataValues,
        cache: true,
        async: true,
        success: function (data, textStatus, jqXHR) {
            if (callback) callback(data, textStatus, jqXHR);
        },
        error: function (jqXHR, textStatus, errorThrown) {
            alert(JSON.stringify(errorThrown));
        }
    });
    return response;
}

function activateLoading(event) {

	$('li').removeClass("active");
	$(event.target).closest('li').addClass("active");
	$("#mydata").find(".spinner-wrapper").removeClass("hidden");
	$(".nodata, .dataurl").addClass("hidden");
}

function addLogRecord(url, dataValues) {
    $.ajax({
        url: url,
        type: "POST",
		data: dataValues,
		cache: true,
        async: true,
        success: function (data, textStatus, jqXHR) {
			$("#mydata").find(".spinner-wrapper").addClass("hidden");
			$("#patrondata").find(".spinner-wrapper").addClass("hidden");
			$("#patrondata").find(".buttons").removeClass("hidden");
        },
        error: function (jqXHR, textStatus, errorThrown) {
            alert(JSON.stringify(errorThrown));
        }
    });
}

function getDataInfo(url) {
	var response;
    $.ajax({
        url: url,
        type: "GET",
        cache: true,
        async: false,
        success: function (data, textStatus, jqXHR) {
			response = data;
        },
        error: function (jqXHR, textStatus, errorThrown) {
            response = null;
        }
	});
	return response;
}

function PDFTemplate(json, time, section) {
	var translator = new Translator(myDataTranslations);
	var doc = new jsPDF();
	var data;
	section = section.substr(0,1).toUpperCase()+section.substr(1);
    doc.setFontSize(10);
    doc.setLineWidth(100);
	doc.text(translator.translate(section), 10, 10);
	doc.text(translator.translate("Field"), 10, 20);
	doc.text(translator.translate("Value"), 50, 20);
	doc.setFontSize(9);
	var line = 30;
	for (var i in json) if (json.hasOwnProperty(i)) {
		data = dataParser(json[i]);
		for (var it = 0; it < data.length; it++) {
			if (data[it] && data[it].value) {
				doc.text(data[it].key, 10, line);
				var splitValue = "";
				if (data[it].value) {
					splitValue = doc.splitTextToSize(data[it].value, 145);
				}
				doc.text(splitValue, 50, line);
				var lineValue;
				if (splitValue.length >= 2) {
					lineValue = 9*splitValue.length/2;
				} else {
					lineValue = 9;
				}
			}
			line += lineValue;
			if (line >= 250) {
				doc.addPage();
				line = lineValue;
			}
		}
		line += 9;
	}
	doc.save(section+"data_"+time+".pdf");

}

function dataParser(json) {
	var self = this;

	self.arr = [];

	for (var i in json) if (json.hasOwnProperty(i)) {
		if ($.isArray(json)) {
			var childJson = json[i];
			for (var it in childJson) if (childJson.hasOwnProperty(it)) {
				if (childJson[it] != "" && childJson[it] != null && childJson[it] != 0 && TrimValues(it)) {
					if (it == "itemnumber") {
						var item = getDataInfo('/api/v1/items/'+childJson[it]);
						if (item) {
							it = "barcode", 
							childJson[it] = item.barcode ? item.barcode : "No barcode";
						}
					}
					if (it == "biblionumber") {
						var biblio = getDataInfo('/api/v1/biblios/'+childJson[it]);
						if (biblio) {
							it = "title", 
							childJson[it] = biblio.title ? biblio.title : "No title";
						}
					}
					self.arr.push(parseKeyValue(it, childJson[it]));
				}
			}
			self.arr.push({"row": null});
		} else {
			if (json[i] != "" && json[i] != null && json[i] != 0 && TrimValues(i)) {
				self.arr.push(parseKeyValue(i, json[i]));
			}
		}
	}
	return self.arr;
}

function parseKeyValue(key, value) {

	var hash;
	if (value != "" && value != null && value != 0) {
		hash = {"key": key, "value": TrimInfo(value)};
	}

	return hash
}

function TrimJson(json) {
	var self = this;

	for (var i in json) if (json.hasOwnProperty(i)) {
		if ($.isArray(json)) {
			var childJson = json[i];
			for (var it in childJson) if (childJson.hasOwnProperty(it)) {
				TrimValues(it, childJson, ["biblionumber", "itemnumber"]);
			}

		} else {
			TrimValues(i, json, ["biblionumber", "itemnumber"]);
		}
	}

}

function TrimValues(key, array, addisonalValues) {
	var arr = ["borrowernumber",
				"issue_id",
				"reserve_id",
				"accountlines_id",
				"manager_id",
				"message_id",
				"borrower_debarment_id",
				"suggestionid",
				"suggestedby",
				"managedby",
				"rejectedby",
				"notify_id",
				"accountno",
				"user",
				"action_id",
				"object"];
	var returnkey = true;
	arr = arr.concat(addisonalValues);
	if ($.inArray( key, arr ) !== -1) {
		if (array) {
			delete array[key]
		} else{
			returnkey = false;
		}

	}

	return returnkey;

}

function TrimInfo(string) {

	if (string.match(/VAR/)) {
		string = string.match(/'action' =>.*'/);
	}

	return string;

}

function Translator(values){
    var self = this;
    self.translations = {};
    self.initTranslations = function(){
        self.translations = values;
    };
    self.isInited = false;

    self.translate = function(string){
        if(!self.isInited){
            self.initTranslations();
            self.isInited = true;
        }
        if(string && self.translations.hasOwnProperty(string)){
            string = self.translations[string];
        }
        return string;
    }
}

function isDate(val) {
    var d = new Date(val);
    return !isNaN(d.valueOf());
}