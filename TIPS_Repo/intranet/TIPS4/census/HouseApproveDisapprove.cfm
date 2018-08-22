<!----------------------------------------------------------------------------------------------
| DESCRIPTION - HouseApproveDisapprove.cfm                                                     |
|----------------------------------------------------------------------------------------------|
| To approve house occupancy                                                                   |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| fzahir     | 11/03/2005 | To show all tenants in a house. Based on the tenants, either         |
|            |            | approve or disapprove the house. An email is sent to concerned       |
|            |            | persons of houses that have not been approved on daily basis.        |
| mlaw       | 05/08/2006 | To add logic which will exclude CurrentStatusInBedAtMidnight = 'N'   |
| sfarmer    | 04/08/2013 | add user sorting capablities change default is correct room numbers  |
| sfarmer    | 03/10/2014 | Removed ts.dtMoveIn <= '#CompareDate#' due to use of future move-ins |
------------------------------------------------------------------------------------------------->

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Approve Daily Census</title>
</head>

<body>
<cfif not isDefined("session.qselectedhouse.ihouse_id") or not isDefined("session.userid")>
<cflocation url="../../Loginindex.cfm" addtoken="yes">
</cfif>
<!--- Include Intranet header --->
<cfinclude template="../../header.cfm">

<!--- Include the page for house header --->
<cfinclude template="../Shared/HouseHeader.cfm">
<cfparam name="sortby" default="">
<cfif isdefined("form.dtCompare")>
	<cfset dtCompare=#form.dtCompare# >
<cfelse >
	<cfset dtCompare=#url.dtCompare# >
</cfif>
 	

<!--- Get all the tenants information --->
<cfquery name="validatehouse" datasource="#APPLICATION.datasource#">
	select 
		a.cAptNumber
		, a.iAptType_ID
		, t.iTenant_ID
		, t.cLastName
		, t.cFirstName
		, ts.dtMoveIn
		, rt.cDescription 
	from 
		tenant t
		, tenantstate ts
		, House H
		, AptAddress a
		, ResidencyType rt
	where 
		t.iTenant_ID = ts.iTenant_ID
	and a.iAptAddress_ID = ts.iAptAddress_ID 
	and rt.iResidencyType_ID = ts.iResidencyType_ID
	and t.iHouse_ID = H.iHouse_ID 
	and t.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	and t.dtRowDeleted is NULL 
	and ts.dtrowdeleted is null 
	and ts.dtmovein is not null 
	<!--- and ts.dtmovein <= '#dtCompare#' ---> 
	and (ts.dtMoveOut >= '#dtCompare#' or ts.dtMoveOut is NULL)
	and ts.itenantstatecode_id = 2
	and t.itenant_ID not in
		(
			select 
				dct.itenant_ID 
			from 
				dailycensustrack dct
			join 
				tenant t
			on t.itenant_ID = dct.itenant_ID
			where 
				t.ihouse_Id = #SESSION.qSelectedHouse.iHouse_ID#
		    and 
				dct.CurrentStatusInBedAtMidnight = 'N'
			and
				dct.dtrowdeleted is NULL
			and
				dct.census_date = '#dtCompare#' 
			and
				t.dtrowdeleted is NULL
		)
			<cfif sortby is ''>
				order by len(a.cAptNumber) , a.cAptNumber
			<cfelseif sortby is "Room">
				order by len(a.cAptNumber) , a.cAptNumber
			<cfelseif sortby is "residentid"> 
				order by isNull(t.iTenant_ID, 99999) , len(a.cAptNumber) , a.cAptNumber 
			<cfelseif sortby is "residentname"> 
				order by  IsNull(t.cLastName, 'zzzzz') , len(a.cAptNumber) , a.cAptNumber 		
			</cfif>	
</cfquery>

<!---Mshah added query to check for medicaid recordcount--->
<cfquery name="Medicaidrecordcount" datasource="#application.datasource#">
select * from tenant t join tenantstate ts on ts.itenant_ID=t.itenant_ID
where ts.itenantstatecode_ID=2
and ts.iresidencytype_ID= 2
and ts.dtrowdeleted is null
and t.dtrowdeleted is null
and t.ihouse_ID= #session.qselectedhouse.ihouse_ID#
</cfquery>
<!---<cfdump var="#Medicaidrecordcount#">--->
<!---Mshah--->

<script>
//Mshah
	function approved(){
		//alert('test')
		cnt= document.DailyCensusApproveDisapprove.queryCount.value;
		if (cnt > 0){
			var x = confirm('This daily census data is used by Enlivant to accurately calculate reimbursement amounts to which the company may be entitled from the relevant Medicaid waiver program state authority or its designated managed care organization.  By submitting this data, you are attesting that this census data is accurate and complete for each resident.  If you subsequently learn that this census data is incorrect for any reason, you must promptly submit a correction for each resident. \nClick OK to Approve and Cancel to return!');
		  if (x== true)
		  {
			 //alert('true') ;
			 document.DailyCensusApproveDisapprove.submit();
		  }
		  else 
		  {
			 
			 // alert('false') ;
			  window.location.replace("http://CF01/intranet/tips4/Census/Census.cfm") ;
			  return false; 
		  }
		}
	}
//Mshah
</script>
	
<cfquery name="GetAptsNbr" dbtype="query">
  select distinct cAptNumber
  from
	validatehouse
</cfquery>

<cfset aptcount = GetAptsNbr.recordcount>
<cfset dailycount = validatehouse.recordcount>

<table align="center">
	<tr valign="top">
		<td align="center">
			<h2><b>Approve Daily Census</b></h2>
		</td>
	</tr>
	<tr valign="top">
		<td>
			<cfoutput><b>#dailycount# Residents in #aptcount# Apartments</b></cfoutput>
		</td>
	</tr>
		
	<form name="DailyCensusApproveDisapprove" action="DailyCensusApproveDisapprove.cfm" method="post">
		<tr>
			<td align="center">
				<input type="submit" name="approve" value="Approve"  onclick="return approved();">
				<!--- <input type="submit" name="disapprove" value="Disapprove" /> --->
			</td>
				<input type="hidden" name="countrecord" value=<cfoutput>"#dailycount#"</cfoutput>>
				<input type="hidden" name="dtCompare" value=<cfoutput>"#dtCompare#"</cfoutput>>
				<input type="hidden" name="queryCount" id="queryCount" value=<cfoutput>"#Medicaidrecordcount.RecordCount#"</cfoutput> /> <!---Mshah added for getting medicaid count in funtion validate--->
				
		</tr>
	</form>
</table>
<p>
<table border="1" align="center">
	<tr align="center">
		<td><cfoutput><a href="HouseApproveDisapprove.cfm?sortby=room&dtCompare=#dtCompare#"><b>Room</b></a></cfoutput></td>
		<td><b>Bed</b></td>
		<td><cfoutput><a href="HouseApproveDisapprove.cfm?sortby=residentID&dtCompare=#dtCompare#"><b>Res ##</b></a></cfoutput></td>
		<td><cfoutput><a href="HouseApproveDisapprove.cfm?sortby=residentname&dtCompare=#dtCompare#"><b>Resident Name</b></a></cfoutput></td>
		<td><b>Date Move In</b></td>
		<td><b>Payor Type</b></td>
	</tr>
	<cfoutput query="validatehouse">
		<tr>
			<td>#cAptNumber# </td>
			<td>#iAptType_ID#</td>
			<td>#iTenant_ID#</td>
			<td>#cLastName#, #cFirstName#</td>
			<td>#dateformat(dtMoveIn,"MM/DD/YYYY")#</td>
			<td>#cDescription#</td>
		</tr>
	</cfoutput>	
</table>

</body>
</html>
<!--- Include Intranet footer --->
<cfinclude template="../../footer.cfm">