	 	if (document.images) {
		home0 = new Image();
		home0.src = "/intranet-tmpl/npl/en/images/home0.gif";
		library0 = new Image();
		library0.src = "/intranet-tmpl/npl/en/images/library0.gif";
		kids0 = new Image();
		kids0.src = "/intranet-tmpl/npl/en/images/kids0.gif";
		teens0 = new Image();
		teens0.src = "/intranet-tmpl/npl/en/images/teens0.gif";
		readers0 = new Image();
		readers0.src = "/intranet-tmpl/npl/en/images/readers0.gif";
		search0 = new Image();
		search0.src = "/intranet-tmpl/npl/en/images/search0.gif";
		branch0 = new Image();
		branch0.src = "/intranet-tmpl/npl/en/images/branch0.gif";
		programs0 = new Image();
		programs0.src = "/intranet-tmpl/npl/en/images/programs0.gif";
		mobile0 = new Image();
		mobile0.src = "/intranet-tmpl/npl/en/images/mobile0.gif";
		OPLIN0 = new Image();
		OPLIN0.src = "/intranet-tmpl/npl/en/images/OPLIN0.gif";
		contact0 = new Image();
		contact0.src = "/intranet-tmpl/npl/en/images/contact0.gif";
		
		home1 = new Image();
		home1.src = "/intranet-tmpl/npl/en/images/home1.gif";
		library1 = new Image();
		library1.src = "/intranet-tmpl/npl/en/images/library1.gif";
		kids1 = new Image();
		kids1.src = "/intranet-tmpl/npl/en/images/kids1.gif";
		teens1 = new Image();
		teens1.src = "/intranet-tmpl/npl/en/images/teens1.gif";
		readers1 = new Image();
		readers1.src = "/intranet-tmpl/npl/en/images/readers1.gif";
		search1 = new Image();
		search1.src = "/intranet-tmpl/npl/en/images/search1.gif";;
		branch1 = new Image();
		branch1.src = "/intranet-tmpl/npl/en/images/branch1.gif";
		programs1 = new Image();
		programs1.src = "/intranet-tmpl/npl/en/images/programs1.gif";
		mobile1 = new Image();
		mobile1.src = "/intranet-tmpl/npl/en/images/mobile1.gif";
		OPLIN1 = new Image();
		OPLIN1.src = "/intranet-tmpl/npl/en/images/OPLIN1.gif";
		contact1 = new Image();
		contact1.src = "/intranet-tmpl/npl/en/images/contact1.gif";
}

// Function to 'activate' images.
function imgOn(imgName) {
	if (document.images) {
		document[imgName].src = eval(imgName + "0.src");
	}
}

// Function to 'deactivate' images.
function imgOff(imgName) {
	if (document.images) {
		document[imgName].src = eval(imgName + "1.src");
		}
	}