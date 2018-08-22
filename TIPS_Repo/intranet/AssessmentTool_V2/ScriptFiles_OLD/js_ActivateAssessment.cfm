<cfoutput>
<script language="javascript">
	function ActivateAssessment(residentType)
	{
		//first get the activebilling date
		var billingActiveDate = document.getElementsByName('activeBillingDate')[0].value;
		
		//now set a url to redirect to
		if(residentType == 'Tenant')
		{
			var theUrl = 'index.cfm?fuse=activateAssessment&assessmentId=#Assessment.GetId()#&billingActiveDate=' + billingActiveDate;
		}
		else
		{
			var theUrl = 'index.cfm?fuse=activateAssessmentWithoutBilling&assessmentId=#Assessment.GetId()#&billingActiveDate=' + billingActiveDate;
		}
		window.location = theUrl;	
	}
</script>
</cfoutput>