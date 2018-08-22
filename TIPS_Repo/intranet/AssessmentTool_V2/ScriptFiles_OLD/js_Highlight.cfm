<script language="javascript">
	function Highlight(theObj)
	{	
		theParent = theObj.parentNode.parentNode;
		
		theRows = theParent.getElementsByTagName('td');
		
		for(i = 0; i < theRows.length; i++)
		{
			
			if(theObj.type == 'checkbox')
			{
				if(theObj.checked)
				{
					theRows[i].className = 'highlight';
				}
				else
				{
					theRows[i].className = 'serviceOption';
				}
			}
			else
			{
				if(theObj.value == 'yes')
				{
					theRows[i].className = 'highlight';
				}
				else
				{
					theRows[i].className = 'serviceOption';
				}
			}
		}
			
	}
</script>