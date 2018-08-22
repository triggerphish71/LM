<cfset datasource = "DMS">
<!--- <cfset datasource2 = "Census">
<cfset datasource3 = "ALCWeb"> --->
<cfparam name="librarybit" default="1">


<cfinclude template="/intranet/header.cfm">


<!--- gets primary info for the other queries --->
<cfquery name="getmediainfo" datasource="#Datasource#" dbtype="ODBC">
Select *
From MediaInfo
Where uniqueid = #URL.id#
</cfquery>

	
<!--- obtains record to be displayed --->
<cfquery name="getmedialocation" datasource="#Datasource#" dbtype="ODBC">
Select *
From MediaLocation
Where mediaid = #getmediainfo.uniqueid#
</cfquery>

 <cfquery name="getchilddoc" datasource="#datasource#" dbtype="ODBC">
  Select mediainfo.filename,medialocation.uniqueid
  From mediainfo,docassociation,medialocation
  Where medialocation.mediaid = mediainfo.uniqueid
  AND medialocation.uniqueid = docassociation.childdoc
  AND docassociation.parentdoc = #getmedialocation.mediaid#
  </cfquery>
  
<!--- for a dropdown menu --->
<cfquery name="getregion" datasource="#Datasource#" dbtype="ODBC">
Select region_ndx, regionname
From vw_regions
</cfquery>

<!--- for a dropdown menu --->
<cfquery name="getdepartments" datasource="#Datasource#" dbtype="ODBC">
Select Department_Ndx,department
From VW_Departments
</cfquery>

<cfquery name="getlibrarycategories" datasource="#datasource#" dbtype="ODBC">
Select distinct categories.name,cattopicassgn.categoryid
From Categories,cattopicassgn
Where cattopicassgn.categoryid = Categories.uniqueid
</cfquery>

<!--- for a dropdown menu --->
	<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
<cfquery name="getlocationtype" datasource="#Datasource#" dbtype="ODBC">
Select locationtype.uniqueid,locationtype.locationtypename
from locationtype,medialocation
where locationtype.uniqueid = #getmedialocation.locationtypeid#
</cfquery>

<!--- for a dropdown menu --->
<cfquery name="getotherlocation2" datasource="#Datasource#" dbtype="ODBC">
Select locationtypename
from locationtype
</cfquery>

<cfquery name="getmediatype" datasource="#Datasource#" dbtype="ODBC">
Select *
From MediaType
</cfquery>

<!--- <cfif url.category GT 0>
	<cfquery name="currenttopics" datasource="#Datasource#" dbtype="ODBC">
	select topics.uniqueid,topics.name
	from topics,categories,cattopicassgn A
	Where topics.uniqueid = A.topicid AND categories.uniqueid = A.categoryid AND categories.uniqueid = #url.category#
	</cfquery>  
</cfif>--->


<script language="JavaScript1.2" type="text/javascript">
<!--

	function getcatid()
	{
		var catid = window.document.resourcerec.categoryid.value;
		
		assign('fileassign.cfm?categoryid=' + catid,500,500)
	}
	
	function fieldset(searchtypefield)
	{
			if (searchtypefield == 1){
			document.resourcerec.searchtype[0].checked = true;}
			
			if (searchtypefield == 2){
			document.resourcerec.searchtype[1].checked = true;}
			
			if (searchtypefield == 3){
			cat = document.resourcerec.categoryid.options[resourcerec.categoryid.selectedIndex].value;
			document.resourcerec.searchtype[2].checked = true;
			}
			
			if (searchtypefield == 4){
			document.resourcerec.searchtype[3].checked = true;}
	}
	
	<!--- comment: will reinstate this validation when I have more time to test it--->
	/*function childfilevalidate()
	{
		if (document.resourcerec.childfile.value == document.resourcerec.childtemp.value)
			{
				alert("You cannot assign this document to the existing parent document");
				return false;
			}
	}*/
//-->
</script>
<cfoutput query="getmediainfo">
<UL>
<form method="post" action="editfileaction.cfm" enctype="multipart/form-data" name="resourcerec";>
 
<table width="620" border="0" cellspacing="2" cellpadding="2" height="335">
  <tr bgcolor="##006699"> 
    <td colspan="2">&nbsp;&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Edit Media Entry</font></td>
  </tr>
  
  <tr bgcolor="##f7f7f7"> 
    <td colspan="2" valign="middle">
	<font size="2" face="Arial, Helvetica, sans-serif"><b><font color="##006633">Show</font> 
     <cfif show is 1>
	 	<input type="radio" name="show" value="#show#" checked>
      &nbsp;&nbsp;<font color="##990000">Hide</font> 
      <input type="radio" name="show" value="0">
	<cfelse>
		 <input type="radio" name="show" value="1">
      &nbsp;&nbsp;<font color="##990000">Hide</font> 
      <input type="radio" name="show" value="#show#" checked>
	</cfif>
</b></font></td>
  </tr>
   <tr bgcolor="##ffffff"> 
    <td height="8" colspan="2"></td>
  </tr>
  <tr bgcolor="##f7f7f7"> 
    <td colspan="2">&nbsp;<font face="Arial, Helvetica, sans-serif" size="2"><b><font size="3">New 
      Location:</font></b></font></td>
  </tr>
  <tr bgcolor="##f7f7f7"> 
    <td width="123" valign="middle"> &nbsp;&nbsp;&nbsp; 
	<cfif getlocationtype.locationtypename is "regions">
		<input type="radio" name="searchtype" value="regions" checked>
	<cfelse>
     	<input type="radio" name="searchtype" value="regions">
	</cfif>
      <b><font size="2" face="Arial, Helvetica, sans-serif">Region</font></b> 
    </td>
    <td width="363"><b> 
      <select name="region" onChange="fieldset(1)">
	  <cfif getlocationtype.locationtypename is "regions">
	   <!--- retrievs a current selection --->
		 <cfquery name="getRegplace" datasource="#Datasource#" dbtype="ODBC">
			Select regionname,region_Ndx 
			From vw_regions
			Where region_Ndx = #getmedialocation.locationid#
		</cfquery>

      	<option value="#getRegplace.region_Ndx#">#getRegplace.regionname#</option>
	  </cfif>
		<option value="">____________________</option>
		<cfloop query="getregion"><option value="#region_ndx#">#regionname#</option></cfloop>
      </select>
      </b>
	 </td>
  </tr>
  <tr bgcolor="##f7f7f7"> 
    <td width="123" valign="middle"> &nbsp;&nbsp;&nbsp; 
	<cfif getlocationtype.locationtypename is "departments">
		<input type="radio" name="searchtype" value="departments" checked>
	<cfelse>
      	<input type="radio" name="searchtype" value="departments">
	</cfif>
      <b><font size="2" face="Arial, Helvetica, sans-serif">Department</font></b> 
    </td>
    <td width="363"><b> 
      <select name="department" onChange="fieldset(2)">
	  	<cfif getlocationtype.locationtypename is "departments">
		<!--- retrievs a current selection --->
			<cfquery name="getDepplace" datasource="#Datasource#" dbtype="ODBC">
			Select department,department_Ndx 
			From VW_departments
			Where department_Ndx = #getmedialocation.locationid#  
			</cfquery>

        	<option value="#getDepplace.department_Ndx#">#getDepplace.department#</option>
		</cfif> 
		<option value="">____________________</option>
		<cfloop query="getdepartments"><option value="#getdepartments.department_ndx#">#department#</option></cfloop> 
      </select>
      </b> </td>
  </tr>
  <tr bgcolor="##f7f7f7"> 
        <td width="186" valign="middle"> 
		&nbsp;&nbsp;&nbsp;
			<cfif getlocationtype.locationtypename is "library">
				<input type="radio" name="searchtype" value="library" checked>
			<cfelse>
		      	<input type="radio" name="searchtype" value="library">
			</cfif>
	
          
          <b><font size="2" face="Arial, Helvetica, sans-serif">Library</font></b> 
        </td>
        <td><b> 
          <select name="categoryid" onChange="fieldset(3)">
		   <cfif getlocationtype.locationtypename is "library">
		   
<!--- -------------------------------------------------------------------------------------------------------------------------------------------------------------
	Following query is saved for retoration. 
	The qurey getlibrary place had the uniqueid in place of the categoryid.
	Thus, when a file was to be edited the file was placed into the incorrect category. I have exchanged the uniqueid with the category id to fix this problem
	No existing problems are seen 
	Paul Buendia 02-21-01
------------------------------------------------------------------------------------------------------------------------------------------------------------- --->
		   
 			<cfquery name="getlibraryplace" datasource="#datasource#" dbtype="ODBC">
				Select distinct cattopicassgn.categoryid,categories.name,cattopicassgn.uniqueid
				From Categories,cattopicassgn
				Where cattopicassgn.uniqueid = #getmedialocation.locationid# AND cattopicassgn.categoryid = Categories.uniqueid
				</cfquery>
				
<!--- 				<cfquery name="getlibraryplace" datasource="#datasource#" dbtype="ODBC">
				Select distinct cattopicassgn.categoryid,categories.name,cattopicassgn.uniqueid
				From Categories,cattopicassgn
				Where cattopicassgn.categoryid = #getmedialocation.locationid# AND cattopicassgn.categoryid = Categories.uniqueid
				</cfquery> --->

				<option value="#getlibraryplace.uniqueid#">#getlibraryplace.name#</option>
			</cfif>
            <option value="">____________________</option>
			<cfloop query="getlibrarycategories"><option value="#getlibrarycategories.categoryid#">#getlibrarycategories.name#</option></cfloop>
          </select>
          </b>
		  <!--- &nbsp;&nbsp;
		  <cfif url.category GT 0>
		  	<select name="topicid">
			<cfloop query="currenttopics"><option value="#currenttopics.uniqueid#" SELECTED>#currenttopics.name#</option></cfloop>
			</select>
		  </cfif> --->
		  </td>
      </tr>
	  </tr>
	   <tr bgcolor="##f7f7f7"> 
        <td align="right"><b><font size="2" face="Arial, Helvetica, sans-serif">Associate File:</font></td>
        <td valign="middle">
		<input type="text" name="childname" value="#getchilddoc.filename#">&nbsp;
		<input type="button" name="assign" value="Select File" onClick="getcatid();">
		<input type="hidden" name="parentfile" value="#getmedialocation.mediaid#">
		<cfif getchilddoc.recordcount is 0>
			<input type="hidden" name="childstate" value="0">
		<cfelse>
			<input type="hidden" name="childstate" value="1">
		</cfif>
		</td>
		</tr>
		
		<cfif getchilddoc.recordcount is 1>
			<cfquery name="getdocassign" datasource="#datasource#" dbtype="ODBC">
			Select uniqueid
			From docassociation
			Where parentdoc = #getmedialocation.mediaid# AND childdoc = #getchilddoc.uniqueid#
			</cfquery>

		     <tr bgcolor="##f7f7f7"> 
	        <td align="right"><b><font size="2" face="Arial, Helvetica, sans-serif">Remove Association:</font></td>
	        <td valign="middle">
			<input type="checkbox" name="dissassociate" value="1">
			<input type="hidden" name="assignid" value="#getdocassign.uniqueid#">
			</td>
	      </tr>
	  </cfif>
      </tr>
	<!---      <tr bgcolor="##f7f7f7"> 
        <td align="right"><b><font size="2" face="Arial, Helvetica, sans-serif">Remove Association:</font></td>
        <td valign="middle">
		<input type="checkbox" name="dissassociate" value="1">
		</td>
      </tr> --->
  <tr bgcolor="##f7f7f7"> 
    <td width="123" valign="middle"> 
	<!--- comment: the 'other' section no longer necessary --->
	</td>
    <td width="363"></td>
  </tr>
  <tr bgcolor="##f7f7f7"> 
    <td colspan="2" valign="top" height="15"> <font size="1" face="Arial, Helvetica, sans-serif" color="##CC0033">*</font><font size="1" face="Arial, Helvetica, sans-serif">You 
      will need to reassign the media to a new content entry.</font> </td>
  </tr>
  <tr bgcolor="##ffffff"> 
    <td height="8" colspan="2"></td>
  </tr>
  <tr bgcolor="##eaeaea"> 
        <td width="123" ><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;Heading:</font></b></td>
        <td> 
			<input type="text" name="heading" value="#title#" size="50" maxlength="50">
        </td>
      </tr>
	  <tr bgcolor="##eaeaea"> 
        <td width="123" ><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;Subheading:</font></b></td>
        <td> 
			<input type="text" name="subheading" value="#subtitle#" size="50" maxlength="50">
        </td>
      </tr>
	  <tr bgcolor="##eaeaea"> 
        <td width="123" ><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;Notes:</font></b></td>
        <td> 
		<input type="text" name="notes" value="#notes#" size="50" maxlength="50">
        </td>
      </tr>
	   <tr bgcolor="##ffffff"> 
    <td height="8" colspan="2"></td>
  </tr>
  <tr bgcolor="##eaeaea"> 
    <td width="123">&nbsp;<font face="Arial, Helvetica, sans-serif"><b><font size="2">Current File:</font></b></td>
    <td width="363"><font color="##000000" style="font-family: Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">#Filename#.#fileextention#</font></td>
  </tr>
  <tr bgcolor="##eaeaea"> 
    <td colspan="2">&nbsp;<font style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Replace file with: </font>&nbsp;&nbsp;
          <input type="file" name="thefile" size="50" accept="application/msword,application/pdf,image/jpeg,image/GIF,video/quicktime,application/msexcel,image/pjpeg">
    </td>
  </tr>
  <tr bgcolor="##eaeaea"> 
    <td colspan="2" valign="top" height="19"> <font size="1" face="Arial, Helvetica, sans-serif" color="##CC0000">*</font><font size="1" face="Arial, Helvetica, sans-serif">The 
      name of the file you are uploading will over-write the existing file. The 
      existing file will be archived.</font> </td>
  </tr>
  <tr bgcolor="##eaeaea"> 
        <td><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;Media Type:</font></b></td>
        <td>
         <select name="mediatypeid">
		 <cfquery name="getmediatypename" datasource="#datasource#" dbtype="ODBC">
			Select mediatype.name,mediatype.uniqueid
			From Mediatype,mediainfo
			Where mediatype.uniqueid = #getmediainfo.mediatypeid#
		</cfquery>
		 
		 <option value="#getmediatypename.uniqueid#">#getmediatypename.name#</option>
		<option value="">______________________</option>
		<cfloop query="getmediatype"><option value="#getmediatype.uniqueid#">#getmediatype.name#</option></cfloop>
		</select>
        </td>
      </tr>
     <tr bgcolor="##ffffff"> 
    <td height="8" colspan="2"></td>
  </tr>
  <tr bgcolor="##f7f7f7"> 
    <td width="123">&nbsp;<font face="Arial, Helvetica, sans-serif"><b><font size="2">
      Post Date:</font></b></font></td>
    <td width="363"><A href="javascript:calendar(1)"><img src="../../pix/calendaricon.gif" width="19" height="20" border="0" alt=""></A>&nbsp; 
      <input type="text" name="postdate" value="#DateFormat(postdate,'mm/dd/yy')#" size="10" maxlength="10">
    </td>
  </tr>
  <tr  bgcolor="##f7f7f7"> 
    <td width="123">&nbsp;<font face="Arial, Helvetica, sans-serif"><b><font size="2">
      Expiration Date:</font></b></font></td> 
    <td width="363"><A href="javascript:calendar(2)"><img src="../../pix/calendaricon.gif" width="19" height="20" border="0" alt=""></A>&nbsp; 
      <input type="text" name="expirationdate" value="#DateFormat(expirationdate,'mm/dd/yy')#" size="10" maxlength="10">
    </td>
  </tr>
       <tr bgcolor="##ffffff"> 
    <td height="8" colspan="5"></td>
  </tr>
  
    <tr  bgcolor="##cccccc"> 
    <td width="363" colspan="2">
	<cfif archive is 1>
		<font color="Navy" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Archive status:</font> <font color="Purple" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Archived</font>&nbsp;&nbsp;&nbsp;<font color="Navy" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Change Status?</font><input type="checkbox" name="archive" value="0">
	<cfelse>
		<font color="Navy" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Archive Status:</font> <font color="Green" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Active</font>
	&nbsp;&nbsp;&nbsp;<font color="Navy" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Change Status?</font><input type="checkbox" name="archive" value="1"></cfif>
	

</td>
  </tr>
     <tr bgcolor="##ffffff"> 
    <td height="8" colspan="5"></td>
  </tr>
  <tr bgcolor="##eaeaea"> 
    <td height="2" colspan="2">
	<input type="hidden" name="editedby" value="#session.userid#"><!--- change later to the session.userid --->
    <input type="hidden" name="childfile" value="#getchilddoc.uniqueid#">
	 <input type="hidden" name="childtemp" value="#getchilddoc.uniqueid#">
	 <input type="hidden" name="uploadedby" value="#uploadedby#">
	 <input type="hidden" name="uniquefileid" value="#uniqueid#">
	 <input type="submit" name="Submit" value="Submit Changes">
    </td>
  </tr>
</table>
 
  </form>
</UL></cfoutput>

<cfinclude template="/intranet/footer.cfm">
</body>
</html>
