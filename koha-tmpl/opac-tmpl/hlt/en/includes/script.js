if (document.images) {
	homeon = new Image();
	homeon.src = "<TMPL_VAR NAME='themelang'>/images/styles/home-btn-on.gif";
	homeoff = new Image();
	homeoff.src = "<TMPL_VAR NAME='themelang'>/images/styles/home-btn-off.gif";
	abouton = new Image();
	abouton.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-about-on.gif";
	aboutoff = new Image();
	aboutoff.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-about-off.gif";
	memberson = new Image();
	memberson.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-members-on.gif";
	membersoff = new Image();
	membersoff.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-members-off.gif";
	searchon = new Image();
	searchon.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-search-on.gif";
	searchoff = new Image();
	searchoff.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-search-off.gif";
	maorion = new Image();
	maorion.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-maori-on.gif";
	maorioff = new Image();
	maorioff.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-maori-off.gif";
	kidson = new Image();
	kidson.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-kids-on.gif";
	kidsoff = new Image();
	kidsoff.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-kids-off.gif";
	teenson = new Image();
	teenson.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-teens-on.gif";
	teensoff = new Image();
	teensoff.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-teens-off.gif";
	newon = new Image();
	newon.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-new-on.gif";
	newoff = new Image();
	newoff.src = "<TMPL_VAR NAME='themelang'>/images/styles/nav-new-off.gif";
}

function imgOn(imgName) {
	if (document.images) {
		document[imgName].src = eval(imgName + "on.src");
	}
}

function imgOff(imgName) {
	if (document.images) {
		document[imgName].src = eval(imgName + "off.src");
	}
}