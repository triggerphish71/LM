<script language="javascript">
	function Highlight(theObj)
	{	
		theParent = theObj.parentNode;
		
		theRows = theParent.getElementsByTagName('td');
		var inputArray = document.getElementsByTagName('input');
		serviceId = theObj.name.substring(theObj.name.indexOf('_') + 1,theObj.name.length);
		
		
		for(i = 0; i < inputArray.length; i++){
		if(theObj.value == 'yes' && theObj.checked == true){
		//alert(serviceId +"service id value");
		}
		}
		
		
		
		for(i = 0; i < theRows.length; i++)
		{
			
			if(theObj.type == 'radio')
			{
				if(theObj.checked )
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
				if(theObj.value == 'yes' )
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