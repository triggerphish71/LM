<html>
<head>
<cfset datasource = "DMS">
	<title>Assign child file</title>
	<script language="JavaScript1.2" type="text/javascript">
<!--

window.moveTo(200,200);
window.focus();

function set_parent()
{
	opener.document.resourcerec.childfile.value = document.assignform.fileid.value;
	//opener.document.resourcerec.childstate.value = 2;
	
	var options_string = "";
	var the_select = window.document.assignform.fileid;
	for (loop=0; loop < the_select.options.length; loop++)
	{
		if (the_select.options[loop].selected == true)
		{
			options_string += the_select.options[loop].text + " ";
			opener.document.resourcerec.childname.value = options_string
		}
	}

	self.close();
	
}

//-->
</script>
</head>

<cfif url.categoryid is not "">

<cfquery name="getcatname" datasource="#datasource#" dbtype="ODBC">
	Select categories.name
	From categories,cattopicassgn
	Where cattopicassgn.categoryid = Categories.uniqueid
	AND categories.uniqueid = #url.categoryid#
</cfquery>


<!--- cannot associate with ones self --->
	<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
 <cfquery name="getfiles" datasource="#datasource#" dbtype="ODBC">
	Select distinct medialocation.uniqueid, mediainfo.filename
	From mediainfo,medialocation,locationtype,categories,cattopicassgn
	Where mediainfo.uniqueid = medialocation.mediaid 
	AND medialocation.locationtypeid = 5 
	AND medialocation.locationid = cattopicassgn.uniqueid
	AND cattopicassgn.categoryid = categories.uniqueid
	AND cattopicassgn.uniqueid = #url.categoryid#
</cfquery> 
<body leftmargin=0 topmargin=0 marginheight="0" marginwidth="0">
<form name="assignform" id="assignform">
<table width="400" cellspacing="2" cellpadding="2" border="0">
<tr>
    <td colspan="2" bgcolor="#006666"><font color="#ffffff" style="font-family: Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Associate File</font></td>
    
</tr>
<tr bgcolor="#eaeaea">
    <td><font color="#484848" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Location:</font></td>
    <td><font color="#003399" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Library</font></td>
</tr>
<tr bgcolor="#eaeaea">
    <td><font color="#484848" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Category:</font></td>
    <td><font color="#003399" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;"><cfoutput query="getcatname">#name#</cfoutput></font></td>
</tr>
<tr bgcolor="#eaeaea">
    <td><font color="#484848" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Files:</font></td>
    <td>

	<select name="fileid" size="5">
		<cfoutput query="getfiles">
			<cfif uniqueid is not url.categoryid>
				<option value="#uniqueid#">#filename#</option>
			</cfif>
		</cfoutput>
	</select>

	
</td>
</tr>
<tr bgcolor="#f7f7f7">
    <td><input type="button" name="submit" value="Assign" onClick='set_parent();'></td>
   <td><p align="right"><input type="button" name="close" value="Close Window" onClick='self.close();'></p></td>
</tr>
</table>
 </form> 

<cfelse>
<body leftmargin=0 topmargin=0 marginheight="0" marginwidth="0">
<form name="assignform" id="assignform">
<table width="400" cellspacing="2" cellpadding="2" border="0">
<tr>
    <td bgcolor="#006666"><font color="#ffffff" style="font-family: Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Alert!</font></td>
</tr>

<tr bgcolor="#f7f7f7">
    <td><BR><ul><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">You must first select a Library category before assigning this file.</font></ul></td>
</tr>
<tr bgcolor="#eaeaea">

   <td><input type="button" name="close" value="Okay" onClick='self.close();'></td>
</tr>
</table>
 </form> 
</cfif>

</body>
</html>
