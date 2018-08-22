<!--- *******************************************************************************
Name:           dsp_EFTFeeMaintenance.cfm                                            
Process:        Set up EFT fees                                                      

Called by:      MainMenu.cfm                                                        
Calls/Submits:  act_EFTAdd.cfm, act_EFTFeeEdit.cfm                                  
		
Modified By             Date            Reason                                      
-------------------     -------------   --------------------------------------------
Steven Farmer            01/27/2012      Created for Project 75019                  
******************************************************************************** --->

 
 



<cfquery name="qryEFTFee" datasource="#application.datasource#">
Select iEFTFee_ID, iFromDay, iThruDay, mFeeAmount, dtRowEnd
From dbo.EFTFees
where iEFTFee_ID = #url.ID#
 
</cfquery>
<CFINCLUDE TEMPLATE="../../../header.cfm">

<body>
<h1 class="PageTitle"> Tips 4 - EFT Fee Maintenance </h1>

<Form name="addEFTFee" method="post" id="idaddEFTFee" action="act_EFTFeeUpdate.cfm">
<cfoutput><input type="hidden" name="FeeID" value="#qryEFTFee.iEFTFee_ID#"></cfoutput>
	<table>
		<tr>
			<td colspan="3">Make changes to EFT Fees as necessary and Submit</td>
		</tr>
		<tr>
			<td>From Day</td>
			<td>Through Day</td>
			<td>EFT Fee</td>
			<td>Drop</td>				
		</tr>
	<cfoutput query="qryEFTFee">		
		<tr>
			<td><input type="text"  name="iFromDay"  value="#iFromDay#"/></td>
			<td><input type="text"  name="iThruDay" value="#iThruDay#" /></td>
			<td>$<input type="text"  name="mFeeAmount" value="#dollarformat(mFeeAmount)#" /></td>
			<td><input type="checkbox" name="dropthisone" value="X"></td>
		</tr>	
	</cfoutput>
		<tr>
			<td><input type="submit" name="Submit" value="Submit"></td>
			
	</table>

</Form>

<cfinclude template="../../../footer.cfm">