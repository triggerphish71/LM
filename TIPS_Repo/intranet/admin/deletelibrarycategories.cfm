<!--------------------------------------->
<!--- Programmer: Andy Leontovich        --->
<!--- File: admin/librarycategories.cfm  --->
<!--- Company: Maxim Group/ALC           --->
<!--- Date: June                         --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfparam name="url.page" default="0">
<cfinclude template="/intranet/header.cfm">


<cfif url.page is 0>

<cfquery name="currentcategories" datasource="#datasource#" dbtype="ODBC">
Select distinct categories.name,cattopicassgn.uniqueid
From Categories,cattopicassgn
Where cattopicassgn.categoryid = Categories.uniqueid AND user_id = #session.userid#
</cfquery>

<ul>
<form action="deletelibrarycategories.cfm?page=1" method="post">
<table width="400" border="0" cellspacing="0" cellpadding="2">
  <tr bgcolor="#804040"> 
    <td colspan="4"><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;Delete A Library Category</font></td>
  </tr>
<tr bgcolor="#eaeaea">
	<td><br>
		&nbsp;<select name="categoryid">
			<option value="0" SELECTED>Choose</option>
			<cfoutput query="currentcategories"><option value="#uniqueid#">#name#</option></cfoutput>
		</select><br><br>
	</td>
</tr>
<tr bgcolor="#f7f7f7">
	<td>
		&nbsp;<input type="submit" name="submit" value="Retrieve Category">
	</td>
</tr>
      </td>
  </tr>
</table>
</form>
</ul>

<cfelseif url.page is 1>
<!--- comment: Next Page--->
<cfif categoryid is 0>
	<cflocation url="error.cfm?errorid=0" addtoken="No">
</cfif>
<!--- <cfquery name="currentcategories2" datasource="#datasource#" dbtype="ODBC">
select *
from categories
Where uniqueid = #categoryid#
</cfquery>  --->

<cfquery name="currentcategories2" datasource="#datasource#" dbtype="ODBC">
Select distinct categories.name,cattopicassgn.uniqueid
From Categories,cattopicassgn
Where cattopicassgn.categoryid = Categories.uniqueid AND cattopicassgn.uniqueid = #categoryid#
</cfquery>

<!--- Will work on Topics when there is time --->
<!--- <cfquery name="assignedtopics" datasource="#datasource#" dbtype="ODBC">
select distinct topics.uniqueid,topics.name
from topics,cattopicassgn,categories
Where cattopicassgn.categoryid = #categoryid# AND topics.uniqueid = cattopicassgn.topicid
</cfquery> --->
<!--- 
<cfquery name="assignedfiles" datasource="#datasource#" dbtype="ODBC">
select mediainfo.filename
from cattopicassgn,categories,mediainfo,medialocation
Where cattopicassgn.uniqueid = #categoryid# AND mediainfo.uniqueid = medialocation.mediaid AND medialocation.locationid = cattopicassgn.uniqueid AND cattopicassgn.categoryid = categories.uniqueid AND 
</cfquery> --->

<cfquery name="assignedfiles" datasource="#datasource#" dbtype="ODBC">
select mediainfo.filename
from cattopicassgn,categories,mediainfo,medialocation
Where medialocation.locationid = #currentcategories2.uniqueid# AND mediainfo.uniqueid = medialocation.mediaid AND medialocation.locationid = cattopicassgn.uniqueid AND cattopicassgn.categoryid = categories.uniqueid and medialocation.locationtypeid = 5
</cfquery>
<ul>
<form action="libraryaction.cfm" method="post">
<table width="520" border="0" cellspacing="0" cellpadding="2">
  <tr bgcolor="#FFFFFF"> 
    <td colspan="3" bgcolor="#663300"><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Delete A Library Category</font></td>
  </tr>
   <tr bgcolor="#FFFFFF"> 
    <td colspan="3" bgcolor="#eaeaea"><BR></td>
  </tr>
  <tr bgcolor="#eaeaea"> 
    <td height="39" width="250" valign="Top"> 
     &nbsp;<b><font size="2" face="Arial, Helvetica, sans-serif" color="#666666"> 
        Category Name:</font>
            <cfoutput query="currentcategories2">
			<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">#name#</font><input type="hidden" name="categoryid" size="40" maxlength="50" value="#uniqueid#">
			</cfoutput>
			
		
		<cfif assignedfiles.recordcount is 0>
       	<ul>
	   		<input type="submit" name="Submit" value="Remove Category">
		</ul>
		<cfelse>
		<HR>
        </cfif>
      <font size="2" face="Arial, Helvetica, sans-serif">
	  <cfif assignedfiles.recordcount is Not 0>
	  <BR><BR><b>
        &nbsp;NOTE: Deleting a category will orphan the files associated with the category. 
        You must reassign or delete the files before you can delete a category.</b></font><BR>
		<HR></cfif>
		<cfif assignedfiles.recordcount is Not 0>
		<!--- <input type="button" name="topics" value="Library Topics" onClick="window.location.href='deletelibrarytopics.cfm';"> &nbsp; --->&nbsp;<input type="button" name="Submit" value="File Manager" onClick="window.location.href='fileuploader/deletefilemenu.cfm';">
    	</cfif>
	</td>
    <!--- <td valign="top">
	&nbsp;
	<font face="Arial, Helvetica, sans-serif" size="2" color="#666666" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Topics Assigned</font><br>
        <select name="topicslist" size="10">
		<cfif assignedtopics.recordcount is 0>
			<option value="">None assigned</option>
		<cfelse>
		<cfoutput query="assignedtopics"><option value="">#name#</option></cfoutput>
		</cfif>
          
        </select> 
    </td>--->
    <td align="center" valign="top"> 
     <font face="Arial, Helvetica, sans-serif" size="2" color="#666666" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Files Assigned </font> <br>
        <select name="filelist" size="10">
		<cfif assignedfiles.recordcount is 0>
          <option value="">None assigned</option>
		  <cfelse>
		   <cfoutput query="assignedfiles"><option value="">#filename#</option></cfoutput>
		</cfif>
		 
        </select>
      </p>
    </td>
  </tr>
</table>
  <input type="hidden" name="Libselectiontype" value="1">
  <input type="hidden" name="function" value="3"></form>
</ul>
</cfif>
<cfinclude template="/intranet/Footer.cfm">
</body>
</html>
