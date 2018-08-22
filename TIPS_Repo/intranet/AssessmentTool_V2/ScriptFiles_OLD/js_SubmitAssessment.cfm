<script language="javascript">
	function SubmitAssessment(action)
	{
		//get the fuse input
		theInput = document.getElementsByName('fuse')[0];
		
		if(action == 'save')
		{
			theInput.value = 'saveAssessment'
			document.forms[0].submit();
		}
		else if(action =='finalize')
		{
			theInput.value = 'finalizeAssessment'
			document.forms[0].submit();
		}
		else if(action == 'new')
		{
			theInput.value = 'addNewAssessment'
			document.forms[0].submit();
		}
	}
</script>