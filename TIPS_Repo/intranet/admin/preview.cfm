<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/preview.cfm          --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: May                       --->
<!--------------------------------------->
<cfparam name="fileid" default="">
<cfparam name="region" default="">
<cfparam name="homelocation" default="">
<cfparam name="department" default="">
<cfparam name="publishto" default="0">
<cfparam name="unlinklib" default="0">
<cfparam name="unlinkillus" default="0">
<cfparam name="fileassign2" default="0">
<cfset Datasource = "DMS">

<cfinclude template="/intranet/header.cfm">
<cfif previewcode is 1><!--- the below queries are for Add only --->
	<cfif department is not "">
		<cfquery name="getdepartments"
         datasource="#Datasource#"
         dbtype="ODBC">
			Select department_ndx,department
			From vw_departments
			Where department_ndx = #department#
		</cfquery>
	</cfif>
	
	
	<cfif region is not "">
		<cfquery name="getregions" datasource="#Datasource#" dbtype="ODBC">
		Select region_ndx,regionname
		From vw_regions
		Where region_ndx = #region#
		</cfquery>
	</cfif>
		<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
	<cfif locationtypeid is 3>
	<cfset homelocation = "home">
</cfif>
	
	
</cfif>

<cfif fileid is not "" AND unlinkillus is 0>
<cfquery name="getmedia2" datasource="#Datasource#" dbtype="ODBC">
	Select path,filename,fileextention,uniqueid
	From mediainfo
	Where uniqueid = #fileid#
	</cfquery>
</cfif>

	
<form action="actionadmin.cfm" method="post">
<ul>
<cfoutput>
<cfif fileid is not "" AND unlinkillus is 0>
<cfset newpath = #ReplaceNoCase(RemoveChars(getmedia2.path,1,18),"\","/",'all')#>
</cfif>
<table width="600" cellspacing="2" cellpadding="2" border="0">
<tr>
    <td>
	<cfif previewcode is 1>
	<font color="Black" style="font-family: Arial, Helvetica, sans-serif; font-size: small;">Entry to be posted on #postdate# in <cfif region is not "">#getregions.regionname#</cfif><cfif department is not "">#getdepartments.department#</cfif><cfif homelocation is not "">Home</cfif>.</font><BR><BR><BR>
	</cfif>
	<b><font color="Black">#heading#</font></b><BR>
	<font style="font-size: xx-small; font-family: Arial, Helvetica, sans-serif;"><font color="Black">#subheading#</font></font><BR>
	<cfif fileid is not ""  AND unlinkillus is 0>

<img src="#RemoveChars(getmedia2.path,1,18)##getmedia2.filename#.#getmedia2.fileextention#" border="0" align="absmiddle" alt="Illustration">
	</cfif>
	
	<font style="color="Black" font-size: x-small; font-family: 'Times New Roman', Times, serif;">#content#</font><BR>
	<br><input type="submit" name="Submit" value="Post Entry">&nbsp;&nbsp;<input type='button' name='back' value='Back' onClick='history.back();'>
	</td>
</tr>
</table>
</ul>
<cfif Previewcode IS 2>
<input type="hidden" name="ndx" value="#ndx#">
</cfif>
<input type="hidden" name="previewcode" value="#previewcode#">
<input type="hidden" name="whatsnew" value="#whatsnew#">
<input type="hidden" name="whatsnewexpirationdate" value="#whatsnewexpirationdate#">
<input type="hidden" name="heading" value="#heading#">
<input type="hidden" name="subheading" value="#subheading#">
<input type="hidden" name="content" value="#content#">
<input type="hidden" name="postdate" value="#postdate#">
<input type="hidden" name="expirationdate" value="#expirationdate#">
<input type="hidden" name="fileid" value="#fileid#">
<input type="hidden" name="region" value="#region#">
<input type="hidden" name="publishto2" value="#publishto#">
<input type="hidden" name="department" value="#department#">
<input type="hidden" name="unlinkillus" value="#unlinkillus#">
<input type="hidden" name="unlinklib" value="#unlinklib#">
<input type="hidden" name="fileassign2" value="#fileassign#">

</form></cfoutput>
<cfinclude template="/intranet/Footer.cfm">

