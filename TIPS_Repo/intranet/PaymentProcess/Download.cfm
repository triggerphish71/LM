<CFHEADER name="Content-Disposition" value="attachment;filename=final.txt">
	<cfset currentPath = getCurrentTemplatePath()>
	<cfset currentDirectory = getDirectoryFromPath(currentPath)>
<CFCONTENT file="#currentDirectory#Final.txt" type="application/x-download" deletefile="no">

