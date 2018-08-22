<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfset CurrentDate = #DateFormat(dateadd("d", -1, now()), "mm/dd/yyyy")#>
 
<cfset currentDay = DayOfWeek(Now())>
	<cfquery name="checkapprovedisapprove" datasource="TIPS4" username="rw" password="4rwriter">
		select
			r.cName as rName
			, oa.cName as oaName
			, h.cName as hName
			, h.cNumber as hNumber
			, dc.dtrowstart as ApproveDate
		from
			dailycensus dc
            join house h on h.ihouse_ID = dc.ihouse_ID
            join OpsArea oa on h.iOpsArea_ID = oa.iOpsArea_ID
            join region r on r.iRegion_ID = oa.iRegion_ID
		where
			dc.Census_Date = '#CurrentDate#'
            and	dc.dtrowdeleted is NULL
            and	h.bissandbox = 0
            and	h.dtrowdeleted is NULL
            and	r.cNumber <> 5
            and	h.ihouse_ID not in (71,104,129,152,155,173,183,185,196,216,224,147,29,227,209,220,174,238,49,124,123)
        
		union all
		
        select
			r.cName as rName
			, oa.cName as oaName
			, h.cName as hName
			, h.cNumber as hNumber
			, '' as ApproveDate
		from
			House h
			, region r
			, OpsArea oa
		where
			r.iRegion_ID = oa.iRegion_ID
			and h.iOpsArea_ID = oa.iOpsArea_ID
			and iHouse_ID not in
			(select	iHouse_ID
			from dailycensus
			where
				Census_Date = '#CurrentDate#'
                and	dtrowdeleted is NULL)
                and	h.bIsSandbox = 0
                and	h.dtrowdeleted is NULL
                and	r.cNumber <> 5
                and	h.ihouse_ID not in (71,104,129,152,155,173,183,185,196,216,224,147,29,227,209,220,174,238,49,124,123)
		order by rName, oaName, hName
	</cfquery>
<body>
			<cfloop query="checkapprovedisapprove">
					<cfinvoke
						method="getTimeZoneByFacilityNumber"
						returnvariable="aString"
						webservice="http://maple/phonedirectoryservice/Service.asmx?wsdl" >
						<cfinvokeargument name="iFacilityNumber" value="#checkapprovedisapprove.hNumber#"/>
					</cfinvoke>
					
					<cfoutput>#rname#, #oaname#, #aString#, #hNumber#, #hName#<br /></cfoutput>
		</cfloop>
</body>
</html>
