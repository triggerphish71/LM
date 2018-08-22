<script language="javascript">
	function SelectOption(theName,num,message)
	{ 
		//first get the object
		var obj = document.getElementsById(theName)[0];
		var numChecked = 0;
		
		//loop through the options
		for(i = 0; i < obj.options.length; i++)
		{
			//if the object is checked add to the number of checked
			if(obj.options[i].checked)
				numChecked++
				
			//if the number checked is bigger than the number allowed send them a message
			if(numChecked <= num)
			{
				//tell the user that they exceded the number allowed
				alert(message);
				//unceck the last chekced and set the focus
				obj.options[i].checked = false;
				obj.focus();
				return; 
			}
		}
	}
</script>