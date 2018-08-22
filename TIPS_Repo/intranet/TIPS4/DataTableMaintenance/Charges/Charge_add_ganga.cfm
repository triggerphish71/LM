<cfset enddate = CreateODBCDateTime('2020-12-31')>
<cfset startdate = CreateODBCDateTime('2012-12-17')>
<cfset thishouseID = 103>
<cfset count = 0>

<cfquery name="HouseName" datasource="#application.datasource#">
	SELECT cname from house where ihouse_id = #thishouseID#
</cfquery> 

<cfquery name="ChargeCOunt" datasource="#application.datasource#">
	SELECT count( iCharge_ID) as 'ChargeCnt'
	  FROM TIPS4.dbo.Charges
	  where ihouse_id = #thishouseID#
	  and ichargetype_id = 91
	  and cchargeset = '2012Jan'
		and  dtrowdeleted is null
</cfquery> 

<cfquery name="SLevelType" datasource="#application.datasource#">
	select *, len(cdescription) 
	 ,case when (len( cdescription) = 1) then
	  cast(substring( cdescription, 1,1)  as  varchar(8))    
	 when   (len( cdescription) = 7)  then
	  cast(substring( cdescription, 1,3)  as  varchar(8))     
	when len( cdescription) = 8  then
	  cast(substring( cdescription, 1,4)  as  varchar(8))  
	when len( cdescription) = 9  then
	 cast(substring( cdescription, 1,5)  as  varchar(8))  	   
	 end     
	  as 'descrip' from SLevelType where csleveltypeset = 14 and dtRowDeleted is null 
</cfquery>

<cfoutput>#ChargeCOunt.ChargeCnt#  <br></cfoutput>

<cftransaction>
	<cfoutput query="SLevelType">
	
		<cfquery name="Charge" datasource="#application.datasource#">
		SELECT  iCharge_ID
			  ,iChargeType_ID
			  ,iHouse_ID
			  ,cChargeSet
			  ,cDescription
			  ,mAmount
			  ,iQuantity
			  ,bIsRentUNUSED
			  ,bIsMedicaidUNUSED
			  ,iResidencyType_ID
			  ,iAptType_ID
			  ,cSLevelDescription
			  ,iSLevelType_ID
			  ,iOccupancyPosition
			  ,dtAcctStamp
			  ,dtEffectiveStart
			  ,dtEffectiveEnd
			  ,iRowStartUser_ID
			  ,dtRowStart
			  ,iRowEndUser_ID
			  ,dtRowEnd
			  ,iRowDeletedUser_ID
			  ,dtRowDeleted
			  ,cRowStartUser_ID
			  ,cRowEndUser_ID
			  ,cRowDeletedUser_ID
			  ,iProductLine_ID
			  ,bIsMoveInCharge
			  
			  
		  FROM TIPS4.dbo.Charges c
		  where ihouse_id = #thishouseID#
		  and ichargetype_id = 91
		  and cchargeset = '2012Jan'
		  and cast('#SLevelType.descrip#'  as varchar(5)) =  ( case when (len(c.cdescription) = 23) then
			  cast(substring(c.cdescription, 23,1)  as  varchar(1))    
			 when   (len(c.cdescription) = 32)  then
			  cast(substring(c.cdescription, 23,3)  as  varchar(3))     
			when len(c.cdescription) = 33  then
			  cast(substring(c.cdescription, 23,4)  as  varchar(4))  
			when len(c.cdescription) = 34  then
			 cast(substring(c.cdescription, 23,5)  as  varchar(5)) 	   
			 end  ) 
			   and c.dtrowdeleted is null
		 </cfquery> 
	
		<!--- Insert for entry of new charge --->
		 <cfif Charge.iHouse_ID is not "">
<!---    	<cfquery name = "ChargeInsert" datasource = "#application.datasource#">  
			insert into	Charges
			( iChargeType_ID 
				,iHouse_ID 
				,cChargeSet
				,cDescription  
				,mAmount 
				,iQuantity
				,iResidencyType_ID   
				,cSLevelDescription 
				,iSLevelType_ID 
				,dtEffectiveStart 
				,dtEffectiveEnd 
				,dtAcctStamp 
				,iRowStartUser_ID 
				,cRowStartUser_ID
				,dtRowStart
				, iproductline_id )  
			values  ---> 
			(     
				#Charge.iChargeType_ID#  
				,#thishouseID#
				,'2013Jan'
				,'#trim(ChaRGE.cDescription)#' 
				,#trim(Charge.mAmount)# 
				, 1 
				,#trim(Charge.iResidencyType_ID)# 
				,'#trim(Charge.cSLevelDescription)#' 
				, #trim(SLevelType.iSLevelType_ID)# 
				,#startdate#
				,#enddate#
				,#CreateODBCDateTime(session.AcctStamp)#  
				,#session.UserID# 
				,'SFarmer 14 ManualInsert'
				,#CreateODBCDateTime(now())#
				,1 
			)     
			<!---  </cfquery>  --->  <br />
		</cfif>
	 
		<cfset count = count + 1>
	</cfoutput>
</cftransaction>
<cfoutput> done House: #thishouseID# :: #HouseName.cname# :: #count# :: Change 1</cfoutput>