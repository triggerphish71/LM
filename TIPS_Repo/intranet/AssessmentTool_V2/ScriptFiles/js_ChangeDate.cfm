<cfoutput>
<script language="javascript">
	//create the corresponding dates for the reviewtypes
	// 12352 changes for hide show datepicker and ReviewTypeDateArray[2][1] GetMaxFutureBillingDays
	var ReviewTypeDateArray = new Array(#ArrayLen(ReviewTypeArray)#);
	
	<cfloop from="1" to="#ArrayLen(ReviewTypeArray)#" index="i">
		ReviewTypeDateArray[#i - 1#] = new Array(2);
		ReviewTypeDateArray[#i - 1#][0] = '#ReviewTypeArray[i].GetId()#';
 		ReviewTypeDateArray[#i - 1#][1] = '#DateFormat(DateAdd("d",ReviewTypeArray[i].GetGutureBillingDays(),NOW()),"mm/dd/yyyy")#'; 	
	</cfloop>
	
	ReviewTypeDateArray[2][1] =  '#DateFormat(DateAdd("d",ReviewType.GetMaxFutureBillingDays(application.datasource),NOW()),"mm/dd/yyyy")#';

	function ChangeDate(theSelect,dateInput)
	{
		theDate = document.getElementsByName(dateInput)[0]; // i.e. dateInput = nextreviewdate

		for(i = 0; i < ReviewTypeDateArray.length; i++){		
		
			if(theSelect.options[theSelect.selectedIndex].value == ReviewTypeDateArray[i][0])
			{ 
			 	theDate.value = ReviewTypeDateArray[i][1];
			 	if((theSelect.options[theSelect.selectedIndex].value == 9) || (theSelect.options[theSelect.selectedIndex].value == 4)){
					//document.getElementById("withdate").style.display='block';  
			 		document.getElementById("idNextReviewDate").readOnly=false; 
					}
				else{
					//document.getElementById("withdate").style.display='none';			 
			 		document.getElementById("idNextReviewDate").readOnly=true; 					
				};
				return;
			}
		}
	}	
</script>
</cfoutput>