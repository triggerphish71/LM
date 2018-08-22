
<SCRIPT language="javascript" type="text/javascript">
	
	function displayWindow(url, width, height) 
	{
		var Win = window.open(url, "displayWindow", 
				  'width=' + width + ', height=' + 
				  height + ',resizable=1,scrollbars=yes,menubar=yes' );
	}
	
			
	function doSel(obj)
	{
		for (i = 1; i < obj.length; i++)
		{
			if (obj[i].selected == true)
			{
				eval(obj[i].value);
			}
		}
	}
	function doSelAll(obj)
	{
		for (i = 0; i < obj.length; i++)
		{
			if (obj[i].selected == true)
			{
				eval(obj[i].value);
			}
		}
	}
</SCRIPT>