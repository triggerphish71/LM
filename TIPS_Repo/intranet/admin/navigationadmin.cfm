<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/navigationadmin.cfm --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: May                       --->
<!--------------------------------------->
<cfinclude template="/intranet/header.cfm">
<cfif adminform is "1">
<cfparam name="locat" default="0">
<cfparam name="messageA" default="">
<cfparam name="messageB" default="">
<cfparam name="messageC" default="">



<cfif function is 0 >
	<cfset messagec = "You must select a function: Add, Edit, or Delete before proceding.">
</cfif>

<cfif locat IS 0>	
	<cfset messageB = "You must click Home, Department, or Region and then make a selection from the adjacent menus."& "<BR><BR>" >
</cfif>

<cfif  (IsDefined("regionid") is "False") and (locat is "region")>
	<cfset messageA = "You must select a region or department from the drop down menus to Edit." & "<BR><BR>">
</cfif>

<cfif  (departmentid is 0) and (locat is "department")>
	<cfset messageA = "You must select a region or department from the drop down menus to Edit." & "<BR><BR>">
</cfif>


<cfset message = messageA & messageB & messageC>

<cfif message is not "">
<ul>
<table width="400" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#990000">
	    <td>&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Error</font></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td width="350"><br><ul>&nbsp;<font face="Arial" size="2"  style="font-weight: bold;"><cfoutput>#message#</cfoutput><br><br>Click the Back button to return to the previous screen.</font></ul></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td><input type="button" name="button" value="Back" onClick="history.back();"></td>
	</tr>
	</table>
	</ul>
	
<cfinclude template="/intranet/Footer.cfm">


<cfelse>



<!-------------------------------------- code for the content admin ---------------------------------------->
	<!--- need to keep the drop list linked to the radio button. --->
	 <cfif locat is "Department">
			<cfset regionid = "">
		<cfelseif locat is "Region">
			<cfset departmentid = "">
		<cfelseif locat is "home">
			<cfset regionid = "6">
			<cfset departmentid = "">
		</cfif>
	<cfif function is 1><!--- add --->
		
<cflocation url="addcontent.cfm?regionid=#regionid#&departmentid=#departmentid#&location=#locat#" addtoken="No"> 
	<!--- <cfoutput>regionid=#regionid#& departmentid=#departmentid#& location=#locat#</cfoutput> --->
	<cfelseif function is 2><!--- edit --->
	
			<cflocation url="editcontentmenu.cfm?regionid=#regionid#&departmentid=#departmentid#&location=#locat#" addtoken="No">
	
	<cfelseif function is 3><!--- delete --->
	
			<cflocation url="deletecontentmenu.cfm?regionid=#regionid#&departmentid=#departmentid#&location=#locat#" addtoken="No">
	</cfif>
	</cfif>
<!-------------------------------------- End code for the content admin ---------------------------------------->

<cfelseif adminform is "2">
<!-------------------------------------- code for the Employment Listing admin ---------------------------------------->
<cfparam name="function" default="0">

		<cfif function is "1">
			<cfif taskid is 1>
				<cflocation url="addjobcategories.cfm?region=#region#" addtoken="No">
			<cfelse>
				<cflocation url="createjobposting.cfm?region=#region#" addtoken="No">
			</cfif>
			
			
			
		<cfelseif function is "2">
			<cfif taskid is 1>
				<cflocation url="editjobcategoriesmenu.cfm?region=#region#" addtoken="No">
			<cfelse>
				<cflocation url="editjobpostlisting.cfm?region=#region#" addtoken="No">
			</cfif>
			
			
			
		<cfelseif function is "3">
				<cfif taskid is 1>
			<cflocation url="deletejobcategoriesmenu.cfm?region=#region#" addtoken="No">
			<cfelse>
				<cflocation url="deletejobpostlisting.cfm?region=#region#" addtoken="No">
			</cfif>
		</cfif>
	
	<ul>
<table width="400" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#990000">
	    <td>&nbsp;<b><font color="White">Error</font></b></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td width="350"><br><ul>&nbsp;<font face="Arial" size="2"  style="font-weight: bold;">You must select a region and a function.<br><br>Click the Back button to return to the previous screen.</font></ul></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td><input type="button" name="button" value="Back" onClick="history.back();"></td>
	</tr>
	</table>
	</ul>
	
<cfinclude template="/intranet/Footer.cfm">
</body>
</html>

<!-------------------------------------- End code for the Employment Listing admin ---------------------------------------->


<cfelseif adminform is "3">
<cfparam name="function" default="0">
<!-------------------------------------- code for the Library Category admin ---------------------------------------->
		<cfif function is 1>
			<cfif Libselectiontype is 1>
				<cflocation url="addlibrarycategories.cfm" addtoken="No">
			<cfelse>
				<cflocation url="addlibrarytopics.cfm" addtoken="No">
			</cfif>
		<cfelseif function is 2>
			<cfif Libselectiontype is 1>
				<cflocation url="editlibrarycategories.cfm" addtoken="No">
			<cfelse>
				<cflocation url="editlibrarytopics.cfm" addtoken="No">
			</cfif>
		<cfelse>
		<cfif Libselectiontype is 1>
				<cflocation url="deletelibrarycategories.cfm" addtoken="No">
			<cfelse>
				<cflocation url="deletelibrarytopics.cfm?page=0" addtoken="No">
			</cfif>
			<ul>
			
<table width="400" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#990000">
	    <td>&nbsp;<b><font color="White">Error</font></b></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td width="350"><br><ul>&nbsp;<font face="Arial" size="2"  style="font-weight: bold;">You must select a catalog item.<br><br>Click the Back button to return to the previous screen.</font></ul></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td><input type="button" name="button" value="Back" onClick="history.back();"></td>
	</tr>
	</table>
	</ul>
		</cfif>
	
<!-------------------------------------- End code for the Library Category admin ---------------------------------------->


<cfelseif adminform is "4">
<cfparam name="filemanagement" default="0">
<!-------------------------------------- code for the File Management admin ---------------------------------------->
		<cfif filemanagement is 1>
			<cflocation url="fileuploader/fileuploadernav.cfm?index=2" addtoken="No">
		<cfelseif filemanagement is 2>
			<cflocation url="fileuploader/fileuploadernav.cfm?index=1" addtoken="No">
		<cfelseif filemanagement is 3>
			<cflocation url="fileuploader/fileuploadernav.cfm?index=3" addtoken="No">
		<cfelse>
			<ul>
<table width="400" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#990000">
	    <td>&nbsp;<b><font color="White">Error</font></b></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td width="350"><br><ul>&nbsp;<font face="Arial" size="2"  style="font-weight: bold;">You must select a catelog item and a function.<br><br>Click the Back button to return to the previous screen.</font></ul></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td><input type="button" name="button" value="Back" onClick="history.back();"></td>
	</tr>
	</table>
	</ul>
	</cfif>

<!-------------------------------------- code for the HR admin ---------------------------------------->
<cfelseif adminform is "5">

	 
	 	<cfif locat is 1>
			<cflocation url="HRjobpostlisting.cfm?region=#regionA1#&locat=#locat#" addtoken="No">
		</cfif>

			<cfif locat is 2>
				<cflocation url="HRjobpostlisting.cfm?region=#regionA2#&locat=#locat#" addtoken="No">
			</cfif>

			<cfif  locat is 3>
				<cflocation url="HRjobpostlisting.cfm?region=#regionA3#&locat=#locat#" addtoken="No">
			</cfif>
	
<!-------------------------------------- code for the user Management admin ---------------------------------------->
<cfelseif adminform is "6">
	<cfif function is 1>
			<cflocation url="usermgmt/bioentry.cfm" addtoken="No">
		<cfelseif function is 2>
			<cflocation url="usermgmt/bioupdate.cfm" addtoken="No">
		<cfelseif function is 3>
			<cflocation url="usermgmt/biodelete.cfm" addtoken="No">
		<cfelse>
			<ul>
<table width="400" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#990000">
	    <td>&nbsp;<b><font color="White">Error</font></b></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td width="350"><br><ul>&nbsp;<font face="Arial" size="2"  style="font-weight: bold;">You must select a function .<br><br>Click the Back button to return to the previous screen.</font></ul></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td><input type="button" name="button" value="Back" onClick="history.back();"></td>
	</tr>
	</table>
	</ul>
	</cfif>
	
	<cfelseif adminform is "7">
	<cfif function is 1>
			<cflocation url="groupmgmt/groupcreation.cfm" addtoken="No">
		<cfelseif function is 2>
			<cflocation url="groupmgmt/groupupdate.cfm" addtoken="No">
		<cfelseif function is 3>
			<cflocation url="groupmgmt/groupdelete.cfm" addtoken="No">
		<cfelse>
			<ul>
<table width="400" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#990000">
	    <td>&nbsp;<b><font color="White">Error</font></b></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td width="350"><br><ul>&nbsp;<font face="Arial" size="2"  style="font-weight: bold;">You must select a function .<br><br>Click the Back button to return to the previous screen.</font></ul></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td><input type="button" name="button" value="Back" onClick="history.back();"></td>
	</tr>
	</table>
	</ul>
	</cfif>
	
	<cfelseif adminform is "8">
			<cflocation url="securityassignmentmenu.cfm" addtoken="No">
	</cfif>

