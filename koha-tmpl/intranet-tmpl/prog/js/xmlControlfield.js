

// Add an option to a select form field
function add_option(select, text, value, selected)
{
    var option = document.createElement('option');
    option.text = text;
    option.value = value;
    if (selected) option.selected = true;
    try {
        select.add(option, null);
    }
    catch(ex) {
        select.add(option);
    }
}//add_option


// Return the value of a parameter from the url
function returnValueParam(param)
{
    var params = location.search.substr(1);
    var arr = params.split("&");
    var pattern = param + "=";
    for (var i=0; i < arr.length; i++) {
        if (arr[i].indexOf(pattern) == 0) {
            return unescape(arr[i].substr(pattern.length));
        }
    }
    return "";
}//returnValueParam


// Return a value from a position on the result string
function returnValuePosFromResult(result, pos)
{
    var index;
    if ((index = pos.indexOf("-")) > 0) {
        var ini = parseInt(pos.substring(0, index) ,10);
        var end = parseInt(pos.substr(index + 1) ,10);
        return result.substring(ini, end + 1);
    } else {
        return result.substr(pos, 1);
    }
}//returnValuePosFromResult


// Build string from form fields
function returnResultFromValues(form)
{
    var resultStr = form.result.value;
    var pos;
    var value;
    for (var i=0; i < form.elements.length; i++) {
        var pattern = new RegExp("f[0-9]+(?:[0-9]+)?");
        if (pattern.test(form.elements[i].name)) {
            pos = form.elements[i].name.substr(1);
            value = (pos.indexOf("-") > 0)?form.elements[i].value:form.elements[i].options[form.elements[i].selectedIndex].value;
            resultStr = changePosResult(pos, value, resultStr);
        }
    }
    return resultStr;
}//returnResultFromValues


// Build/modify result string for a position and a value
function changePosResult(pos, value, resultStr)
{
    var index;
    var result = "";
    if ((index = pos.indexOf("-")) > 0) {
        var ini = parseInt(pos.substring(0, index) ,10);
        var end = parseInt(pos.substr(index + 1) ,10);
        var roffset = (1 + end - ini)- value.length;
        if (roffset > 0) for (var i=0; i < roffset; i++) value += " ";
        if (ini == 0)
            result = value + resultStr.substr(end + 1);
        else {
            result = resultStr.substring(0, ini) + value;
            if (end < resultStr.length)
                result += resultStr.substr(end + 1);
        }
    } else {
        var ini = parseInt(pos, 10);
        if (ini == 0)
            result = value + resultStr.substr(1);
        else {
            result = resultStr.substring(0, ini) + value;
            if (ini < resultStr.length)
                result += resultStr.substr(ini + 1);
        }
    }
    result = result.replace(/#/g, " ");
    return result;
}//changePosResult


// Display the result string on a row of a table indicating positions and coloring them if they are incorrect or they are selected
function renderResult(tr_result, result)
{
    if (tr_result) {
        var td;
        if (tr_result.cells.length != result.length) {
            for (var i = tr_result.cells.length - 1; i >= 0; i--)
                tr_result.deleteCell(i);
            for (var i=0; i < result.length; i++) {
                value = result.charAt(i);
                td = tr_result.insertCell(tr_result.cells.length);
            }
        }
        var value;
        var ini = -1;
        var end = -1;
        var args = renderResult.arguments;
        var whiteAllTD = false;
        if (args.length > 2) {
            if (typeof(args[2]) == "boolean") {
                whiteAllTD = args[2];
            } else {
                var index;
                if ((index = args[2].indexOf("-")) > 0) {
                    ini = parseInt(args[2].substring(0, index) ,10);
                    end = parseInt(args[2].substr(index + 1) ,10);
                } else ini = parseInt(args[2], 10);
            }
        }
        for (var i=0; i < result.length; i++) {
            value = result.charAt(i);
            td = tr_result.cells[i];
            if (td.style.backgroundColor != "yellow" || whiteAllTD) td.style.backgroundColor = "white";
            td.innerHTML = (value == " ")?"&nbsp;":value;
            td.title = "Pos " + i + ". Value: \"" + value + "\"";
            if (ini >= 0) {
                if (end > 0) {
                    if (ini <= i && i <= end) td.style.backgroundColor = "#cccccc";
                } else if (i == ini) td.style.backgroundColor = "#cccccc";
            } else {
                var pos = (i < 10)?'0' + i:i + '';
                var obj;
                if ((obj = document.getElementById('f' + pos)) != null) {
                    var found = false;
                    for (var j=0; j < obj.options.length && !found; j++)
                        if (obj.options[j].value == value) found = true;
                    if (!found) {
                        td.style.backgroundColor = "yellow";
                        td.title = "Pos " + i + ". Incorrect Value: \"" + value + "\"";
                    }
                }
            }
        }//for
    }
}//renderResult


// Change displaying of result in the page
function changeH4Result(form, h4_result, tr_result, pos, value)
{
    var resultStr = form.result.value;
    var result = changePosResult(pos, value, resultStr);
    renderResult(tr_result, result, pos);
    h4_result.innerHTML = "&quot;" + result + "&quot;";
    form.result.value = result;
}//changeH4Result



// Class to read the xml and render the type of material
(function()
{

    xmlControlField = function(tagfield, form_id, select, table, h4_result, tr_result, idMaterial, themelang, marcflavour)
    {
        this.tagfield = tagfield;
        this.idMaterial = idMaterial;
        this.form_id = form_id;
        this.form = document.getElementById(form_id);
        this.select = select;
        this.table = table;
        this.h4_result = h4_result;
        this.tr_result = tr_result;
        this.themelang = themelang;
        this.marcflavour = marcflavour.toLowerCase();
    };//xmlControlField


    xmlControlField.prototype =
    {
        tagfield: "",
        idMaterial: "",
        root: null,
        form_id: "",
        form: null,
        select: null,
        table: null,
        h4_result: "",
        tr_result: "",
        themelang: "",


        setIdMaterial: function(idMaterial)
        {
            this.idMaterial = idMaterial;
        },//setIdMaterial

        loadXmlValues: function()
        {
            this.xmlDoc = $.ajax({
                type: "GET",
                url: this.themelang + "/data/" + this.marcflavour + "_field_" + this.tagfield + ".xml",
                dataType: "xml",
                async: false
            }).responseXML;
            if (this.xmlDoc) this.renderTemplate();
            $("*").ajaxError(function(evt, request, settings){
                alert(__("AJAX error: receiving data from %s").format(settings.url));
            });
        },//loadXmlValues


        renderTemplate: function()
        {
            this.root = this.xmlDoc.documentElement;
            if (this.root.nodeName == "Tagfield" && this.root.nodeType == 1 && this.root.hasChildNodes()) {
                var tag = this.root.attributes.getNamedItem("tag").nodeValue;
                var nodeMaterial = this.root.getElementsByTagName('Material');
                if (nodeMaterial != null && nodeMaterial.length > 0) {
                    if (this.idMaterial == "") this.idMaterial = nodeMaterial[0].attributes.getNamedItem("id").nodeValue;
                    this.renderSelectMaterial(nodeMaterial);
                    this.renderPositions(nodeMaterial, (this.form.result.value != "")?this.form.result.value:returnValueParam("result"));
                }
            }
        },//renderTemplate


        renderSelectMaterial: function(nodeMaterial)
        {
            if (this.select != null && nodeMaterial != null && nodeMaterial.length > 0) {
                if (this.select.options.length <= 1) {
                    var id;
                    var name;
                    var arrSort = new Array();
                    var arrEquiv = new Array();
                    for (var i=0; i < nodeMaterial.length; i++) {
                        id = nodeMaterial[i].attributes.getNamedItem("id").nodeValue;
                        name = nodeMaterial[i].getElementsByTagName('name')[0].textContent;
                        arrEquiv[id] = i;
                        arrSort.push(id);
                    }
                    arrSort.sort();
                    var j;
                    for (var i=0; i < arrSort.length; i++) {
                        j = arrEquiv[arrSort[i]];
                        add_option(this.select, arrSort[i] + " - " + nodeMaterial[j].getElementsByTagName('name')[0].textContent, arrSort[i], (this.idMaterial != "" && arrSort[i] == this.idMaterial)?true:false);
                    }
                } else if (this.idMaterial != "") {
                    for (var i=0; i < this.select.options.length; i++) {
                        if (this.select.options[i].value == this.idMaterial) this.select.options[i].selected = true;
                    }
                }
            }
        },//renderSelectMaterial


        renderPositions: function(nodeMaterial, result)
        {
            var materialNode;
            try {
                var resultXPath = this.xmlDoc.evaluate("//a:Material[@id='" + this.idMaterial + "']", this.xmlDoc.documentElement, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
                materialNode = resultXPath.singleNodeValue;
            } catch (e) {
                for (var i=0; i < nodeMaterial.length; i++) {
                    if (this.idMaterial == nodeMaterial[i].attributes.getNamedItem("id").nodeValue) {
                        materialNode = nodeMaterial[i];
                        break;
                    }
                }
            }
            if (this.table != null) { // Render table
                var tbody = this.table.tBodies[0];
                // Clean up table
                if (tbody.rows.length > 0)
                    for (var i = tbody.rows.length - 1; i >= 1; i--)
                        tbody.deleteRow(i);
                // Parse Material node
                if (materialNode != undefined && materialNode != null && materialNode.nodeType == 1 && materialNode.hasChildNodes()) {
                    var nodePos = materialNode.firstChild;
                    var tr;
                    var td;
                    var title;
                    var pos;
                    var value;
                    var strInnerHTML = "";
                    var selected;
                    var index;
                    var url;
                    var description;
                    var name;
                    while (nodePos != null) {
                        if (nodePos.nodeType == 1 && nodePos.nodeName == "Position") {
                            tr = tbody.insertRow(tbody.rows.length);
                            td = tr.insertCell(tr.cells.length);
                            pos = nodePos.attributes.getNamedItem("pos").nodeValue;
                            // description is required by schema
                            description = nodePos.getElementsByTagName('description')[0].textContent;
                            name = nodePos.getElementsByTagName('name')[0].textContent
                            title = ( description != "")?description:name;
                            try {
                                url = ((nodePos.getAttributeNode("url") || nodePos.hasAttribute("url")) && nodePos.getAttribute("url") != "" && nodePos.getElementsByTagName('urltext')[0].textContent != "")?"&nbsp;<a href='" + nodePos.attributes.getNamedItem("url").nodeValue + "' target='_blank'>" + nodePos.getElementsByTagName('urltext')[0].textContent + "</a>":"";
                            } catch (e) { url = "";}
                            td.innerHTML = "<label for='f" + pos + "' title='" + title + "'>" + pos + " - " + name + url + "</label>";
                            td = tr.insertCell(tr.cells.length);
                            value = returnValuePosFromResult(result, pos);
                            if ((index = pos.indexOf("-")) > 0) { // Position interval
                                var ini = parseInt(pos.substring(0, index) ,10);
                                var end = parseInt(pos.substr(index + 1) ,10);
                                value = value.replace(/ /g, "#");
                                strInnerHTML = "<input type='text' name='f" + pos + "' id='f" + pos + "' value='" + value + "' size='" + (1 + end - ini) + "' maxlength='" + (1 + end - ini) + "' onkeyup='this.value = this.value.replace(/ /g, \"#\"); changeH4Result(document.getElementById(\"" + this.form_id + "\"), document.getElementById(\"" + this.h4_result + "\"), document.getElementById(\"" + this.tr_result + "\"), \"" + pos + "\", this.value)' onfocus='changeH4Result(document.getElementById(\"" + this.form_id + "\"), document.getElementById(\"" + this.h4_result + "\"), document.getElementById(\"" + this.tr_result + "\"), \"" + pos + "\", this.value)' />";
                            } else {
                                strInnerHTML = "<select name='f" + pos + "' id='f" + pos + "' style='width:400px' onchange='changeH4Result(document.getElementById(\"" + this.form_id + "\"), document.getElementById(\"" + this.h4_result + "\"), document.getElementById(\"" + this.tr_result + "\"), \"" + pos + "\", this.options[this.selectedIndex].value)' onfocus='changeH4Result(document.getElementById(\"" + this.form_id + "\"), document.getElementById(\"" + this.h4_result + "\"), document.getElementById(\"" + this.tr_result + "\"), \"" + pos + "\", this.options[this.selectedIndex].value)'>";
                                value = value.replace("#", " ");
                                if (nodePos.getElementsByTagName("Value").length != 0) {
                                    var nodeValue = nodePos.firstChild;
                                    while (nodeValue != null) {
                                        if (nodeValue.nodeType == 1 && nodeValue.nodeName == "Value" && nodeValue.hasChildNodes()) {
                                            var code = nodeValue.attributes.getNamedItem("code").nodeValue;
                                            description = nodeValue.getElementsByTagName('description')[0].textContent;
                                            var valNode = code;
                                            valNode = valNode.replace("#", " ");
                                            selected = (value == valNode)?"selected='selected'":"";
                                            strInnerHTML += "<option value='"  + valNode + "' " + selected + ">" + code + " - " + description +  "</option>";
                                        }
                                        nodeValue = nodeValue.nextSibling;
                                    }
                                } else {
                                    strInnerHTML += "<option value=' ' " + ((value == " ")?"selected='selected'":"") + "># - " + title +  "</option>";
                                    strInnerHTML += "<option value='|' " + ((value == "|")?"selected='selected'":"") + ">| - " + title +  "</option>";
                                }
                                strInnerHTML += "</select>";
                            }
                            td.innerHTML = strInnerHTML;
                        }
                        nodePos = nodePos.nextSibling;
                    }
                }
            }
        }//renderPositions
    };

})();

