<script language="javascript">
function TrHover(theRow, theStyle)
{
	var theCells = null;
	if (typeof(document.getElementsByTagName) != 'undefined') 
	{
		theCells = theRow.getElementsByTagName('td');
	}
	else if (typeof(theRow.cells) != 'undefined') 
	{
		theCells = theRow.cells;
	}
	else 
	{
		return false;
	}
	
	var rowCellsCnt  = theCells.length;
	
	 for (c = 0; c < rowCellsCnt; c++) 
	 {
			theCells[c].className = theStyle;
	  }
}

function TrOut(theRow, theStyle)
{
	var theCells = null;
	if (typeof(document.getElementsByTagName) != 'undefined') 
	{
		theCells = theRow.getElementsByTagName('td');
	}
	else if (typeof(theRow.cells) != 'undefined') 
	{
		theCells = theRow.cells;
	}
	else 
	{
		return false;
	}
	
	var rowCellsCnt  = theCells.length;
	
	 for (c = 0; c < rowCellsCnt; c++) 
	 {
			theCells[c].className = theStyle;
	  }
}

</script>