<!--------------------------------------->
<!--- Programmer: Andy Leontovich        --->
<!--- File: admin/librarycategories.cfm  --->
<!--- Company: Maxim Group/ALC           --->
<!--- Date: June                         --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfparam name="url.page" default="0">
<cfparam name="page" default="0">
<cfinclude template="/intranet/header.cfm">
<cfparam name="buttonshow" default="0">

<cfif url.page LTE 1>
<cfquery name="currentcategories" datasource="#datasource#" dbtype="ODBC">
select *
from categories

<cfif url.page is 1>
	Where uniqueid = #categoryid# AND  user_id = #session.userid#
<cfelse>
	Where user_id = #session.userid#
</cfif>
</cfquery>


<cfif url.page is 1>
	<cfset page = 2>
<cfelse>
	<cfset page = 1>
</cfif>

<ul>
<cfoutput><form action="editlibrarytopics.cfm?page=#page#" method="post"></cfoutput>
<table width="490" border="0" cellspacing="0" cellpadding="2">
  <tr bgcolor="#006699"> 
    <td colspan="4"><font face="Arial, Helvetica, sans-serif" color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: medium; font-weight: bold;">&nbsp;Edit 
      A Library Topic</font></td>
  </tr>
  <tr bgcolor="#eaeaea">
	<td>
		<BR>
	</td>
</tr>
<tr bgcolor="#eaeaea">
	<td>&nbsp;<font color="#7e7e7e" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Category</font><br>
		&nbsp;<select name="categoryid">
			<cfif url.page is not 1>
			<option value="0" SELECTED>Choose a Category</option>
			</cfif>
			<cfoutput query="currentcategories"><option value="#uniqueid#">#name#</option></cfoutput>
		</select>
		<BR><BR>
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
		&nbsp;<font color="#7e7e7e" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Topic</font><br>
		&nbsp;<select name="topicid">
			<option value="" SELECTED>Choose a Topic</option>
			<cfoutput query="currenttopics"><option value="#uniqueid#">#name#</option></cfoutput>
		</select>
		<BR><BR>
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
<!--- comment: topic queries not used in the over all system. Time was cut short--->
<cfquery name="currenttopics2" datasource="#datasource#" dbtype="ODBC">
select *
from topics
Where uniqueid = #topicid#
</cfquery> 


<cfquery name="assignedtopics" datasource="#datasource#" dbtype="ODBC">
select *
from topics
</cfquery> 

<ul><form action="libraryaction.cfm" method="post">
  <table width="450" border="0" cellspacing="0" cellpadding="3">
    <tr bgcolor="#006699"> 
      <td colspan="3"><font color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: medium; font-weight: bold;">Edit 
        A Library Topic</font></td>
      
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td colspan="3" bgcolor="#EAEAEA">&nbsp; </td>
    </tr>

    <tr bgcolor="#eaeaea"> 
      <td valign="middle">
        <cfoutput query="currenttopics2">
		<p><font size="2"><b><font face="Arial, Helvetica, sans-serif" color="##666666"> 
          Topic Name</font><font face="Arial, Helvetica, sans-serif"><br>
          <input type="hidden" name="uniqueid" size="40" maxlength="50" value="#uniqueid#"></font>
         
         <input type="text" name="name" value="#name#">
		 <input type="hidden" name="name_required" value="The Topic Name needs to have an entry.">
		</cfoutput>
		  <br>
       <cfquery name="getcurrentcategory" datasource="#datasource#" dbtype="ODBC">
		select *
		from categories
		Where uniqueid = #categoryid#
	  </cfquery>
	  
	   <cfquery name="getcatagories" datasource="#datasource#" dbtype="ODBC">
		select *
		from categories
	  </cfquery>

    <font size="2"><b><font face="Arial, Helvetica, sans-serif" color="#666666">Assigned 
      to Category</font><br>
      <select name="categoryid">
	  <cfif getcurrentcategory.recordcount is not 0>
	  	<cfoutput query="getcurrentcategory"><option value="#uniqueid#">#name#</option></cfoutput>
		<option value="">_____________________</option>
		</cfif>
		<cfoutput query="getcatagories"><option value="#uniqueid#">#name#</option></cfoutput>
	
      </select>
      </font></b>
		  <BR><BR>
          <input type="submit" name="Submit" value="Submit Changes to Topic">
      </td>
	  <td valign="top">
	   <table width="78" border="0" cellspacing="6" cellpadding="0">
        <tr align="center"> 
          <td><font size="1" face="Arial, Helvetica, sans-serif">Visible</font></td>
          <td><font size="1" face="Arial, Helvetica, sans-serif">Hidden</font></td>
        </tr>
        <tr> 
          <td align="center">
		  	<cfif currenttopics2.visible is 1>
				<cfoutput> <input type="radio" name="visible" value="1" checked></cfoutput>
			<cfelse>
				 <input type="radio" name="visible" value="1">
			</cfif>
           
          </td>
          <td align="center"> 
             <cfif currenttopics2.visible is 0>
				<cfoutput><input type="radio" name="visible" value="0" checked></cfoutput>
			<cfelse>
				  <input type="radio" name="visible" value="0">
			</cfif>
          </td>
        </tr>
      </table>
	  
	  </td>
      <td valign="top"><!---  <font face="Arial, Helvetica, sans-serif" size="2" color="#666666" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Files 
        Assigned </font> <br>
        <select name="filelist" size="10">
          <option value="">None assigned</option>
        </select> --->
      </td>
    </tr>
	  
  </table>
  <input type="hidden" name="function" value="2">
<input type="hidden" name="Libselectiontype" value="2">
  </form>
</ul>
</cfif>
<cfinclude template="/intranet/Footer.cfm">

