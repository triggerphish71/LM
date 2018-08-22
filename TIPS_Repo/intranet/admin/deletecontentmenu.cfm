<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/editcontentmenu.cfm --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: May                       --->
<!--------------------------------------->
<cfset datasource = "DMS">
<cfinclude template="/intranet/header.cfm">


<cfif url.departmentid is not "">
	<cfquery name="getdepartments" datasource="#datasource#" dbtype="ODBC">
	Select department_ndx,department
	From vw_departments
	Where department_ndx = #URL.departmentid#
	</cfquery>
	
	<cfset locationbit = 2>
	<cfset headingvar = #URL.departmentid#>
</cfif>

<cfif location is "home">
	<cfset headingvar = "0">
	<cfset locationbit = "3">
</cfif>

<cfif url.regionid is not "">
	<cfquery name="getregions" datasource="#datasource#" dbtype="ODBC">
	Select region_ndx,regionname
	From vw_regions
	Where nregionnumber = #URL.regionid#
	</cfquery>
	
	<cfset locationbit = 1>
	<cfset headingvar = #URL.regionid#>
</cfif>
	<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
<cfquery name="getheading" datasource="#Datasource#" dbtype="ODBC">
Select cHeading,ndx
From releases,medialocation
Where  medialocation.locationid = #headingvar# AND releasecontent = 1 AND mediaid = releases.ndx AND locationtypeid = #locationbit# AND releases.postedby = #session.userid#
</cfquery>


<!--- <cfquery name="getheading" datasource="#datasource#" dbtype="ODBC">
Select cHeading,ndx
From releases
Where nsectionid = #headingvar#
</cfquery> --->

<ul>

<form action="deleteconfirm.cfm" method="post">
<table width="600" cellspacing="2" cellpadding="2" border="0">
<tr bgcolor="#804040">
    <td colspan="2">&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Delete Content Menu</font></td>
</tr>
<tr bgcolor="#eaeaea">
    <td width="180" >
	&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="#5a5a5a">Region/Department: </font></font>
</td>
<td>
<cfoutput>&nbsp;<font style="font-family: sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a"><cfif url.regionid is not "">#getregions.regionname#</cfif><cfif url.departmentid is not "">#getdepartments.department#</cfif></font></cfoutput>
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
		
	
		<select name="ndx">
		<option value="0" SELECTED>Select Heading</option>
		<cfoutput query="getheading"><option value="#ndx#">#cheading#</option></cfoutput>
	</select>
	</cfif>
	</td>
</tr>

<tr bgcolor="#eaeaea">
    <td width="180">&nbsp;</td>
	<td>
	<cfif getheading.recordcount is 0>
	<input type="button" name="back" value="Back" onClick="history.back();">
	<cfelse>
	<cfoutput><input type="hidden" name="region" value="#URL.regionid#"></cfoutput>
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
