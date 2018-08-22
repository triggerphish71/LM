
<CFQUERY NAME = "NextKey" DATASOURCE = "#APPLICATION.datasource#">
	(SELECT	
		(SELECT iHouse_ID
		FROM trigger_happy.dbo.HOUSE H 	JOIN 	#application.censusdbserver#.do_not_touch_census.DBO.HOUSES DH
				ON	H.cNumber = DH.nHouse
		WHERE H.cNumber = o.nhouse) as 'iHouse_ID',
	
		(SELECT dh.nHouse
		FROM trigger_happy.dbo.HOUSE H 	JOIN 	#application.censusdbserver#.do_not_touch_census.DBO.HOUSES DH
				ON	H.cNumber = DH.nHouse
		WHERE H.cNumber = o.nhouse) as 'cNumber',
	
		(SELECT cast(MAX(CTENANTID) as int)
		FROM 	#application.censusdbserver#.do_not_touch_census.DBO.TENANTS 
		WHERE 	NHOUSE = O.NHOUSE)	as iNextSolomonKey
	 
		FROM	#application.censusdbserver#.do_not_touch_census.DBO.HOUSES O) 
	ORDER BY iHouse_ID
</CFQUERY>




<CFOUTPUT QUERY = "NextKey">

<CFSET iHouse_ID 		= #NextKey.iHouse_ID#>

<CFIF NextKey.iNextSolomonKey GT 1>

	<CFSET First = (#NextKey.cNumber# - 1800)>
	<CFSET SECOND = (#Right(NextKey.iNextSolomonKey,4)# + 10000)>
	<CFSET iNextSolomonKey 	= #First# & #second#>
	
<CFELSE>

	ELSE
	<CFSET iNextSolomonKey  = (#NextKey.cNumber# - 1800) & 10000>

</CFIF>


<CFQUERY NAME = "Insert" DATASOURCE = "#APPLICATION.datasource#">
	INSERT INTO SOLOMONKEY
	(iHouse_ID, iNextSolomonKey)
		VALUES
	(#iHouse_ID#, 
	
	<CFIF iNextSolomonKey NEQ "">
		#iNextSolomonKey#
	<CFELSE>
		10000
	</CFIF>
	)
</CFQUERY>



</CFOUTPUT>