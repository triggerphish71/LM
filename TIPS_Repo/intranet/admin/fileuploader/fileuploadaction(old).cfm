<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/file upload action.cfm --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: august                       --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfinclude template="/intranet/header.cfm">
<cfparam name="heading" default="none">
<cfparam name="subheading" default="none">
<cfparam name="notes" default="none">
<cfparam name="locationbit" default="0">
<cfparam name="childfile" default="0">

 <cfset path = "C:\inetpub\wwwroot\intranet">
 <!----------------------------------- location is departments ------------------------------------------>
<cfif location is "departments">
<cfset locationbit = 2>
<!--- check for and create if necessary the upper directory --->
	<cfdirectory action="LIST" directory="c:\inetpub\wwwroot\intranet\#location#" name="isDirThere">
	<cfif isDirThere.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#location#">
		 <cfdirectory action="LIST" directory="#path#\#location#" name="isDirThereCheck">
		 
		<cfif isDirThereCheck.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The directory was not created.Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
	<cfset place = replace(department," ","","All")>
	
<!--- check for and create if necessary the lower directory --->
	<cfdirectory action="LIST" directory="#path#\#location#\#place#" name="isDirThere">
		<cfif isDirThere.recordcount is 0>
			<cfdirectory action="CREATE" directory="#path#\#location#\#Place#">
			<cfdirectory action="LIST" directory="#path#\#location#\#place#" name="isDirThereCheck">
				 
			<cfif isDirThereCheck.recordcount is 0>
				<script language="JavaScript1.2" type="text/javascript">
					<!--
						Alert("The Sub directory was not created.");
					//-->
				</script>
			<cfelse>
				<cfset locationpathPlace = #path#&"\"&#location#&"\"&#place#>
			</cfif>
		</cfif>
		
<!--- create the "media" Directory --->
<cfdirectory action="LIST" directory="#path#\#location#\#Place#\media" name="isDirThere2">
	<cfif isDirThere2.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#locationpathPlace#\media">
		 <cfdirectory action="LIST" directory="#locationpathPlace#\media" name="isDirThereCheck2">
		 
		<cfif isDirThereCheck2.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The Media directory was not created. Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
 <!----------------------------------- location is regions ------------------------------------------>
<cfelseif location is "regions">
<cfset locationbit = 1>
	<!--- check for and create if necessary the upper directory --->
	<cfdirectory action="LIST" directory="c:\inetpub\wwwroot\intranet\#location#" name="isDirThere">
	<cfif isDirThere.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#location#">
		 <cfdirectory action="LIST" directory="#path#\#location#" name="isDirThereCheck">
		 
		<cfif isDirThereCheck.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The directory was not created. Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
	<cfset place = replace(region," ","","All")>
	<!--- <cfset place = #region#> --->
	<!--- <cfset place = #region#&"\"> --->
<!--- check for and create if necessary the lower directory --->
	<cfdirectory action="LIST" directory="#path#\#location#\#place#" name="isDirThere">
		<cfif isDirThere.recordcount is 0>
			<cfdirectory action="CREATE" directory="#path#\#location#\#Place#">
			<cfdirectory action="LIST" directory="#path#\#location#\#place#" name="isDirThereCheck">
				 
			<cfif isDirThereCheck.recordcount is 0>
				<script language="JavaScript1.2" type="text/javascript">
					<!--
						Alert("The Sub directory was not created. Contact the site administrator.");
					//-->
				</script>
			<cfelse>
				<cfset locationpathPlace = #path#&"\"&#location#&"\"&#place#>
			</cfif>
		</cfif>
		
<!--- create the "media" Directory --->
<cfdirectory action="LIST" directory="#path#\#location#\#Place#\media" name="isDirThere2">
	<cfif isDirThere2.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#location#\#Place#\media">
		 <cfdirectory action="LIST" directory="#path#\#location#\#Place#\media" name="isDirThereCheck2">
		 
		<cfif isDirThereCheck2.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The Media directory was not created.Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>


 <!----------------------------------- location is operations ------------------------------------------>
<cfelseif location is "operations">
	<cfdirectory action="LIST" directory="c:\inetpub\wwwroot\intranet\#location#" name="isDirThere">
	<cfif isDirThere.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#location#">
		 <cfdirectory action="LIST" directory="#path#\#location#" name="isDirThereCheck">
		 
		<cfif isDirThereCheck.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The directory was not created. Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
	
<!--- create the "media" Directory --->
<cfdirectory action="LIST" directory="#path#\#location#\media" name="isDirThere2">
	<cfif isDirThere2.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#location#\media">
		 <cfdirectory action="LIST" directory="#path#\#location#\media" name="isDirThereCheck2">
		 
		<cfif isDirThereCheck2.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The Media directory was not created.Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
	
	<cfset place = "">
	
	 <!----------------------------------- location is library ------------------------------------------>
<cfelseif location is "library">
	<cfset locationbit = 5>
	<cfdirectory action="LIST" directory="c:\inetpub\wwwroot\intranet\#location#" name="isDirThere">
	<cfif isDirThere.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#location#">
		 <cfdirectory action="LIST" directory="#path#\#location#" name="isDirThereCheck">
		 
		<cfif isDirThereCheck.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The directory was not created.Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
	
		<cfquery name="getsearchtypenameL" datasource="#datasource#" dbtype="ODBC">
		Select Distinct name
		From categories
		Where uniqueid = #categoryid#
		</cfquery>
		
	<cfset placeint = categoryid>
	
	<cfset place = replace(getsearchtypenameL.name," ","","All")>
	
	<!--- check for and create if necessary the lower directory --->
	<cfdirectory action="LIST" directory="#path#\#location#\#place#" name="isDirThere">
		<cfif isDirThere.recordcount is 0>
			<cfdirectory action="CREATE" directory="#path#\#location#\#Place#">
			<cfdirectory action="LIST" directory="#path#\#location#\#place#" name="isDirThereCheck">
				 
			<cfif isDirThereCheck.recordcount is 0>
				<script language="JavaScript1.2" type="text/javascript">
					<!--
						Alert("The Sub directory was not created. Contact the site administrator.");
					//-->
				</script>
			<cfelse>
				<cfset searchtypepathPlace = #path#&"\"&#location#&"\"&#place#>
			</cfif>
		</cfif>
	
<!--- create the "media" Directory --->
<cfdirectory action="LIST" directory="#path#\#location#\#Place#\media" name="isDirThere2">
	<cfif isDirThere2.recordcount is 0>
		 <cfdirectory action="CREATE" directory="#path#\#location#\#Place#\media">
		 <cfdirectory action="LIST" directory="#path#\#location#\#Place#\media" name="isDirThereCheck2">
		 
		<cfif isDirThereCheck2.recordcount is 0>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			Alert("The Media directory was not created.Contact the site administrator.");
		//-->
		</script>
		</cfif>
	</cfif>
</cfif>
<!---------------------------------- Begin Upload ---------------------------------------------->
<cffile action="UPLOAD"
        filefield="docfile"
        destination="c:\inetpub\wwwroot\intranet\#location#\#place#\media"
        nameconflict="OVERWRITE"
        accept="image/gif,application/msword,application/pdf,image/jpeg,video/quicktime,application/x-msexcel,image/pjpeg,text/html">
	
	<cfset convertpath = #file.serverDirectory#>
	
	<cfset newpath = convertpath&"\">
	<cfquery name="insertmediainfo" datasource="#datasource#" dbtype="ODBC">
	Insert Into MediaInfo (filename,mediatypeid,uploadedby,show,postdate,uploaddate,expirationdate,title,subtitle,notes,archive,path,fileextention)
	Values('#file.serverfilename#',#mediatypeid#,'#uploadedby#',1,'#postdate#','#DateFormat(Now())#','#expirationdate#','#heading#','#subheading#','#notes#',0,'#newpath#','#File.ClientFileExt#')
	</cfquery>
	
	<cfquery name="getmediainfondx" datasource="#datasource#" dbtype="ODBC">
	Select uniqueid
	From Mediainfo
	Where filename = '#file.serverfilename#' AND mediatypeid = #mediatypeid# AND uploaddate = '#DateFormat(Now())#' AND uploadedby = '#uploadedby#'
	</cfquery>

	<cfquery name="getlocationtypeid" datasource="#datasource#" dbtype="ODBC">
	Select uniqueid
	From locationtype
	Where locationtypename = <cfif location is "regions" AND #region# is "ALC Home Office">'home'<cfelse>'#location#'</cfif>
	</cfquery>
	
	
	<cfif childfile GT 0>
		<cfquery name="insertassociation" datasource="#datasource#" dbtype="ODBC">
		Insert Into docassociation(childdoc,parentdoc)
		Values(#childfile#,#getmediainfondx.uniqueid#)
		</cfquery>
	</cfif>
	

	<cfif locationbit is 1>
		<cfif Right(#place#,1) is "\">
			<cfset newplace = RemoveChars(place, Findoneof("\", place,1), 1)>
		<cfelse>
			<cfset newplace = place>
		</cfif>
		<cfquery name="getlocationid" datasource="Census" dbtype="ODBC">
		Select Distinct regionName,Region_Ndx
		From Regions
		Where regionname = '#region#'
		</cfquery>
		
		<cfset locationndx = #getlocationid.Region_Ndx#>
	<cfelseif locationbit is 2>
	
		<cfif Right(#place#,1) is "\">
			<cfset newplace = RemoveChars(place, Findoneof("\", place,1), 1)>
		<cfelse>
			<cfset newplace = place>
		</cfif>
		
		<cfquery name="getlocationid" datasource="#datasource#" dbtype="ODBC">
		Select Distinct Department,Department_NDX
		From vw_Departments
		Where department = '#department#'
		</cfquery>
		<!--- Where department = '#newplace#' --->
		
		<cfset locationndx = #getlocationid.Department_NDX#>
	<cfelseif locationbit is 5>
	<!--- library --->
		<cfset locationndx = #categoryid#>
	<cfelse>
		<cfset locationndx = 0>
	</cfif>
	
	<cfif location is "library">
	
		<cfquery name="getcattopicassgn" datasource="#datasource#" dbtype="ODBC">
		Select uniqueid
		From cattopicassgn
		Where categoryid = #categoryid#
		</cfquery>
		
	<cfif getcattopicassgn.recordcount is 0>
			<cfquery name="insertcattopic" datasource="#datasource#" dbtype="ODBC">
			insert into cattopicassgn(categoryid)
			Values(#form.categoryid#)
			</cfquery>
			
		<cfquery name="getcattopicassgn" datasource="#datasource#" dbtype="ODBC">
		Select uniqueid
		From cattopicassgn
		Where categoryid = #categoryid#
		</cfquery>
		</cfif>

		<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
		<cfquery name="insertmedialocation" datasource="#datasource#" dbtype="ODBC">
		Insert into Medialocation(locationtypeid,mediaid,locationid,mediacontent)
		Values(#getlocationtypeid.uniqueid#,#getmediainfondx.uniqueid#,#getcattopicassgn.uniqueid#,1)
		</cfquery>
	<cfelse>
		<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
		<cfquery name="insertmedialocation" datasource="#datasource#" dbtype="ODBC">
		Insert into Medialocation(locationtypeid,mediaid,locationid,mediacontent)
		Values(#getlocationtypeid.uniqueid#,#getmediainfondx.uniqueid#,#locationndx#,1)
		</cfquery>
	</cfif>
<ul>
<CFOUTPUT>

<form action="fileuploadernav.cfm?index=2" method="post">
<table width="700" cellspacing="2" cellpadding="3">
<TR bgcolor="##006666">
<td colspan="5"><font color="white" style="font-family: Arial, Helvetica, sans-serif; font-size: medium; ">The file upload was successful!</font></td>

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
<!--- <TR bgcolor="##f7f7f7">
<TH VALIGN=top align=LEFT><font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Server dir</font></TH>
<TD>#file.serverDirectory#</TD>
<TD>&nbsp;&nbsp;&nbsp;</TD>
<TH VALIGN=top align=LEFT>&nbsp;</TH>
<TD>&nbsp;</TD>
</TR> --->
</TABLE>
</CFOUTPUT></ul>
</TD>
</TR>
<tr>
	<td>
		<ul><form action="filuploadernav.cfm?index=3" method="post">
		&nbsp;<input type="submit" name="addagain" value="Add Another">
		</form></ul>
	</td>
</tr>
</TABLE>
</form>
<cfinclude template="/intranet/footer.cfm">
