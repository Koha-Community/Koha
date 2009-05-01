// this function checks id date is like DD/MM/YYYY
function CheckDate(field) {
var d = field.value;
if (d!="") {
      var amin = 1900; 
      var amax = 2100; 
      var date = d.split("/");
      var ok=1;
      var msg;
      if ( (date.length < 2) && (ok==1) ) {
        msg = _("Separator must be /"); 
    	alert(msg); ok=0; field.focus();
    	return;
      }
      var dd   = date[0];
      var mm   = date[1];
      var yyyy = date[2]; 
      // checking days
      if ( ((isNaN(dd))||(dd<1)||(dd>31)) && (ok==1) ) {
        msg = _("day not correct."); 
	    alert(msg); ok=0; field.focus();
	    return false;
      }
      // checking months
      if ( ((isNaN(mm))||(mm<1)||(mm>12)) && (ok==1) ) {
        msg = _("month not correct.");
	    alert(msg); ok=0; field.focus();
	    return false;
      }
      // checking years
      if ( ((isNaN(yyyy))||(yyyy<amin)||(yyyy>amax)) && (ok==1) ) {
        msg = _("years not correct."); 
	    alert(msg); ok=0; field.focus();
	    return false;
      }
   }
}

//function test if member is unique and if it's right the member is registred
function unique() {
var msg1;
var msg2;
if (  document.form.check_member.value==1){
	if (document.form.categorycode.value != "I"){
		
		msg1 += ("Warning  !!!! Duplicate patron!!!!");
		alert(msg1);
	check_form_borrowers(0);
	document.form.submit();
	
	}else{
		msg2 += ("Warning !!!! Duplicate organisation!!!!");
		alert(msg2);
	check_form_borrowers(0);
	}
}
else
{
	document.form.submit();
}

}
//end function
//function test if date enrooled < date expiry
// WARNING: format-specific test.
function check_manip_date(status) {
if (status=='verify'){
// this part of function('verify') is used to check if dateenrolled<date expiry
if (document.form.dateenrolled != '' && document.form.dateexpiry.value !='') {
var myDate1=document.form.dateenrolled.value.split ('/');
var myDate2=document.form.dateexpiry.value.split ('/');
	if ((myDate1[2]>myDate2[2])||(myDate1[2]==myDate2[2] && myDate1[1]>myDate2[1])||(myDate1[2]==myDate2[2] && myDate1[1]>=myDate2[1] && myDate1[0]>=myDate2[0]))
	
		{ 
		document.form.dateenrolled.focus();
		var msg = ("Warning !!! check date expiry  >= date enrolment");
		alert(msg);
		}
	}
	}
}
//end function


// function to test all fields in forms and nav in different forms(1 ,2 or 3)
function check_form_borrowers(nav){
	var statut=0;
	if (document.form.check_member.value == 1 )
	{
		if (document.form_double.answernodouble) {
			if( (!(document.form_double.answernodouble.checked))){
				document.form.nodouble.value=0;
			} else {
				document.form.nodouble.value=1;
			}
 		}
 	} 
	
	if (document.form.BorrowerMandatoryField.value=='')
	{}
	else
	{
	    var champ_verif = document.form.BorrowerMandatoryField.value.split ('|');
	    var message ="The following fields are mandatory :\n";
	    var message_champ="";
		for (var i=0; i<champ_verif.length; i++) {
			if (document.getElementsByName(""+champ_verif[i]+"")[0]) {
				var val_champ=eval("document.form."+champ_verif[i]+".value");
				var ref_champ=eval("document.form."+champ_verif[i]);
				//check if it's a select
				if (ref_champ.type=='select-one'){
					// check to see if first option is selected and is blank
					if (ref_champ.options[0].selected &&
					    ref_champ.options[0].text == ''){
						// action if field is empty
						message_champ+=champ_verif[i]+"\n";
						//test to know if you must show a message with error
						statut=1;
					}
				} else {
					if ( val_champ == '' ) {
						// action if the field is not empty
						message_champ+=champ_verif[i]+"\n";
						statut=1;
					}	
			    }
			}
		}
	}
	//patrons form to test if you checked no to the question of double
 	if (statut!=1 && document.form.check_member.value > 0 ) {
		if (!(document.form_double.answernodouble.checked)){
			message ="";
			message_champ+=("Please confirm suspicious duplicate patron !!! ");
			statut=1;
			document.form.nodouble.value=0;
		} else {
			document.form.nodouble.value=1;
		}
 	}
		
	if (statut==1){
		//alert if at least 1 error
		alert(message+"\n"+message_champ);
		return false;
	} else {
		document.form.submit();
	}
}

function Dopop(link) {
// // 	var searchstring=document.form.value[i].value;
	var newin=window.open(link,'popup','width=600,height=400,resizable=no,toolbar=false,scrollbars=no,top');
}

function Dopopguarantor(link) {

	var newin=window.open(link,'popup','width=600,height=400,resizable=no,toolbar=false,scrollbars=yes,top');
}
