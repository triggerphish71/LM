<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/deletefile.cfm      --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: june                      --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfinclude template="/intranet/header.cfm">
<cfquery name="getfiletodelete" datasource="#datasource#" dbtype="ODBC">
Select *
From mediainfo
Where uniqueid = #url.id#
</cfquery>

<cfquery name="getassoc" datasource="#datasource#" dbtype="ODBC">
	Select docassociation.childdoc
	From docassociation
	Where parentdoc = #url.id# 
</cfquery>

<cfset listing = arrayNew(1)>

<cfloop index="index" from="1" to="5">
	<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
	 <cfquery name="getregionrelease" datasource="#datasource#" dbtype="ODBC">
	Select releases.cheading,locationtype.locationtypename
	From releases,medialocation,locationtype
	Where medialocation.locationtypeid = #index# AND releasecontent = 1 AND releases.ndx = medialocation.mediaid 
	AND releases.nfilendx = #url.id# AND medialocation.locationtypeid = locationtype.uniqueid
	</cfquery>
	
	<cfif getregionrelease.recordcount is not 0>
		<cfset listing[#index#] = "#getregionrelease.cheading#...#getregionrelease.locationtypename#">
	</cfif>
</cfloop>

<cfset arraylength = Arraylen(listing)>

<cfif getassoc.recordcount is not 0>
	<cfquery name="getchildren" datasource="#datasource#" dbtype="ODBC">
	Select filename,fileextention
	From mediainfo,medialocation
	Where medialocation.uniqueid  IN (#ValueList(getassoc.childdoc)#) AND mediainfo.uniqueid = medialocation.mediaid
	</cfquery>
</cfif> 
<ul>
<form action="deletefileaction.cfm" method="post">
<cfoutput query="getfiletodelete">
	<table width="600" cellspacing="2" cellpadding="2" border="0">
<tr bgcolor="##663300">
    <td colspan="2">&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Alert!</font></td>
</tr>
<tr bgcolor="##eaeaea">
    <td colspan="2"><br><blockquote><font color="black" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">
	Are you sure you want to delete the following file from the system and from all of the publications which use this file?</font></blockquote></td>
</tr>
<tr bgcolor="##f7f7f7">
    <td>
	<BR>
	<ul><font color="##5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">
		Name: &nbsp;&nbsp;#filename#.#fileextention#
		<BR><BR>
		Postdate: &nbsp;&nbsp;#DateFormat(Postdate)#
		<BR>
		Expirationdate: &nbsp;&nbsp;#Dateformat(Expirationdate)#
		<BR>
		Archived:&nbsp;&nbsp;
		<cfif archive is 1>
			Archived
		<cfelse>
			Active
		</cfif>
		<BR>
		Title: &nbsp;&nbsp;#title#
		<BR>
		Subtitle: &nbsp;&nbsp;#Subtitle#
		<BR>
		Notes: &nbsp;&nbsp;#Notes#
	</font></ul>
	</td>
	<td valign="top">
	<font color="##5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">
	Associations:</font><BR>
	<cfif arraylength is not 0>
	<select name="assoc" size="10">
		<cfloop index="i" from="1" to="#arraylength#">
			
				<option value="">#listing[i]#</option>
		</cfloop>
		<cfif getassoc.recordcount is not 0>
		<option value="">____________________________</option>
		<cfloop query="getchildren">
				<option value="">#getchildren.filename#.#getchildren.fileextention#</option>
		</cfloop>
		</cfif>
	</select>
	<cfelse>
	<font color="##5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">None</font>
	</cfif>
	</td>
</tr>
<tr bgcolor="##eaeaea">
    <td colspan="2"><input type="hidden" name="fileid" value="#uniqueid#">
	<input type="hidden" name="thefilename" value="#filename#.#fileextention#">
	&nbsp;<input type="submit" name="submit" value="Delete">&nbsp;&nbsp;&nbsp;<input type="button" name="Cancel" value="Cancel" onClick="history.back();">
	</td>
</tr>
</table>
</cfoutput>
</form>
</ul>


<cfinclude template="/intranet/Footer.cfm">

