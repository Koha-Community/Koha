	/*
// +----------------------------------------------------------------------+
// | Copyright (c) 2005 LibLime                                           |
// +----------------------------------------------------------------------+
// | Licensed under the Apache License, Version 2.0 (the "License");      |
// | you may not use this file except in compliance with the License.     |
// | You may obtain a copy of the License at                              |
// | http://www.apache.org/licenses/LICENSE-2.0                           |
// | Unless required by applicable law or agreed to in writing, software  |
// | distributed under the License is distributed on an "AS IS" BASIS,    |
// | WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or      |
// | implied. See the License for the specific language governing         |
// | permissions and limitations under the License.                       |
// +----------------------------------------------------------------------+
// | Author: Joshua Ferraro <jmf at liblime dot com>                      |
// | Thanks to Bitflux GmbH <devel at bitflux dot ch>                     |
// +----------------------------------------------------------------------+

*/
var liveSearchReq = false;
var t = null;
var liveSearchLast = "";
	
var isIE = false;
// on !IE we only have to initialize it once
if (window.XMLHttpRequest) {
	liveSearchReq = new XMLHttpRequest();
}

function liveSearchInit() {
	
	if (navigator.userAgent.indexOf("Safari") > 0) {
		document.getElementById('keyword').addEventListener("keydown",liveSearchKeyPress,false);
//		document.getElementById('keyword').addEventListener("blur",liveSearchHide,false);
	} else if (navigator.product == "Gecko") {
		
		document.getElementById('keyword').addEventListener("keypress",liveSearchKeyPress,false);
		document.getElementById('keyword').addEventListener("blur",liveSearchHideDelayed,false);
		
	} else {
		document.getElementById('keyword').attachEvent('onkeydown',liveSearchKeyPress);
//		document.getElementById('keyword').attachEvent("onblur",liveSearchHide,false);
		isIE = true;
	}
	
	document.getElementById('keyword').setAttribute("autocomplete","off");

}

function liveSearchHideDelayed() {
	window.setTimeout("liveSearchHide()",400);
}
	
function liveSearchHide() {
	document.getElementById("LSResult").style.display = "none";
	var highlight = document.getElementById("LSHighlight");
	if (highlight) {
		highlight.removeAttribute("id");
	}
}

function liveSearchKeyPress(event) {
	
	if (event.keyCode == 40 )
	//KEY DOWN
	{
		highlight = document.getElementById("LSHighlight");
		if (!highlight) {
			highlight = document.getElementById("LSShadow").firstChild.firstChild;
		} else {
			highlight.removeAttribute("id");
			highlight = highlight.nextSibling;
		}
		if (highlight) {
			highlight.setAttribute("id","LSHighlight");
		} 
		if (!isIE) { event.preventDefault(); }
	} 
	//KEY UP
	else if (event.keyCode == 38 ) {
		highlight = document.getElementById("LSHighlight");
		if (!highlight) {
			highlight = document.getElementById("LSResult").firstChild.firstChild.lastChild;
		} 
		else {
			highlight.removeAttribute("id");
			highlight = highlight.previousSibling;
		}
		if (highlight) {
				highlight.setAttribute("id","LSHighlight");
		}
		if (!isIE) { event.preventDefault(); }
	} 
	//ESC
	else if (event.keyCode == 27) {
		highlight = document.getElementById("LSHighlight");
		if (highlight) {
			highlight.removeAttribute("id");
		}
		document.getElementById("LSResult").style.display = "none";
	} 
}
function liveSearchStart() {
	if (t) {
		window.clearTimeout(t);
	}
	t = window.setTimeout("liveSearchDoSearch()",200);
}

function liveSearchDoSearch() {

	if (typeof liveSearchRoot == "undefined") {
		liveSearchRoot = "";
	}
	if (typeof liveSearchRootSubDir == "undefined") {
		liveSearchRootSubDir = "";
	}
	if (typeof liveSearchParams == "undefined") {
		liveSearchParams = "";
	}
	if (liveSearchLast != document.forms.searchform.cql_query.value) {
	if (liveSearchReq && liveSearchReq.readyState < 4) {
		liveSearchReq.abort();
	}
	if ( document.forms.searchform.cql_query.value == "") {
		liveSearchHide();
		return false;
	}
	if (window.XMLHttpRequest) {
	// branch for IE/Windows ActiveX version
	} else if (window.ActiveXObject) {
		liveSearchReq = new ActiveXObject("Microsoft.XMLHTTP");
	}
	liveSearchReq.onreadystatechange= liveSearchProcessReqChange;
	liveSearchReq.open("GET", liveSearchRoot + "/cgi-bin/koha/livesearch.pl?cql_query=" + document.forms.searchform.cql_query.value + liveSearchParams);
	liveSearchLast = document.forms.searchform.cql_query.value;
	liveSearchReq.send(null);
	}
}

function liveSearchProcessReqChange() {
	
	if (liveSearchReq.readyState == 4) {
		var  res = document.getElementById("LSResult");
		res.style.display = "block";
		var  sh = document.getElementById("LSShadow");
		
		sh.innerHTML = liveSearchReq.responseText;
		 
	}
}

function liveSearchSubmit() {
	var highlight = document.getElementById("LSHighlight");
	if (highlight && highlight.firstChild) {
		window.location = liveSearchRoot + liveSearchRootSubDir + highlight.firstChild.getAttribute("href");
		return false;
	} 
	else {
		return true;
	}
}

// for mouseovers
function liveSearchHover(el) {
		highlight = document.getElementById("LSHighlight");
		if (highlight) {
			highlight.removeAttribute("id");
		}
		el.setAttribute("id","LSHighlight");
}

function liveSearchClicked(el) {
		highlight = document.getElementById("LSHighlight");
		if (highlight) {
			highlight.removeAttribute("id");
		}
		el.setAttribute("id","LSHighlight");
		return liveSearchSubmit();
}

