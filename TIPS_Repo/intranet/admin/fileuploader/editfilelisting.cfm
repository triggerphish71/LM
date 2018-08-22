<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/editfilelisting.cfm --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: June                       --->
<!--------------------------------------->

<!--- search queries --->
<cfset datasource1 = "DMS">
<cfset datasource2 = "census">
<cfset datasource3 = "ALCweb">
<cfparam name="norecsavail" default="0">
<cfinclude template="/intranet/header.cfm">

<cfswitch expression="#searchtype#">

	<cfcase value="regions">
		<cfquery name="getlocationtype" datasource="#datasource1#" dbtype="ODBC">
		Select uniqueid
		From locationtype
		Where locationtypename = '#searchtype#'
		</cfquery>
			<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
		<cfquery name="getregiondocs" datasource="#datasource1#" dbtype="ODBC">
		Select distinct mediainfo.uniqueid,filename,archive,show,fileextention,mediatypeid,path,medialocation.uniqueid AS medialocid
		From mediainfo,medialocation
		Where locationtypeid = #getlocationtype.uniqueid#  AND locationid = #region# AND mediainfo.uniqueid = medialocation.mediaid AND uploadedby = #session.userid#
		</cfquery>
		
		<cfif getregiondocs.recordcount is Not 0>
			<cfquery name="getregionname" datasource="#datasource2#" dbtype="ODBC">
			Select regionname
			From regions
			Where region_ndx = #region#
			</cfquery>
			
			
			<cfquery name="getfiletype" datasource="#datasource1#" dbtype="ODBC">
			Select name
			From Mediatype,mediainfo
			Where mediatype.uniqueid = #getregiondocs.mediatypeid#
			</cfquery>
		</cfif>
		
		<cfif getregiondocs.recordcount is 0>
			<cfset norecsavail = 1>
		</cfif>
		<cfset qname = "getregiondocs">
	</cfcase>
	
	<CFcase value="library">
			<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
		<cfquery name="getlibrarydocs" datasource="#datasource1#" dbtype="ODBC">
		Select distinct mediainfo.uniqueid,filename,archive,show,fileextention,mediatypeid,path,medialocation.uniqueid AS medialocid
		From mediainfo,medialocation
		Where locationtypeid = 5  AND locationid = #categoryid# AND mediainfo.uniqueid = medialocation.mediaid AND uploadedby = #session.userid#
		</cfquery>
		
		<cfif getlibrarydocs.recordcount is Not 0>
			<cfquery name="getfiletype" datasource="#datasource1#" dbtype="ODBC">
			Select name
			From Mediatype,mediainfo
			Where mediatype.uniqueid = #getlibrarydocs.mediatypeid#
			</cfquery>
		</cfif>
		
		<cfif getlibrarydocs.recordcount is 0>
			<cfset norecsavail = 1>
		</cfif>
		
		<cfset qname = "getlibrarydocs">
	</cfcase>
	
	<CFcase value="departments">
		<cfquery name="getlocationtype" datasource="#datasource1#" dbtype="ODBC">
		Select uniqueid
		From locationtype
		Where locationtypename = '#searchtype#'
		</cfquery>
			<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
		<cfquery name="getdepartmentdocs" datasource="#datasource1#" dbtype="ODBC">
		Select distinct mediainfo.uniqueid,filename,archive,show,fileextention,mediatypeid,path,medialocation.uniqueid AS medialocid
		From mediainfo,medialocation
		Where locationtypeid = #getlocationtype.uniqueid#  AND locationid = #department# AND mediainfo.uniqueid = medialocation.mediaid AND uploadedby = #session.userid#
		</cfquery>
		
		<cfif getdepartmentdocs.recordcount is Not 0>
			<cfquery name="getfiletype" datasource="#datasource1#" dbtype="ODBC">
			Select name
			From Mediatype,mediainfo
			Where mediatype.uniqueid = #getdepartmentdocs.mediatypeid#
			</cfquery>
		</cfif>
		
		<cfif getdepartmentdocs.recordcount is 0>
			<cfset norecsavail = 1>
		</cfif>
		
		<cfset qname = "getdepartmentdocs">
	</cfcase>
	
	<!--- comment: The other context is no longer necessary--->
	<!--- <CFcase value="other">
		
		<cfquery name="getotherdocs" datasource="#datasource1#" dbtype="ODBC">
		Select distinct mediainfo.uniqueid,mediainfo.filename,mediainfo.archive,mediainfo.show,mediainfo.fileextention,mediainfo.mediatypeid,mediainfo.path,medialocation.uniqueid AS medialocid
		From mediainfo,medialocation
		Where medialocation.locationtypeid = #other# AND medialocation.mediaid = mediainfo.uniqueid
		</cfquery>
		
		<cfif getotherdocs.recordcount is Not 0>
			<cfquery name="getfiletype" datasource="#datasource1#" dbtype="ODBC">
			Select name
			From Mediatype,mediainfo
			Where mediatype.uniqueid = #getotherdocs.mediatypeid#
			</cfquery>
		</cfif>
		
		<cfif getotherdocs.recordcount is 0>
			<cfset norecsavail = 1>
		</cfif>
		
		<cfset qname = "getotherdocs">
	</cfcase> --->
	
	<CFcase value="postdate">
		<cfquery name="getpostdatedocs" datasource="#datasource1#" dbtype="ODBC">
		Select distinct mediainfo.uniqueid,filename,archive,show,fileextention,mediatypeid,path,medialocation.uniqueid AS medialocid
		From mediainfo,medialocation
		Where postdate = '#postdate#' AND mediainfo.uniqueid = medialocation.mediaid  AND uploadedby = #session.userid#
		</cfquery>
		
		<cfif getpostdatedocs.recordcount is Not 0>
			<cfquery name="getfiletype" datasource="#datasource1#" dbtype="ODBC">
			Select name
			From Mediatype,mediainfo
			Where mediatype.uniqueid = #getpostdatedocs.mediatypeid#
			</cfquery>
		</cfif>
		
		<cfif getpostdatedocs.recordcount is 0>
			<cfset norecsavail = 1>
		</cfif>
		
		<cfset qname = "getpostdatedocs">
	</cfcase>
	
	<CFcase value="expirationdate">
			<cfquery name="getexpireddocs" datasource="#datasource1#" dbtype="ODBC">
		Select distinct mediainfo.uniqueid,filename,archive,show,fileextention,mediatypeid,path,medialocation.uniqueid AS medialocid
		From mediainfo,medialocation
		Where expirationdate = '#expirationdate#' AND mediainfo.uniqueid = medialocation.mediaid AND uploadedby = #session.userid#
		</cfquery>
		
		<cfif getexpireddocs.recordcount is Not 0>
			<cfquery name="getfiletype" datasource="#datasource1#" dbtype="ODBC">
			Select name
			From Mediatype,mediainfo
			Where mediatype.uniqueid = #getexpireddocs.mediatypeid#
			</cfquery>
		</cfif>
		
		<cfif getexpireddocs.recordcount is 0>
			<cfset norecsavail = 1>
		</cfif>
		
		<cfset qname = "getexpireddocs">
	</cfcase>
	
	<CFcase value="filename">
			<cfquery name="getfilenamedocs" datasource="#datasource1#" dbtype="ODBC">
			Select mediainfo.uniqueid,filename,archive,show,fileextention,mediatypeid,path,medialocation.uniqueid AS medialocid
			From mediainfo,medialocation
			Where filename LIKE '%#filename#%' AND mediainfo.uniqueid = medialocation.mediaid  AND uploadedby = #session.userid#
			</cfquery>
		
		<cfif getfilenamedocs.recordcount is Not 0>
			<cfquery name="getfiletype" datasource="#datasource1#" dbtype="ODBC">
			Select name
			From Mediatype,mediainfo
			Where mediatype.uniqueid = #getfilenamedocs.mediatypeid#
			</cfquery>
		</cfif>
		
		<cfif getfilenamedocs.recordcount is 0>
			<cfset norecsavail = 1>
		</cfif>
		
		<cfset qname = "getfilenamedocs">
	</cfcase>
<cfdefaultcase>Error Call the Site Administrator</cfdefaultcase>
</CFSwitch>
<ul>
<cfif norecsavail is 1>
<form action="" method="post">
	<table width="400" cellspacing="2" cellpadding="2" border="0">
<tr bgcolor="#8080C0">
    <td>&nbsp;<font color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: medium; font-weight: bold;">Alert!</font></td>
</tr>
<tr bgcolor="#f7f7f7">
    <td><br><blockquote><font color="black" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">
	There are no images available for editing in that category. Click the Back button to try a different search.</font></blockquote></td>
</tr>
<tr bgcolor="#eaeaea">
    <td>
	&nbsp;
		<input type="button" value="Back" onClick="history.back();">
	
	</td>
</tr>
</table>
</form>
<cfelse>
<form action="" method="post" name="theform" id="theform">
<table width="700" border="0" cellspacing="2" cellpadding="2">
  <tr bgcolor="#006699"> 
    <td colspan="6"><font size="3" face="Arial, Helvetica, sans-serif"><b><font color="#FFFFFF">Search 
      Results for: <cfoutput>#searchtype#</cfoutput></font></b></font></td>
  </tr>
  <tr bgcolor="#909090"> 
    <td> 
      <div align="center"><b><font face="Arial, Helvetica, sans-serif" size="2" color="#FFFFFF">Title</font></b></div>
    </td>
    <td> 
      <div align="center"><b><font face="Arial, Helvetica, sans-serif" size="2" color="#FFFFFF">Location</font></b></div>
    </td>
    <td> 
      <div align="center"><b><font face="Arial, Helvetica, sans-serif" size="2" color="#FFFFFF">
        Type</font></b></div>
    </td>
	
	 <td> 
      <div align="center"><b><font face="Arial, Helvetica, sans-serif" size="2" color="#FFFFFF">Visible</font></b></div>
    </td>
    <td> 
      <div align="center"><b><font face="Arial, Helvetica, sans-serif" size="2" color="#FFFFFF">Active 
        / Archive</font></b></div>
    </td>
	<td> 
      <div align="center"><b><font face="Arial, Helvetica, sans-serif" size="2" color="#FFFFFF">Action</font></b></div>
    </td>
  </tr>
  <cfset rowcolorcounter = 1>

  <cfoutput query="#qname#">

  <cfquery name="getparentdoc" datasource="#datasource#" dbtype="ODBC">
		Select mediainfo.filename
		From mediainfo,docassociation,medialocation
		Where medialocation.uniqueid = docassociation.parentdoc 
		 <cfif searchtype is "filename">AND docassociation.childdoc = #getfilenamedocs.medialocid#
		 <cfelseif searchtype is "library">AND docassociation.childdoc = #getlibrarydocs.medialocid#
		 <cfelseif searchtype is "regions">AND docassociation.childdoc = #getregiondocs.medialocid#
		 <cfelseif searchtype is "departments">AND docassociation.childdoc = #getdepartmentdocs.medialocid#</cfif>
		AND medialocation.mediaid = mediainfo.uniqueid
		</cfquery> 
		<!--- comment: no longer used--->
		<!--- <cfelseif searchtype is "other">AND docassociation.childdoc = #getotherdocs.medialocid# --->
  	<cfset linecount = rowcolorcounter mod 2>
			<cfif linecount is 0>
	          	<TR bgcolor="##f7f7f7"> 
			<cfelse>
				<TR bgcolor="##ffffff"> 
			</cfif>
	<cfset rowcolorcounter = rowcolorcounter+1>

    <td>
	&nbsp;&nbsp;<A HREF="##" Onclick=view('#ReplaceNoCase(RemoveChars(path,1,18),"\","/",'all')##filename#.#fileextention#',220,220)><font color="Black" style="font-family: Arial, Helvetica, sans-serif; font-size: xx-small;">#filename#.#fileextention#</font></A></td>
    <td><font color="Black" style="font-family: Arial, Helvetica, sans-serif; font-size: xx-small;">#path#</font></td>
    <td align="center"><font color="Black" style="font-family: Arial, Helvetica, sans-serif; font-size: xx-small;">#getfiletype.name#</font></td>
	   <!---  <td align="center"><font color="Black" style="font-family: Arial, Helvetica, sans-serif; font-size: xx-small;">
		<cfif getparentdoc.recordcount is 0>
			none
		<cfelse>
			#getparentdoc.filename#
		</cfif>
		</font>
		</td> --->
	 <td align="center">
	 	<cfif show is 0>
			<font color="Black" style="font-family: Arial, Helvetica, sans-serif; font-size: xx-small;">Hidden</font>
		<cfelse>
			<font color="Black" style="font-family: Arial, Helvetica, sans-serif; font-size: xx-small;">Visible</font>
		</cfif>
		</td>
    <td align="center">
		<cfif archive is 0>
			<font color="Black" style="font-family: Arial, Helvetica, sans-serif; font-size: xx-small;">Active</font>
		<cfelse>
			<font color="Black" style="font-family: Arial, Helvetica, sans-serif; font-size: xx-small;">Inactive</font>
		</cfif>
		</td>
		<td align="center">
		<font color="Black" style="font-family: Arial, Helvetica, sans-serif; font-size: xx-small;">[<A HREF="editfile.cfm?id=#uniqueid#&category=0">edit</A>]</font>
		</td>
  </tr>
  </cfoutput>
  <tr>
	  <td>
	  <BR>
	  	<input type="button" name="Back" value="Back" onClick="history.back();">
	  </td>
  </tr>
</table></form>
</cfif>
</ul>

<cfinclude template="/intranet/footer.cfm">


