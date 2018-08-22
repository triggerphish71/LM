


<CFIF IsDefined("Session.HouseName") and IsDefined("Session.TIPSMonth")>
	<CFQUERY NAME='qTIPSMonth' DATASOURCE='#APPLICATION.datasource#'>
		select * from houselog where dtrowdeleted is null and ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
	<CFIF SESSION.TIPSMonth NEQ qTipsMonth.dtCurrentTipsMonth>
		<CFSET Session.TIPSMonth = qTipsMonth.dtCurrentTipsMonth>
		<CFLOCATION URL='../MainMenu.cfm' addtoken="yes">
	</CFIF>
	<CFOUTPUT>
		<TABLE STYLE="width: 640; border: none; background:transparent;">
			<TR>
				<TD CLASS="HouseHeader" STYLE='border: none;'>	
					<A HREF="http://#SERVER_NAME#/intranet/Tips4/Index.cfm">	
						<CFIF IsDefined("SESSION.USERID") AND SESSION.USERID NEQ "" AND (SESSION.USERID EQ 3025 OR SESSION.USERID EQ 3146)>
							#SESSION.HouseName# (#SESSION.nHouse#-#SESSION.qSelectedHouse.iHouse_ID#)
						<CFELSE>
							#SESSION.HouseName# (#SESSION.nHouse#)
						</CFIF>
					</A>
					<BR>
				</TD> 
				<TD CLASS="HouseHeader" STYLE="text-align: right; border: none;">TIPS Month - #DATEFORMAT(SESSION.TIPSMonth, "mmmm yyyy")# </TD>
			</TR>
		</TABLE>
	</CFOUTPUT>
	
	<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.USERID EQ ''> 
		<CFLOCATION URL="http://#server_name#/intranet/login.cfm" ADDTOKEN="No"> 
	</CFIF>	
</CFIF>