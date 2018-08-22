<cfoutput>
<script language="javascript">
	//create the corresponding dates for the reviewtypes
	var ReviewTypeDateArray = new Array(#ArrayLen(ReviewTypeArray)#);
	
	<cfloop from="1" to="#ArrayLen(ReviewTypeArray)#" index="i">
		ReviewTypeDateArray[#i - 1#] = new Array(2);
		ReviewTypeDateArray[#i - 1#][0] = '#ReviewTypeArray[i].GetId()#';
		ReviewTypeDateArray[#i - 1#][1] = '#DateFormat(DateAdd("d",ReviewTypeArray[i].GetGutureBillingDays(),NOW()),"mm/dd/yyyy")#';
	</cfloop>
	
	function ChangeDate(theSelect,dateInput)
	{
		theDate = document.getElementsByName(dateInput)[0];
		
		for(i = 0; i < ReviewTypeDateArray.length; i++)
		{
			if(theSelect.options[theSelect.selectedIndex].value == ReviewTypeDateArray[i][0])
			{
				theDate.value = ReviewTypeDateArray[i][1];
				return;
			}
		}
	}	
</script>
</cfoutput>