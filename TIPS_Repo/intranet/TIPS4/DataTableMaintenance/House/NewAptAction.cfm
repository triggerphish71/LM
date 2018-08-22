<!--- *******************************************************************************
Name:			NewAptAction.cfm
Process:		Database Submit for new Apt

Called by: 		NewApt.cfm
Calls/Submits:	NewApt.cfm
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Paul Buendia            02/07/2002      Original Authorship
Sathya Sanipina			05/20/2008      Added a condition so that it checks the deleted records also.
******************************************************************************** --->

<!--- ==============================================================================
Check for another apt of the same type and description
(Check for Duplicates)
05/20/08--CMR-23,063--ssathya added the check for deleted apartments as it 
                       did not allow reassigning the same apartment number again.

11/12/08 - RTS - 26955 updated "qInsertNewApt" query to set the bBondIncluded value to '0'
=============================================================================== --->
<cfquery name="qDuplicateCheck" datasource="#APPLICATION.datasource#">
	select * from  AptAddress
	where iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#   
	and iAptType_ID = #form.iAptType_ID# and cAptNumber = '#form.cAptNumber#'
	and dtrowdeleted is null
	<cfif isDefined("form.iAptAddress_ID")>and iAptAddress_ID <> #form.iAptAddress_ID#</cfif>
</cfquery>

<cfif qDuplicateCheck.RecordCount GT 0>
	<table>
		<tr>
			<td> 
				This room already exists. Cannot Save.<BR> 
				<A HREF="HouseApts.cfm" STYLE="font-size: 18; color: navy;">Click Here to Continue</A> 
			</td>
		</tr>
	</table>
	<CFABORT>
</cfif>

<cfif qDuplicateCheck.RecordCount EQ 0>
<cfif not isDefined("form.iAptAddress_ID")><!--- save new --->
	<cftransaction>
		<cfparam name="form.fOccupancyWeight" type="numeric" default="1">
		<cfquery name="qInsertNewApt" datasource="#APPLICATION.datasource#">
			INSERT INTO AptAddress
			(iHouse_ID, iAptType_ID, cAptNumber, cComments, iRowStartUser_ID, dtRowStart, fOccupancyWeight, iHouseProductLine_ID, bBondIncluded)
			VALUES
			(#SESSION.qSelectedHouse.iHouse_ID#,#form.iAptType_ID#,'#TRIM(form.cAptNumber)#','#form.cComments#',#SESSION.USERID#, getDate(),#trim(form.fOccupancyWeight)#, #form.iHouseProductLine_ID#, '0')
		</cfquery>
	</cftransaction>
<cfelse><!--- update --->
	<cftransaction>
		<cfquery name="qUpdateNewApt" datasource="#APPLICATION.datasource#">
			UPDATE AptAddress SET 
			iHouse_ID= #SESSION.qSelectedHouse.iHouse_ID#, iAptType_ID=#form.iAptType_ID#, cAptNumber='#TRIM(form.cAptNumber)#', cComments='#form.cComments#', iRowStartUser_ID=#SESSION.USERID#, dtRowStart= getDate(), fOccupancyWeight=#trim(form.fOccupancyWeight)#, iHouseProductLine_ID=#form.iHouseProductLine_ID#
			WHERE
			iAptAddress_ID = #form.iAptAddress_ID#
		</cfquery>
	</cftransaction>
</cfif>
</cfif>

<cflocation url="HouseApts.cfm">