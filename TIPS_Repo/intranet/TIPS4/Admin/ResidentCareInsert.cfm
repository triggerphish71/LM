<!----------------------------------------------------------------------------------------------
| DESCRIPTION    ResidentCareInsert.cfm                                                        |
|----------------------------------------------------------------------------------------------|
|  File used to insert resident care rates into the charges table in tips4 database            |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  header.cfm, househeader.cfm                                                                 |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| Unknown    | Unknown    | File Created                                                       |
| J Cruz     | 06/11/2008 | Re-Formated Queries to remove field setting to string from int.    | 
----------------------------------------------------------------------------------------------->
<cfoutput>
<!--- retrieve current resident care charge type ---->
<cfquery name="qcttype" datasource="#APPLICATION.datasource#">
select * from chargetype where dtrowdeleted is null
and cgrouping='RD'
</cfquery>

<!--- retrieve level data--->
<cfquery name="qLevels" datasource="#APPLICATION.datasource#">
select * from sleveltype where dtrowdeleted is null and isleveltype_id in (#form.typeids#)
</cfquery>

<!--- initialize chargeset variable for insert --->
<cfif trim(form.cchargeset) eq "">
<cfset cchargeset=''>
<cfelse>
<cfset cchargeset=trim(form.cchargeset)>
</cfif>

<cftry>
<cftransaction>

<!--- create temp table --->
<cfquery name="qcreatetmp" datasource="#APPLICATION.datasource#">
CREATE TABLE ##tmpCharges (
	[iChargeType_ID] [int],
	[iHouse_ID] [int],
	[cChargeSet] [varchar] (15) ,
	[cDescription] [varchar] (35),
	[mAmount] [money],
	[iQuantity] [int],
	[bIsRentUNUSED] [bit],
	[bIsMedicaidUNUSED] [bit],
	[iResidencyType_ID] [int],
	[iAptType_ID] [int],
	[cSLevelDescription] [varchar] (35),
	[iSLevelType_ID] [int],
	[iOccupancyPosition] [int],
	[dtAcctStamp] [datetime],
	[dtEffectiveStart] [datetime],
	[dtEffectiveEnd] [datetime],
	[iRowStartUser_ID] [int],
	[dtRowStart] [datetime],
	[iRowEndUser_ID] [int],
	[dtRowEnd] [datetime],
	[iRowDeletedUser_ID] [int],
	[dtRowDeleted] [datetime],
	[cRowStartUser_ID] [varchar] (50),
	[cRowEndUser_ID] [varchar] (50),
	[cRowDeletedUser_ID] [varchar] (50),
	[iProductLine_ID] [int]
	)
</cfquery>

<cfloop index="id" list="#form.typeids#" delimiters=",">

<!--- retrieve level data--->
<cfquery name="qinstance" dbtype="query">
select cdescription from qLevels where isleveltype_id = #id#
</cfquery>

<!--- check for duplicates --->
<cfquery name="qDup" datasource="#APPLICATION.datasource#">
select * from charges where dtrowdeleted is null
and iSLevelType_ID='#id#' and cdescription='#structfind(form, ("cdescription_" & id))#'
and ihouse_id='#session.qselectedhouse.ihouse_id#' and ichargetype_id='#trim(qcttype.ichargetype_id)#'
and cchargeset='#trim(cChargeset)#'
</cfquery>

<cfif qdup.recordcount eq 0>
<!--- J Cruz - 6/11/2008 - Modified values to remove field formating on certain fields to stop errors due to field conversion issues. Int type fields were being set to strings causing errors. --->
<cfquery name="qInsert_#id#" datasource="#APPLICATION.datasource#">
insert into ##tmpCharges
( [iChargeType_ID], [iHouse_ID], [cChargeSet], [cDescription], 
[mAmount], [iQuantity], [bIsRentUNUSED], [bIsMedicaidUNUSED], 
[iResidencyType_ID], [iAptType_ID], [cSLevelDescription], [iSLevelType_ID], 
[iOccupancyPosition], [dtAcctStamp], [dtEffectiveStart], [dtEffectiveEnd], 
[iRowStartUser_ID], [dtRowStart], [iRowEndUser_ID], [dtRowEnd],
[iRowDeletedUser_ID], [dtRowDeleted], [cRowStartUser_ID], [cRowEndUser_ID],
[cRowDeletedUser_ID],[iProductLine_ID]
)
values
( #trim(qcttype.ichargetype_id)#, #session.qselectedhouse.ihouse_id#, <cfif trim(cChargeset) neq ''>'#trim(cChargeset)#'<cfelse>NULL</cfif>, '#structfind(form, ("cdescription_" & id))#',#structfind(form, ("amount_" & id))#,1, NULL, NULL,1, NULL, '#qinstance.cdescription#', #trim(id)#,NULL, '#session.acctstamp#', '#structfind(form, ("dteffectivestart_" & id))#', '#structfind(form, ("dteffectiveend_" & id))#', 
#session.userid#, getdate(), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
</cfquery>

</cfif>

</cfloop>

<!--- create records --->
<cfquery name="qInsertCharges" datasource="#APPLICATION.datasource#">
insert into dbo.charges 
select * 
from ##tmpCharges
</cfquery>

<!--- delete temp table --->
<cfquery name="qdeltmp" datasource="#APPLICATION.datasource#">
drop table ##tmpCharges
</cfquery>

<!---
<cfquery name="qErrorout" datasource="#APPLICATION.datasource#">
seleart getdate()
</cfquery>
--->

</cftransaction>
<cfcatch type="any">
<cfdump var="#cfcatch#">
<cfabort>
</cfcatch>
</cftry>

<!--- <cfdump var="#form#"> --->

<!--- Include header file --->
<CFINCLUDE TEMPLATE='../../header.cfm'>

<!--- Include shared javascript --->
<CFINCLUDE TEMPLATE='../Shared/HouseHeader.cfm'>

<BR> <A HREF='menu.cfm'>Click Here to Go Back to the Administration Screen.</A> <BR>
</cfoutput>