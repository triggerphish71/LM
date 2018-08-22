
 
<title>TIPS4 - Medicaid</title>
</head>
<cfparam name="cStateAcuity"  default="">
<cfparam name="cMedicaidLevelLow"  default="">
<cfparam name="cMedicaidLevelMedium"  default="">
<cfparam name="cMedicaidLevelHigh"  default="">
<cfparam name="mStateMedicaidAmt_BSF_Daily"  default="">
<cfparam name="mMedicaidBSF"  default="">
<cfparam name="mMedicaidCopay"  default="">
<cfparam name="cComments"  default="">

<cfif entrytype is "new">
<cfquery name="inserthouseMedicaid" DATASOURCE="#APPLICATION.datasource#">
INSERT INTO HouseMedicaid
           (iHouse_ID
           ,mStateMedicaidAmt_BSF_Daily
           ,mMedicaidBSF
           ,mMedicaidCopay
    <!---        ,cStateAcuity
           ,cMedicaidLevelLow
           ,cMedicaidLevelMedium
           ,cMedicaidLevelHigh --->
           ,cComments
           ,dteffectiveStart
           ,dtrowadded
           ,iRowAddedByUserID
           ,cRowAddedByUserName)
     VALUES
           ( #iHouse_ID# 
           ,#mStateMedicaidAmt_BSF_Daily# 
           ,#mMedicaidBSF# 
           ,<cfif mMedicaidCopay is '' >null <cfelse>#mMedicaidCopay# </cfif>
          <!---  ,<cfif cStateAcuity is '' >null<cfelse>#cStateAcuity# </cfif> --->
          <!---  ,<cfif cMedicaidLevelLow is '' >null<cfelse>#cMedicaidLevelLow# </cfif> --->
          <!---  ,<cfif cMedicaidLevelMedium is '' >null<cfelse>#cMedicaidLevelMedium# </cfif> --->
          <!---  ,<cfif cMedicaidLevelHigh is '' >null<cfelse>#cMedicaidLevelHigh# </cfif> --->
           ,<cfif cComments is '' >null<cfelse> #cComments# </cfif>
           ,getdate()
           ,getdate()
           ,#session.userid#
           ,'#session.username#')
	</cfquery>
<cfelse>
	<cfquery name="updatehouseMedicaid" DATASOURCE="#APPLICATION.datasource#">
		update HouseMedicaid
           set
           mStateMedicaidAmt_BSF_Daily = #mStateMedicaidAmt_BSF_Daily#
           ,mMedicaidBSF = #mMedicaidBSF#
           ,mMedicaidCopay = #mMedicaidCopay#
           ,<cfif cStateAcuity is '' >cStateAcuity =null <cfelse>cStateAcuity = #cStateAcuity#</cfif>
           ,<cfif cMedicaidLevelLow is '' >cMedicaidLevelLow = null <cfelse>cMedicaidLevelLow = #cMedicaidLevelLow#</cfif>
           ,<cfif cMedicaidLevelMedium is '' >cMedicaidLevelMedium = null <cfelse>cMedicaidLevelMedium = #cMedicaidLevelMedium#</cfif>
           ,<cfif cMedicaidLevelHigh is '' >cMedicaidLevelHigh = null <cfelse>cMedicaidLevelHigh = #cMedicaidLevelHigh#</cfif>
           ,<cfif cComments is '' >cComments = null <cfelse>cComments = #cComments#</cfif>
           ,dteffectiveStart = getdate()
           ,dtrowadded = getdate()
           ,iRowAddedByUserID = #session.userid#
           ,cRowAddedByUserName = '#session.username#'
		   where iHouse_ID = #ihouse_id#
	</cfquery>
	<cfquery name="updatestatemedicaid" datasource="#APPLICATION.datasource#" result="updatestatemedicaid">
		Update charges
		set mamount= #CRmStateMedicaidAmt_BSF_Daily#
		where cchargeset ='#cchargeset#'
		and dtrowdeleted is null 
		and ihouse_ID = #ihouse_ID#
		and ichargetype_ID in (8)
	 </cfquery>	
	<cfquery name="updateMedicaidBSF" datasource="#APPLICATION.datasource#" result="updateMedicaidBSF">
		Update charges
		set mamount= #CRmMedicaidBSF#
		where cchargeset ='#cchargeset#'
		and dtrowdeleted is null 
		and ihouse_ID = #ihouse_ID#
		and ichargetype_ID in (31)
	 </cfquery>	 
	<cfquery name="updateMedicaidcopay" datasource="#APPLICATION.datasource#" result="updateMedicaidcopay">
		Update charges
		set mamount= #CRmMedicaidCopay#
		where cchargeset ='#cchargeset#'
		and dtrowdeleted is null 
		and ihouse_ID = #ihouse_ID#
		and ichargetype_ID in (1661)
	 </cfquery>	 
</cfif>

<body>
<cfoutput><cflocation url="MedicaidHouseUpdate.cfm?ihouse_id=#ihouse_id#"></cfoutput>
</body>
</html>

