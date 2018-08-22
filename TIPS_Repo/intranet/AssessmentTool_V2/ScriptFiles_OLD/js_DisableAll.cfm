<cfoutput>
	<script language="javascript">
	function DisableAll()
	{	
		//get all the input buttons
		InputArray = document.getElementsByTagName('input');
		
		<cfif isDefined("Assessment") AND Assessment.GetIsFinalized()>
			var z = 2;
		<cfelse>
			var z = 1;
		</cfif>
		for(i = z; i < InputArray.length; i++)
		{
			InputArray[i].disabled = true;
		}
	}
	</script>
</cfoutput>