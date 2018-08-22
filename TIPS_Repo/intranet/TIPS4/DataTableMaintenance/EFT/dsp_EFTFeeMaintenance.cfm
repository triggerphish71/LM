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
where dtRowEnd is null
Order by iFromDay
</cfquery>
<CFINCLUDE TEMPLATE="../../../header.cfm">

<body>
<h1 class="PageTitle"> Tips 4 - EFT Fee Maintenance </h1>
<table>
	<tr style="background-color:#FFFF99">
		<td>ID<br/>Select to Edit</td>
		<td>From Day</td>
		<td>Through Day</td>
		<td>Fee Amount</td>
 
	</tr>
	<cfoutput query="qryEFTFee">
		<cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE">
			<td><a href="act_EFTFeeEdit.cfm?id=#iEFTFee_ID#">#iEFTFee_ID#</a></td>
			<td> #iFromDay#</td>
			<td>#iThruDay#</td>
			<td>#dollarformat(mFeeAmount)#</td>
 
		</cf_cttr>
	</cfoutput>
</table>

<Form name="addEFTFee" method="post" id="idaddEFTFee" action="act_EFTFeeAdd.cfm">
	<table>
		<tr>
			<td colspan="3">To Add an EFT Fee, enter EFT Fee information</td>
		</tr>
		<tr>
			<td>From Day</td>
			<td>Through Day</td>
			<td>EFT Fee</td>
		</tr>
		<tr>
			<td><input type="text"  name="iFromDay" /></td>
			<td><input type="text"  name="iThruDay" /></td>
			<td>$<input type="text"  name="mFeeAmount" /></td>
		</tr>	
		<tr>
			<td><input type="submit" name="Submit" value="Submit"</td>
			
	</table>
</Form>

<cfinclude template="../../../footer.cfm">