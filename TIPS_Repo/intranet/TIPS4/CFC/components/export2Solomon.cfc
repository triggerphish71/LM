<cfcomponent  output="false" displayname="Close House Services" hint="I am the process that creates the invoice in Tips and sends it to SL" extends="intranet.TIPS4.CFC.utils.utilityServices">

	<cffunction access="public" name="sp_ExportInv2Solomon" output="true" returntype="any" hint="I am called when a house is closed. I Update the solomon database and can release the batch process.">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="iHouseID" type="numeric" required="true">
		<cfargument name="period" type="string" required="true">
		<cfargument name="invoice" type="string" required="true">		
		<cfargument name="batchType" type="string" required="true" hint="This is the action that is calling this function">
		<cfargument name="tenantId" type="numeric" required="false" default="0">

		<!--- default variables used below --->
		<cfset local.fromEmail="TIPS4-message@alcco.com">
		<cfset local.accountingEmail="jgedelman@enlivant.com">
		<cfset local.developersEmail="CFDevelopers@enlivant.com"> 
		<cfset local.subfolder = "\autorelease\">
		<cfset local.tenantID = arguments.tenantID>
		<cfset local.iHouseID = arguments.iHouseID>
		<cfif local.tenantID NEQ 0>
			<!--- get the correct data for the spreadsheet --->
	 		<cfset local.getTenantInfo =  getTenantInformation(datasource=application.datasource,batchType=arguments.batchType,tenantID=local.tenantID)>
	 		<cfset local.iHouseID = local.getTenantInfo.iHouse_ID>
		</cfif>
			
		<cfset local.houseName= getHouseInformation(houseID=local.iHouseID)>
		<!--- variables based on the calling action --->
		<cfswitch expression="#arguments.batchType#">
			<cfcase value="moveout">
				<cfset local.emailSubject="Auto Import Move Out">
				<cfset local.callingPath="Tips4\MoveOut\CloseAccount.cfm">
				<cfset local.autoRelease="0">
				<cfset local.folder = arguments.batchtype>
			</cfcase>
			<cfcase value="movein">
				<cfset local.emailSubject="Auto Import Move In">
				<cfset local.callingPath="TIPS4\MoveIn\FinalizedMoveIn.cfm">
				<cfset local.autoRelease="1">
				<cfset local.folder = arguments.batchtype>
			</cfcase>
			<cfcase value="respite">
				<cfset local.emailSubject="Respite Invoice To Solomon Fail">
				<cfset local.callingPath="Tips4\RespiteInvoicing\RespiteInvoiceFinalize.cfm">
				<cfset local.autoRelease="0">
				<cfset local.folder = arguments.batchtype>
			</cfcase>
			<cfcase value="house">
				<cfset local.emailSubject="Auto Import Monthly">
				<cfset local.callingPath="Tips4\Admin\Rdoclose.cfm">
				<cfset local.autoRelease="1">
				<cfset local.folder = "houseclose">
			</cfcase>
			<cfcase value="multihouse">
				<cfset local.emailSubject="Auto Import Monthly">
				<cfset local.callingPath="Tips4\Admin\Rdoclose_Multiple.cfm">
				<cfset local.autoRelease="1">
				<cfset local.folder = "houseclose">
			</cfcase>
			<cfcase value="QFMoveIn">
				<cfset local.emailSubject="Quick Fix Missing Solomon Batch For Move In">
				<cfset local.callingPath="Quickfix\Index.cfm">
				<cfset local.autoRelease="1">
				<cfset local.folder = "movein">
			</cfcase>
			<cfcase value="QFMoveOut">
				<cfset local.emailSubject="Quick Fix Missing Solomon Batch For Move Out">
				<cfset local.callingPath="Quickfix\Index.cfm">
				<cfset local.autoRelease="0">
				<cfset local.folder = "moveout">
			</cfcase>
			<cfcase value="QFHouse">
				<cfset local.emailSubject="Quick Fix Missing Solomon Batch For House">
				<cfset local.callingPath="QuickFix\Index.cfm">
				<cfset local.autoRelease = "1">
				<Cfset local.folder="houseclose">
			</cfcase>
			<cfcase value="ReImport">
				<cfset local.emailSubject="reImport SQL">
				<cfset local.callingPath="Tips4\Admin\reImportSQL.cfm">
				<cfset local.autoRelease="1">
			</cfcase>
		</cfswitch>	
		<cfset local.folder = local.subfolder&local.folder>
		<cftry>  
			<cfstoredproc procedure="rw.sp_ExportInv2Solomon" datasource="#arguments.datasource#" debug="yes" result="exp2sol" returncode="yes">
				<cfprocparam cfsqltype="cf_sql_integer" value="#arguments.iHouseID#" dbVarName="@house" type="in">
				<cfprocparam cfsqltype="cf_sql_char" value="#arguments.period#" dbVarName="@period" null="#IIF(LEN(arguments.period) EQ 0,true,false)#" type="in"> 
				<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.invoice#" dbVarName="@invoice" type="in" null="#IIF(Len(arguments.invoice) EQ 0,true,false)#">
				<cfprocparam cfsqltype="CF_SQL_TINYINT" value="#local.autoRelease#" dbVarName="@autoRelease" type="in">
				<cfprocparam cfsqltype="cf_sql_integer" type="out" variable="status" dbVarname="@status">
				<cfprocparam cfsqltype="cf_sql_varchar" type="out" variable="batnbr" dbVarname="@Batnbr">
		 	</cfstoredproc> 

			<!--- if the stored proc throws an error --->
		 	<cfcatch type="any">			 	
		 		<cfset local.bBatchCreated = checkIfBatchWasCreated(ahouseid=arguments.iHouseID,batchType=arguments.batchType,tenantID=local.tenantId)>

		 		<cfif local.bBatchCreated EQ 0>		 			
	 				<cfif local.tenantID NEQ 0>	 				
	 					<!--- get data and make a call to generate the pdf --->
	 					<cfset local.getData = getBatchData(datasource=application.datasource,batchtype=arguments.batchtype,tenantid=local.tenantId)>
	 				<cfelse>
				 		<cfset local.getData = getBatchData(datasource=application.datasource,batchType=arguments.batchType,houseid=arguments.iHouseId)>
		 			</cfif>
		 				 			
		 			<cfset local.fName = "sp_exportInv2Solomon#dateformat(now(),'mmddyyyy')#_t_#timeformat(now(),'HHnnss')#"> 
		 			<!--- call the function to genrate the spreadsheet for the artrans results ---->		
 					<cfset local.attachment = spreadsheetNewFromQuery(thedata=local.getData,sheetName="Data",filename=local.fName,outputToBrowser=false,folder=local.folder)> 	

 					<cfset local.friendlyErrorMessage=cfcatch.detail>
 					<cfif local.friendlyErrorMessage CONTAINS "]">
 						<cfset local.friendlyErrorMessage = ListLast(local.friendlyErrorMessage,"]")>
 					</cfif>
			 		<!--- email to accounting --->
			 		<cfmail from="#local.fromEmail#" to="#local.accountingEmail#" cc="#local.developersEmail#" subject="Error:#local.emailSubject#"  mimeattach="#local.attachment#" type="html">
					 	<p>					 		
						An error occurred during the Auto release process<br />
						<p><strong>Error Message:</strong>&nbsp;#local.friendlyErrorMessage#<br /></p>
						Batch Type: #arguments.batchType#<br />
						House Id: #local.iHouseID#<br />
						House Name: #local.houseName#<br />
						<cfif local.tenantID NEQ 0>
						Resident ID: #local.getTenantInfo.SolomonKey#<br />
						Resident Name: #local.getTenantInfo.fullName#<br />
						</cfif>						
						A email has been sent to the developement team with the details<br />							
						</p>
			 		</cfmail>

			 		<!--- email to developer --->
					<cfmail type="html" from="#local.fromEmail#" to="#local.developersEmail#" subject="Error:#local.emailSubject#"  mimeattach="#local.attachment#">
						<p>
							DECLARE	@return_value int,
									@Status int,
									@Batnbr varchar(10)

							EXEC	@return_value = [rw].[sp_ExportInv2Solomon]
									@house = #local.iHouseID#,
									@period = N'#arguments.period#',
									@Invoice = #arguments.invoice#,
									@AutoRelease = #local.autoRelease#,
									@Status = @Status OUTPUT,
									@Batnbr = @Batnbr OUTPUT

							SELECT	@Status as N'@Status',
									@Batnbr as N'@Batnbr'

							GO<br /></p>
							SELECT	'Return Value' = @return_value
						<p>Server_name: #cgi.server_name#<br />
						   Path: #local.callingPath#<br />
						   House Name: #local.houseName#<br />
						</p>
						<p>Error Information:<br />
						 <cfdump var="#cfcatch#"><br />
						</p>
	 				</cfmail> 		
	 				<cfset local.rtn = {success="false"}>
	 			<cfelse>
	 				<cfmail from="#local.fromEmail#" to="#local.accountingEmail#" cc="#local.developersEmail#" subject="Batch was created but not released" type="html">
	 					The following #local.houseName# batch was created in Solomon but was not released
	 				</cfmail>
	 				<cfset  local.rtn = {success="true"}>
	 			</cfif>	
 				<cfreturn local.rtn>
		 	</cfcatch>
		</cftry> 
		<cfset local.rtn = {status=status,batchnum=batnbr}>
		
		<!--- if the stored proc returns a status of 2 then the batch was created in Solomon but not released --->
		<cfif status EQ 2>
		
			<!--- get data to populate the spread sheet --->
			<cfset local.getData = getBatchData(datasource=application.datasource,batchType=arguments.batchType,batchNum=batnbr)>		 
		 	<cfset local.fName = "sp_exportInv2Solomon#dateformat(now(),'mmddyyyy')#_t_#timeformat(now(),'HHnnss')#"> 		 
		 	<!--- call the function to genrate the spreadsheet for the artrans results ---->		
 			<cfset local.attachment = spreadsheetNewFromQuery(thedata=local.getData,sheetName="Data",filename=local.fName,outputToBrowser=false,folder=local.folder)>			

			<cfmail type="html" from="#local.fromEmail#" to="#local.developersEmail#" cc="#local.accountingEmail#" subject="#local.emailSubject#" mimeattach="#local.attachment#" >
				<p>The Auto release process failed to relase the batch to Solomon<br />
					Batch Type: #arguments.batchType#<br />
					House Id: #local.iHouseID#<br />
					House Name:  #local.housename#<br />
					<cfif local.tenantID NEQ 0>
					Resident ID: #local.getTenantInfo.SolomonKey#<br />
					Resident Name: #local.getTenantInfo.fullName#<br />
					</cfif>

					Attached is the batch numbers, house, resident, etc. So that you can manually release the batch. 
				</p>
			</cfmail>
		
			<cfset local.rtn.success = false>
		<cfelseif status EQ 1>	
			<cfset local.rtn.success= true>	 
		<cfelse> 		
			<cfif local.tenantID NEQ 0>		 				 
		  		<cfset local.getData = getBatchData(datasource=application.datasource,batchtype=arguments.batchtype,tenantid=local.tenantId)>
	 		<cfelse>
				<cfset local.getData = getBatchData(datasource=application.datasource,batchType=arguments.batchType,houseid=arguments.iHouseId)>
		  	</cfif>
		  	<!--- if there is data then create the spreadsheet and send out emails. --->
		 
			  	<cfset local.fName = "sp_exportInv2Solomon#dateformat(now(),'mmddyyyy')#_t_#timeformat(now(),'HHnnss')#"> 
			 	<!--- call the function to genrate the spreadsheet for the artrans results ---->		
	 			<cfset local.attachment = spreadsheetNewFromQuery(thedata=local.getData,sheetName="Data",filename=local.fName,outputToBrowser=false,folder=local.folder)> 	

				<cfmail type="html" from="#local.fromEmail#" to="#local.accountingEmail#"  subject="#local.emailSubject#" mimeattach="#local.attachment#">
					<p>The batch processed failed<br />
						Batch Type: #arguments.batchType#<br />
						House Id: #arguments.iHouseID#<br />
						House Name: #local.housename#<br />
						<cfif arguments.tenantID NEQ 0>
						Resident ID: #local.getTenantInfo.SolomonKey#<br />
						Resident Name: #local.getTenantInfo.fullName#<br />
						</cfif>				
					</p>
				</cfmail>

	 			<cfmail type="html" from="#local.fromEmail#" to="#local.developersEmail#" subject="#local.emailSubject#" mimeattach="#local.attachment#">
					<p>status:0<br />
					   batch Number:0<br />
					<p>
						DECLARE	@return_value int,
								@Status int,
								@Batnbr varchar(10)

						EXEC	@return_value = [rw].[sp_ExportInv2Solomon]
								@house = #local.iHouseID#,
								@period = N'#arguments.period#',
								@Invoice = #arguments.invoice#,
								@AutoRelease = #local.autoRelease#,
								@Status = @Status OUTPUT,
								@Batnbr = @Batnbr OUTPUT

						SELECT	@Status as N'@Status',
								@Batnbr as N'@Batnbr'

						GO<br /></p>
						SELECT	'Return Value' = @return_value
						<p>Server_name: #cgi.server_name#<br />
						Path: #local.callingPath#<br />
						House Name: #local.houseName#<br />
						</p>
						<p>Error Information:<br />
						<cfdump var="#cfcatch#"><br />
						</p>
					
				</cfmail> 			
			
			<cfset local.rtn.success = false>			
 		</cfif> 		
 		<cfreturn local.rtn>
	</cffunction>

	<cffunction access="public" name="getBatchData" output="false" returntype="query" hint="I return the resultset of the batch information">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="batchType" type="string" required="true">
		<cfargument name="batchNum" type="numeric" requried="false" default="0">
		<cfargument name="houseid" type="numeric" required="false" default="0">
		<cfargument name="tenantID" type="numeric" required="false" default="0">

		<cfquery name="local.qGetBatchData" datasource="#arguments.datasource#">
			SELECT  DISTINCT t.iTenant_ID as [tenat_ID], t.cFirstname + ' ' + t.cLastName as [Resident Name],
	 			t.cSolomonKey as [Solomon Key],h.cName as [House Name], 
	 			<cfif arguments.batchNum NEQ 0>
	 				ar.batNbr <cfelse> ''</cfif> as [Batch Num],
	 			'#arguments.batchType#' as "Batch Type"
	 		FROM Tenant t WITH (NOLOCK)
	 		INNER JOIN TenantState ts WITH (NOLOCK) on t.iTenant_ID = ts.iTenant_ID 
	 			and ts.dtRowDeleted IS NULL
	 			and t.dtRowDeleted IS NULL
	 		INNER JOIN House h WITH (NOLOCK) on t.iHouse_id = h.iHouse_id
	 		<cfif arguments.batchNum NEQ 0>
	 			INNER JOIN Krishna.Houses_App.dbo.ARDoc ar WITH (NOLOCK) on t.cSolomonKey = ar.CustID
	 		</cfif>
	 		WHERE 1=1
	 		<cfif arguments.batchNum NEQ 0>
		 		AND ar.BatNbr IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.batchnum#">)		 	
		 		AND ts.dtMoveOut IS NULL 
		 		AND ts.dtMoveIn IS NOT NULL
		 	<cfelseif arguments.tenantID NEQ 0>
		 		AND t.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		 	<cfelseif arguments.houseid NEQ 0>
		 		AND h.iHouse_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		 		AND ts.dtMoveOut Is NULL		 	
		 	    AND ts.dtMoveIn IS NOT NULL	
			</cfif>
		</cfquery>
		<cfreturn local.qGetBatchData>
	</cffunction>

	<cffunction access="public" name="getTenantInformation" output="false" returntype="query" hint="I return a resultset of the tenant information">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
	
		<cfquery name="local.qGetData" datasource="#arguments.datasource#">
 			SELECT cSolomonKey as solomonKey, cFirstname + ' ' + cLastName as fullname, iHouse_ID	 			
 			FROM Tenant  WITH (NOLOCK)
 			WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">	 			
 		</cfquery>	

	 	<cfreturn local.qGetData>
	</cffunction> 	

	<cffunction access="public" name="getHouseInformation" output="false" returntype="string" hint="I return the name of the house">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="local.qGetHouseName" datasource="#arguments.datasource#">
			SELECT cName
			FROM house WITH (NOLOCK)
			WHERE iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>
		<cfreturn local.qGetHouseName.cName>
	</cffunction>

	<cffunction access="public" name="checkIfBatchWasCreated" output="false" returntype="numeric" hint="i generate the data to check for batch ">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ahouseid" type="numeric" required="true">
		<cfargument name="batchType" type="string" required="true">
		<cfargument name="tenantID" type="numeric" required="true">

		<cfquery name="qGetKey" datasource="#arguments.datasource#">
			select   
 				 Left(right(rtrim(h.cGLsubaccount),3)+h.cName,10) as crtdUser,
 				 hl.dtCurrentTipsMonth,
 				 t.cSolomonKey
			from house  h with (NOLOCK)
			inner join houselog hl WITH (NOLOCK) on h.iHouse_Id = hl.iHouse_Id
			INNER JOIN tenant t WITH (NOLOCK) on h.iHouse_id = t.iHouse_ID
			INNER JOIN tenantState ts with (NOLOCK) on t.itenant_id = ts.iTenant_ID
			where h.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ahouseid#"> 
			AND	H.dtRowDeleted IS NULL 
			AND HL.dtRowDeleted IS NULL
			<cfif arguments.batchType NEQ "moveout"> 
			 AND ts.dtMoveOut IS NULL
			</cfif>
			<cfif arguments.tenantID NEQ 0>
			 AND t.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			</cfif>
 		</cfquery>
 	
 		<cfset bBatchCreated = checkSolForBatch(solomonkey=#QuotedValueList(qGetKey.cSolomonKey)#,crtduser=#qGetKey.crtdUser#,period=#dateformat(qGetKey.dtCurrentTipsMonth,"yyyymm")#)>
 		
 		<cfreturn VAL(bBatchCreated.recordcount)> 	
	</cffunction>

	<cffunction access="public" name="checkSolForBatch" output="false" returntype="query" hint="i check solomon to see if batch was created in solomon">
		<cfargument name="datasource" type="string" required="false" default="HOUSES_APP">
		<cfargument name="solomonKey" type="string" required="true">
		<cfargument name="crtduser" type="string" required="true">
		<cfargument name="period" type="string" required="true">
		
		<cfquery name="qCheckBatchCreation" datasource="#arguments.datasource#">
			SELECT *
			FROM artran WITH (NOLOCK)
			WHERE custID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value='#ListPrepend(arguments.Solomonkey,"'0'",",")#'>)
			AND perpost = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.period#">
			AND crtd_user = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.crtdUser#">
			and rlsed = 0
		</cfquery>	

		<cfreturn qCheckBatchCreation>
	</cffunction>


</cfcomponent>
