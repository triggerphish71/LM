<cfset destFilePath = "\\fs01\ALC_IT\EFTPull">	
<cfset filename = "NRFDeferreddata">
<cfquery name="qryNRFData" datasource="#application.datasource#">
		select
		t.itenant_id 
		,t.csolomonkey 
		,t.cfirstname
		, t.clastname
		, h.cname as housename
		, h.iOpsArea_ID 
		,OPSA.cName	as 'OPSname'
		,OPSA.iRegion_ID
		,reg.cName	as 'Regionname'			
		,HL.dtCurrentTipsMonth		
		,ts.mBaseNRF as 'BaseNRF'
		,ts.mAdjNRF as 'AdjNRF'
		,rc.mAmount as 'DeferredNRF'
		,rc.cdescription
		,ts.cNRFAdjApprovedBy
		,rc.dtRowStart
		,rc.dtEffectiveStart
		,rc.dtEffectiveEnd
		,rc.dtRowDeleted
		,datediff(m,HL.dtCurrentTipsMonth ,rc.dtEffectiveEnd  ) as 'paymentrem'
 		,datediff(m,rc.dtEffectiveStart,rc.dtEffectiveEnd) + 1 as 'nbrpaymnt'  
		from tenant t
		join tenantstate ts on t.itenant_id = ts.itenant_id
		join house h on t.ihouse_id = h.ihouse_id
		join dbo.OpsArea OPSA on OPSA.iOpsArea_ID  = h.iOpsArea_ID
		join dbo.Region reg on reg.iRegion_ID = OPSA.iRegion_ID
		join dbo.RecurringCharge RC on RC.iTenant_ID = t.iTenant_ID 
		JOIN HouseLog HL ON h.iHouse_ID = HL.iHouse_Id
		join charges chg on chg.iCharge_ID = RC.iCharge_ID and chg.ichargetype_id = 1740
 
		where ts.bIsNRFDeferred = 1
		  and   rc.dtEffectiveEnd >= getdate() 
		  AND rc.mAmount  <> 0
		order by OPSA.iRegion_ID,h.iOpsArea_ID,housename,t.itenant_id,rc.dtRowStart
</cfquery>
		
<cfsetting enablecfoutputonly="yes">   
<cfset delim = 44>  

<cfcontent  type="application/vnd.ms-excel">
<cfheader  name="Content-Disposition" value="filename=NRFDeferreddata.csv">		


		 <cffile action="write"
                 file="#destFilePath#\#filename#.csv"
                  output="iRegion_ID#chr(delim)#Regionname#chr(delim)#iOpsArea_ID#chr(delim)#OPSname#chr(delim)#housename#chr(delim)#itenant_id#chr(delim)#csolomonkey#chr(delim)#cfirstname#chr(delim)#clastname#chr(delim)#dtCurrentTipsMonth#chr(delim)#BaseNRF#chr(delim)#AdjNRF#chr(delim)#DeferredNRF#chr(delim)#cdescription#chr(delim)#cNRFAdjApprovedBy#chr(delim)#dtRowStart#chr(delim)#dtEffectiveStart#chr(delim)#dtEffectiveEnd#chr(delim)#dtRowDeleted#chr(delim)#paymentrem#chr(delim)#nbrpaymnt"
				   addnewline="yes">
<cfoutput>
<cfloop query="qryNRFData">
		 <cffile action="append"
                 file="#destFilePath#\#filename#.csv"
                  output="#iRegion_ID##chr(delim)##Regionname##chr(delim)##iOpsArea_ID##chr(delim)##OPSname##chr(delim)##housename##chr(delim)##itenant_id##chr(delim)##csolomonkey##chr(delim)##cfirstname##chr(delim)##clastname##chr(delim)##dtCurrentTipsMonth##chr(delim)##BaseNRF##chr(delim)##AdjNRF##chr(delim)##DeferredNRF##chr(delim)##cdescription##chr(delim)##cNRFAdjApprovedBy##chr(delim)##dtRowStart##chr(delim)##dtEffectiveStart##chr(delim)##dtEffectiveEnd##chr(delim)##dtRowDeleted##chr(delim)##paymentrem##chr(delim)##nbrpaymnt#"
				   addnewline="yes">
</cfloop>
</cfoutput>

	<div><cfoutput>File Created at: #destFilePath#\#filename#.csv</cfoutput></div>	