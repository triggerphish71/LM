<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/addcontent.cfm      --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: May                       --->
<!--------------------------------------->

<CFSET DATASOURCE = "DMS">

<CFPARAM NAME = "location" DEFAULT = "">


<!--- ==============================================================================
	Comment: medialocation.locationtypeid is used to track the global location of the content. 
	medialocation.locationtypeid,locationid need to be deprecated in the next release of the 
	content management system.
=============================================================================== --->
<CFIF URL.regionid IS NOT "">
	<CFSET locationtypeid = 1>
	<CFSET headingvar = URL.regionid>
<CFELSEIF URL.departmentid IS NOT "">
	<CFSET locationtypeid = 2>
	<CFSET headingvar = departmentid>
</CFIF>

<CFIF URL.location IS "home">
	<cfset locationtypeid = 1><!--- comment: changed from three--->
	<cfset headingvar = 6>
</CFIF>


<!--- ==============================================================================
Retrieve Departmental Information
=============================================================================== --->
<CFQUERY NAME = "getdepartments" DATASOURCE = "#datasource#" dbtype="ODBC">
	SELECT 	department_ndx,department
	FROM 	vw_departments
	WHERE 	department_ndx = '#url.departmentid#'
</CFQUERY>


<!--- ==============================================================================
Retrieve Region information if a region was chosen
=============================================================================== --->
<CFIF url.regionid IS NOT  "">
	<CFQUERY NAME = "getregions" DATASOURCE = "#datasource#" dbtype="ODBC">
		Select region_ndx,regionname
		From VW_regions
		where region_ndx = '#url.regionid#'
	</CFQUERY>
	
	<CFIF getregions.region_ndx is 6>
		<cfset headingvar = 6>
	</CFIF>
</CFIF>


	<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
<CFQUERY NAME = "getmedia" DATASOURCE = "#datasource#" dbtype="ODBC">
	SELECT 	mediainfo.filename,
			mediainfo.uniqueid,
			medialocation.locationid
	
	FROM 	mediainfo,medialocation
	WHERE 	mediainfo.uniqueid = medialocation.mediaid AND medialocation.mediacontent = 1 AND medialocation.locationtypeid = #locationtypeid# AND locationid = #headingvar#
</CFQUERY>


<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE = "/intranet/header.cfm">


<script language="JavaScript1.2" type="text/javascript">
<!--
var theselection = "&nbsp;&nbsp;<font style='font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;'>No Files Selected</font>";
 
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


<UL>
	<FORM ACTION = "preview.cfm" METHOD = "post" NAME = "resourcerec" ID="resourcerec" onSubmit="changequotes();">
		<table width="683" border="0" cellspacing="2" cellpadding="2">
		<tr>
		    <td colspan="5" bgcolor="#9999cc">&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Add Content To: <cfoutput>#location# - <cfif url.regionid is not  ""><cfif getregions.regionname is "ALC Home Office">Home<cfelse>#getregions.regionname#</cfif></cfif> #getdepartments.Department#</cfoutput></font></td>
		</tr>
		 
		<tr bgcolor="#f7f7f7">
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">"What's New?</font></font></td>
		    <td><font color="#5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Yes:<input type="radio" name="whatsnew" value="1">&nbsp;&nbsp; No:<input type="radio" name="whatsnew" value="0" checked></font></td>
<td><font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a"> Banner Expires:</td> 
			<td colspan="2">&nbsp;<A href="javascript:calendar(9)"><img src="../pix/calendaricon.gif" width="19" height="20" alt="" border="0" align="absmiddle"></A>&nbsp;<input type="text" name="whatsnewexpirationdate" size="10" maxlength="10"></td>
		</tr>
		<tr bgcolor="#eaeaea">
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Heading:</font></font></td>
		    <td colspan="4"><input type="text" name="heading" size="50" maxlength="100"></td>
		</tr>
		<tr bgcolor="#eaeaea">
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Sub Heading:</font></font></td>
		    <td colspan="4"><input type="text" name="subheading" size="50" maxlength="100"></td>
		</tr>
		<tr bgcolor="#eaeaea">
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Content:</font></font></td>
		    <td colspan="4"><textarea cols="60" rows="6" name="content" wrap="hard"></textarea></td>
		</tr>

		<tr bgcolor="#f7f7f7">
		<!--- comment: Spannum is a variable used to set the column span based on whether or no there are illustration files available for use. Simply, the query results determine the page format--->
		<cfif getmedia.recordcount is not 0>
			<cfset spannum = 0>
		<cfelse>
			<cfset spannum = 4>
		</cfif>
		
		<cfif getmedia.recordcount is not 0>
		    <td width="150">&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Select Illustration:</font></font></td>
		   <cfoutput> <td colspan="#spannum#"></cfoutput>
			
			<select name="fileid">
				<option value="" SELECTED>Choose...</option>
				<cfoutput query="getmedia"><option value="#uniqueid#">#filename#</option></cfoutput>
			</select>
		</td>
		</cfif>
		
		  <td width="150">
		&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Library Files:</font></font>
		</td>
		    <cfoutput><td colspan="#spannum#" align="center"></cfoutput>
			<input type="button" name="getlib" value="Open Library" onClick="getlibfile()";>
			<BR><Br>
			<input type="text" name="fileassignname" readonly>
		</td>
		</tr>
		
		<tr bgcolor="#eaeaea">
		    <td>&nbsp;<A href="javascript:calendar(1)"><img src="/intranet/pix/calendaricon.gif" width="19" height="20" alt="" border="0" align="absmiddle"></A>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Post Date:</font></font></td>
		    <td colspan="4"><input type="text" name="postdate" size="12" maxlength="12">&nbsp;&nbsp;<font face="verdana" size="1">*Entry will be posted on the date entered.</font></td>
		</tr>
		<tr bgcolor="#eaeaea">
		    <td>&nbsp;<A href="javascript:calendar(2)"><img src="/intranet/pix/calendaricon.gif" width="19" height="20" alt="" border="0" align="absmiddle"></A>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Expiration Date:</font></font></td>
		    <td colspan="4"><input type="text" name="expirationdate" size="12" maxlength="12">&nbsp;&nbsp;<font face="verdana" size="1">You will be emailed the day the entry expires. The entry will not be deleted from the system.</font></td>
		</tr>
		
		<cfif #getdepartments.Department# is "training">
			<cfquery name="getregionsall" datasource="#datasource#" dbtype="ODBC">
			Select region_ndx,regionname
			From vw_regions
			</cfquery> 

		<tr bgcolor="#f7f7f7">
		    <td>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Publish in region:</font></td>
		    <td colspan="4">
			<select name="publishto">
			<option value="0" Selected>None</option>
				<cfoutput query="getregionsall"><option value="#Region_Ndx#">#regionname#</option></cfoutput>
			</select>
		</td>
		</tr>
		</cfif>
		<tr bgcolor="#eaeaea">
		    <td>&nbsp;</td>
		    <td colspan="4"><input type="submit" name="Submit" value="Preview"></td>
		</tr>
		</table>
		<input type="hidden" name="previewcode" value="1">
		<input type="hidden" name="fileassign" value="0">
		<cfoutput><input type="hidden" name="region" value="#URL.regionid#">
		<input type="hidden" name="department" value="#getdepartments.department_ndx#">
		<input type="hidden" name="locationtypeid" value="3"></cfoutput>
	</form>
</ul>




<cfinclude template="/intranet/Footer.cfm">

