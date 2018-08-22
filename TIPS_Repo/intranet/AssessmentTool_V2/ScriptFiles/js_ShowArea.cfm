<script language="javascript">
	function ShowArea(areaName)
	{
		theArea = document.getElementsByName(areaName)[0];
		
		if(theArea.style.display == 'block')
		{
			theArea.style.display = 'none';
			theArea.parentNode.innerHTML = theArea.parentNode.innerHTML.replace(/\^/,"+");
		}
		else
		{	
			theArea.style.display = 'block';
			theArea.parentNode.innerHTML = theArea.parentNode.innerHTML.replace(/\+/,"^");
		}
	}
</script>