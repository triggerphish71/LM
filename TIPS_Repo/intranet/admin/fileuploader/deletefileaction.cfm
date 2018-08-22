<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/index2.cfm          --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: May                       --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfinclude template="/intranet/header.cfm">
<cfquery name="getfileinfo" datasource="#datasource#" dbtype="ODBC">
Select *
From mediainfo
Where uniqueid = #fileid#
</cfquery>

<!--- delete from mediainfo --->
<cfquery name="deletefrommediainfo" datasource="#datasource#" dbtype="ODBC">
Delete from mediainfo
Where uniqueid = #fileid#
</cfquery>

<!--- delete from medialocation --->
<cfquery name="deletefrommedialocation" datasource="#datasource#" dbtype="ODBC">
Delete from medialocation
Where mediaid = #fileid#
</cfquery>

<!--- delete from docassign --->
<cfquery name="deletefromdocassign" datasource="#datasource#" dbtype="ODBC">
Delete from docassociation
Where parentdoc = #fileid#
</cfquery>

<!--- delete from releases --->
<cfquery name="deletefromreleases" datasource="#datasource#" dbtype="ODBC">
update releases
Set mediainfouniqueid = 0
Where mediainfouniqueid = #fileid#
</cfquery>

<!--- comment: deletes the directory if its empty--->
<cffile action="DELETE" file="#getfileinfo.path##getfileinfo.filename#.#getfileinfo.fileextention#">

<form action="" method="post">
<ul>
	<table width="400" cellspacing="2" cellpadding="2" border="0">
<tr bgcolor="#663300">
    <td>&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Confirmation</font></td>
</tr>
<tr bgcolor="#eaeaea">
    <td><br>
	<blockquote><font color="black" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">
		<cfoutput>The file: #thefilename# has been deleted.</cfoutput>
	</font></blockquote></td>
</tr>

<tr bgcolor="#eaeaea">
    <td>
	&nbsp;<input type="button" name="deleteagain" value="Delete Another" onClick="history.go(-3)">
	</td>
</tr>
</table>
</ul>

</form>
<cfinclude template="/intranet/Footer.cfm">

