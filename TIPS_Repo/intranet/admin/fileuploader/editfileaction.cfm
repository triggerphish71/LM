<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/editfileaction.cfm --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: June                       --->
<!--- 11/20/2013 Sfarmer 102505 all C:\ file locations changed to E:\ for move to CF01 --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfinclude template="/intranet/header.cfm">
<cfparam name="heading" default="">
<cfparam name="subheading" default="">
<cfparam name="notes" default="">
<cfparam name="searchtypebit" default="0">
<cfparam name="archive" default="0">
<cfparam name="childfile" default="0">
<cfparam name="dissassociate" default="0">


<!-------------------------------------------- New directory creation ------------------------------------------>
<cfset path = "E:\inetpub\wwwroot\intranet">
 <!----------------------------------- searchtype is departments -------------------------------->
<cfif searchtype is "departments">
<cfset searchtypebit = 2>
<!--- check for and create if necessary the upper directory --->
<!--- 	<cfdirectory action="LIST" directory="c:\inetpub\wwwroot\intranet\#searchtype#" name="isDirThere"> --->
	<cfdirectory action="LIST" directory="e:\inetpub\wwwroot\intranet\#searchtype#" name="isDirThere">
	<cfif isDirThere.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#searchtype#">
		 <cfdirectory action="LIST" directory="#path#\#searchtype#" name="isDirThereCheck">
		 
		<cfif isDirThereCheck.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The directory was not created.Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
	<cfquery name="getsearchtypename" datasource="ALCWeb" dbtype="ODBC">
		Select Distinct Department
		From Departments
		Where department_ndx = #department#
		</cfquery>
<cfset placeint = department>

<cfset place = replace(getsearchtypename.department," ","","All")>
<!--- <cfset place = #getsearchtypename.department#> --->
	
<!--- check for and create if necessary the lower directory --->
	<cfdirectory action="LIST" directory="#path#\#searchtype#\#place#" name="isDirThere">
		<cfif isDirThere.recordcount is 0>
			<cfdirectory action="CREATE" directory="#path#\#searchtype#\#Place#">
			<cfdirectory action="LIST" directory="#path#\#searchtype#\#place#" name="isDirThereCheck">
				 
			<cfif isDirThereCheck.recordcount is 0>
				<script language="JavaScript1.2" type="text/javascript">
					<!--
						Alert("The Sub directory was not created.");
					//-->
				</script>
			<cfelse>
				<cfset searchtypepathPlace = #path#&"\"&#searchtype#&"\"&#place#>
			</cfif>
		</cfif>
		
<!--- create the "media" Directory --->
<cfdirectory action="LIST" directory="#path#\#searchtype#\#Place#\media" name="isDirThere2">
	<cfif isDirThere2.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#searchtypepathPlace#\media">
		 <cfdirectory action="LIST" directory="#searchtypepathPlace#\media" name="isDirThereCheck2">
		 
		<cfif isDirThereCheck2.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The Media directory was not created.Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
 <!----------------------------------- searchtype is regions ------------------------------------------>
<cfelseif searchtype is "regions">
<cfset searchtypebit = 1>
	<!--- check for and create if necessary the upper directory --->
	<!--- <cfdirectory action="LIST" directory="c:\inetpub\wwwroot\intranet\#searchtype#" name="isDirThere"> --->
	<cfdirectory action="LIST" directory="e:\inetpub\wwwroot\intranet\#searchtype#" name="isDirThere">	
	<cfif isDirThere.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#searchtype#">
		 <cfdirectory action="LIST" directory="#path#\#searchtype#" name="isDirThereCheck">
		 
		<cfif isDirThereCheck.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The directory was not created. Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
		<cfquery name="getsearchtypename" datasource="Census" dbtype="ODBC">
		Select Distinct regionName
		From Regions
		Where Region_ndx = '#region#'
		</cfquery>
		
	<cfset placeint = region>
	<cfset place = replace(getsearchtypename.regionname," ","","All")>
	<!--- <cfset place = #getsearchtypename.regionname#> --->

<!--- check for and create if necessary the lower directory --->
	<cfdirectory action="LIST" directory="#path#\#searchtype#\#place#" name="isDirThere">
		<cfif isDirThere.recordcount is 0>
			<cfdirectory action="CREATE" directory="#path#\#searchtype#\#Place#">
			<cfdirectory action="LIST" directory="#path#\#searchtype#\#place#" name="isDirThereCheck">
				 
			<cfif isDirThereCheck.recordcount is 0>
				<script language="JavaScript1.2" type="text/javascript">
					<!--
						Alert("The Sub directory was not created. Contact the site administrator.");
					//-->
				</script>
			<cfelse>
				<cfset searchtypepathPlace = #path#&"\"&#searchtype#&"\"&#place#>
			</cfif>
		</cfif>
		
<!--- create the "media" Directory --->
<cfdirectory action="LIST" directory="#path#\#searchtype#\#Place#\media" name="isDirThere2">
	<cfif isDirThere2.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#searchtype#\#Place#\media">
		 <cfdirectory action="LIST" directory="#path#\#searchtype#\#Place#\media" name="isDirThereCheck2">
		 
		<cfif isDirThereCheck2.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The Media directory was not created.Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>

<cfelseif searchtype is "Library">
<cfset searchtypebit = 5>
	<!--- check for and create if necessary the upper directory --->
<!--- 	<cfdirectory action="LIST" directory="c:\inetpub\wwwroot\intranet\#searchtype#" name="isDirThere"> --->
	<cfdirectory action="LIST" directory="e:\inetpub\wwwroot\intranet\#searchtype#" name="isDirThere">
	<cfif isDirThere.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#searchtype#">
		 <cfdirectory action="LIST" directory="#path#\#searchtype#" name="isDirThereCheck">
		 
		<cfif isDirThereCheck.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The directory was not created. Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
		<cfquery name="getsearchtypenameL" datasource="#datasource#" dbtype="ODBC">
		Select Distinct name, cattopicassgn.uniqueid
		From categories,cattopicassgn
		Where cattopicassgn.categoryid = #categoryid# AND cattopicassgn.categoryid = categories.uniqueid
		</cfquery>

<!--- 		<cfquery name="getsearchtypenameL" datasource="#datasource#" dbtype="ODBC">
		Select Distinct name
		From categories,cattopicassgn
		Where cattopicassgn.uniqueid = #categoryid# AND cattopicassgn.categoryid = categories.uniqueid
		</cfquery> --->
		
<cfset placeint = categoryid>
	<cfset place = replace(getsearchtypenameL.name," ","","All")>
	

<!--- check for and create if necessary the lower directory --->
	<cfdirectory action="LIST" directory="#path#\#searchtype#\#place#" name="isDirThere">
		<cfif isDirThere.recordcount is 0>
			<cfdirectory action="CREATE" directory="#path#\#searchtype#\#Place#">
			<cfdirectory action="LIST" directory="#path#\#searchtype#\#place#" name="isDirThereCheck">
				 
			<cfif isDirThereCheck.recordcount is 0>
				<script language="JavaScript1.2" type="text/javascript">
					<!--
						Alert("The Sub directory was not created. Contact the site administrator.");
					//-->
				</script>
			<cfelse>
				<cfset searchtypepathPlace = #path#&"\"&#searchtype#&"\"&#place#>
			</cfif>
		</cfif>
		
<!--- create the "media" Directory --->
<cfdirectory action="LIST" directory="#path#\#searchtype#\#Place#\media" name="isDirThere2">
	<cfif isDirThere2.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#searchtype#\#Place#\media">
		 <cfdirectory action="LIST" directory="#path#\#searchtype#\#Place#\media" name="isDirThereCheck2">
		 
		<cfif isDirThereCheck2.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The Media directory was not created.Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>

 <!----------------------------------- searchtype is operations Convert to generic searchtypetype later------------------------------------------>
<cfelseif searchtype is "other">
<!--- 	<cfdirectory action="LIST" directory="c:\inetpub\wwwroot\intranet\#other#" name="isDirThere"> --->
	<cfdirectory action="LIST" directory="e:\inetpub\wwwroot\intranet\#other#" name="isDirThere">
	<cfif isDirThere.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#other#">
		 <cfdirectory action="LIST" directory="#path#\#other#" name="isDirThereCheck">
		 
		<cfif isDirThereCheck.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The directory was not created. Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
	
<!--- create the "media" Directory --->
<cfdirectory action="LIST" directory="#path#\#other#\media" name="isDirThere2">
	<cfif isDirThere2.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#other#\media">
		 <cfdirectory action="LIST" directory="#path#\#other#\media" name="isDirThereCheck2">
		 
		<cfif isDirThereCheck2.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The Media directory was not created.Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
	<cfset place = replace(other," ","","All")>
	<!--- <cfset place = "#other#"> --->
	
	 <!----------------------------------- searchtype is other ------------------------------------------>
<cfelseif searchtype is "other">
	<!--- <cfdirectory action="LIST" directory="c:\inetpub\wwwroot\intranet\#searchtype#" name="isDirThere"> --->
	<cfdirectory action="LIST" directory="e:\inetpub\wwwroot\intranet\#searchtype#" name="isDirThere">	
	<cfif isDirThere.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#searchtype#">
		 <cfdirectory action="LIST" directory="#path#\#searchtype#" name="isDirThereCheck">
		 
		<cfif isDirThereCheck.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The directory was not created.Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
	
<!--- create the "media" Directory --->
<cfdirectory action="LIST" directory="#path#\#searchtype#\media" name="isDirThere2">
	<cfif isDirThere2.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#searchtype#\media">
		 <cfdirectory action="LIST" directory="#path#\#searchtype#\media" name="isDirThereCheck2">
		 
		<cfif isDirThereCheck2.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The Media directory was not created.Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
	<cfset place = replace(other," ","","All")>
	<!--- <cfset place = "#other#"> --->
</cfif>
<!-------------------------------------------- End New directory creation ------------------------------------------>

	
<!----------------------------------- File upload action ------------------------------------------------>
<cfif thefile is not "">
	<cfquery name="getrecordtoarchive" datasource="#datasource#" dbtype="ODBC">
	Select *
	From mediainfo
	Where uniqueid = #uniquefileid#
	</cfquery>
	
	<cfquery name="insertmediainfo" datasource="#datasource#" dbtype="ODBC">
		Insert Into MediaInfo (filename,mediatypeid,uploadedby,show,postdate,uploaddate,expirationdate,title,subtitle,notes,archive,path,fileextention,editedby)
		Values('#getrecordtoarchive.filename#',#getrecordtoarchive.mediatypeid#,'#getrecordtoarchive.uploadedby#',#getrecordtoarchive.show#,'#getrecordtoarchive.postdate#','#getrecordtoarchive.uploaddate#','#getrecordtoarchive.expirationdate#','#getrecordtoarchive.title#','#getrecordtoarchive.subtitle#','#getrecordtoarchive.notes#',1,'#getrecordtoarchive.path#','#getrecordtoarchive.fileextention#','#getrecordtoarchive.editedby#')
	</cfquery>
	<cfif searchtype is "other">
			<cffile action="UPLOAD"
	        filefield="thefile"
	        destination="e:\inetpub\wwwroot\intranet\#place#\media"
	        nameconflict="OVERWRITE"
	        accept="image/gif,application/msword,application/pdf,image/jpeg,video/quicktime,application/msexcel,image/pjpeg">
	<cfelse>
			<cffile action="UPLOAD"
	        filefield="thefile"
	        destination="e:\inetpub\wwwroot\intranet\#searchtype#\#place#\media"
	        nameconflict="OVERWRITE"
	        accept="image/gif,application/msword,application/pdf,image/jpeg,video/quicktime,application/msexcel,image/pjpeg">
	</cfif>
</cfif>
<!----------------------------------- End File upload action ------------------------------------------------>
	
<!------------------------------------ file move assessment ---------------------------------------->

<cfif searchtype is "other">
	<cfset newmovepath = "e:\inetpub\wwwroot\intranet\"&#place#&"\media\">
<cfelse>
	<cfset newmovepath = "e:\inetpub\wwwroot\intranet\"&#searchtype#&"\"&#place#&"\media\">
</cfif>

<cfquery name="getmediapath" datasource="#datasource#" dbtype="ODBC">
Select path,uniqueid,filename,fileextention
From mediainfo
Where uniqueid = #uniquefileid#
</cfquery>

<cfset pathcomparison = compareNoCase("#getmediapath.path#","#newmovepath#")>
<cfset sourcepath = #getmediapath.path#&""&#getmediapath.filename#&"."&#getmediapath.fileextention#>
	<!--- <cfoutput>newpath: #newmovepath#<BR>
  pathcomparrison:#pathcomparison#<BR>
  sourcepath: #sourcepath#<BR>
  Place:#place#<br>
  searchtypename:#getsearchtypenameL.name#<BR>
  placeint:#placeint#</cfoutput> --->
<!------------------------------------ End file move assessment ---------------------------------------->

<!---------------------------------- File Move action -------------------------------------------------->
<cfif pathcomparison is not 0>
	<cffile action="MOVE"
	        source="#sourcepath#"
	        destination="#newmovepath#"
	        attributes="normal">
			
		<cfset path = #newmovepath#>
		<!--- 		<cfset convertpath = Removechars(#file.serverDirectory#,1,18)> --->
<!--- 	<cfset newpath = Replace(convertpath, "\", "/" ,"all")> --->
</cfif> 

<!---------------------------------- End File Move action ---------------------------------------------->


<!--- Updates the media info record "works" --->
	<cfquery name="updatemediainfo" datasource="#datasource#" dbtype="ODBC">
	Update MediaInfo 
	Set mediatypeid = #mediatypeid#,
		editedby = #session.userid#,
		show = #show#,
		postdate = '#postdate#',
		expirationdate = '#expirationdate#',
		title = '#heading#',
		subtitle = '#subheading#',
		notes = '#notes#',
		archive = #archive#
		<cfif pathcomparison is not 0>
		,path = '#path#'
		<cfelseif thefile is not "">,
		filename = '#file.serverfilename#',
		uploaddate = '#DateFormat(NOW())#',
		path = '#newmovepath#',
		fileextention = '#File.ClientFileExt#'</cfif>
	Where uniqueid = #uniquefileid#
	</cfquery>
<!--------- End Update media info record "works" ---------------->
	
	<cfif thefile is not "">
	<cfquery name="getmediainfondx" datasource="#datasource#" dbtype="ODBC">
	Select uniqueid
	From Mediainfo
	Where filename = '#file.serverfilename#' AND mediatypeid = #mediatypeid# AND uploaddate = '#DateFormat(File.TimeCreated,'DD MMM YY')#' AND uploadedby = '#uploadedby#'
	</cfquery>
</cfif>

<cfif dissassociate is 1>
	<cfset childstate = 2>
</cfif>

<cfif childstate is 0>
	<cfif childfile is not "">
		<cfquery name="insertassociation" datasource="#datasource#" dbtype="ODBC">
			Insert Into docassociation(parentdoc,childdoc)
			Values(#childfile#,#parentfile#)
		</cfquery>
<!--- comment: the childfile and parent file are reversed so that the hierarchy works like it should in the library AL--->
	</cfif>
<cfelseif childstate is 1>
	<cfquery name="updatechild" datasource="#datasource#" dbtype="ODBC">
		Update docassociation
		Set childdoc = #childfile#
		Where parentdoc = #parentfile# AND childdoc = #childtemp#
	</cfquery>
<cfelseif childstate is 2>
<cfquery name="deleteassoc" datasource="#datasource#" dbtype="ODBC">
	Delete from docassociation
	Where uniqueid = #assignid#
	</cfquery>
</cfif>

<cfif searchtype is "other">
	<cfset newsearchtype = #other#>
<cfelse>
	<cfset newsearchtype = searchtype>
</cfif>
 	<cfquery name="getsearchtypetypeid" datasource="#datasource#" dbtype="ODBC">
	Select uniqueid
	From locationtype
	Where locationtypename = '#newsearchtype#'
	</cfquery>
	
	<cfif searchtypebit is 1>
		<cfquery name="getsearchtypeid" datasource="Census" dbtype="ODBC">
		Select Distinct regionName,Region_Ndx
		From Regions
		Where Region_ndx = '#placeint#'
		</cfquery>
		
		<cfset searchtypendx = #getsearchtypeid.Region_Ndx#>
		
	<cfelseif searchtypebit is 2>
		<cfquery name="getsearchtypeid" datasource="ALCWeb" dbtype="ODBC">
		Select Distinct Department,Department_NDX
		From Departments
		Where department_ndx = '#placeint#'
		</cfquery>
		
		<cfset searchtypendx = #getsearchtypeid.Department_NDX#>
		
	<cfelseif searchtypebit is 5>
		<!--- <cfquery name="getsearchtypeid" datasource="#datasource#" dbtype="ODBC">
		Select Distinct name,uniqueid
		From Categories
		Where uniqueid = '#placeint#'
		</cfquery> --->
		
		
		<cfset searchtypendx = #categoryid#>
	<cfelse>
		<cfset searchtypendx = 0>
	</cfif> 

<!-------------- Updates the location of the media files in the media location directory ---------->
		<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
	<cfquery name="updatemediasearchtype" datasource="#datasource#" dbtype="ODBC">
	Update medialocation
	Set  locationtypeid= <cfif searchtypebit is 5>5<cfelse>#getsearchtypetypeid.uniqueid#</cfif>,
		locationid = #getsearchtypenameL.uniqueid#
	Where mediaid = #uniquefileid#
	</cfquery>
	
	<!---  cattopicassgn.uniqueid --->

<!--- 	<cfquery name="updatemediasearchtype" datasource="#datasource#" dbtype="ODBC">
	Update medialocation
	Set  locationtypeid= <cfif searchtypebit is 5>5<cfelse>#getsearchtypetypeid.uniqueid#</cfif>,
		locationid = #searchtypendx#
	Where mediaid = #uniquefileid#
	</cfquery>
	 --->
<!-------------- End Update of the location of the media files in the media location directory ---------->

<ul>
<CFOUTPUT>

 <!----------------------------- if the "file" field has anything in it ---------------------------------------->
	
	
<cfif thefile is not "">
		<table width="700" cellspacing="2" cellpadding="3">
		<TR bgcolor="##eaeaea">
		<td colspan="5"><font color="Green" style="font-family: Arial, Helvetica, sans-serif; font-size: medium;">The file upload was successful!</font></td>
		</TR>
		<TR bgcolor="##f7f7f7">
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Content SubType:</font></TH> 
		<TD>#File.ContentSubType#</TD>
		<TD>&nbsp;&nbsp;&nbsp;</TD>
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Content Type:</font></TH> 
		<TD>#File.ContentType#</TD>
		</TR>
		
		<TR bgcolor="##f7f7f7">
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Client FileExt:</font></TH>
		<TD>#File.ClientFileExt#</TD>
		<TD>&nbsp;&nbsp;&nbsp;</TD>
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Client Path:</font></TH><TD>#File.ClientDirectory#</TD>
		</TR>
		<TR bgcolor="##f7f7f7">
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Server File:</font></TH><TD>#File.ServerFile#</TD>
		<TD>&nbsp;&nbsp;</TD>
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Server FileName:</font></TH>
		<TD>#File.ServerFileName#</TD>
		</TR>
		
		<TR bgcolor="##f7f7f7">
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">File Existed?</font></TH><TD>#File.FileExisted#</TD>
		<TD>&nbsp;&nbsp;&nbsp;</TD>
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">File Was Saved?</font></TH><TD>#File.FileWasSaved#</TD>
		</TR>
		<TR bgcolor="##f7f7f7">
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">File Was Overwritten?</font></TH>
		<TD>#File.FileWasOverWritten#</TD>
		<TD>&nbsp;&nbsp;&nbsp;</TD>
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">File Was Appended?</font></TH>
		<TD>#File.FileWasAppended#</TD>
		</TR>
		<TR bgcolor="##f7f7f7">
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">File Was Renamed?</font></TH>
		<TD>#File.FileWasRenamed#</TD>
		<TD>&nbsp;&nbsp;&nbsp;</TD>
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">File Size:</font></TH><TD>#File.Filesize#</TD></TH>
		</TR>
		<TR bgcolor="##f7f7f7">
		<TH VALIGN=top ALIGN=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Old File Size:</font></TH><TD>#File.OldFileSize#</TD>
		<TD>&nbsp;&nbsp;&nbsp;</TD>
		<TH VALIGN=top align=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Date Last Accessed:</font></TH>
		<TD>#DateFormat(File.DateLastAccessed,'DD MMM YY')#</TD>
		</TR>
		<TR bgcolor="##f7f7f7">
		<TH VALIGN=top align=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Date/Time Created:</font></TH>
		<TD>#DateFormat(File.TimeCreated,'DD MMM YY')# 
		#Timeformat(File.TimeCreated,'HH:MM:SS')#</TD>
		<TD>&nbsp;&nbsp;&nbsp;</TD>
		<TH VALIGN=top align=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Date/Time Modified:</font></TH>
		<TD>#DateFormat(File.TimeLastModified,'DD MMM YY')# 
		#Timeformat(File.TimeLastModified,'HH:MM:SS')#</TD>
		</TR>
		</TABLE>
		<cfelse>
		

<form action="fileuploadernav.cfm?index=1" method="post">
<ul>
	<table width="400" cellspacing="2" cellpadding="2" border="0">
<tr bgcolor="##336699">
    <td>&nbsp;<font color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: medium;">Confirmation</font></td>
</tr>
<tr bgcolor="##eaeaea">
    <td><br>
	<blockquote><font color="black" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">
		The file information has been updated.
	</font></blockquote></td>
</tr>

<tr bgcolor="##eaeaea">
    <td>
	&nbsp;<input type="submit" name="editagain" value="Edit Another">
	</td>
</tr>
</table>
</ul>

</form>
	</cfif>
</CFOUTPUT>
</ul>
</TD>
</TR>
</TABLE>
<cfinclude template="/intranet/footer.cfm">
