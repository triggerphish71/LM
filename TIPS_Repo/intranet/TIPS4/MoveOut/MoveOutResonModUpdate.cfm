 
 

<CFQUERY NAME = "qTenant" DATASOURCE = "#APPLICATION.datasource#">
	SELECT  T.iTenant_ID,    T.cFirstName + ' ' + T.cLastName as FullName, TS.dtMoveOut,
	TS.iMoveReasonType_ID, TS.iMoveReason2Type_ID
	FROM   Tenant T(nolock)
	Left Join TenantState TS (nolock) ON T.iTenant_ID = TS.iTenant_ID
	WHERE T.iTenant_ID = #form.Tenant_ID# 

</CFQUERY>

<CFINCLUDE TEMPLATE="../../header.cfm">	
<LINK REL=StyleSheet TYPE="Text/css"  HREF="//#SERVER_NAME#/intranet/Tips4/Shared/Style2.css">
	<div><CENTER>Resident Move Out Reason Code Change</CENTER></div>
	
	<cfif isDefined("form.Reason2") and  (#form.Reason2# is qTenant.iMoveReasonType_ID) and
	 isDefined("form.Reason1") and(#form.Reason2# is form.Reason1) >
		<CFQUERY NAME = "qReasonCode" DATASOURCE = "#APPLICATION.datasource#">
			select cDescription 
			from MoveReasonType
			Where iMoveReasonType_ID =  #form.Reason2#
		</CFQUERY>
		<cfoutput>
		<div>
			<CENTER><STRONG STYLE='color: red;'>
			 For #qTenant.FullName#, the second Move Out Reason Code - "#qReasonCode.cDescription#" - is the same as the first Move Out Reason Code,  <a href="MoveOutReasonMod.cfm">Please Reselect</a>
  <cfoutput><br/>#form.Tenant_ID# ::R1 #form.Reason1# :R2: #form.Reason2#  ::CR1 #qTenant.iMoveReasonType_ID# ::CR2 #qTenant.iMoveReason2Type_ID#</cfoutput> 
			</STRONG></CENTER>
		</div>
		</cfoutput>

		<!--- ==============================================================================
		Include Intranet Footer
		=============================================================================== --->
		<CFINCLUDE TEMPLATE="../../footer.cfm">
		
		<cfabort>
	</cfif>

	<cfif isDefined("form.Reason1") and  (#form.Reason1# is qTenant.iMoveReason2Type_ID)>
		<CFQUERY NAME = "qReasonCode" DATASOURCE = "#APPLICATION.datasource#">
			select cDescription 
			from MoveReasonType
			Where iMoveReasonType_ID =  #form.Reason1#
		</CFQUERY>
		<cfoutput>
		<div>
			<CENTER><STRONG STYLE='color: red;'>
			 For #qTenant.FullName#, the first Move Out Reason Code - "#qReasonCode.cDescription#" - is the same as the second Move Out Reason Code,  <a href="MoveOutReasonMod.cfm">Please Reselect</a>
			</STRONG></CENTER>
		</div>
		</cfoutput>

		<!--- ==============================================================================
		Include Intranet Footer
		=============================================================================== --->
		<CFINCLUDE TEMPLATE="../../footer.cfm">
		
		<cfabort>
	</cfif>
	
	<cfif ((form.Reason2 is "9e9") and (qTenant.iMoveReason2Type_ID is not ""))>
 		<CFQUERY NAME = "TenantState" DATASOURCE="#APPLICATION.datasource#">
			UPDATE 	TenantState
			SET  iMoveReason2Type_ID	= ''
			WHERE	iTenant_ID = #form.Tenant_ID#
		</CFQUERY>
		<cfset Action = "MoveOutReasonMod.cfm" >
		<CFLOCATION URL="#Action#" ADDTOKEN="No">
 	</cfif>
	
	<cfif ((form.Reason1 is "") and (form.Reason2 is ""))>
		<cfoutput>
		<div>
			<CENTER><STRONG STYLE='color: red;'>
			 For #qTenant.FullName#, no updated Move Out Reason Codes were selected.  <a href="MoveOutReasonMod.cfm">Please Reselect</a>
			</STRONG></CENTER>
		</div>
		</cfoutput>
	<!--- ==============================================================================
	Include Intranet Footer
	=============================================================================== --->
	<CFINCLUDE TEMPLATE="../../footer.cfm">	

	<cfabort>
	  
	</cfif>

	<cfif  isDefined("form.Reason1")  and  isDefined("form.Reason2")  and (#form.Reason1#  is #form.Reason2#)>
		<CFQUERY NAME = "qReasonCode" DATASOURCE = "#APPLICATION.datasource#">
			select cDescription 
			from MoveReasonType
			Where iMoveReasonType_ID =  #form.Reason1#
		</CFQUERY>
	
		<CFOUTPUT>
			<CFIF FindNoCase("TIPS4",getTemplatePath(),1) GT 0>
				<LINK REL=StyleSheet TYPE="Text/css"  HREF="//#SERVER_NAME#/intranet/Tips4/Shared/Style2.css">
			<CFELSE>
				<LINK REL="STYLESHEET" TYPE="text/css" HREF="//#SERVER_NAME#/intranet/TIPS/Tip30_Style.css">
			</CFIF>
		</CFOUTPUT>	
		<cfoutput>
			<div >
			<CENTER><STRONG STYLE='color: red;'>
		 For #qTenant.FullName# you have selected the same Code for Move Out Reason Code 1 and Move Out Reason Code 2 - #qReasonCode.cDescription#
			
			to correct this select here: <a href="MoveOutReasonMod.cfm">CONTINUE</a>
			</STRONG></CENTER>
			</div>
		</cfoutput>

	<cfelse>
	 
		<CFQUERY NAME = "TenantState" DATASOURCE="#APPLICATION.datasource#">
			UPDATE 	TenantState
			<cfif ((#form.Reason1# is not "") and (#form.Reason2# is  ""))>	
				SET  iMoveReasonType_ID	= #form.Reason1# 
			<cfelseif ((#form.Reason1# is not "") and (#form.Reason2# is not ""))>	
					SET  iMoveReasonType_ID  = #form.Reason1#, 
						 iMoveReason2Type_ID = #form.Reason2#
			<cfelseif ((#form.Reason1# is  "") and (#form.Reason2# is not ""))>	
				SET  iMoveReason2Type_ID	= #form.Reason2#
			</cfif>
			WHERE	iTenant_ID = #form.Tenant_ID#
		</CFQUERY>	
	 
		<cfset Action = "MoveOutReasonMod.cfm" >
		<CFLOCATION URL="#Action#" ADDTOKEN="No">
	</cfif>
	<!--- ==============================================================================
	Include Intranet Footer
	=============================================================================== --->
	<CFINCLUDE TEMPLATE="../../footer.cfm">