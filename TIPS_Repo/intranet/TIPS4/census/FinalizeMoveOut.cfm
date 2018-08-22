<!----------------------------------------------------------------------------------------------
| DESCRIPTION - census/FinalizeMoveOut.cfm                                                     |
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
| mlaw       | 07/26/2006 | Create an initial Finalize MoveOut page                  	       |
----------------------------------------------------------------------------------------------->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<!--- //<meta http-equiv="refresh" content="1"> --->
	<script language="javascript">
		function RefreshParent()
		{
			window.parent.location.href = window.parent.location.href;
		}
	</script>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<title>Finalize MoveOut Page</title>
</head>

<!--- <body bgcolor="#FFFFCC" onload="RefreshParent()"> --->
<body bgcolor="#FFFFCC">
<CFIF isdefined("url.TenantID")>
	<CFIF #url.TenantID# neq "" >
		<!--- Get the last Tenant's Apt Address information --->
		<CFQUERY NAME="GetTenantStatus" DATASOURCE="#APPLICATION.datasource#">
			select 
				*
			from 
				tenantstate ts
			join 
				Tenant T
			on T.itenant_ID = ts.itenant_ID
			where 
				ts.itenant_ID =  #url.TenantID#
			and 
				ts.dtrowdeleted is NULL
			and
				t.dtrowdeleted is NULL
		</CFQUERY>
		<CFOUTPUT>
			<table>
				<tr>
				   <td>
				   <!--- <a href = "javascript:window.parent.location.reload(true)" onMouseOver="RefreshParent()"></a> ---> #GetTenantStatus.cfirstname# #GetTenantStatus.clastname# has been moved out.
				   </td>
				   <td>
				   <input type="button" value="Refresh" onclick="window.parent.location.reload(true)">
				   </td>
				</tr>
			</table>
		</CFOUTPUT>
	<CFELSE>
		Please click on the above Tenant(s) and process the move out.
	</CFIF>
</CFIF>

<p>
	<font color="#FF0000">
		<b>
		Please click "Continue" below if you are done with all the move outs, otherwise click on the above Tenant(s). </b>
	</font>
</body>
</html>
