<script language="JavaScript" type="text/javascript">
function CheckDate(d) {
	if (d!="")
{
      // Cette fonction vérifie le format JJ/MM/AAAA saisi et la validité de la date.
      // Le séparateur est défini dans la variable separateur
      var amin=1900; // année mini
      var amax=2100; // année maxi
      var separateur="/"; // separateur entre jour/mois/annee
      var j=(d.substring(0,2));
      var m=(d.substring(3,5));
      var a=(d.substring(6));
      var ok=1;
	var msg; 
      if ( ((isNaN(j))||(j<1)||(j>31)) && (ok==1) ) {
        msg = _("day not correct."); 
	alert(msg); ok=0;
      }
      if ( ((isNaN(m))||(m<1)||(m>12)) && (ok==1) ) {
        msg = _("month not correct.");
	 alert(msg); ok=0;
      }
      if ( ((isNaN(a))||(a<amin)||(a>amax)) && (ok==1) ) {
         msg = _("years not correct."); 
	alert(msg); ok=0;
      }
      if ( ((d.substring(2,3)!=separateur)||(d.substring(5,6)!=separateur)) && (ok==1) ) {
         alert("Separator must be "+separateur); ok=0;
      }
      return ok;
   }
}   
   



//function test if member is unique and if it's right the member is registred
function unique() {
var msg1;
var msg2;
if (  document.form.check_member.value==1){
	if (document.form.categorycode.value != "I"){
		
		msg1 += _("Warning  !!!! Duplicate borrower!!!!");
		alert(msg1);
	check_form_borrowers(0);
	document.form.submit();
	
	}else{
		msg2 += _("Warning !!!! Duplicate organisation!!!!");
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
function check_manip_date(status) {
if (status=='verify'){
// this part of function('verify') is used to check if dateenrolled<date expiry
var myDate1=document.form.dateenrolled.value.split ('/');
var myDate2=document.form.dateexpiry.value.split ('/');
	if ((myDate1[2]>myDate2[2])||(myDate1[2]==myDate2[2] && myDate1[1]>myDate2[1])||(myDate1[2]==myDate2[2] && myDate1[1]>=myDate2[1] && myDate1[0]>=myDate2[0]))
	
		{ 
		var msg = _("Warning !!! check date expiry  > date enrolment");
		alert(msg);
		document.form.dateexpiry.value="";
		document.form.dateexpiry.setfocus;
		}
	}
}
//end function


// function to test all fields in forms and nav in different forms(1 ,2 or 3)
 function check_form_borrowers(nav){
var statut=0;
if (nav < document.form.step.value) {
	document.form.step.value=nav;
	if ((document.form.step.value==0) && document.form.check_member.value == 1 )
	{
 	
		if (document.form_double.answernodouble)	{
			if( (!(document.form_double.answernodouble.checked))){
				document.form.nodouble.value=0;
			}
			else {
			document.form.nodouble.value=1;
			}
 		}
 	} 
	document.form.submit();
	

} else {
	if (document.form.BorrowerMandatoryfield.value==''||document.form.FormFieldList.value=='' )
	{}
	else
	{
	var champ_verif = document.form.BorrowerMandatoryfield.value.split ('|');
 	var champ_form= document.form.FormFieldList.value.split('|');
		var message ="The following fields are mandatory :\n";
		var message_champ="";
	for (var j=0; j<champ_form.length; j++){ 
		if (document.getElementsByName(""+champ_form[j]+"")[0]){
			for (var i=0; i<champ_verif.length; i++) {
					if (document.getElementsByName(""+champ_verif[i]+"")[0]) {
						var val_champ=eval("document.form."+champ_verif[i]+".value");
						var ref_champ=eval("document.form."+champ_verif[i]);
						var val_form=eval("document.form."+champ_form[j]+".value");
						if (champ_verif[i] == champ_form[j]){
							//check if it's a select
							if (ref_champ.type=='select-one'){
								if (ref_champ.options[0].selected ){
									// action if field is empty
									message_champ+=champ_verif[i]+"\n";
									//test to konw if u must show a message with error
									statut=1;
								}
							}else {
								if ( val_champ == '' ) {
									// action if the field is not empty
									message_champ+=champ_verif[i]+"\n";
									statut=1;
								}	
							}
						}
					}
			}
		}
	}
	}
//borrowers form 2 test if u chcked no to the quetsion of double 
 	if (document.form.step.value==2 && statut!=1 && document.form.check_member.value > 0 )
	{
		
  		
			if (!(document.form_double.answernodouble.checked)){
					
				message ="";
					message_champ+=_("Please confirm suspicious duplicate borrower !!! ");
					statut=1;
					document.form.nodouble.value=0;
			}
			else {
			document.form.nodouble.value=1;
			}
 	}
		
			if (statut==1){
			//alert if at least 1 error
				alert(message+"\n"+message_champ);
			}
			else 
			{
			document.form.step=nav;
			document.form.submit();
			}
		}

}
function Dopop(link) {
// // 	var searchstring=document.form.value[i].value;
	newin=window.open(link,'popup','width=600,height=400,resizable=no,toolbar=false,scrollbars=no,top');
}

function Dopopguarantor(link) {

	newin=window.open(link,'popup','width=600,height=400,resizable=no,toolbar=false,scrollbars=no,top');
}

</script>
