<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 12/14/2006 | Created                                                            |
----------------------------------------------------------------------------------------------->

<cfparam name="AptTypeArray" default="#ArrayNew(1)#">
<cfparam name="aptTypeList" default="">
<cfparam name="secondResidentGlCode" default="0">
<cfparam name="secondResidentDiscountGlCode" default="0">

<cfoutput>
<form action="../ControlFiles/ctl_ManageGlCodes.cfm" method="post">
<table>
	<tr>
		<th>Room Type</th>
		<th>R&B GL Code</th>
		<th>Discount GL Code</th>
		<th>Room Type</th>
		<th>R&B GL Code</th>
		<th>Discount GL Code</th>
	</tr>
	<tr>
	<cfloop from="1" to="#ArrayLen(AptTypeArray)#" index="i">
		<cfif i MOD 2>
			<tr>
		</cfif>
		<td>#AptTypeArray[i].GetDescription()# (#AptTypeArray[i].GetActiveCount()#)</td>
		<td><input type="text" name="GL_#AptTypeArray[i].GetId()#" value="#AptTypeArray[i].GetGlCode()#" size="6"></td>
		<td><input type="text" name="GLDiscount_#AptTypeArray[i].GetId()#" value="#AptTypeArray[i].GetDiscountGlCode()#" size="6"></td>
		<cfif NOT i MOD 2>
			</tr>
		</cfif>
	</cfloop>
	</tr>
	<tr>
		<td>
			Second Tenant
		</td>
		<td>
			<input type="text" name="secondResidentGLCode" value="#secondResidentGlCode#" size="6">
		</td>
		<td>
			<input type="text" name="secondResidentDiscountGLCode" value="#secondResidentDiscountGlCode#" size="6">
		</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td colspan="8" align="center"><input type="submit" value="Save"></td>
	</tr>
</table>
<input type="hidden" name="fuse" value="SaveGlCodeMap">
<input type="hidden" name="aptTypeList" value="#aptTypeList#">
</form>
</cfoutput>