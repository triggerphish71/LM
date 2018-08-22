<!----------------------------------------------------------------------------------------------
| DESCRIPTION - census/FinalizeRelocate.cfm                                                    |
|----------------------------------------------------------------------------------------------|
| 													                                           |
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
| mlaw       | 07/26/2006 | Create an initial FinalizeRelocate page                  	       |
----------------------------------------------------------------------------------------------->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Finalize Relocate Page</title>
</head>

<body bgcolor="#FFFFCC">
<CFIF isdefined("url.TenantID")>
	<CFIF #url.TenantID# neq "" >
		<!--- Get the last Tenant's Apt Address information --->
		<CFQUERY NAME="qRoomAndBoard" DATASOURCE="#APPLICATION.datasource#">
		select 
			top 1 captnumber
			, al.dtrowstart
			, al.itenant_ID
			, al.dtActualEffective
		from 
			activitylog al
		join 
			aptaddress aa
		on aa.iaptaddress_ID = al.iaptaddress_ID
		where 
			itenant_ID =  #url.TenantID#
			and iActivity_ID = 4
		order by al.dtRowStart desc
		</CFQUERY>
		<CFOUTPUT>
			Tenant #qRoomAndBoard.itenant_ID# is located in Room #qRoomAndBoard.captnumber#, Effective on #qRoomAndBoard.dtActualEffective#.
		</CFOUTPUT>
	<CFELSE>
		Please click on the above Tenant(s) and relocate them.
	</CFIF>
</CFIF>

<p>
	<font color="#FF0000">
		<b>Please click "Continue" below if you are done with relocation, otherwise click on the above Tenant(s). </b>
	</font>
</body>
</html>
