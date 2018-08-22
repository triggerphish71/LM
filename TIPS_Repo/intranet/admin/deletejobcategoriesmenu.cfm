<!--------------------------------------->
<!--- Programmer: Andy Leontovich        --->
<!--- File: admin/editjobcategories.cfm  --->
<!--- Company: Maxim Group/ALC           --->
<!--- Date: June                         --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfparam name="url.page" default="0">
<cfinclude template="/intranet/header.cfm">
 
<cfif url.page is 0>

<cfquery name="getcatagories" datasource="#datasource#" dbtype="ODBC">
Select distinct heading,toc_ndx
From jobtoc
Where user_id = #session.userid#
</cfquery>

<ul>
<form action="deletejobcategory.cfm" method="post">
<table width="490" border="0" cellspacing="0" cellpadding="2">
  <tr bgcolor="#663300"> 
    <td colspan="4">&nbsp;<font face="Arial, Helvetica, sans-serif" color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: medium; ">&nbsp;Delete 
      A Job Category</font></td>
  </tr>
<tr bgcolor="#f7f7f7">
	<td><br>
		&nbsp;<select name="toc_ndx">
			<option value="0" SELECTED>Choose</option>
			<cfoutput query="getcatagories"><option value="#toc_ndx#">#heading#</option></cfoutput>
		</select>
		<br><br>
	</td>
</tr>
<tr bgcolor="#eaeaea">
	<td>
		&nbsp;<input type="submit" name="submit" value="Confirm">
	</td>
</tr>
      </td>
  </tr>
</table>
</form></ul>

<cfelseif url.page is 1>
<cfif categoryid is 0>
	<cflocation url="error.cfm" addtoken="No">
</cfif>
<cfquery name="currentcategories2" datasource="#datasource#" dbtype="ODBC">
select *
from categories
Where uniqueid = #categoryid#
</cfquery> 

<cfquery name="currentcategories" datasource="#datasource#" dbtype="ODBC">
select *
from categories
</cfquery> 

<cfquery name="assignedtopics" datasource="#datasource#" dbtype="ODBC">
select *
from topics
</cfquery> 
<form action="libraryaction.cfm" method="post">
<ul>
<table width="700" border="0" cellspacing="0" cellpadding="2">
  <tr bgcolor="#006699"> 
    <td colspan="4"> &nbsp;<font color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: medium; font-weight: bold;">Edit
      A Library Category</font></td>
  </tr>
  <tr bgcolor="#eaeaea"> 
    <td height="39" width="210" valign="middle"><font size="2"><b><font face="Arial, Helvetica, sans-serif" color="#666666"> 
      Category Name</font><font face="Arial, Helvetica, sans-serif"><br>
    <cfoutput query="currentcategories2">
	<input type="text" name="name" size="40" maxlength="50" value="#name#">
	<input type="hidden" name="name_required" size="40" maxlength="50" value="Please Enter a name for the category">
	<input type="hidden" name="categoryid" size="40" maxlength="50" value="#uniqueid#">
	</cfoutput>
      <br>
      </font><font size="2" face="Arial, Helvetica, sans-serif"> 
      <input type="submit" name="Submit" value="Submit Category">
      </font></b></font></td>
    <td height="39" width="78" valign="middle"> 
      <table width="78" border="0" cellspacing="3" cellpadding="0">
        <tr align="center"> 
          <td><font size="1" face="Arial, Helvetica, sans-serif">Visible</font></td>
          <td><font size="1" face="Arial, Helvetica, sans-serif">Hidden</font></td>
        </tr>
        <tr> 
          <td align="center">
		  	<cfif currentcategories2.visible is 1>
				<cfoutput> <input type="radio" name="visible" value="1" checked></cfoutput>
			<cfelse>
				 <input type="radio" name="visible" value="1">
			</cfif>
           
          </td>
          <td align="center"> 
             <cfif currentcategories2.visible is 0>
				<cfoutput><input type="radio" name="visible" value="0" checked></cfoutput>
			<cfelse>
				  <input type="radio" name="visible" value="0">
			</cfif>
          </td>
        </tr>
      </table>
      
    </td>
	<cfquery name="currenttopics" datasource="#datasource#" dbtype="ODBC">
	select topics.uniqueid,topics.name
	from topics,categories,cattopicassgn A
	Where topics.uniqueid = A.topicid AND categories.uniqueid = A.categoryid AND categories.uniqueid = #categoryid#
	</cfquery>
    <td valign="top"><font color="Gray" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Current Categories</font><br>
      <select name="currentcategories" size="10">
       <cfoutput query="currentcategories"> <option value="">#name#</option></cfoutput>
      </select>
      </td>
    <td valign="top"> 
      <font face="Arial, Helvetica, sans-serif" size="2" color="#666666" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Topics 
        Assigned</font><br>
        <select name="topicslist" size="10">
		<cfif assignedtopics.recordcount is 0>
			<option value="">None assigned</option>
		<cfelse>
		<cfoutput query="currenttopics"><option value="">#name#</option></cfoutput>
		</cfif>
          
        </select>
     
	      </td>
  </tr>
</table></ul>
<input type="hidden" name="function" value="2">
<input type="hidden" name="Libselectiontype" value="1">
</form>
</cfif>


<cfinclude template="/intranet/Footer.cfm">
</body>
</html>
