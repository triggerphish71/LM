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
| gthota     | 11/03/2005 | created new page for relocation residents approval                |
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
			a.room 	, a.Start_Community		,  a.iTenant_ID ,  a.cLastName 		, a.cFirstName		, 'Private' as cDescription
	<!---		, isNULL(pdct.CurrentStatusInBedAtMidnight,'Y') as PreviousStatus	, dct.CurrentStatusInBedAtMidnight
            , dct.NoticeOfDischarge			, dct.DischargeDate as DischargeDate		, pdct.DischargeDate as PreviousDischargeDate		--->
	from [dbo].[RL_RES_STG] a 
	 join	TenantState ts  on a.iTenant_ID = ts.iTenant_ID			
	 join Tenant t  	on (t.iTenant_ID = ts.iTenant_ID)	
		
	where a.iTenant_ID = t.iTenant_ID
	
	and a.toHouseID = #SESSION.qSelectedHouse.iHouse_ID#
	and t.dtRowDeleted is NULL 
	and ts.dtrowdeleted is null 
	and t.itenant_ID not in
		(
			select 
				dct.itenant_ID 
			from 
				dailycensustrack_RL dct
			join 	tenant t 	on t.itenant_ID = dct.itenant_ID
			where 
				dct.rl_tohouse_Id = #SESSION.qSelectedHouse.iHouse_ID#
		    and 
				dct.CurrentStatusInBedAtMidnight = 'N'
			and
				dct.dtrowdeleted is NULL
			and
				dct.census_date = '#dtCompare#' 
			and
				t.dtrowdeleted is NULL
		)
			
		order by isNull(t.iTenant_ID, 99999) , a.room 				
</cfquery>


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
  select distinct room
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
		
	<form name="DailyCensusApproveDisapprove" action="DailyCensusApproveDisapprove_RL.cfm" method="post">
		<tr>
			<td align="center">
				<input type="submit" name="approve" value="Approve"  onclick="return approved();">
				<!--- <input type="submit" name="disapprove" value="Disapprove" /> --->
			</td>
				<input type="hidden" name="countrecord" value=<cfoutput>"#dailycount#"</cfoutput>>
				<input type="hidden" name="dtCompare" value=<cfoutput>"#dtCompare#"</cfoutput>>				
				
		</tr>
	</form>
</table>
<p>
<table border="1" align="center">
	<tr align="center">
	    <td>From House</td>
		<td><cfoutput><b>Room</b></cfoutput></td>		
		<td><cfoutput><b>Res ##</b></cfoutput></td>
		<td><cfoutput><b>Resident Name</b></cfoutput></td>		
		<td><b>Payor Type</b></td>
	</tr>
	<cfoutput query="validatehouse">
		<tr>
			<td>#Start_Community#</td>
			<td>#room# </td>			
			<td>#iTenant_ID#</td>
			<td>#cLastName#, #cFirstName#</td>			
			<td>#cDescription#</td>
		</tr>
	</cfoutput>	
</table>

</body>
</html>
<!--- Include Intranet footer --->
<cfinclude template="../../footer.cfm">