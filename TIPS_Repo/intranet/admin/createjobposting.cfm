<cfset datasource = "DMS">

<cfif IsDefined("url.viewcriteria")>
	<cfset viewcriteria = 1>
</cfif>
<cfparam name="viewcriteria" default="0">

<!--- clear out garbage in the jobcriteria table --->
<cfif viewcriteria is 0>
	<cfquery name="deletestraycriteria" datasource="#datasource#" dbtype="ODBC">
		DELETE from jobcriteria
		WHERE buildid = #session.userid#
	</cfquery>
</cfif>

<cfquery name="gethouse" datasource="#datasource#" dbtype="ODBC">
Select housename,nhouse
From vw_houses
Where nregionnumber = #url.region#
</cfquery>

<cfquery name="getregions2" datasource="#datasource#" dbtype="ODBC">
Select RegionName
From VW_regions
Where nregionnumber = #url.region#
</cfquery>

<cfquery name="getcat" datasource="#datasource#" dbtype="ODBC">
Select toc_ndx,heading
From jobTOC
Where nregionnumber = #url.region#
</cfquery>

<cfquery name="getuser" datasource="#datasource#" dbtype="ODBC">
Select fname,lname
From vw_employees
Where employee_ndx = #session.userid#
</cfquery>

<cfquery name="getjobcode" datasource="#datasource#" dbtype="ODBC">
SELECT *
FROM jobcode
</cfquery>

<CFINCLUDE template="/intranet/header.cfm">

<ul>
<BR>
<cfif viewcriteria is 0>

<cfif getcat.recordcount is 0>
 	 <cfoutput><form action="addjobcategories.cfm?region=#url.region#" method="post" name="resourcerec"></cfoutput>
 <cfelse>
 	<form action="jobaction.cfm" method="post" name="resourcerec" enctype="multipart/form-data">
 </cfif>
    <table width="640" border="0" cellspacing="2" cellpadding="2" bgcolor="White">
      <tr> 
        <td colspan="4" bgcolor="#006666"> 
        <cfif FindNoCase("western",getregions2.RegionName,1) GT 0>
           <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;New Job Posting for the Western Region</font>
		   <cfelseif FindNoCase("ALC Home Office",getregions2.RegionName,1) GT 0> 
           <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;New Job Posting for the Home Office</font> 
            <cfelseif FindNoCase("central",getregions2.RegionName,1) GT 0> 
           <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;New Job Posting for the Central Region</font> 
            <cfelseif FindNoCase("southeast",getregions2.RegionName,1) GT 0> 
            <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;New Job Posting for the South East Region</font>
            <cfelseif FindNoCase("eastern",getregions2.RegionName,1) GT 0>
            <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;New Job Posting for the Eastern Region</font> 
          </cfif> 
        </td>
      </tr>
	  <cfif getcat.recordcount is 0>
    <tr bgcolor="#f7f7f7">
	<td colspan="4">
		<ul><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">		Currently there are no job categories created for this region. You will be able to enter a new job posting when there is at least one category available.</font></ul>
	</td>
	</tr>
	<tr bgcolor="#eaeaea">
		<td>
			<input type="button" name="back" value="Back" onClick="history.back();">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Create a Category">
		</td>
	</tr>
	</table>
	</form>
	<cfelse>
	  <tr bgcolor="#f7f7f7"> 
        <td width="86">
			&nbsp;<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Region:</font>
		</td>
        <td width="130">
			<cfoutput query="getregions2"><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#regionname#</font></cfoutput>
		</td>
        <td width="80">
			<font size="2"><b><font face="Verdana, Arial, Helvetica, sans-serif" color="#363636">Posted By:</font></b></font>
		 </td>
        <td> 
		<font face="Verdana, Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;"><cfoutput>#getuser.fname# #getuser.lname#</cfoutput></font>
        </td>
      </tr>
	 <tr bgcolor="#f7f7f7"> 
        <td nowrap>
			&nbsp;<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Post Location:</font>
		</td>
     <td colspan="3">
	 <select name="location">
		<option value="" SELECTED>Choose...</option>
		<option value="0">Internal</option>
		<option value="1">External</option>
		<option value="2">Internal and External</option>
</select>
	 	</td>
      </tr>
	   <tr bgcolor="#f7f7f7"> 
        <td>
			&nbsp;<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Resume To:</font>
		</td>
     <td>
		<select name="resumeto">
			<option value="" SELECTED>Choose...</option>
			<option value="Human Resources">Human Resources</option>
		</select>
	 </td>
	 <td colspan="2">
	 	<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Close Resume Date:</font>&nbsp;&nbsp;&nbsp;<A href="javascript:calendar(6)"><img src="/intranet/pix/calendaricon.gif" width="19" height="20" border="0" alt="" align="absmiddle"></A>&nbsp;<input type="text" name="resumedate" size="12" maxlength="12">
	 </td>
      </tr>
    
      <tr bgcolor="#f7f7f7"> 
        <td width="86"><font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;"> 
          &nbsp;House:</font></td>
        <td width="130"> 
         		<select name="nhouse">
					<option value="1800" SELECTED>Choose...</option>
					<cfoutput query="gethouse"><option value="#nhouse#">#housename#</option></cfoutput>
				</select>
			
        </td>
        <td width="80"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><b><font color="#363636">Category:</font></b></font></td>
        <td >
          <select name="category">
		  <option value="" selected>Choose...</option>
            <cfoutput query="getcat"><option value="#toc_ndx#">#heading#</option></cfoutput>
          </select>
        </td>
      </tr>
      
<tr bgcolor="#f7f7f7">
<td width="86">
	&nbsp;<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Job Desc:</font>
</td>
	<td width="130">
		<select name="jobnumber">
		<option value="" SELECTED>Choose...</option>
		<cfoutput query="getjobcode"><option value="#jobcode#">#descrip#</option></cfoutput>
</select>
	</td>
	<td width="80">
		<b><font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#009900">View:</font><font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#363636"> <input type="radio" name="view" value="1" checked></font></b>
	</td>
	<td>
		<font size="2"><b><font face="Verdana, Arial, Helvetica, sans-serif" color="#990000">Hide:</font><font face="Verdana, Arial, Helvetica, sans-serif" color="#363636"> <input type="radio" name="view" value="0"></font></b></font>
	</td>
</tr>
<tr bgcolor="#f7f7f7">
	<td width="86">
		&nbsp;<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Job Title:</font>
	</td>
	<td colspan="3">
		<input type="text" name="jobtitle" size="50" maxlength="50">
	</td>
</tr>
<tr bgcolor="#f7f7f7">
	<td width="86">
		&nbsp;<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Post Date:</font>
		</td>
		<td width="130">
		<A href="javascript:calendar(3)"><img src="../pix/calendaricon.gif" width="19" height="20" align="absmiddle" border="0" alt=""></a>&nbsp;<input type="text" name="postdate" size="12" maxlength="12">
	</td>
	<td width="80">
		<font size="2"><b><font face="Verdana, Arial, Helvetica, sans-serif" color="#363636">Expiration:</font></b></font>
	</td>
	<td>
		<A href="javascript:calendar(4)"><img src="../pix/calendaricon.gif" width="19" height="20" align="absmiddle" border="0" alt=""></a>&nbsp;<input type="text" name="expiredate" size="12" maxlength="12">
	</td>
</tr>
  <tr bgcolor="#f7f7f7"> 
	<td colspan="4">&nbsp; <font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Notes:</font>&nbsp;
	  <input type="text" name="notes" size="70" maxlength="200">
	</td>
</tr>
	  
	    <cfoutput><input type="hidden" name="region" value="#url.region#"></cfoutput>
       <input type="hidden" name="function" value="1">
	   <input type="hidden" name="taskid" value="2">
	       <tr bgcolor="#f7f7f7"> 
        <td colspan="4">&nbsp; 
          <input type="submit" name="submit" value="Submit Posting for Review">
        </td>
      </tr>
  </table>
   <input type="hidden" name="category_required" value="">
  <input type="hidden" name="jobnumber_required" value="">
  <input type="hidden" name="postdate_required" value="">
  <input type="hidden" name="expiredate_required" value="">
  <input type="hidden" name="resumeto_required" value="">
   <input type="hidden" name="location_required" value="">
  </form>
  </cfif>
<cfelse> 
<!-------------------------------------------------------- view criteria ------------------------------------------>
	<cfquery name="getjoblisting" datasource="#datasource#" dbtype="ODBC">
	SELECT *
	FROM joblistings
	Where form_ndx = #url.return#
	</cfquery>
	
	<cfquery name="getspecificcat" datasource="#datasource#" dbtype="ODBC">
		Select heading
		From jobTOC
		Where toc_ndx = #url.cat#
	</cfquery>

<cfoutput query="getjoblisting">
    <table width="660" border="0" cellspacing="2" cellpadding="2" bgcolor="White">
      <tr> 
        <td colspan="4" bgcolor="##006666"> 
        <cfif FindNoCase("western",getregions2.RegionName,1) GT 0>
           <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;New Job Posting for the Western Region</font>
            <cfelseif FindNoCase("ALC Home Office",getregions2.RegionName,1) GT 0> 
           <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;New Job Posting for the Home Office</font> 
			<cfelseif FindNoCase("central",getregions2.RegionName,1) GT 0> 
           <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;New Job Posting for the Central Region</font> 
            <cfelseif FindNoCase("southeast",getregions2.RegionName,1) GT 0> 
            <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;New Job Posting for the South East Region</font>
            <cfelseif FindNoCase("eastern",getregions2.RegionName,1) GT 0>
            <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;New Job Posting for the Eastern Region</font> 
          </cfif> 
        </td>
      </tr>
	   <tr bgcolor="##f7f7f7"> 
        <td nowrap>
			&nbsp;<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Post Location:</font>
		</td>
     <td colspan="3">
	 	<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">
		<cfif location is 0>
			&nbsp;Internal
		<cfelseif location is 1>
			&nbsp;External
		<cfelse>
			&nbsp;Internal and External
		</cfif>
		</font>
	 	</td>
      </tr>
	  <tr bgcolor="##f7f7f7"> 
        <td>
			&nbsp;<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Resume To:</font>
		</td>
     <td>
		<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#resumeto#</font>
	 </td>
	 <td colspan="2">
	 	<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Close Resume Date:</font>&nbsp;&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#DateFormat(resumedate)#</font>
	 </td>
      </tr>
      <tr bgcolor="##f7f7f7"> 
        <td width="86">
			&nbsp;<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Region:</font>
		</td>
        <td width="130"> 
			<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#getregions2.regionname#</font></td>
        <td width="80">
			<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Posted By:</font>
		</td>
        <td > 
			<font face="Verdana, Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#getuser.fname# #getuser.lname#</font>
        </td>
      </tr>
	  
      <tr bgcolor="##f7f7f7"> 
        <td width="86"><font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">&nbsp;House:</font>
		  </td>
        <td width="130"> 
			<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#gethouse.housename#</font>
        </td>
        <td width="80">
			<font size="2" face="Verdana, Arial, Helvetica, sans-serif"><b><font color="##363636">Category:</font>
		</td>
        <td >
           <font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#getspecificcat.heading#</font>
        </td>
     </tr>
      
<tr bgcolor="##f7f7f7">
	<td width="86">
	&nbsp;<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Job Desc:</font>
	</td>
	<td width="130">
		<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#jobnumber#</font>
	</td>
	<td >
		<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Viewable?</font>&nbsp;
	</td>
	<td>
		<cfif show is 1>
			<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Yes</font>
		<cfelse>
			<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">No</font>
		</cfif>
	</td>
</tr>

<tr bgcolor="##f7f7f7">
	<td width="86">
		&nbsp;<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Job Title:</font>
	</td>
	<td colspan="3">
		<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#jobtitle#</font>
	</td>
</tr>

<tr bgcolor="##f7f7f7">
	<td width="86">
		&nbsp;<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Post Date:</font>
	</td>
	<td width="130">
		<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">&nbsp;#dateformat(activedate)#</font>
	</td>
	<td width="80">
		<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Expiration:</font>
	</td>
	<td >
		<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">&nbsp;#dateformat(closedate)#</font>
	</td>
</tr>

  <tr bgcolor="##f7f7f7"> 
        <td colspan="4">
		<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Notes:</font>&nbsp;
         <font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;"> #notes#</font>
		</td>
  </tr>
  </table>
  </cfoutput>
<!------------------ Begin add criteria section form ------------------------------------------------>
  <form action="jobaction.cfm?function=4" method="post" name="criteria" id="criteria">
  <table width="660" border="0" cellspacing="2" cellpadding="2">
  <tr bgcolor="#006666">
	  <td colspan="3">
	  	<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Build Responsibility and Skills Listing for this Post</font>
	  </td>
  </tr>
  <tr bgcolor="#eaeaea"> 
        <td>
			<table width="20" border="0" cellspacing="0" cellpadding="0">
			<tr>
			    <td>
					<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Responsibility:</font>
				</td>
	    		<td>
					<input type="radio" name="criteria" value="1">
				</td>
			</tr>
				<tr>
			    <td>
					<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Skill:</font>
				</td>
	    		<td>
					<input type="radio" name="criteria" value="0">
				</td>
			</tr>
			<tr>
			    <td>
					<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Mandatory:</font>
				</td>
	    		<td>
					<input type="radio" name="criteria" value="2">
				</td>
			</tr>
			</table>
	 </td>
		   <td>
			<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Description:</font>&nbsp;
			<input type="text" name="criteriadesc" size="50" maxlength="100">
			</td>
			<td>
				&nbsp;<input type="submit" name="Addcriteria" value="Add">
			</td>
      </tr>
			<cfoutput>
				<input type="hidden" name="listingnumber" value="#url.return#">
				<input type="hidden" name="region" value="#url.region#">
				<input type="hidden" name="category" value="#url.cat#">
			</cfoutput>
			
		<input type="hidden" name="criteria_required">
	  </form>
<!--- end add section of the criteria form ----------------------------------------------------------->
	  
	  <cfquery name="getcriteria" datasource="#datasource#" dbtype="ODBC">
		Select criteriadesc,criteriatype,buildid,jobcriteria_id
		From jobcriteria
		Where buildid = #session.userid#
	</cfquery>
	
	  <tr bgcolor="#eaeaea"> 
        <td colspan="3">
			<font color="#000099" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Responsibilities:</font>
		 </td>
      </tr>
	  <cfif getcriteria.recordcount is 0>
	 		<tr bgcolor="#eaeaea">
		    	<td colspan="3">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#363636" face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">Ready</font>
				</td>
		  	</tr>
	  <cfelse>
	
    <cfoutput query="getcriteria">
		<cfif criteriatype is 1>
			<tr bgcolor="##f7f7f7">
		    	<td colspan="2">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#criteriadesc#</font>
				</td>
		    	<td>
					<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">[<A HREF="jobaction.cfm?id=#jobcriteria_id#&function=6&return=#url.return#&region=#url.region#&viewcriteria=1&cat=#url.cat#">delete</a>]</font>
				</td>
		  	</tr>
		</cfif>
	</cfoutput>
	</cfif>
	 <tr bgcolor="#eaeaea">
	    <td colspan="3">
		<font color="#000099" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Skills:</font>
		</td>
	 </tr>
	 <cfif getcriteria.recordcount is 0>
	 		<tr bgcolor="#eaeaea">
		    	<td colspan="3">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#363636"face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">Ready</font>
				</td>
		  	</tr>
	  <cfelse>
	 <cfoutput query="getcriteria">
		 <cfif criteriatype is 0>
		    <tr bgcolor="##f7f7f7">
		    	<td width="300" colspan="2">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#criteriadesc#</font>
				</td>
		    	<td>
					<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">[<A HREF="jobaction.cfm?id=#jobcriteria_id#&function=6&return=#url.return#&region=#url.region#&viewcriteria=1&cat=#url.cat#">delete</a>]</font>
				</td>
		  	</tr>
		 </cfif>
	  </cfoutput>
	  <tr bgcolor="#eaeaea"> 
        <td colspan="3">
			<font color="#000099" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Mandatory Skills:</font>
		 </td>
      </tr>
	  <cfif getcriteria.recordcount is 0>
	 		<tr bgcolor="#eaeaea">
		    	<td colspan="3">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#363636" face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">Ready</font>
				</td>
		  	</tr>
	  <cfelse>
	
    <cfoutput query="getcriteria">
		<cfif criteriatype is 2>
			<tr bgcolor="##f7f7f7">
		    	<td colspan="2">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#criteriadesc#</font>
				</td>
		    	<td>
					<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">[<A HREF="jobaction.cfm?id=#jobcriteria_id#&function=6&return=#url.return#&region=#url.region#&viewcriteria=1&cat=#url.cat#">delete</a>]</font>
				</td>
		  	</tr>
		</cfif>
	</cfoutput>
	</cfif>
	<cfoutput>  <form action="jobaction.cfm?function=5&region=#url.region#" method="post"></cfoutput>
	  		<tr bgcolor="#eaeaea">
		    	<td colspan="3">
					<input type="submit" name="submit" value="Finish Posting">
				</td>
		  	</tr>
			
	  </form>
	  </cfif> 	
 </table>
</cfif> <!--- end view criteria --->
</ul>

<CFINCLUDE template="/intranet/Footer.cfm">



