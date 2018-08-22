<!--- *****************************************************************************
Programmer: Andy Leontovich
File: admin/index2.cfm          
Company: Maxim Group/ALC        
Date: May                       

Revised by Paul Buendia 11/8/2001
Modifications: added comments and fixed lookup of images
				Problem: coded to look for 'disk9' 
						thus, infor for disk9 would come up for all disks
						with this format iel. disk90, disk9xx, disk9xxxx etc.
****************************************************************************** --->


<!--- ==============================================================================
Set Variable for the datasource
=============================================================================== --->
<CFSET DATASOURCE="DMS">

<!--- ==============================================================================
Include Intranet header
=============================================================================== --->
<cfinclude template="/intranet/header.cfm">

<!--- ==============================================================================
Set codeblockA to URL.ID
concept of codeblock was a convention used by author (Andy Leontovich) in many of 
the applications. 
=============================================================================== --->
<cfset codeblockA = URL.id>

<!--- ----------------------------------------------------------------------------------------------
<cfif IsDefined("session.codeblock")>
	<cfset codeblock = session.codeblock>
</cfif> 
----------------------------------------------------------------------------------------------- --->

<!--- ==============================================================================
place department and region queries up here for the menu below
=============================================================================== --->
<CFQUERY NAME="getdepartments" DATASOURCE="#datasource#">
	SELECT department_ndx,department From VW_departments
</cfquery>

<cfquery name="getregions" datasource="#datasource#">
<!--- 	Select regionname,nregionnumber,region_ndx From vw_regions --->
		Select cname,cnumber From vw_regions
</cfquery>

<cfquery name="gethrqueue" datasource="#datasource#">
	Select * From joblistings
</cfquery>

<CFIF gethrqueue.recordcount is not 0>
	<cfquery name="getHRregions" datasource="#datasource#">
		Select cname,cnumber
		From vw_regions
		Where cnumber IN(#valuelist(gethrqueue.nregionnumber)#)
	</cfquery>
</CFIF>

<cfquery name="PopHeading" datasource="#datasource#">
	select * from categories
</cfquery>


<table width="350" border="0" cellspacing="4" cellpadding="0">
<tr>
	<td colspan="4">
		<font color="Gray" style="font-family: Arial, Helvetica, sans-serif; font-size: large;">Site Administration</font>
		<hr align="left" width="100%" size="1" color="#ff9933" noshade>
	</td>
</tr>
</table>
<!---------------------------------- Begin Content Management ----------------------------------------------->
<cfif listfindNocase(session.codeblock,codeblockA) GT 0 AND codeblockA is 1>

		<form action="navigationadmin.cfm" method="post" name="resourcerec">
	<ul>
		<table width="270" border="0" cellspacing="2" cellpadding="2">
		
		<tr bgcolor="#9999cc">
		<td>&nbsp;<font color="white" style="font-family: Arial, Helvetica, sans-serif; font-size: medium;">Copy Management</font></td>
		</tr>
		
		<tr bgcolor="#f6f6f6">
		<td>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Function:&nbsp;
		<select name='function'>
		<option value="0" selected>Choose</option>
		<option value="1">Add content to...</option>
		<option value="2">Edit content in...</option>
		<option value="3">Delete content from...</option>
		</select></font></font>
		<input type="hidden" name="function_required" value="">
		</td>
		</tr>
		<tr bgcolor="#f6f6f6">
		<td>
		&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Location:</font></font>
		
		<table width="250" border="0" cellspacing="2" cellpadding="2">
		<tr>
		<td width="10">&nbsp;</td>
		<td width="10"><input type="radio" name="locat" value="home"></td>
		<td width="25"><font style="font-family: sans-serif; font-size: xx-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Home</font></font></td>
		<td>&nbsp;</td>
		</tr>
		<tr>
		<td width="10">&nbsp;</td>
		<td>&nbsp;</td>
		<td><font style="font-family: sans-serif; font-size: xx-small; font-style: italic; font-weight: bold;"><font color="#000000">or</font></font></td>
		<td>&nbsp;</td>
		</tr>
		<tr>
		<td width="10">&nbsp;</td>
		<td><input type="radio" name="locat" value="Department"></td>
		<td><font style="font-family: sans-serif; font-size: xx-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Departments</font></font></td>
		<td>
		<select name="departmentid" onChange="fieldset(2)">
		<option value="0" SELECTED>Choose</option>
		<cfoutput query="getdepartments"><option value="#department_ndx#">#department#</option></cfoutput>
		</select>
		</td>
		</tr>
		<tr>
		<td width="10">&nbsp;</td>
		<td>&nbsp;</td>
		<td><font style="font-family: sans-serif; font-size: xx-small; font-style: italic; font-weight: bold;"><font color="#000000">or</font></font></td>
		<td>&nbsp;</td>
		</tr>
		
		<tr>
		<td width="10">&nbsp;</td>
		<td><input type="radio" name="locat" value="Region"></td>
		<td><font style="font-family: sans-serif; font-size: xx-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Regions</font></font></td>
		<td><select name="regionid" onChange="fieldset(3)">
		<option value="" SELECTED>Choose</option>
		<cfoutput query="getregions"><option value="#cnumber#">#cname#</option></cfoutput>
		</select></td>
		</tr>
		</table>

		</td>
		</tr>
	
		<tr bgcolor="#eaeaea">
	   	 <td>&nbsp;<input type="submit" name="Submit" value="             GO            "><input type="hidden" name="adminform" value="1"></td></form>
		</tr>
		<tr bgcolor="#ffffff">
	   	 <td height="5"></td>
		</tr>
		</table></ul>
	
	</cfif>
<!---------------------------------- End Content Management ----------------------------------------------->

<!---------------------------------- Begin File Management ----------------------------------------------->
<cfif listfindNocase(session.codeblock,codeblockA) GT 0 AND codeblockA is 5>
<!--- <cfif listfindNocase(codeblock,5) GT 0> --->
	<form action="navigationadmin.cfm" method="post" name="files">
		
		<ul><table width="300" border="0" cellspacing="2"><tr bgcolor="#eaeaea">
		<tr bgcolor="#9999cc">
		<td>&nbsp;<font color="white" style="font-family: Arial, Helvetica, sans-serif; font-size: medium;">File Management</font></td>
		</tr>
		<tr bgcolor="#f7f7f7">
		<td><br><font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="Dimgray">&nbsp;Function:&nbsp;
		<select name='filemanagement'>
		<option value="0" selected>Choose</option>
		<option value="1">Upload a File</option>
		<option value="2">Edit a File</option>
		<option value="3">Delete a file</option>
		</select>
		</font>
		<input type="hidden" name="filemanagement_required" value=""><br><br>
		</td>
		</tr>
		<tr bgcolor="#eaeaea">
	   	 <td>&nbsp;<input type="submit" name="Submit" value="             GO            "><input type="hidden" name="adminform" value="4"></td>
		</tr></table></ul></form>
</cfif>
<!---------------------------------- Begin File Management ----------------------------------------------->


<!--------------------------------- Begin Library section ------------------------------>
<cfif listfindNocase(session.codeblock,codeblockA) GT 0 AND codeblockA is 12>
<!--- <cfif listfindNocase(codeblock,12) GT 0>	 --->	
<ul>	<form action="navigationadmin.cfm" name="lib" method="post">
		<table width="250" border="0" cellspacing="2" cellpadding="2">
		<tr>
			<td colspan="3" bgcolor="#9999cc">&nbsp;<font color="white" style="font-family: Arial, Helvetica, sans-serif; font-size: medium;">Library Categories</font></td>
		</tr>
		<tr bgcolor="#eaeaea">
		<td>
		&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Function:&nbsp;
		<select name='function'>
		<option value="" selected>Choose</option>
		<option value="1">Add</option>
		<option value="2">Edit</option>
		<option value="3">Delete</option>
		</select></font></font>
		<input type="hidden" name="function_required" value="">
		</td>
		</tr>
		<!---  <tr bgcolor="#f6f6f6">
		<td>
		<table cellspacing="2" cellpadding="2" border="0">
		<tr>
		    <td><input type="radio" name="Libselectiontype" value="1" checked></td>
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: xx-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Library Categories</font>
				</td>
		  
		</tr> --->
<!--- Will implement topics at another time --->
			<!--- <tr>
				
				<td>&nbsp;</td>
				<td><font style="font-family: sans-serif; font-size: xx-small; font-style: italic; font-weight: bold;"><font color="#000000">or</font></font></td>
				
				</tr>
		<tr>
		    <td><input type="radio" name="Libselectiontype" value="2"></td>
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: xx-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Library Topics</font></td>
		    
		</tr> --->
		<!--- </table>
		</td>
		</tr> --->
		<tr bgcolor="#eaeaea">
		  	 <td>&nbsp;<input type="submit" name="Submit" value="             GO            "><input type="hidden" name="adminform" value="3"></td>
		</tr>
		</table>
		<input type="hidden" name="Libselectiontype" value="1">
	</form></ul>
</cfif>	
<!-------------------------- End Library ---------------------------------------->


<!------------------------------- begin user management ---------------------------------->
<cfif listfindNocase(session.codeblock,codeblockA) GT 0 AND codeblockA is 13>
<!--- <cfif listfindNocase(codeblock,13) GT 0> --->
<cfquery name="getuserinfo" datasource="#datasource#" dbtype="ODBC">
	Select fname,lname,employee_ndx
	From users,vw_employees
	Where users.employeeid = vw_employees.employee_ndx
	and users.dtrowdeleted is null
	AND	expires > getdate() AND (last_accessed is not null or last_accessed > #CreateODBCDateTime(DateAdd('m',-2,now()))# )
	Order By fname
</cfquery>
<ul>
<form action="navigationadmin.cfm" name="lib" method="post">
	<table width="300" border="0" cellspacing="2" cellpadding="2">
	<tr bgcolor="#9999cc">
	    <td>&nbsp;<font color="white" style="font-family: Arial, Helvetica, sans-serif; font-size: medium;">User Management</font></td>
	</tr>
	<tr bgcolor="#f7f7f7">
	    <td>
		<BR>
		&nbsp;
		<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Function:&nbsp;
		<select name='function'>
		<option value="" selected>Choose</option>
		<option value="1">Add</option>
		<option value="2">Edit</option>
		<option value="3">Delete</option>
		</select>
		</font>
		<input type="hidden" name="function_required" value="">
		<BR><BR>
		</td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td>
			<input type="submit" name="submit" value="          GO         ">
			<input type="hidden" name="adminform" value="6">
		</td>
	</tr>
	</form>
	<tr bgcolor="#eaeaea">
		<td height="7">
		</td>
	</tr>
	<form action="/intranet/admin/usermgmt/bioreport.cfm" method="post">
	<tr bgcolor="#f7f7f7">
		<td>
		
			<br>
			&nbsp;<font color="Dimgray" style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;">User Summary:</font>&nbsp;
			<select name="userid">
				<option value="" SELECTED>Choose...</option>
				<cfoutput query="getuserinfo"><option value="#employee_ndx#">#fname# #lname#</option></cfoutput>
			</select>
			<br><br>
		</td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td>
			<input type="submit" name="submit" value="Get Report">
		</td>
	</tr>
	</form>
	</table>
	
	

</ul>
</cfif>
<!------------------------------- end user management ---------------------------------->




<!------------------------------- begin group management ---------------------------------->
<cfif listfindNocase(session.codeblock,codeblockA) GT 0 AND codeblockA is 14>
<!--- <cfif listfindNocase(codeblock,14) GT 0> --->
<ul><form action="navigationadmin.cfm" name="lib" method="post">
<table width="200" cellspacing="2" cellpadding="2" border="0">
<tr bgcolor="#9999cc">
    <td colspan="2">&nbsp;<font color="white" style="font-family: Arial, Helvetica, sans-serif; font-size: medium;">Group Management</font></td>
</tr>
<tr bgcolor="#f7f7f7">
    <td><BR>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Function:&nbsp;
		<select name='function'>
		<option value="" selected>Choose</option>
		<option value="1">Add</option>
		<option value="2">Edit</option>
		<option value="3">Delete</option>
		</select></font></font>
		<input type="hidden" name="function_required" value=""><BR><BR></td>
</tr>
<tr bgcolor="#eaeaea">
    <td colspan="2"><input type="submit" name="submit" value="             GO            "></td>
</tr>
</table>
<input type="hidden" name="adminform" value="7">
</form></ul>
<!------------------------------- end group management ---------------------------------->
</cfif>

<!--------------------------------- Begin Employment listing section ------------------------------>
<cfif listfindNocase(session.codeblock,codeblockA) GT 0 AND codeblockA is 15>
<!--- <cfif listfindNocase(codeblock,15) GT 0> --->
	<ul><form action="navigationadmin.cfm" method="post" name="emp" id="emp">
		<table width="200" cellspacing="2" cellpadding="2" border="0">
		<tr>
			<td colspan="3" bgcolor="#9999cc">&nbsp;<font color="white" style="font-family: Arial, Helvetica, sans-serif; font-size: medium;">Employment Listing</font></td>
		</tr>
			<tr bgcolor="#eaeaea">
		<td>
		&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Function:&nbsp;
		<select name='function'>
		<option value="" selected>Choose</option>
		<option value="1">Add</option>
		<option value="2">Edit</option>
		<option value="3">Delete</option>
		</select></font></font>
		<input type="hidden" name="function_required" value="">
		</td>
		</tr>
		<tr bgcolor="#f7f7f7">
		<td>
		
		<table width="200" border="0" cellspacing="2" cellpadding="2">
		<tr bgcolor="#fcfcfc">
		<td width="10">&nbsp;</td>
		<td align="center"><input type="radio" name="taskid" value="1"></td>
		<td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Job Categories</font></td>
		<td>&nbsp;</td>
		</tr>
		<tr>
		<td width="10">&nbsp;</td>
		<td>&nbsp;</td>
		<td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: italic; font-weight: bold;"><font color="#000000">or</font></font></td>
		<td>&nbsp;</td>
		</tr>
		
		<tr bgcolor="#fcfcfc">
		<td width="10">&nbsp;</td>
		<td align="center"><input type="radio" name="taskid" value="2"></td>
		<td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Job Posting</font></font></td>
		<td>&nbsp;
		
		</td>
		</tr>
		<tr>
		<td colspan="4">&nbsp;</td>
		</tr>
		<tr bgcolor="#fcfcfc">
		<td>&nbsp;</td>
		<td><font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Region:&nbsp;</font>
		
		<td colspan="2"><select name="region">
		<option value="" selected>Choose</option>
		<cfoutput query="getregions"><option value="#cnumber#">#cname#</option></cfoutput>
		</select>
		<!--- <input type="hidden" name="region_required" value=""> --->
		</td>
		</td>
		</tr>
		</table>
		<br>
		</td>
		</tr>
		<tr bgcolor="#eaeaea">
	   	 <td>&nbsp;<input type="submit" name="Submit" value="             GO            "><input type="hidden" name="adminform" value="2"></td>
		</tr>
		</table>
		<input type="hidden" name="region_required" value="">
		<input type="hidden" name="taskid_required" value="Please select a Job Category or a Job Posting">
		
</form>
</ul>
</cfif>
<!-------------------------- End Employment ---------------------------------------->

<!-------------------------- Begin HR Review ---------------------------------------->
<cfif listfindNocase(session.codeblock,codeblockA) GT 0 AND codeblockA is 20>

<form action="navigationadmin.cfm" method="post" name="hrform">
	<ul>
<table width="267" border="0" cellspacing="2" cellpadding="0">
  <tr bgcolor="#9999cc"> 
    <td colspan="4">&nbsp;<font color="#ffffff" style="font-family: sans-serif; font-size: medium; font-style: normal;">HR Review</font></td>
  </tr>
  <tr bgcolor="#f7f7f7"><td height="7" colspan="4"></td></tr>


<cfset norecmessage = 0>
<cfset loopcounter = 0>

<cfloop index="index" from="1" to="3">

<cfoutput><script language="JavaScript1.2" type="text/javascript">
<!--
	function validate#index#()
	{
		document.hrform.validatefield.value = document.hrform.regionA#index#.value
	}
//-->
</script>
</cfoutput>
	<cfquery name="gethractive" datasource="#datasource#" dbtype="ODBC">
		SELECT distinct joblistings.nregionnumber,joblistings.form_ndx,joblistings.hractive,vw_regions.regionname
		FROM joblistings,vw_regions
		WHERE joblistings.nregionnumber = vw_regions.nregionnumber AND joblistings.hractive = #index#
	</cfquery>

	<cfif gethractive.recordcount is not 0>

	  <tr bgcolor="#f7f7f7"> 
	    <td width="20">&nbsp;</td>
	    <td width="27" align="center" valign="middle"> 
	     <cfoutput> <input type="radio" name="locat" value="#index#"></cfoutput>
	    </td>
			<cfif index is 1>
					    <td width="64">&nbsp;<font color="Gray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Add</font></td>
			<cfelseif index is 2>
					    <td width="64">&nbsp;<font color="Gray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Edit</font></td>
			<cfelse>
						<td width="64">&nbsp;<font color="Gray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Delete</font></td>
			</cfif>
	    <td width="156"> 
		
	     <cfoutput> <select name="regionA#index#" onChange="validate#index#();"> </cfoutput>
	        <option value="">Choose...</option>
			<cfoutput query="gethractive" group="nregionnumber">
				<option value="#nregionnumber#">#regionname#</option>
			</cfoutput>
	      </select>
	    </td>
	  </tr>
	<cfset loopcounter = loopcounter+1>
	</cfif>
	<cfset norecmessage = norecmessage+gethractive.recordcount>
</cfloop>

<cfif gethractive.recordcount is 0 AND norecmessage is 0>
<!--- <cfif index is 3 AND norecmessage is 0> --->
 <tr bgcolor="#f7f7f7"> 
    <td colspan="4"> 
	<BR>
     <ul><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">There are no requests in the queue.</font></ul>
    </td>
  </tr>
    <tr bgcolor="#eaeaea"> 
    <td colspan="4">&nbsp; 
     
    </td>
  </tr>
</table>
<cfelse>

  <tr bgcolor="#f7f7f7">
  <td height="7" colspan="4"></td>
  </tr>
  <tr bgcolor="#eaeaea"> 
    <td colspan="4"> 
      <input type="submit" name="Submit" value="View Listing">

    </td>
  </tr>
</table>
</font>
</ul>
<input type="hidden" name="adminform" value="5">


<input type="hidden" name="validatefield" >
 <input type="hidden" name="validatefield_required" value="Please select a region from the drop-down field next to the appropriate radio button.">

 <input type="hidden" name="locat_required" value="Please select Add, Edit, or Delete">
</form>
</cfif>
</table>
</cfif> 
<!-------------------------- End HR Review ---------------------------------------->
<!------------------------------- begin security assignment ---------------------------------->
<cfif listfindNocase(session.codeblock,codeblockA) GT 0 AND codeblockA is 19>
<ul>

<table width="310" cellspacing="2" cellpadding="0" border="0">
<tr bgcolor="#9999cc">
    <td><font color="White" style="font-family: sans-serif; font-size: small; font-weight: bold;">Security Assignments</font></td>
</tr>
<tr bgcolor="#eaeaea">
    <td>
	<form action="securityassignment.cfm" method="post">
		<table cellspacing="2" cellpadding="2" border="0" width="300" >
			<tr>
			    <td colspan="2">&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;"><font color="Dimgray">Assign:</font></td>
			</tr>
			<tr bgcolor="#f7f7f7">
			    <td width="35" align="center"><input type="radio" name="function" value="1"></td>
			    <td><font style="font-family: sans-serif; font-size: xx-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Employee to Groups</font></td>
			</tr>
			<tr bgcolor="#f7f7f7">
			    <td colspan="2">&nbsp;&nbsp;&nbsp;<font style="font-family: sans-serif; font-size: xx-small; font-style: italic; font-weight: bold;"><font color="#000000">or</font></td>
			</tr>
			<tr bgcolor="#f7f7f7">
			    <td width="35" align="center"><input type="radio" name="function" value="2"></td>
			    <td><font style="font-family: sans-serif; font-size: xx-small; font-style: normal; font-weight: bold;"><font color="Dimgray">Site Feature to Groups</font></td>
			</tr>
			<tr bgcolor="#eaeaea">
			    <td colspan="2"><input type="submit" name="submit" value="             GO            "></td>
			</tr>
		</table>
</form>
	
	</td>
</tr>
<tr bgcolor="#eaeaea">
    <td height="7">
	<!--- comment: just a space--->
	</td>
</tr>
<tr bgcolor="#eaeaea">
    <td>
		<form action="security_group_report.cfm" method="post">
			<table cellspacing="2" border="0" width="300">
			<tr bgcolor="#eaeaea">
			    <td colspan="2">&nbsp;<font color="Gray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Security Group Reports</font></td>
			</tr>
			<tr bgcolor="#f7f7f7">
			    <td width="35" align="center"><input type="radio" name="report" value="1"></td>
			    <td>&nbsp;<font color="Gray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">Groups By Site Sections</font></td>
			</tr>
			<tr bgcolor="#f7f7f7">
			    <td width="35" align="center"><input type="radio" name="report" value="3"></td>
			    <td>&nbsp;<font color="Gray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">Groups By House</font></td>
			</tr>
			<tr bgcolor="#f7f7f7">
			    <td width="35" align="center"><input type="radio" name="report" value="2"></td>
			    <td>&nbsp;<font color="Gray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">Groups By Users</font></td>
			</tr>
			<tr bgcolor="#eaeaea">
			    <td colspan="2"><input type="submit" name="submit" value="Get Report"></td>
			</tr>
			</table>
		</form>
	</td>
</tr>
</table>
</ul>
</cfif>

<!------------------------------- begin Document Imaging Management ---------------------------------->
<cfif listfindNocase(session.codeblock,codeblockA) GT 0 AND codeblockA is 33>
	
		<!--- <cfquery name="getcurrentindex" datasource="DMS" dbtype="ODBC">
			Select distinct path
			From acctdocs
			Order By path
		</cfquery>
		
		<cfparam name="submit" default="Index another directory">
		
		<cfif submit is "Index another directory">
		
		<cfdirectory action="LIST" directory="G:\scannedimages" name="imagedirs">
		
		<ul>
		<form action="newimageindex.cfm" method="post">
			<table width="520" cellspacing="2" cellpadding="2" border="0">
			<tr bgcolor="#008080">
			    <td colspan="2">&nbsp;<font color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Index Upload</font></td>
			</tr>
			<tr bgcolor="#f7f7f7">
			    <td>
				<ul>
				<BR>
				<font color="#5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Select a directory to index.</font>
				<BR>
				<select name="dir" size="1">
					<cfoutput query="imagedirs">
					<cfif name is not "." AND name is not "..">
					<option value="#name#">#name#</option>
					</cfif>
					</cfoutput>
				</select>
				</ul>
				</td>
				<td align="center">
					<font color="#5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Currently Indexed:</font><BR>
					<cfset showindex = 0>
					<select name="" size="10">
						<cfoutput query="getcurrentindex">
						<cfset indexdir = listgetat(path,1,"\")>
						<cfif indexdir is not showindex>
							<option value="">#indexdir#</option>
						</cfif>
						<cfset showindex = indexdir>
						</cfoutput>
					</select>
				</td>
			</tr>
			<tr bgcolor="#eaeaea">
			    <td colspan="2"><input type="submit" name="Submit" value="Begin Indexing"></td>
			</tr>
			</table>
					<input type="hidden" name="page" value="1">
		</form>
		</ul>
		
		<cfelseif submit is "Begin Indexing">
		
		<cfdirectory action="LIST" directory="G:\scannedimages\#dir#" name="images">
		<cfoutput query="images"><!--- the main loop --->
			<cfif name is not "." AND name is not "..">
				<cfset nhouse2 = listgetat(name,1,"-")>
				<cfset nhouse = Right(nhouse2,3)>
				<cfset file = listgetat(name,2,"-")>
				<!--- 	<cfset nhouse =nhouse> --->
				<cfset checknum = listgetat(file,1,".")>
		<!---------------- data from Solomon ---------------------------------->
			<cfif nhouse is not "000">
					 <cfquery name="imageindex" datasource="dms" dbtype="ODBC">
						exec HouseCall '#nhouse#','#checknum#'
					</cfquery> 
					
					<cfloop query="imageindex">
						<cfquery name="insertrecord" datasource="DMS" dbtype="ODBC">
						Insert into acctdocs(housenum,checknum,path,adjgrefnbr,acct,sub,adjddocdate,invcdate,adjgdocdate,origdocamt,vendid,vend_name,adjdrefnbr,invcnbr,tranamt,indexdate)
						Values(#nhouse#,'#Trim(checknum)#','#dir#\#file#','#Trim(imageindex.adjgrefnbr)#','#Trim(imageindex.acct)#','#Trim(imageindex.sub)#','#dateformat(imageindex.docdate)#','#dateformat(imageindex.invcdate)#','#dateformat(imageindex.adjgdocdate)#',#Trim(imageindex.origdocamt)#,'#Trim(imageindex.vendid)#','#Trim(imageindex.name)#','#Trim(imageindex.adjdrefnbr)#','#Trim(imageindex.invcnbr)#',#Trim(imageindex.tranamt)#,'#dateformat(Now())#')
						</cfquery>
					</cfloop>
					
				<cfelse> 
					<cfquery name="Corpimageindex" datasource="dms" dbtype="ODBC">
					exec CorpCall '#checknum#'
					</cfquery>
					
					<cfloop query="Corpimageindex">
						<cfquery name="insertrecord" datasource="DMS" dbtype="ODBC">
						Insert into acctdocs(housenum,checknum,path,adjgrefnbr,acct,sub,adjddocdate,invcdate,adjgdocdate,origdocamt,vendid,vend_name,adjdrefnbr,invcnbr,tranamt,indexdate)
						Values(#nhouse#,'#Trim(checknum)#','#dir#\#file#','#Trim(Corpimageindex.adjgrefnbr)#','#Trim(Corpimageindex.acct)#','#Trim(Corpimageindex.sub)#','#dateformat(Corpimageindex.docdate)#','#dateformat(Corpimageindex.invcdate)#','#dateformat(Corpimageindex.adjgdocdate)#',#Corpimageindex.origdocamt#,'#Trim(Corpimageindex.vendid)#','#Trim(Corpimageindex.name)#','#Trim(Corpimageindex.adjdrefnbr)#','#Trim(Corpimageindex.invcnbr)#',#Trim(Corpimageindex.tranamt)#,'#dateformat(Now())#')
						</cfquery>
					</cfloop>
				</cfif> 
		<!---------------- end data from Solomon -------------------------------->
				
			</cfif>
		</cfoutput>
		
		<form action="newimageindex.cfm" method="post">
		<ul>
			<table width="400" cellspacing="2" cellpadding="2" border="0">
				<tr bgcolor="#008080">
				    <td colspan="2">&nbsp;<font color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Indexing Complete</font></td>
				</tr>
				<tr bgcolor="#f7f7f7">
				    <td>
						<ul>
							<font color="#5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The records were added to the system.</font>
						</ul>
					</td>
				</tr>
				<tr bgcolor="#eaeaea">
					<input type="hidden" name="page" value="0">
				    <td>
						<input type="submit" name="Submit" value="Index Another Directory">
					</td>
				</tr>
			</table>
			</ul>
		</form>
		</cfif>

 --->
 <!---  Select distinct path From acctdoc_new Order By path --->
<cfquery name="getcurrentindex" datasource="DMS" dbtype="ODBC">
Select distinct left(path,(charindex('\',path,1)-1)) as path
From acctdoc_new 
where path <> '\intranet\documentimaging\noimagedoc.cfm'
Order By left(path,(charindex('\',path,1)-1))
</cfquery>
<cfset datasource = "DMS">

<cfparam name="submit" default="Index another directory">



<cfif submit is "Index another directory">
	<cfdirectory action="LIST" directory="D:\Scanned Images\ScannedImages" name="imagedirs">

	<ul>
	<form action="index2.cfm?id=33" method="post">
	<table width="520" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#008080">
	    <td colspan="2">&nbsp;<font color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Index Upload</font></td>
	</tr>
	<tr bgcolor="#f7f7f7">
	    <td>
			<ul><BR>
			
			<font color="#5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">
				Select a directory to index.
			</font>
			<BR>
			
			<select name="dir" size="1">
				<cfoutput query="imagedirs">
					<cfif name is not "." AND name is not "..">
					<option value="#name#">#name#</option>
					</cfif>
				</cfoutput>
			</select>
			
			</ul>
		</td>
		
		<td align="center">
			<font color="#5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Currently Indexed:</font><BR>
			<cfset showindex = 0>
			<select name="" size="10">
				<cfoutput query="getcurrentindex">
				<cfset indexdir = trim(path)>
				<!--- <cfset indexdir = listgetat(path,1,"\")> --->
				<cfif indexdir is not showindex>
					<option value="">#indexdir#</option>
				</cfif>
				<cfset showindex = indexdir>
				</cfoutput>
			</select>
		</td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td colspan="2"><input type="submit" name="Submit" value="Begin Indexing"></td>
	</tr>
	</table>
			<input type="hidden" name="page" value="1">
</form>
</ul>

<cfelseif submit is "Begin Indexing">

<cfdirectory action="LIST" directory="G:\scannedimages\#dir#" name="images">

<cfoutput query="images"><!--- the main loop --->
	<cfif name is not "." AND name is not "..">
		<cfset nhouse2 = listgetat(name,1,"-")>
		#nhouse2#,
		<cfset nhouse = Right(nhouse2,3)>
		#nhouse#,
		<cfset file = listgetat(name,2,"-")>
		<!--- 	<cfset nhouse =nhouse> --->
		<cfset checknum = listgetat(file,1,".")>
		#checknum#,
		#file#<BR>
	<!---------------- data for tempdocs -------------------------------------------------->
	<!--- comment:find document-imaging and convert to documentimaging--->
	

		<cfquery name="insertrecord" datasource="DMS" dbtype="ODBC">
			Insert into tempdocs
				(
					housenum,checknum,path
				)Values(
					#nhouse#,'#Trim(checknum)#','#dir#\#file#'
				)
		</cfquery>

		
	<!---------------- end data from Solomon -------------------------------------------------->
	</cfif>
</cfoutput>


<!--- comment: update acctdocs with temp data from tempdocs table---------------------------------------->
<cfquery name="updateaccts" datasource="#datasource#" dbtype="ODBC">
	exec im_index
</cfquery>


<!--- comment: End update acctdocs with temp data from tempdocs table---------------------------------------->
<form action="index2.cfm?id=33" method="post">
<ul>
	<table width="400" cellspacing="2" cellpadding="2" border="0">
		<tr bgcolor="#008080">
		    <td colspan="2">&nbsp;<font color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Indexing Complete</font></td>
		</tr>
		<tr bgcolor="#f7f7f7">
		    <td>
				<ul>
					<font color="#5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The records were added to the system.</font>
				</ul>
			</td>
		</tr>
		<tr bgcolor="#eaeaea">
			<input type="hidden" name="page" value="0">
		    <td>
				<input type="submit" name="Submit" value="Index Another Directory">
			</td>
		</tr>
	</table>
	</ul>
</form>
</cfif>
</cfif>
<!------------------------------- end Document Imaging Management ---------------------------------->
<cfif listfindNocase(session.codeblock,codeblockA) is 0>
	<font color="Maroon" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">You do not have access to this area!</font>
<br><br>
</cfif>
<cfinclude template="/intranet/Footer.cfm">

