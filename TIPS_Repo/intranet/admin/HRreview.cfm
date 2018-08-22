<cfset datasource = "DMS">

<cfquery name="getuser" datasource="#datasource#" dbtype="ODBC">
Select fname,lname
From vw_employees
Where employee_ndx = #session.userid#
</cfquery>

 <cfquery name="getlisting2" datasource="#datasource#" dbtype="ODBC">
Select joblistings.Form_Ndx,vw_houses.nhouse,joblistings.revdate,joblistings.dDateStamp,joblistings.JobNumber,joblistings.notes,jobtoc.heading,joblistings.jobtitle,vw_houses.housename,vw_regions.regionname,joblistings.activedate,joblistings.dDateStamp,joblistings.closedate,joblistings.resumeto,joblistings.location,joblistings.resumedate,vw_regions.nregionnumber,joblistings.submittedby,joblistings.hractive
From joblistings,jobtoc,vw_regions,vw_houses
Where joblistings.nregionnumber = vw_regions.nregionnumber
AND joblistings.nhouse = vw_houses.nhouse
AND joblistings.tocid = jobtoc.toc_ndx
AND joblistings.Form_Ndx = #url.index#
</cfquery>

<cfquery name="getsubmitter" datasource="#datasource#" dbtype="ODBC">
Select fname,lname,email,employee_ndx
From vw_employees
Where employee_ndx = #getlisting2.submittedby#
</cfquery>

<cfquery name="GetHouseAddr" datasource="Census" dbtype="ODBC">
	select hAddress, hCity, hState, hPhone  
	from HouseAddresses
	where nHouse = #getlisting2.nHouse#
 </cfquery>
<CFINCLUDE template="/intranet/header.cfm">
<ul><form action="hrreviewaction.cfm" method="post">

<table width="700" border="0" cellspacing="2" cellpadding="2" bgcolor="White">
<tr>
	<cfif getlisting2.hractive is 1>
		<td bgcolor="#006666" colspan="5">
			<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Action Requested: Add Announcement
		<cfif getlisting2.nregionnumber is 1>
						 for the Western Region
		<cfelseif getlisting2.nregionnumber is 2>
						 for the Central Region
		<cfelseif getlisting2.nregionnumber is 3>
						 for the South East Region
		<cfelseif getlisting2.nregionnumber is 4>
						for the Eastern Region
		</cfif>
		</font>
		<cfelseif getlisting2.hractive is 2>
		<td  bgcolor="#006699" colspan="5">
			<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Action Requested: Edit Announcement
		<cfif getlisting2.nregionnumber is 1>
						 for the Western Region
		<cfelseif getlisting2.nregionnumber is 2>
						 for the Central Region
		<cfelseif getlisting2.nregionnumber is 3>
						 for the South East Region
		<cfelseif getlisting2.nregionnumber is 4>
						for the Eastern Region
		</cfif>
		</font>
		<cfelseif getlisting2.hractive is 3>
		<td  bgcolor="#663300" colspan="5">
			<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Action Requested: Delete Announcement
		<cfif getlisting2.nregionnumber is 1>
						 for the Western Region
		<cfelseif getlisting2.nregionnumber is 2>
						 for the Central Region
		<cfelseif getlisting2.nregionnumber is 3>
						 for the South East Region
		<cfelseif getlisting2.nregionnumber is 4>
						for the Eastern Region
		</cfif>
		</font>
		</cfif>
	 </td>
 </tr>
<tr>
	<td colspan="5">
		<font color="##000000" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">Community Relations is recruiting <cfif getlisting2.location is 0>
internally
<cfelseif getlisting2.location is 1>
externally
<cfelse>
internally and externally
</cfif> for the following position:</font><cfoutput>
	<font color="##000000" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">&nbsp;#trim(getlisting2.JobTitle)#</font>
	</cfoutput>
	</td>
</tr>
 <tr bgcolor="#f7f7f7">
	<td colspan="5">
	<cfoutput>
	<font color="##000000" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">&nbsp;Location</font>
	</cfoutput>
	 </td>
 </tr>
<tr>
<cfoutput>
	<td colspan="5">
	<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">
	#getlisting2.HouseName#<BR>
	#getHouseAddr.HAddress#<br>
	#getHouseAddr.HCity#  #getHouseAddr.HState#<br>
	#getHouseAddr.HPhone#</font>
	</td>
</cfoutput>
</tr>

<cfoutput>
<tr>
<td colspan="2">&nbsp;<font color="##000000" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Job Number:&nbsp;&nbsp;#getlisting2.JobNumber#</font></td>
<td colspan="3">&nbsp;<font color="##000000" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Submitted By:&nbsp;&nbsp;#getsubmitter.fname# #getsubmitter.lname#</font></td>
</tr>
<tr>
	<td colspan="2">&nbsp;<font color="##000000" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Posted:&nbsp; #DateFormat(getlisting2.dDateStamp,"MMM,DD,YYYY")#</font></td>
	<td colspan="3">&nbsp;<font color="##000000" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Expiration Date:&nbsp;&nbsp;#DateFormat(getlisting2.closedate)#</font></td>
</tr>
<cfif getlisting2.RevDate is not "">
<tr>
	<td colspan="5">&nbsp;<font color="##000000" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Revision Date:&nbsp;&nbsp;#getlisting2.RevDate#</font></td>
</tr>
</cfif>


</cfoutput>


<cfquery name="getcriteria" datasource="#datasource#" dbtype="ODBC">
		Select criteriadesc,criteriatype,jobcriteria_id
		From jobcriteria
		Where listingid = #getlisting2.form_ndx#
	</cfquery>
	
	  <tr bgcolor="#f7f7f7"> 
        <td colspan="5">
			&nbsp;<font color="#000000" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Responsibilities include but are not limited to:</font>
		 </td>
      </tr>
	
    
			<tr>
		    	<td colspan="5"><ul>
				<cfoutput query="getcriteria">
				<cfif criteriatype is 1>
				
					<li type="disc"><font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#criteriadesc#</font></li>
				
				</cfif>
				</cfoutput>
				</ul>
				</td>
		    
		  	</tr>
	
	 <tr bgcolor="#f7f7f7">
	    <td colspan="5">
		&nbsp;<font color="#000000" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Skills Needed:</font>
		</td>
	 </tr>
		    <tr>
		    	<td colspan="5">
				<ul>
				 <cfoutput query="getcriteria">
				 <cfif criteriatype is 0>
				 
					<li type="disc"><font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#criteriadesc#</font></li>
				
				</cfif>
				</cfoutput>
				</ul>
				</td>
		  	</tr>
 <tr bgcolor="#f7f7f7"> 
        <td colspan="5">
			&nbsp;<font color="#000000" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Mandatory Skills:</font>
		 </td>
      </tr>
	
	
    <cfoutput query="getcriteria">
		<cfif criteriatype is 2>
			<tr bgcolor="##f7f7f7">
		    	<td colspan="5">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#criteriadesc#</font>
				</td>
		  	</tr>
		</cfif>
	</cfoutput>
	
	  <tr bgcolor="#f7f7f7">
	<td colspan="5">&nbsp;<font color="##000000" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Notes:&nbsp;</font>

<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">
	<cfoutput>
	#getlisting2.Notes#
	</cfoutput>
</font></td>
</tr>
	  <tr>
    	<td colspan="5"><br><br>
			<font face="Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">Please provide <cfoutput>#getlisting2.resumeto#</cfoutput> with a copy of your resume no later than <b><cfoutput>#DateFormat(getlisting2.resumedate)#</cfoutput></b> if you are interested in being considered for this position.</font>
		</td>
  	</tr>


<tr bgcolor="#eaeaea">
<td>&nbsp;
<input type="submit" name="back" value="Back to Listings" onClick="history.back();">
</td><cfoutput>
<td><font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Reviewed By:&nbsp;&nbsp;<font face="Verdana, Arial, Helvetica, sans-serif" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#getuser.fname# #getuser.lname#</font>
<input type="hidden" name="reviewedby" value="#session.userid#"></font></td>
<td><font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Accept:&nbsp;<input type="radio" name="show" value="0"></font></td><!--- set variable --->
<td><font color="##363636" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Deny:&nbsp;<input type="radio" name="show" value="#url.locat#"></font></td>
<td><input type="submit" name="submit" value="Submit"></td></cfoutput>
</tr>
</table>

<cfoutput>
	<input type="hidden" name="form_ndx" value="#getlisting2.form_ndx#">
	<input type="hidden" name="submitter" value="#getsubmitter.employee_ndx#">
	<input type="hidden" name="functioncheckforshow" value="#url.locat#">
</cfoutput> 
</td>
</tr>
</table>
<input type="hidden" name="show_required" value="You must Accept or Deny the posting to continue.">
</form>
</ul>

<CFINCLUDE template="/intranet/Footer.cfm">



