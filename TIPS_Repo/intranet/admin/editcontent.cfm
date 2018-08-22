
<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/editcontent.cfm     --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: june                       --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfinclude template="/intranet/header.cfm">
<script language="JavaScript1.2" type="text/javascript">
<!--
		function getlibfile()
	{
		//var catid = window.document.resourcerec.fileid.value;
		//alert(catid);
		
		assign('libassign.cfm',1,1)
		
	}
	
		function changequotes()
	{
		var str = document.resourcerec.content.value;
		var newstr = str.replace(/"/g, "'");
		window.document.resourcerec.content.value = newstr;
	}
//-->
</script>
<cfparam name="locationname" default="home">

<cfif headingvar is 0>
	<cfset headingvar = "6">
</cfif>
<cfquery name="getentry" datasource="#datasource#" dbtype="ODBC">
Select *
From Releases
Where ndx = #recordndx#
</cfquery>


<cfquery name="getuser" datasource="#datasource#" dbtype="ODBC">
Select fname,lname
From vw_employees
Where employee_ndx = #session.userid#</cfquery>

	<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
<cfquery name="getmedia" datasource="#datasource#" dbtype="ODBC">
Select mediainfo.filename,mediainfo.uniqueid,medialocation.locationid
From mediainfo,medialocation
Where mediainfo.uniqueid = medialocation.mediaid AND medialocation.mediacontent = 1 AND locationtypeid = #locationtypeid# AND locationid = #headingvar#
</cfquery>

<cfquery name="getcurrentmedia" datasource="#datasource#" dbtype="ODBC">
Select filename,uniqueid,fileextention
From mediainfo
Where uniqueid = #getentry.mediainfouniqueid#
</cfquery>

<cfquery name="getfileassgnname" datasource="#datasource#" dbtype="ODBC">
Select filename,fileextention
From mediainfo
Where mediainfo.uniqueid = #getentry.nfilendx#
</cfquery>

<ul>

<cfoutput query="getentry">
<form action="Preview.cfm" method="post" name="resourcerec" onSubmit="changequotes();">
		<table width="700" border="0" cellspacing="2" cellpadding="2">
		<tr>
		    <td colspan="5" bgcolor="##004080">&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Edit Content</font></td>
		</tr>
		<tr>
		    <td colspan="5" bgcolor="##eaeaea">&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Editor:</font>&nbsp;&nbsp;#getuser.fname# #getuser.lname#</td>
		</tr>
		<tr bgcolor="##eaeaea">
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">"What's New?</font></font></td>
		    <td>
			<cfif nwhatsnew is 0>
					<font color="Gray" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Yes:</font><input type="radio" name="whatsnew" value="1">&nbsp;&nbsp; <font color="Gray" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">No:</font><input type="radio" name="whatsnew" value="0" checked>
			<cfelse>
					<font color="Gray" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Yes:</font><input type="radio" name="whatsnew" value="1" checked>&nbsp;&nbsp; <font color="Gray" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">No:</font><input type="radio" name="whatsnew" value="0">
			</cfif>
			</td>
			<td><font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a"> Banner Expires:</td> 
			<td colspan="2">&nbsp;<A href="javascript:calendar(9)"><img src="../pix/calendaricon.gif" width="19" height="20" alt="" border="0" align="absmiddle"></A>&nbsp;<input type="text" name="whatsnewexpirationdate" value="#DateFormat(bannerexpiresdate,"mm/dd/yy")#" size="10" maxlength="10"></td>
		</tr>
		<tr bgcolor="##eaeaea">
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Heading:</font></font></td>
		    <td colspan="4"><input type="text" name="heading" value="#cHeading#" size="50" maxlength="100"></td>
		</tr>
		<tr bgcolor="##eaeaea">
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Sub Heading:</font></font></td>
		    <td colspan="4"><input type="text" name="subheading" value="#csubheading#" size="50" maxlength="100"></td>
		</tr>
		<tr bgcolor="##eaeaea">
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Content:</font></font></td>
		    <td colspan="4"><textarea cols="65" rows="12" name="content">#content#</textarea></td>
		</tr>
		<tr bgcolor="##f7f7f7">
		<cfif getmedia.recordcount is not 0>
			<cfset spannum = 0>
		<cfelse>
			<cfset spannum = 4>
		</cfif>
		
		<cfif getmedia.recordcount is not 0>
		    <td width="150">&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Select Illustration:</font></font></td>
		   <td colspan="#spannum#">
			
			<select name="fileid">
				<cfif getcurrentmedia.recordcount is not 0>
				<cfloop query="getcurrentmedia"><option value="#getcurrentmedia.uniqueid#" SELECTED>#getcurrentmedia.filename#</option></cfloop>
				<option value="">__________</option>
			<cfelse>
				<option value="" SELECTED>Choose</option>
			</cfif>
				<cfloop query="getmedia"><option value="#getmedia.uniqueid#">#getmedia.filename#</option></cfloop>
			</select>
		</td>
		</cfif>
		
		  <td>
		  
		&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Select Library File:</font></font>
		</td>
		   <td colspan="#spannum#" align="center">
			<input type="button" name="getlib" value="Open Library" onClick="getlibfile()";>
			<BR><Br>
			<input type="text" name="fileassignname" readonly>
		</td>
		</tr>
		<tr bgcolor="##f7f7f7">
		<cfif getmedia.recordcount is not 0>
			<cfset spannum = 0>
		<cfelse>
			<cfset spannum = 4>
		</cfif>
		
		<cfif getmedia.recordcount is not 0>
		    <td width="150">&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Current File:</font></font>
		</td></td>
		   <td colspan="#spannum#">
			<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;">#getcurrentmedia.filename#.#getcurrentmedia.fileextention#</font>
		</td>
		</cfif>
		
		  <td>
		&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Current File:</font></font>
		</td>
		   <td colspan="#spannum#">
			<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;">#getfileassgnname.filename#.#getfileassgnname.fileextention#</font>
		</td>
		</tr>
		<tr bgcolor="##f7f7f7">
		<cfif getmedia.recordcount is not 0>
			<cfset spannum = 0>
		<cfelse>
			<cfset spannum = 4>
		</cfif>
		
		<cfif getmedia.recordcount is not 0>
		    <td width="150">&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Unlink Illustration:</font></font></td>
		   <td colspan="#spannum#">
			<input type="checkbox" name="unlinkIllus" value="1">
		</td>
		</cfif>
		
		  <td>
		&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Unlink Library File:</font></font>
		</td>
		   <td colspan="#spannum#">
			&nbsp;<input type="checkbox" name="unlinkLib" value="1">
		</td>
		</tr>
		
		
		<!--- <tr bgcolor="##eaeaea">
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Link File:</font></font></td>
		    <td colspan="4"><select name="fileid">
			<cfif getcurrentmedia.recordcount is not 0>
				<cfloop query="getcurrentmedia"><option value="#getcurrentmedia.uniqueid#" SELECTED>#getcurrentmedia.filename#</option></cfloop>
				<option value="">__________</option>
			<cfelse>
				<option value="" SELECTED>Choose</option>
			</cfif>
				<cfloop query="getmedia"><option value="#getmedia.uniqueid#">#getmedia.filename#</option></cfloop>
			</select>&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Unlink File:&nbsp;<input type="checkbox" name="unlink" value="1"></font>
			
			</td>
		  
		</tr> --->
		<tr bgcolor="##eaeaea">
		    <td>&nbsp;<A href="javascript:calendar(1)"><img src="/intranet/pix/calendaricon.gif" width="19" height="20" alt="" border="0"></A>&nbsp; <font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Post Date:</font></font></td>
		    <td colspan="4"><input type="text" name="postdate" value="#DateFormat(dpostdate,"mm/dd/yy")#" size="12" maxlength="12">&nbsp;&nbsp;<font face="Arial" size="1">*Entry will be posted on the date entered.</font></td>
		</tr>
		<tr bgcolor="##eaeaea">
		    <td>&nbsp;<A href="javascript:calendar(2)"><img src="/intranet/pix/calendaricon.gif" width="19" height="20" alt="" border="0"></A>&nbsp; <font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Expiration Date:</font></font></td>
		    <td colspan="4"><input type="text" name="expirationdate" value="#DateFormat(dexpirationdate,"mm/dd/yy")#" size="12" maxlength="12">&nbsp;&nbsp;<font face="Arial" size="1">You will be emailed the day the entry expires. The entry will not be deleted from the system.</font></td>
		</tr>
		<cfif locationname is "training">
			
		
			<cfquery name="getallregions" datasource="#datasource#" dbtype="ODBC">
			Select region_ndx,regionname
			From vw_regions
			</cfquery>
			
			<cfquery name="getregion" datasource="#datasource#" dbtype="ODBC">
			Select region_ndx,regionname
			From vw_regions,medialocation,releases
			Where medialocation.publishto = vw_regions.region_ndx AND medialocation.mediaid = releases.ndx AND releases.ndx = #recordndx#
			</cfquery>
		<tr bgcolor="##f7f7f7">
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Publish in region:</font></td>
		    <td colspan="4">
			<select name="publishto">
			<cfloop query="getregion"><option value="#getregion.region_ndx#" Selected>#getregion.regionname#</option></cfloop>
				<cfloop query="getallregions"><option value="#getallregions.Region_Ndx#">#getallregions.regionname#</option></cfloop>
			</select>
		</td>
		</tr>
		</cfif>
		<tr bgcolor="##eaeaea">
		    <td>&nbsp;</td>
		    <td colspan="4"><input type="submit" name="Submit" value="Preview"></td>
		</tr>
		</table>
		<input type="hidden" name="ndx" value="#getentry.ndx#">
		
		<input type="hidden" name="fileassign" value="#getentry.nfilendx#">
		<input type="hidden" name="previewcode" value="2">
	</form>
	</cfoutput>
</ul>

<cfinclude template="/intranet/Footer.cfm">
</BODY>
</html>
