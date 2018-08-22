<!----------------------------------------------------------------------------------------------|
| DESCRIPTION      :The Main purpose of this file is that it shows the category notes .         |
|                   The category notes doesnt has a parents so had to create a new function     |
|-----------------------------------------------------------------------------------------------|
|                                                                                             	|
|-----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                           	|
|-----------------------------------------------------------------------------------------------|
|  none                                                                                       	|
|-----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                    	|
|-----------------------------------------------------------------------------------------------|
|  none                                                                                       	|
|-----------------------------------------------------------------------------------------------|
| HISTORY                                                                                     	|
|-----------------------------------------------------------------------------------------------|
| Author    | Date       | 	Description                                                       	|
|-----------|------------|----------------------------------------------------------------------|
| sathya    | 2/18/2010  |	Created this for Project 41315.                                                         	|
------------------------------------------------------------------------------------------------>

<script language="javascript">
	function ShowCategoryNotes(divName,remove)
	{
		theDiv = document.getElementsByName(divName)[0];
		
		if(!remove)
		{
			theDiv.innerHTML = '<a href="javascript:ShowCategoryNotes(\''+ divName + '\',true)">remove notes : notes for this Category will be discarded</a><br><textarea name="add_' + divName + '" rows="3" cols="45"></textarea>';
		}
		else
		{
			theDiv.innerHTML = '<a href="javascript:ShowCategoryNotes(\'' + divName + '\')">add notes</a>';
		}
	}
</script>