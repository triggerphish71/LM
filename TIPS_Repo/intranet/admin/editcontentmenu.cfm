<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/editcontentmenu.cfm --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: May                       --->
<!--------------------------------------->
<cfset Datasource = "DMS">
<cfinclude template="/intranet/header.cfm">


<cfif url.departmentid is not "">
	<cfquery name="getdepartments" datasource="#Datasource#" dbtype="ODBC">
	Select department_ndx,department
	From VW_departments
	Where department_ndx = #URL.departmentid#
	</cfquery>
	
	<cfset locationbit = 2>
	<cfset headingvar = #URL.departmentid#>
<!--- 	<cfoutput>department headingvar: #headingvar#</cfoutput> --->
</cfif>


<cfif url.regionid is not "">
	<cfquery name="getregions" datasource="#Datasource#" dbtype="ODBC">
	Select region_ndx,regionname
	From VW_regions
	Where region_ndx = #URL.regionid#
	</cfquery>
	
	<cfset locationbit = 1>
	<cfset headingvar = #URL.regionid#>
	<!--- Region headingvar: <cfoutput>#headingvar#</cfoutput> --->
</cfif>

<cfif location is "home">
	<cfset headingvar = "6">
	<cfset locationbit = "1">
</cfif>

	<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
<cfquery name="getheading" datasource="#Datasource#" dbtype="ODBC">
	
	
<!--- ==============================================================================
Do not constrain for me or Noel Webb 07/17/2001
=============================================================================== --->
	<CFIF SESSION.USERID EQ 3025 OR SESSION.UserID EQ 3127 OR SESSION.UserID EQ 3133>
	
		Select cHeading,releases.ndx,medialocation.locationtypeid
		From releases,medialocation
		Where  medialocation.locationid = #headingvar# 
		AND medialocation.releasecontent = 1 
		AND medialocation.mediaid = releases.ndx 
		AND medialocation.locationtypeid = #locationbit# 
	
	<CFELSE>
	
		Select cHeading,releases.ndx,medialocation.locationtypeid
		From releases,medialocation
		Where  medialocation.locationid = #headingvar# 
		AND medialocation.releasecontent = 1 
		AND medialocation.mediaid = releases.ndx 
		AND medialocation.locationtypeid = #locationbit# 
		AND releases.postedby = #session.userid#
	
	</CFIF>

</cfquery>
<ul>

<form action="editcontent.cfm" method="post"><table width="600" cellspacing="2" cellpadding="2" border="0">
<tr bgcolor="#004080">
    <td colspan="2">&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Edit Content Menu</font></td>
</tr>
<tr bgcolor="#eaeaea">
    <td width="180" >
	&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Region/Department: </font></font>
</td>
<td>
<cfoutput>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a"><cfif url.regionid is not ""><input type="hidden" name="locationname" value="#getregions.regionname#">#getregions.regionname#</cfif><cfif url.departmentid is not "">#getdepartments.department#<input type="hidden" name="locationname" value="#getdepartments.department#"></cfif></font></cfoutput>
</td>
</tr>
<tr bgcolor="#eaeaea">
    <td width="180">
	&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Select an Entry to Change:  </font></font>
	
	</td>
	<td>
	<cfif getheading.recordcount is 0>
		<font face="Arial" size="3" color="#004080" style="font-weight: bold;">There are no entries to edit at this time.</font>
		<cfelse>
		
	
	<select name="recordndx">
		<option value="0" SELECTED>Select Heading</option>
		<cfoutput query="getheading"><option value="#ndx#" SELECTED>#cheading#</option></cfoutput>
	</select>
	</cfif>
	</td>
</tr>

<tr bgcolor="#eaeaea">
    <td width="180">&nbsp;</td>
	<td>
		<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
	<cfoutput><input type="hidden" name="headingvar" value="#headingvar#">
	<input type="hidden" name="locationtypeid" value="#getheading.locationtypeid#">
	</cfoutput>
	<cfif getheading.recordcount is 0>
	<input type="button" name="back" value="Back" onClick="history.back();">
	<cfelse>
	<input type="submit" name="submit" value="Retrieve">
	</cfif>
	</td>
</tr>
</table>

</form>

</ul>




<cfinclude template="/intranet/Footer.cfm">
</body>
</html>
