
<!--- 
01/14/2016  |S Farmer     |         |  Replaced crystal report with Coldfusion CFDocument-PDF |
 --->

<CFOUTPUT>

#session.housename#  prompt2='#form.prompt1# 
 		<cflocation url="TenantChargeSummary.cfm?prompt1=#SESSION.qSelectedHouse.iHouse_ID#&prompt2=#form.prompt1#">
 </CFOUTPUT>

	

