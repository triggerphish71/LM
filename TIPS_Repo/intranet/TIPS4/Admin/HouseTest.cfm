<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
		<cfquery name="QueryGetInformation" datasource="TIPS4">
			SELECT
				 h.*
				,L.dtCurrentTipsMonth AS tipsmonth
				,IsNull(L.bIsPdClosed,0) AS isClosed
				,'' AS houseemail
				<!--- ,IsNull(a.houseemail,'') AS houseemai ---> 
			FROM
				House h
			INNER JOIN
				HouseLog L ON L.ihouse_id = H.ihouse_id
			<!--- LEFT JOIN 
				#variables.censusdbserver#.census.dbo.houseaddresses a on a.nHouse = h.cNumber	 --->
			WHERE
				h.iHouse_ID = 273
		</cfquery>
	<cfoutput><cfdump var="#QueryGetInformation#"></cfoutput>
			<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
				//alias the get information query to make typing easier
				theQuery = QueryGetInformation;
	
				variables.opsAreaId = theQuery["iOpsArea_ID"][1];
				variables.pdUserId = theQuery["iPDUser_ID"][1];
				acctUserId = theQuery["iAcctUser_ID"][1];
				variables.name = theQuery["cName"][1];
				variables.number = theQuery["cNumber"][1];
				variables.depositTypeSet = theQuery["cDepositTypeSet"][1];
				variables.sLevelTypeSet = theQuery["cSLevelTypeSet"][1];
				variables.glSubAccount = theQuery["cGlSubAccount"][1];
				variables.currentTipsMonth = theQuery["tipsmonth"][1];
			//	variables.isPeriodClosed = BitToBool(theQuery["isClosed"][1]);
				if(theQuery["bIsCensusMedicaidOnly"][1] eq 1)
				{
					variables.isCensusMedicaidOnly = true;
				}
				variables.phoneNumber1 = theQuery["cPhoneNumber1"][1];
				variables.phoneType1Id = theQuery["iPhoneType1_ID"][1];
				variables.phoneNumber2 = theQuery["cPhoneNumber2"][1];
				variables.phoneType2Id = theQuery["iPhoneType2_ID"][1];
				variables.phoneNumber3 = theQuery["cPhoneNumber3"][1];
				variables.phoneType3Id = theQuery["iPhoneType3_ID"][1];
				variables.addressLine1 = theQuery["cAddressLine1"][1];
				variables.addressLine2 = theQuery["cAddressLine2"][1];
				variables.city = theQuery["cCity"][1];
				variables.stateCode = theQuery["cStateCode"][1];
				variables.zipCode = theQuery["cZipCode"][1];
				variables.comments = theQuery["cComments"][1];
				variables.acctStamp = theQuery["dtAcctStamp"][1];
				variables.billingType = theQuery["cBillingType"][1];
				//if the row start is the users id set it, otherwise if its null try the crowstartuserid
				if(theQuery["iRowStartUser_ID"][1] neq "")
				{
					variables.rowStartUserId = theQuery["iRowStartUser_ID"][1];
				}
				else
				{
					variables.rowStartUserId = theQuery["cRowStartUser_ID"][1];
				}
				variables.rowStartDate = theQuery["dtRowStart"][1];
				//if the end start is the users id set it, otherwise if its null try the crowstartuserid
				if(theQuery["iRowEndUser_ID"][1] neq "")
				{
					variables.rowEndUserId = theQuery["iRowEndUser_id"][1];
				}
				else
				{
					variables.rowEndUserId = theQuery["cRowEndUser_id"][1];
				}
				variables.rowEndDate = theQuery["dtRowEnd"][1];
				if(theQuery["iRowEndUser_ID"][1] neq "")
				{
					variables.rowDeletedUserId = theQuery["iRowEndUser_ID"][1];
				}
				else
				{
					variables.rowDeletedUserId = theQuery["cRowEndUser_ID"][1];
				}
				variables.rowDeletedDate = theQuery["dtRowDeleted"][1];
				variables.unitsAvailable = theQuery["iUnitsAvailable"][1];
				variables.rentalAgreementDate = theQuery["dtRentalAgreement"][1];
				variables.nurseUserId = theQuery["cNurseUser_ID"][1];
				variables.ehsiFacilityId = theQuery["EHSIFacilityID"][1];
				if(theQuery["bIsSandbox"][1] eq 1)
				{
					variables.isSandbox = true;
				}
				variables.chargeSetId = theQuery["iChargeSet_ID"][1];
				
				variables.email = theQuery["houseemail"][1];
			}
			else
			{
				Throw("House not found","House #variables.id# was not found in datasource #variables.dsn#");
			}
		</cfscript>
			<cfoutput><cfdump var="#variables#"></cfoutput>
				<!---   <cfoutput> test123 #variables.name# #i# </cfoutput> --->
	  <cfoutput> #UCASE(LEFT(variables.name,1)) & LCASE(RIGHT(variables.name,LEN(variables.name) - 1)) #</cfoutput>
	 		<cfset formattedName = "">
		<cfloop list="#variables.name#" index="i" delimiters=" ">
			<cfset formattedName = #variables.name#>  
		</cfloop>
		<cfscript>
			return TRIM(formattedName);
			
		</cfscript>
	 
</body>
</html>
