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


<CFQUERY NAME="AvailableBondRooms" DATASOURCE="#APPLICATION.datasource#">
	select aa.*, at1.*
	from AptAddress aa (nolock)
	join apttype at1 on (at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null)
	where aa.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	and aa.bBondIncluded = '1'
	and aa.dtrowdeleted is null
	order by aa.iAptAddress_ID
</CFQUERY>
