<!---  -----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                               |
|------------|------------|---------------------------------------------------------------------------|
|S Farmer    | 08-1-2013  | Program to allow AR to directly edit mInvoiceTotal and mLastInvoiceTotal  |
|            |            | Ticket#109105  and allow direct move-out date updates ticket# 109102      |
|S Farmer    | 09-12-2013 | temporarily disable the invoice balance update per T. Bates, still allow  |
|            |            | the move-out date upates                                                  |
|sfarmer     | 2017-05-09 | 'move out date' changed to 'physical move out date'                       |
-------------------------------------------------------------------------------------------------- --->
<!--- Include Intranet Header ---><head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>Edit Move Out Dates</title>
	<style> 
	.red { color: #FF0000; }
	</style>

</head>
	<cfparam name="solomonid" default="">
	<cfinclude template="../../header.cfm">
	<script language="JavaScript"  type="text/javascript">
		function nextstuffD() 
		 {
		 solomonkeyvalue  = document.getElementById('solomonid').value;
		window.location.href = "EditMoveOutDates.cfm?solomonid=" + solomonkeyvalue;
		 }	
	
		function nextstuffI() 
		 {
		 solomonkeyvalue  = document.getElementById('solomonid').value;
		window.location.href = "EditInvoiceAmts.cfm?solomonid=" + solomonkeyvalue;
		 }	
  </script>	
  
<cfif solomonid is not ''>
		<cfquery name="qryResidentID" datasource="#application.datasource#">
			Select h.cname as House,h.ihouse_id, t.cfirstname, t.clastname,t.csolomonkey, t.itenant_id,
				 ts.dtMoveOutProjectedDate,	 ts.dtMoveOut, ts.dtNoticeDate, ts.dtChargeThrough
			from tenant t 
				join tenantstate ts on t.itenant_id = ts.itenant_id
				join house h on h.ihouse_id = t.ihouse_id
			where t.csolomonkey = #solomonid#	
		</cfquery>
</cfif>

<h1 class="PageTitle"> Tips 4 - Tenant EFT House </h1>
	
 

   	<cfinclude template="../Shared/HouseHeader.cfm">
	<cfparam  name="solomonid" default="">

  <cfif solomonid is ''> 
		<form name="submitname" method="post" action="EditMoveOutDates.cfm">
 			<table>
				<cfoutput>
				<tr style="background-color:##FFFF99">
					<td>Enter Resident ID (Solomon Key):</td>
					<td  style="text-align:left; "><input type="text" name="solomonid" id="solomonid" value="#solomonid#" size="12" /></td>
				</tr>	
				<cfif solomonid is not "">
					<tr>
						<td colspan="2"> #qryResidentID.cfirstname# #qryResidentID.clastname# - #qryResidentID.House#</td>
					</tr>
				</cfif>		
				<tr style="background-color:##CCFF99">
					<td  colspan="2" >Use to change PMO date on Current Respite resident<br />or PMO, Charge Through and Move-Out Dates <br />when Move-Out Process has been started, <span class="red"> Select here: <input type="radio" name="changeselect" value="moveout" onclick="nextstuffD()" /></span> </td>
					 <td   style="color:##FF0000; font-weight:bold; text-align:center">Note: For Use Only After the Move-Out Process has been started</td>  
				</tr>
			<!---   temporarily disabled per T. Bates 09/11/2013 sdf --->	<tr>
					<td colspan="2">To Correct Invoice Total AND/OR Previous Balance, 
					<span class="red"> Select here: <input type="radio" name="changeselect" 
					value="lastinvoice" onclick="nextstuffI()"/></span></td>
				</tr> 				
				</cfoutput>
			</table>
		</form>
  	<cfelse>
		<cfquery name="qryResidentID" datasource="#application.datasource#">
			Select h.cname as House,h.ihouse_id, t.cfirstname, t.clastname,t.csolomonkey, t.itenant_id,
				 ts.dtMoveOutProjectedDate,	 ts.dtMoveOut, ts.dtNoticeDate, ts.dtChargeThrough
			from tenant t 
				join tenantstate ts on t.itenant_id = ts.itenant_id
				join house h on h.ihouse_id = t.ihouse_id
			where t.csolomonkey = #solomonid#	
		</cfquery>
		<form name="updDates" method="post" action="updMoveOutDates.cfm">
		<table>
			<cfoutput query="qryResidentID">
			<input type="hidden" name="csolomonkey" value="#csolomonkey#" />
			<input type="hidden" name="tenantid" value="#itenant_id#"/>
			<input type="hidden" name="cfirstname" value="#cfirstname#"/>
			<input type="hidden" name="clastname" value="#clastname#"/>
			<input type="hidden" name="ihouseid" value="#ihouse_id#"/>
				<tr>
					<td colspan="2" style="text-align:left">Name: #cfirstname# #clastname#</td>
				</tr>
				<tr>
					<td colspan="2" style="text-align:left">House: #House#</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td style="text-align:center">Enter Correct Date in appropriate field</td>
				</tr>
		 
				<tr style="background-color:##FFFF99">
					<td >Move Out Notice Date:</td>
					<td style="text-align:center"><input name="noticedate" value="#dateformat(dtNoticeDate,'mm-dd-yyyy')#" size="12" /></td>
				</tr>
				<tr>
					<td>Physical Move Out Date:</td>
					<td style="text-align:center"><input name="moveoutdate" value="#dateformat(dtMoveOut,'mm-dd-yyyy')#"  size="12"/></td>
				</tr>
				<tr style="background-color:##FFFF99">
					<td>Projected Physical Move Out Date:</td>
					<td style="text-align:center"><input name="projectmoveoutdate" value="#dateformat(dtMoveOutProjectedDate,'mm-dd-yyyy')#" size="12" /></td>
				</tr>
				<tr>
					<td>Charge Through Date:</td>
					<td style="text-align:center"><input name="chargedate" value="#dateformat(dtChargeThrough,'mm-dd-yyyy')#" size="12" /></td>
				</tr>	
				<tr>
					<td colspan="2" style="text-align:center"><input name="submit" type="submit" value="Submit" /></td>											
			</cfoutput> 
		</table>
		</form>
		
		
	</cfif>  
	
	
		<!--- Include intranet footer --->
		<cfinclude template="../../footer.cfm">		
	
 
