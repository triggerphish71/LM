<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page is to display unoccupied apt's that are bond applicable for the
 				Bond Designation query comparison used in the Admin/Menu.cfm file             |                                                                        |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
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
| RTS		 |11/11/08    | Wrote query    		                                               |
----------------------------------------------------------------------------------------------->


<CFQUERY NAME="AvailableUO" DATASOURCE="#APPLICATION.datasource#">
	select aa.*, at1.*
	from AptAddress aa (nolock)
	join apttype at1 on (at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null)
	where aa.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	and aa.iAptAddress_ID not in ( 
		select distinct aa.iAptAddress_ID
		from AptAddress aa, tenant te, TenantState TS (NOLOCK) 
		join Tenant T on (T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null)
		join AptAddress AD on (AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null)
		where TS.dtRowDeleted is null
		and TS.iTenantStateCode_ID = '2'
		and AD.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		and TS.iAptAddress_ID = aa.iAptAddress_ID 
		and te.iTenant_ID = ts.iTenant_ID)
	and aa.bBondIncluded = '1'
	and aa.dtrowdeleted is null
	order by aa.iAptAddress_ID
</CFQUERY>