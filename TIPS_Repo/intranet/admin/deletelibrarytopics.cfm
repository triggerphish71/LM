<!--------------------------------------->
<!--- Programmer: Andy Leontovich        --->
<!--- File: admin/librarycategories.cfm  --->
<!--- Company: Maxim Group/ALC           --->
<!--- Date: June                         --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfparam name="url.page" default="0">
<cfinclude template="/intranet/header.cfm">
<cfparam name="buttonshow" default="0">

<cfif url.page LTE 1>
<cfquery name="currentcategories" datasource="#datasource#" dbtype="ODBC">
select *
from categories
<cfif url.page is 1>
	Where uniqueid = #categoryid#
</cfif>
</cfquery>

<cfif url.page is 1>
	<cfset page = 2>
<cfelse>
	<cfset page = 1>
</cfif>

<ul>
<cfoutput><form action="deletelibrarytopics.cfm?page=#page#" method="post"></cfoutput>
<table width="490" border="0" cellspacing="0" cellpadding="2">
  <tr bgcolor="#804040"> 
    <td colspan="4"><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;Delete A Library Topic</font></td>
  </tr>
  <tr bgcolor="#eaeaea">
	<td>
		&nbsp;
	</td>
</tr>
<tr bgcolor="#eaeaea">
	<td>
	<ul><font color="#7e7e7e" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Category</font><br>
		<select name="categoryid">
			<cfif url.page is not 1>
			<option value="0" SELECTED>Choose a Category</option>
			</cfif>
			<cfoutput query="currentcategories"><option value="#uniqueid#">#name#</option></cfoutput>
		</select>
		</ul>
		
	</td>
</tr>

<cfif url.page is 1>
	<cfif categoryid is 0>
	<cflocation url="error.cfm" addtoken="No">
</cfif>

	<cfquery name="currenttopics" datasource="#datasource#" dbtype="ODBC">
	select topics.uniqueid,topics.name
	from topics,categories,cattopicassgn A
	Where topics.uniqueid = A.topicid AND categories.uniqueid = A.categoryid AND categories.uniqueid = #categoryid#
	</cfquery> 
	<tr bgcolor="#f7f7f7">
	<td>
	<cfif currenttopics.recordcount is 0>
	<BR>
		<ul><font style="font-family: Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">There are no topics for this category.</font></ul>
	<cfelse>
		<ul>&nbsp;<font color="#7e7e7e" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Topic</font><br>
		&nbsp;<select name="topicid">
			<option value="0" SELECTED>Choose a Topic</option>
			<cfoutput query="currenttopics"><option value="#uniqueid#">#name#</option></cfoutput>
		</select></ul>
		
	</cfif>
	</td>
</tr>
<cfif currenttopics.recordcount is 0>
<tr bgcolor="#d8d8d8">
	<td>
	<input type="button" name="submit" value="Back" onClick="history.back();">
	</td>
</tr>
	<cfset buttonshow = 1>
	</cfif>
</cfif>
<tr bgcolor="#d8d8d8">
	<td>
	<cfif buttonshow is 0>
		<cfif url.page is 1>
			  <input type="submit" name="submit" value="Retrieve Topic">
		<cfelse>
			<input type="submit" name="submit" value="Retrieve Category">
		</cfif>
	</cfif>
	</td>
</tr>
      </td>
  </tr>
</table>
</form>
</ul>

<cfelseif url.page is 2>
<cfif topicid is 0>
	<cflocation url="error.cfm?errorid=1" addtoken="No">
</cfif>
<cfquery name="currenttopics2" datasource="#datasource#" dbtype="ODBC">
select *
from topics
Where uniqueid = #topicid#
</cfquery> 


<cfquery name="assignedtopics" datasource="#datasource#" dbtype="ODBC">
select *
from topics
</cfquery> 
<form action="libraryaction.cfm" method="post">
<ul>
  <table width="387" border="0" cellspacing="0" cellpadding="2">
    <tr bgcolor="#FFFFFF"> 
      <td width="271" bgcolor="#663300"><b><font color="white">Delete A Library Topic</b></font></td>
      <td width="108" bgcolor="#663300">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="271" bgcolor="#eaeaea">&nbsp; </td>
      <td width="108" bgcolor="#eaeaea">&nbsp;</td>
    </tr>
    <tr bgcolor="#eaeaea"> 
      <td height="39" width="271" valign="Top">
       <b><font face="Arial, Helvetica, sans-serif" size="2" color="#666666">Topic Name</font><font face="Arial, Helvetica, sans-serif"><br>
          <cfoutput query="currenttopics2">
		  <input type="hidden" name="topicid" size="40" maxlength="50" value="#uniqueid#">
		
          <ul><font size="-1">#name#</font></ul>
		  </cfoutput>
          <br>
          <input type="submit" name="Submit" value="Remove Topic">
      </td>
      <td valign="top" width="108"><!---  <font face="Arial, Helvetica, sans-serif" size="2" color="#666666" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Files 
        Assigned </font> <br>
        <select name="filelist" size="10">
          <option value="">None assigned</option>
        </select> --->
      </td>
    </tr>
  </table>
  <input type="hidden" name="Libselectiontype" value="2">
  <input type="hidden" name="function" value="3">
</ul></form>
</cfif>
<cfinclude template="/intranet/Footer.cfm">
</body>
</html>
