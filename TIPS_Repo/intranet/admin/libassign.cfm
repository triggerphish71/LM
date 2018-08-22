<cfset datasource = "DMS">

<cfif IsDefined("url.pageid")>
	<cfset pageid = url.pageid>
<cfelse>
	<cfparam name="pageid" default="1">
</cfif>

<cfif pageid is 1>
	<!--- initail menu query --->
	<cfquery name="getlibrarycategories" datasource="#datasource#" dbtype="ODBC">
	Select distinct categories.name,cattopicassgn.uniqueid
	From Categories,cattopicassgn
	Where cattopicassgn.categoryid = Categories.uniqueid
	</cfquery>
<cfelse>
<!--- queries for listing --->
	<cfquery name="GetHeading" datasource="#datasource#" dbtype="ODBC">
		select name
		from Categories,cattopicassgn
		where categoryid = Categories.uniqueid AND cattopicassgn.uniqueid = #categoryid# 
	 </cfquery>
	 
	
	 <cfquery name="getresources" datasource="#datasource#" dbtype="ODBC">
		select  subtitle, Title, FileName, Path, Notes, Show, locationid, fileextention,revdate,mediainfo.uniqueid
		from mediainfo,medialocation
		where medialocation.locationid = #categoryid# AND mediainfo.uniqueid = medialocation.mediaid<cfif IsDefined("url.item")> AND mediainfo.uniqueid = #url.item#</cfif>
		Order by subtitle asc
	 </cfquery> 
</CFIF>
<html>
<head>
	<title>Library File Assignment</title>
<script language="JavaScript1.2" type="text/javascript">
<!--
window.moveTo(200,200);
window.focus();
//-->
</script>
</head>

 
<body bgcolor="White" leftmargin=0 topmargin=0 marginwidth="0" marginright="0" <cfif pageid is 1>onLoad='window.resizeTo(430,175)'<cfelseif getresources.recordcount is 0>onLoad='window.resizeTo(430,170)'<cfelse>onLoad='window.resizeTo(530,500);'</cfif> >

<cfif pageid is 1>

	<!--- table for the category menu --->
	<form action=" libassign.cfm?pageid=0" method="post">
		<table width="400" cellspacing="2" cellpadding="2" border="0">
		<tr bgcolor="#006666">
		    <td>&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;Library Categories</font></td>
		</tr>
		<tr bgcolor="#f7f7f7">
		    <td>
			<br>
			&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">
			Select a Category: </font>
			<select name="categoryid">
				<option value="">Choose...</option>
				<cfoutput query="getlibrarycategories"><option value="#uniqueid#">#name#</option></cfoutput>
			</select>
			<input type="hidden" name="categoryid_required">
	<br><br>
	</td>
		</tr>
		<tr bgcolor="#eaeaea">
		    <td><input type="submit" name="submit" value="Request Category"></td>
		</tr>
		</table>
	</form>
<cfelse>
	<cfif getresources.recordcount is 0>
<form action="libassign.cfm?pageid=1" method="post">
<table width="500" border="0" cellspacing="2" cellpadding="2">
	<tr bgcolor="#006666">
			<td colspan="3">&nbsp;<font color="white" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;Library</font><BR></td>
	</tr>
	<tr bgcolor="#f7f7f7">
		<td><br>
			<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">There are no files in this category.</font>
			<br><br>
		</td>
	</tr>
	<tr bgcolor="#eaeaea">
		<td>
			<input type="submit" name="submit" value="Select another category">
		</td>
	</tr>
</table>
</form>
<cfelse>
<script language="JavaScript1.2" type="text/javascript">
<!--

function set_file()
{
	var count = <cfoutput>#getresources.recordcount#</cfoutput>;
	if (count == 1)
		{
			var s = window.document.assignform.fileid.value;
			var position = s.split("x");
		
			opener.document.resourcerec.fileassign.value = position[0];
			opener.document.resourcerec.fileassignname.value = position[1];
			
		}
	else
		{
			for (loop=0; loop < count; loop++)
			{
				if (window.document.assignform.fileid[loop].checked == true)
				{
					var p = window.document.assignform.fileid[loop].value;
					var position2 = p.split("x");
					opener.document.resourcerec.fileassign.value = position2[0];
					opener.document.resourcerec.fileassignname.value = position2[1];
				}
			}
	}
	self.close();
}



//-->
</script>

	<!--- end category form --->
	  <cfset firstchar = left(#GetHeading.name#,1)>
	  <cfset firstupper = Ucase(firstchar)>
	  <cfset heading = firstupper & removechars(#GetHeading.name#,1,1)>

	<form action="" name="assignform" id="assignform">
	<table width="500" border="0" cellspacing="2" cellpadding="2">
	<tr bgcolor="#006666">
			<td colspan="3">&nbsp;<font color="white" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;<cfoutput>#heading# Library</cfoutput></font><BR></td>
	</tr>
	<cfloop query="getresources">
			<!--- The State specific files are indented --->
	
	<cfquery name="getassoc" datasource="#datasource#" dbtype="ODBC">
		Select docassociation.childdoc
		From medialocation,docassociation
		Where medialocation.mediaid = #getresources.uniqueid# AND medialocation.uniqueid = docassociation.parentdoc
	</cfquery>
	
	<cfif getassoc.recordcount is not 0>
		<cfquery name="getchildren" datasource="#datasource#" dbtype="ODBC">
		Select filename,fileextention,path,medialocation.uniqueid
		From mediainfo,medialocation
		Where medialocation.uniqueid  IN (#ValueList(getassoc.childdoc)#) AND mediainfo.uniqueid = medialocation.mediaid
		</cfquery>
	</cfif>
	
	 	<cfoutput>
			<tr bgcolor="##f7f7f7">
			<td><input type="radio" name="fileid" value="#getresources.uniqueid#x#getresources.filename#"></td>
			<td>&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#getresources.Title#</font></td>
			<td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">#getresources.subtitle#</font></td>
			</tr>
	 	</cfoutput>
		
		<cfif getassoc.recordcount is not 0><!--- associated files --->
			<cfloop query="getchildren">
				<cfoutput>
					<tr>
					<td><input type="radio" name="fileid" value="#getchildren.uniqueid#x#getchildren.filename#"></td>
						<td colspan="2" bgcolor="##f7f7f7">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;"><A HREF="#RemoveChars(getchildren.path,1,18)##getchildren.filename#.#getchildren.fileextention#" TARGET="_NEW">#getchildren.filename#.#getchildren.fileextention#</A></font></td>
					</tr>
			 	</cfoutput>
			</cfloop>
		</cfif>
	</cfloop>
	<tr bgcolor="#eaeaea">
			<td colspan="2"><input type="button" name="assign" value="Assign" onClick="set_file();"></td>
			
			<td><input type="button" name="close" value="Close Window" onClick="self.close();"></td>
			</tr>
	</table>
	
	</form>

</cfif>

</cfif>

</body>
</html>
