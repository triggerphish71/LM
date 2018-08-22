<cfset datasource = "DMS">

<cfparam name="url.return" default="0">
<cfparam name="url.cat" default="0">

 <cfquery name="getlisting2" datasource="#datasource#" dbtype="ODBC" cachedwithin="#createtimespan(0,0,10,0)#">
Select joblistings.Form_Ndx,vw_houses.nhouse,joblistings.revdate,joblistings.dDateStamp,joblistings.JobNumber,joblistings.notes,jobtoc.heading,joblistings.jobtitle,vw_houses.housename,vw_regions.regionname,joblistings.activedate,joblistings.dDateStamp,joblistings.closedate,joblistings.show,joblistings.reviewedby,joblistings.tocid,joblistings.submittedby,joblistings.location,joblistings.resumeto,joblistings.resumedate
From joblistings,jobtoc,vw_regions,vw_houses
Where joblistings.nregionnumber = vw_regions.nregionnumber
AND joblistings.nhouse = vw_houses.nhouse
AND joblistings.tocid = jobtoc.toc_ndx
AND <cfif isDefined("url.index")>
joblistings.Form_Ndx = #url.index#
<cfelse>
joblistings.Form_Ndx = #url.return#
</cfif></cfquery>

<cfquery name="gethouse" datasource="#datasource#" dbtype="ODBC" cachedwithin="#createtimespan(0,0,10,0)#">
Select housename,nhouse
From vw_houses
Where nregionnumber = #url.region#</cfquery>

<cfquery name="getregions2" datasource="#datasource#" dbtype="ODBC" cachedwithin="#createtimespan(0,0,10,0)#">
Select RegionName,nregionnumber
From VW_regions
Where nregionnumber = #url.region#</cfquery>

<cfquery name="getcat" datasource="#datasource#" dbtype="ODBC" cachedwithin="#createtimespan(0,0,10,0)#">
Select toc_ndx,heading
From jobTOC
Where nregionnumber = #url.region#</cfquery>

<cfquery name="getcatassign" datasource="#datasource#" dbtype="ODBC" cachedwithin="#createtimespan(0,0,10,0)#">
Select toc_ndx,heading
From jobTOC
Where toc_ndx = #getlisting2.tocid#</cfquery>

<cfquery name="getuser" datasource="#datasource#" dbtype="ODBC" cachedwithin="#createtimespan(0,0,10,0)#">
Select fname,lname
From vw_employees
Where employee_ndx = #getlisting2.submittedby#</cfquery>

<cfquery name="getjobcode" datasource="#datasource#" dbtype="ODBC" cachedafter="#createtimespan(0,0,10,0)#">
SELECT *
FROM jobcode</cfquery>

<cfquery name="getonejobcode" datasource="#datasource#" dbtype="ODBC" cachedwithin="#createtimespan(0,0,10,0)#">
SELECT *
FROM jobcode
Where jobcode = #getlisting2.JobNumber#</cfquery>

<CFINCLUDE template="/intranet/header.cfm">

<ul>
<BR>
<cfoutput>  <form action="jobaction.cfm?region=#getregions2.nregionnumber#" method="post" name="resourcerec"></cfoutput>
    <table width="660" border="0" cellspacing="2" cellpadding="2" bgcolor="White">
      <tr> 
        <td colspan="4" bgcolor="#006699"> 
        <cfif FindNoCase("western",getlisting2.regionname,1) GT 0>   
          <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;Edit Job Posting for the Western Region</font>
           <cfelseif FindNoCase("central",getlisting2.regionname,1) GT 0>
          <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;Edit Job Posting for the Central Region</font>
           <cfelseif FindNoCase("southeast",getlisting2.regionname,1) GT 0> 
           <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;Edit Job Posting for the South East Region</font>
            <cfelseif FindNoCase("eastern",getlisting2.regionname,1) GT 0>
                  <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;Edit Job Posting for the Eastern Region</font>
          </cfif> 
        </td>
      </tr>
    
      <tr bgcolor="#f7f7f7"> 
        <td width="86">&nbsp;<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Region:</font></td>
        <td width="130"> <cfoutput query="getregions2"><font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#regionname#</font></cfoutput></td>
        <td width="80"><font size="2"><b><font face="Verdana, Arial, Helvetica, sans-serif" color="#363636">Posted 
          By:</font></b></font></td>
        <td width="184">
		<font face="Verdana, Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;"><cfoutput>#getuser.fname# #getuser.lname#</font></cfoutput>
         <cfoutput> <input type="hidden" name="postedby" value="#getlisting2.reviewedby#" size="30" maxlength="30"></cfoutput>
        </td>
      </tr>
	   <tr bgcolor="#f7f7f7"> 
        <td nowrap>
			&nbsp;<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Post Location:</font>
		</td>
     <td colspan="3">
	 <select name="location">
	<cfoutput query="getlisting2">
	<cfif location is 0>
	<option value="#location#">Internal</option>
<cfelseif location is 1>
<option value="#location#">External</option>
<cfelseif location is 2>
<option value="#location#">Internal And External</option>
</cfif>
	</cfoutput>
		<option value="">________________</option>
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
			<cfoutput query="getlisting2"><option value="#resumeto#">#resumeto#</option></cfoutput>
			<option value="" >_____________________</option>
			<option value="Human Resources">Human Resources</option>
		</select>
	 </td>
	 <td colspan="2">
	 	<cfoutput query="getlisting2"><font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Close Resume Date:</font>&nbsp;&nbsp;&nbsp;<A href="javascript:calendar(6)"><img src="/intranet/pix/calendaricon.gif" width="19" height="20" border="0" alt="" align="absmiddle"></A>&nbsp;<input type="text" name="resumedate" value="#DateFormat(resumedate)#" size="12" maxlength="12"></cfoutput>
	 </td>
      </tr>
      <tr bgcolor="#f7f7f7"> 
        <td width="86"><font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;"> 
          &nbsp;House:</font></td>
        <td width="130"> 
          
            
         		<select name="nhouse">
				<cfoutput><option value="#getlisting2.nhouse#" SELECTED>#getlisting2.housename#</option></cfoutput>
				<option value="">____________________________</option>
		<cfoutput query="gethouse"><option value="#nhouse#">#housename#</option></cfoutput>
</select>
			
        </td>
        <td width="80">
			<font size="2" face="Verdana, Arial, Helvetica, sans-serif">
			<b><font color="#363636">Category:</font></b></font>
		</td>
        <td width="184">
          <select name="category">
		  <cfoutput query="getcatassign"><option value="#toc_ndx#" selected>#heading#</option></cfoutput>
		  <option value="">__________________</option>
            <cfoutput query="getcat"><option value="#toc_ndx#">#heading#</option></cfoutput>
          </select>
        </td>
      </tr>
      

<tr bgcolor="#f7f7f7">
<td width="86">&nbsp;<font color="#363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Job Desc:</font></td>
<td width="130"><select name="jobnumber">
		<cfoutput query="getjobcode"><option value="#jobcode#">#descrip#</option></cfoutput>
		 <option value="">__________________</option>
		 <cfoutput query="getjobcode"><option value="#jobcode#">#descrip#</option></cfoutput>
</select>
</td>
<td width="80"><b><font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#009900">View:</font><font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#363636">
	<cfif getlisting2.show is 1>
		<input type="radio" name="view" value="1" checked>
	<cfelse>
		<input type="radio" name="view" value="1">
	</cfif>
	</font>
	</b>
</td>
<td width="184">
	<font size="2">
	<b>
	<font face="Verdana, Arial, Helvetica, sans-serif" color="#990000">
	Hide:
	</font>
	<font face="Verdana, Arial, Helvetica, sans-serif" color="#363636">
		<cfif getlisting2.show is 0>
			<input type="radio" name="view" value="0" checked>
		<cfelse>
			<input type="radio" name="view" value="0">
		</cfif>
	</font>
	</b>
</td>
</tr>
<cfoutput>
<tr bgcolor="##f7f7f7">
<td width="86">&nbsp;<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Job Title:</font></td><td colspan="3"><input type="text" name="jobtitle" value="#trim(getlisting2.JobTitle)#" size="50" maxlength="50"></td></tr>
<tr bgcolor="##f7f7f7">
<td width="86">&nbsp;<font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Post Date:</font></td><td width="130"><A href="javascript:calendar(3)"><img src="../pix/calendaricon.gif" width="19" height="20" align="absmiddle" border="0" alt=""></a>&nbsp;<input type="text" name="postdate" value="#DateFormat(getlisting2.ACTIVEDATE)#" size="12" maxlength="12"></td><td width="80"><font size="2"><b><font face="Verdana, Arial, Helvetica, sans-serif" color="##363636">Expiration:</font></b></font></td><td width="184"><A href="javascript:calendar(4)"><img src="../pix/calendaricon.gif" width="19" height="20" align="absmiddle" border="0" alt=""></a>&nbsp;<input type="text" name="expiredate" value="#DateFormat(getlisting2.closedate)#" size="12" maxlength="12"></td></tr>

      <tr bgcolor="##f7f7f7"> 
        <td colspan="4">
        &nbsp; <font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Notes:</font>&nbsp;
         <input type="text" name="notes" value="#getlisting2.Notes#" size="60" maxlength="200"></cfoutput>
	</td>
      </tr>
	    <cfoutput><input type="hidden" name="form_ndx" value="#getlisting2.form_ndx#">
	<input type="hidden" name="function" value="2">
	<input type="hidden" name="taskid" value="2">
	</cfoutput>
	 </form> 
	  <!------------------ Begin add criteria section form ------------------------------------------------>
  <form action="jobaction.cfm" method="post" name="criteria" id="criteria">
  <table width="660" border="0" cellspacing="2" cellpadding="2">
  <tr bgcolor="#006699">
	  <td colspan="4">
	  	<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Edit Responsibility and Skills Listing for this Post</font>
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
			<td colspan="2">
				&nbsp;<input type="submit" name="Addcriteria" value="Add">
			</td>
      </tr>
			<cfoutput>
			<input type="hidden" name="function" value="4">
			<input type="hidden" name="edit" value="1">
				<input type="hidden" name="listingnumber" value="#getlisting2.form_ndx#">
				<input type="hidden" name="region" value="#url.region#">
			<input type="hidden" name="category" value="#url.cat#">
			</cfoutput>
			
		<input type="hidden" name="criteria_required">
	  </form>
<!--- end add section of the criteria form ----------------------------------------------------------->
	  <cfif isDefined("url.return")>
	  <cfquery name="getcriteria" datasource="#datasource#" dbtype="ODBC">
			Select criteriadesc,criteriatype,buildid,jobcriteria_id
			From jobcriteria
			Where buildid = #session.userid# OR listingid = #getlisting2.form_ndx#
		</cfquery> 
	<cfelse>
		<cfquery name="getcriteria" datasource="#datasource#" dbtype="ODBC">
			Select criteriadesc,criteriatype,buildid,jobcriteria_id
			From jobcriteria
			Where listingid = #getlisting2.form_ndx#
		</cfquery>
	</cfif>

	  <tr bgcolor="#eaeaea"> 
        <td colspan="4">
			<font color="#000099" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Responsibilities:</font>
		 </td>
      </tr>
	  <cfif getcriteria.recordcount is 0>
	 		<tr bgcolor="#eaeaea">
		    	<td colspan="4">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#363636" face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">Ready</font>
				</td>
		  	</tr>
	  <cfelse>
	
    <cfoutput query="getcriteria">
		<cfif criteriatype is 1>
			<tr bgcolor="##f7f7f7">
		    	<td colspan="3">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#criteriadesc#</font>
				</td>
		    	<td>
					<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">[<A HREF="jobaction.cfm?id=#jobcriteria_id#&function=6&return=#getlisting2.form_ndx#&region=#url.region#&viewcriteria=1&cat=#url.cat#&edit=1">delete</a>]</font>
				</td>
		  	</tr>
		</cfif>
	</cfoutput>
	</cfif>
	 <tr bgcolor="#eaeaea">
	    <td colspan="4">
		<font color="#000099" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Skills:</font>
		</td>
	 </tr>
 <cfif getcriteria.recordcount is 0>
	 		<tr bgcolor="#eaeaea">
		    	<td colspan="4">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#363636"face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">Ready</font>
				</td>
		  	</tr>
<cfelse>
	 <cfoutput query="getcriteria">
		 <cfif criteriatype is 0>
		    <tr bgcolor="##f7f7f7">
		    	<td width="300" colspan="3">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#criteriadesc#</font>
				</td>
		    	<td>
					<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">[<A HREF="jobaction.cfm?id=#jobcriteria_id#&function=6&return=#getlisting2.form_ndx#&region=#url.region#&viewcriteria=1&cat=#url.cat#&edit=1">delete</a>]</font>
				</td>
		  	</tr>
		 </cfif>
	  </cfoutput>
</cfif>  
	  <tr bgcolor="#eaeaea"> 
        <td colspan="4">
			<font color="#000099" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Mandatory Skills:</font>
		 </td>
      </tr>
	  <cfif getcriteria.recordcount is 0>
	 		<tr bgcolor="#eaeaea">
		    	<td colspan="4">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#363636" face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">Ready</font>
				</td>
		  	</tr>
	  <cfelse>
	
    <cfoutput query="getcriteria">
		<cfif criteriatype is 2>
			<tr bgcolor="##f7f7f7">
		    	<td colspan="3">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#criteriadesc#</font>
				</td>
		    	<td>
					<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">[<A HREF="jobaction.cfm?id=#jobcriteria_id#&function=6&return=#getlisting2.form_ndx#&region=#url.region#&viewcriteria=1&cat=#url.cat#&edit=1">delete</a>]</font>
				</td>
		  	</tr>
		</cfif>
	</cfoutput>
	</cfif>
</form>
<!--- 	<cfoutput> <form action="jobaction.cfm?region=#url.region#" method="post"></cfoutput> --->
	  		<tr bgcolor="#eaeaea">
		    	<td colspan="4">
					<input type="button" name="submit" value="Finish Posting" onClick="document.resourcerec.submit();">
				</td>
		  	</tr>
 </table>

    
  <cfoutput><input type="hidden" name="form_ndx" value="#getlisting2.form_ndx#">
	<input type="hidden" name="function" value="2">
	<input type="hidden" name="taskid" value="2">
	</cfoutput>
 
</ul>

<CFINCLUDE template="/intranet/Footer.cfm">



