<script language="javascript">
	function ResetLevel()
	{
		//clear the selected sub options array
		selectedSubOptions = null;
		//recreate it
		selectedSubOptions = new Array();
		//set totalpoints to 0
		totalPoints = 0;
		document.getElementsByName('pointsSpan')[0].innerHTML = '0 Points :: Level 0';
	}
</script>