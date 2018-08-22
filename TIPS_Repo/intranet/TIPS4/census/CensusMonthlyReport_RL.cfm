<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>CensusMonthlyReport</title>
</head>
<cfparam name="prompt0" default="">
<cfparam name="prompt1" default="">

<cfquery name="checkhouse" DATASOURCE="#APPLICATION.datasource#">
	select * from [dbo].[RL_RES_STG]	WHERE ToHouseID = #SESSION.qSelectedHouse.iHouse_ID# and Active = 'Y'
</cfquery>	

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, h.cName, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	  AND	H.dtrowdeleted is NULL
	  AND	H.bisSandbox = 0
</CFQUERY>

<cfset prompt0 = #HouseData.ihouse_id#>
 
<cfquery name="spmonthlycensus" DATASOURCE="#APPLICATION.datasource#">
		EXEC  dbo.sp_monthlycensusreport_RL
		@ihouse_id = #HouseData.iHouse_ID#,
		@Period = #prompt1#
</cfquery>
<body>
<cfdocument  format="PDF" orientation="landscape" margintop="1.5" marginbottom="1" marginleft=".5" marginright=".5">
		<!--- <cfoutput><cfset pagecnt = #spmonthlycensus.iresidencytype_id#></cfoutput> --->
	<cfdocumentitem type="header"  evalAtPrint="true">
 
<cfoutput>
	<table width="100%">
		<tr>
			<td style="text-align:center; font-weight:bold;">Monthly Census Report</td>
		</tr>
		<tr>
			<td style="text-align:center; font-weight:bold;">#HouseData.cname#</td>
		</tr>
		<tr>
			<td style="text-align:center; font-weight:bold;">For the Month of</td>
		</tr>
		<tr>
			<td style="text-align:center; font-weight:bold;">#prompt1#</td>
		</tr>
		<tr>
	<td style="text-align:center;font-weight:bold;">#dateformat(now(),'m/d/yyyy')# #timeformat(now(),'h:mm:ss tt')#</td>
		</tr>				
	</table>

<table width="100%"  cellpadding="1"  cellspacing="1"  >
	<tbody>
		<colgroup>
			<col span="1" style="width: 15%;"> <!---Name--->
			<col span="1" style="width: 4%;">  <!--- LOC--->
			<col span="1" style="width: 2%;">  <!---  1 --->
			<col span="1" style="width: 2%;">  <!---  2 --->
			<col span="1" style="width: 2%;">  <!---  3 --->
			<col span="1" style="width: 2%;">  <!---  4 --->
			<col span="1" style="width: 2%;">  <!---  5 --->
			<col span="1" style="width: 2%;">  <!---  6 --->
			<col span="1" style="width: 2%;">  <!---  7 --->
			<col span="1" style="width: 2%;">  <!---  8 --->
			<col span="1" style="width: 2%;">  <!---  9 --->
			<col span="1" style="width: 2%;">  <!--- 10  --->
			<col span="1" style="width: 2%;">  <!--- 11  --->
			<col span="1" style="width: 2%;">  <!--- 12  --->
			<col span="1" style="width: 2%;">  <!--- 13  --->
			<col span="1" style="width: 2%;">  <!--- 14  --->
			<col span="1" style="width: 2%;">  <!--- 15  --->
			<col span="1" style="width: 2%;">  <!--- 16  --->
			<col span="1" style="width: 2%;">  <!--- 17  --->
			<col span="1" style="width: 2%;">  <!--- 18  --->
			<col span="1" style="width: 2%;">  <!--- 19  --->
			<col span="1" style="width: 2%;">  <!--- 20  --->
			<col span="1" style="width: 2%;">  <!--- 21  --->
			<col span="1" style="width: 2%;">  <!--- 22  --->
			<col span="1" style="width: 2%;">  <!--- 23  --->						
			<col span="1" style="width: 2%;">  <!--- 24  --->
			<col span="1" style="width: 2%;">  <!--- 25  --->
			<col span="1" style="width: 2%;">  <!--- 26  --->
			<col span="1" style="width: 2%;">  <!--- 27  --->
			<col span="1" style="width: 2%;">  <!--- 28  --->
			<col span="1" style="width: 2%;">  <!--- 29  --->
			<col span="1" style="width: 2%;">  <!--- 30  --->
			<col span="1" style="width: 2%;">  <!--- 31  --->
			<col span="1" style="width: 7%;">  <!--- leave  --->
			<col span="1" style="width: 8%;">  <!--- total  --->  		
		</colgroup>			
		<tr>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold; text-align:center;">Resident</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">LOC</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">01</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">02</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">03</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">04</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">05</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">06</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">07</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">08</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">09</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">10</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">11</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">12</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">13</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">14</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">15</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">16</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">17</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">18</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">19</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">20</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">21</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">22</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">23</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">24</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">25</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">26</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">27</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">28</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">29</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">30</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">31</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold; text-align:center;">Leave</td>	
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold; text-align:center;">Total</td>		
		</tr>
	</tbody>
</table>

</cfoutput>
</cfdocumentitem>
<cfset thisResidencytype = #spmonthlycensus.iresidencytype_id#>
 		<cfset GTday01 = 0>	
		<cfset GTday02 = 0>	
		<cfset GTday03 = 0>	
		<cfset GTday04 = 0>	
		<cfset GTday05 = 0>	
		<cfset GTday06 = 0>	
		<cfset GTday07 = 0>	
		<cfset GTday08 = 0>
		<cfset GTday09 = 0>	
		<cfset GTday10 = 0>	
		<cfset GTday11 = 0>	
		<cfset GTday12 = 0>
		<cfset GTday13 = 0>	
		<cfset GTday14 = 0>	
		<cfset GTday15 = 0>	
		<cfset GTday16 = 0>
		<cfset GTday17 = 0>	
		<cfset GTday18 = 0>	
		<cfset GTday19 = 0>	
		<cfset GTday20 = 0>
		<cfset GTday21 = 0>	
		<cfset GTday22 = 0>	
		<cfset GTday23 = 0>	
		<cfset GTday24 = 0>
		<cfset GTday25 = 0>	
		<cfset GTday26 = 0>	
		<cfset GTday27 = 0>	
		<cfset GTday28 = 0>
		<cfset GTday29 = 0>	
		<cfset GTday30 = 0>	
		<cfset GTday31 = 0>	
		<cfset GTTotal = 0>
<!---  --->			
 		<cfset LTday01 = 0>	
		<cfset LTday02 = 0>	
		<cfset LTday03 = 0>	
		<cfset LTday04 = 0>	
		<cfset LTday05 = 0>	
		<cfset LTday06 = 0>	
		<cfset LTday07 = 0>	
		<cfset LTday08 = 0>
		<cfset LTday09 = 0>	
		<cfset LTday10 = 0>	
		<cfset LTday11 = 0>	
		<cfset LTday12 = 0>
		<cfset LTday13 = 0>	
		<cfset LTday14 = 0>	
		<cfset LTday15 = 0>	
		<cfset LTday16 = 0>
		<cfset LTday17 = 0>	
		<cfset LTday18 = 0>	
		<cfset LTday19 = 0>	
		<cfset LTday20 = 0>
		<cfset LTday21 = 0>	
		<cfset LTday22 = 0>	
		<cfset LTday23 = 0>	
		<cfset LTday24 = 0>
		<cfset LTday25 = 0>	
		<cfset LTday26 = 0>	
		<cfset LTday27 = 0>	
		<cfset LTday28 = 0>
		<cfset LTday29 = 0>	
		<cfset LTday30 = 0>	
		<cfset LTday31 = 0>	
		<cfset GTTotal = 0>	
		<cfset CSTTotal = 0>		

	<table width="100%"  cellpadding="1"  cellspacing="1"  >
	<tbody>
		<cfoutput query="spmonthlycensus" group="iresidencytype_id">
  			<tr>
				<td colspan="35">
				<cfif iresidencytype_id is not thisResidencytype>
					<cfdocumentitem type="pagebreak" />	
					<cfset thisResidencytype = #spmonthlycensus.iresidencytype_id#>
				</cfif> 
				</td>
			</tr> 
			<tr>
				<td colspan="1" style="border-bottom:  .5px solid black; font-size:10px; font-weight:bold;" >
				Payor Type: #spmonthlycensus.iresidencytype_id# #spmonthlycensus.cdescription#</td>
				<td colspan="34">&nbsp;</td>
			</tr>			

		<cfset CSTday01 = 0>	
		<cfset CSTday02 = 0>	
		<cfset CSTday03 = 0>	
		<cfset CSTday04 = 0>	
		<cfset CSTday05 = 0>	
		<cfset CSTday06 = 0>	
		<cfset CSTday07 = 0>	
		<cfset CSTday08 = 0>
		<cfset CSTday09 = 0>	
		<cfset CSTday10 = 0>	
		<cfset CSTday11 = 0>	
		<cfset CSTday12 = 0>
		<cfset CSTday13 = 0>	
		<cfset CSTday14 = 0>	
		<cfset CSTday15 = 0>	
		<cfset CSTday16 = 0>
		<cfset CSTday17 = 0>	
		<cfset CSTday18 = 0>	
		<cfset CSTday19 = 0>	
		<cfset CSTday20 = 0>
		<cfset CSTday21 = 0>	
		<cfset CSTday22 = 0>	
		<cfset CSTday23 = 0>	
		<cfset CSTday24 = 0>
		<cfset CSTday25 = 0>	
		<cfset CSTday26 = 0>	
		<cfset CSTday27 = 0>	
		<cfset CSTday28 = 0>
		<cfset CSTday29 = 0>	
		<cfset CSTday30 = 0>	
		<cfset CSTday31 = 0>
		<cfset CSTTotal = 0>			
 <!---  --->		
 		<cfset LSTday01 = 0>	
		<cfset LSTday02 = 0>	
		<cfset LSTday03 = 0>	
		<cfset LSTday04 = 0>	
		<cfset LSTday05 = 0>	
		<cfset LSTday06 = 0>	
		<cfset LSTday07 = 0>	
		<cfset LSTday08 = 0>
		<cfset LSTday09 = 0>	
		<cfset LSTday10 = 0>	
		<cfset LSTday11 = 0>	
		<cfset LSTday12 = 0>
		<cfset LSTday13 = 0>	
		<cfset LSTday14 = 0>	
		<cfset LSTday15 = 0>	
		<cfset LSTday16 = 0>
		<cfset LSTday17 = 0>	
		<cfset LSTday18 = 0>	
		<cfset LSTday19 = 0>	
		<cfset LSTday20 = 0>
		<cfset LSTday21 = 0>	
		<cfset LSTday22 = 0>	
		<cfset LSTday23 = 0>	
		<cfset LSTday24 = 0>
		<cfset LSTday25 = 0>	
		<cfset LSTday26 = 0>	
		<cfset LSTday27 = 0>	
		<cfset LSTday28 = 0>
		<cfset LSTday29 = 0>	
		<cfset LSTday30 = 0>	
		<cfset LSTday31 = 0>	
		<cfset LSTLeave = 0>		
<!---  --->			
		<colgroup>
			<col span="1" style="width: 15%;">  <!---Name--->
			<col span="1" style="width: 4%;">  <!--- LOC  --->
			<col span="1" style="width: 2%;">  <!---  1 --->
			<col span="1" style="width: 2%;">  <!---  2 --->
			<col span="1" style="width: 2%;">  <!---  3 --->
			<col span="1" style="width: 2%;">  <!---  4 --->
			<col span="1" style="width: 2%;">  <!---  5 --->
			<col span="1" style="width: 2%;">  <!---  6 --->
			<col span="1" style="width: 2%;">  <!---  7 --->
			<col span="1" style="width: 2%;">  <!---  8 --->
			<col span="1" style="width: 2%;">  <!---  9 --->
			<col span="1" style="width: 2%;">  <!--- 10  --->
			<col span="1" style="width: 2%;">  <!--- 11  --->
			<col span="1" style="width: 2%;">  <!--- 12  --->
			<col span="1" style="width: 2%;">  <!--- 13  --->
			<col span="1" style="width: 2%;">  <!--- 14  --->
			<col span="1" style="width: 2%;">  <!--- 15  --->
			<col span="1" style="width: 2%;">  <!--- 16  --->
			<col span="1" style="width: 2%;">  <!--- 17  --->
			<col span="1" style="width: 2%;">  <!--- 18  --->
			<col span="1" style="width: 2%;">  <!--- 19  --->
			<col span="1" style="width: 2%;">  <!--- 20  --->
			<col span="1" style="width: 2%;">  <!--- 21  --->
			<col span="1" style="width: 2%;">  <!--- 22  --->
			<col span="1" style="width: 2%;">  <!--- 23  --->						
			<col span="1" style="width: 2%;">  <!--- 24  --->
			<col span="1" style="width: 2%;">  <!--- 25  --->
			<col span="1" style="width: 2%;">  <!--- 26  --->
			<col span="1" style="width: 2%;">  <!--- 27  --->
			<col span="1" style="width: 2%;">  <!--- 28  --->
			<col span="1" style="width: 2%;">  <!--- 29  --->
			<col span="1" style="width: 2%;">  <!--- 30  --->
			<col span="1" style="width: 2%;">  <!--- 31  --->
			<col span="1" style="width: 7%;">  <!--- leave  --->
			<col span="1" style="width: 8%;">  <!--- total  --->		
		</colgroup>	
	
<!---  --->									
		<cfoutput>
			<tr>
				<td style="font-size:10px;">#itenant_id# #clastname#, #cfirstname#</td>
				<td style="font-size:10px;text-align:center;">#LevelDescription#</td>
				<td style="font-size:10px;">#day01#</td>
				<td style="font-size:10px;">#day02#</td>	
				<td style="font-size:10px;">#day03#</td>
				<td style="font-size:10px;">#day04#</td>	
				<td style="font-size:10px;">#day05#</td>
				<td style="font-size:10px;">#day06#</td>	
				<td style="font-size:10px;">#day07#</td>
				<td style="font-size:10px;">#day08#</td>	
				<td style="font-size:10px;">#day09#</td>
				<td style="font-size:10px;">#day10#</td>	
				<td style="font-size:10px;">#day11#</td>
				<td style="font-size:10px;">#day12#</td>	
				<td style="font-size:10px;">#day13#</td>
				<td style="font-size:10px;">#day14#</td>	
				<td style="font-size:10px;">#day15#</td>
				<td style="font-size:10px;">#day16#</td>
				<td style="font-size:10px;">#day17#</td>
				<td style="font-size:10px;">#day18#</td>	
				<td style="font-size:10px;">#day19#</td>
				<td style="font-size:10px;">#day20#</td>	
				<td style="font-size:10px;">#day21#</td>
				<td style="font-size:10px;">#day22#</td>	
				<td style="font-size:10px;">#day23#</td>
				<td style="font-size:10px;">#day24#</td>
				<td style="font-size:10px;">#day25#</td>
				<td style="font-size:10px;">#day26#</td>	
				<td style="font-size:10px;">#day27#</td>
				<td style="font-size:10px;">#day28#</td>	
				<td style="font-size:10px;">#day29#</td>
				<td style="font-size:10px;">#day30#</td>	
				<td style="font-size:10px;">#day31#</td>
				<td style="font-size:10px;text-align:center;">#leave#</td>
				<td style="font-size:10px;text-align:center;">#total#</td>
			</tr>
			<cfif day01 is 'I'>
				<cfset CSTday01 = 1 + CSTday01>
				<cfset GTDay01 = 1 + GTDay01>
			</cfif>
			<cfif day02 is 'I'>
				<cfset CSTday02 = 1 + CSTday02>
				<cfset GTDay02 = 1 + GTDay02>
			</cfif>		
			<cfif day03 is 'I'>
				<cfset CSTday03 = 1 + CSTday03>
				<cfset GTDay03 = 1 + GTDay03>
			</cfif>
			<cfif day04 is 'I'>
				<cfset CSTday04 = 1 + CSTday04>
				<cfset GTDay04 = 1 + GTDay04>
			</cfif>
			<cfif day05 is 'I'>
				<cfset CSTday05 = 1 + CSTday05>
				<cfset GTDay05 = 1 + GTDay05>
			</cfif>	

			<cfif day06 is 'I'>
				<cfset CSTday06 = 1 + CSTday06>
				<cfset GTDay06 = 1 + GTDay06>
			</cfif>		
			<cfif day07 is 'I'>
				<cfset CSTday07 = 1 + CSTday07>
				<cfset GTDay07 = 1 + GTDay07>
			</cfif>
			<cfif day08 is 'I'>
				<cfset CSTday08 = 1 + CSTday08>
				<cfset GTDay08 = 1 + GTDay08>
			</cfif>	
			<cfif day09 is 'I'>
				<cfset CSTday09 = 1 + CSTday09>
				<cfset GTDay09 = 1 + GTDay09>
			</cfif>
			<cfif day10 is 'I'>
				<cfset CSTday10 = 1 + CSTday10>
				<cfset GTDay10 = 1 + GTDay10>
			</cfif>		
			<cfif day11 is 'I'>
				<cfset CSTday11 = 1 + CSTday11>
				<cfset GTDay11 = 1 + GTDay11>
			</cfif>
			<cfif day12 is 'I'>
				<cfset CSTday12 = 1 + CSTday12>
				<cfset GTDay12 = 1 + GTDay12>
			</cfif>	
			<cfif day13 is 'I'>
				<cfset CSTday13 = 1 + CSTday13>
				<cfset GTDay13 = 1 + GTDay13>
			</cfif>
			<cfif day14 is 'I'>
				<cfset CSTday14 = 1 + CSTday14>
				<cfset GTDay14 = 1 + GTDay14>
			</cfif>		
			<cfif day15 is 'I'>
				<cfset CSTday15 = 1 + CSTday15>
				<cfset GTDay15 = 1 + GTDay15>
			</cfif>
			<cfif day16 is 'I'>
				<cfset CSTday16 = 1 + CSTday16>
				<cfset GTDay16 = 1 + GTDay16>
			</cfif>		
			<cfif day17 is 'I'>
				<cfset CSTday17 = 1 + CSTday17>
				<cfset GTDay17 = 1 + GTDay17>
			</cfif>
			<cfif day18 is 'I'>
				<cfset CSTday18 = 1 + CSTday18>
				<cfset GTDay18 = 1 + GTDay18>
			</cfif>		
			<cfif day19 is 'I'>
				<cfset CSTday19 = 1 + CSTday19>
				<cfset GTDay19 = 1 + GTDay19>
			</cfif>
			<cfif day20 is 'I'>
				<cfset CSTday20 = 1 + CSTday20>
				<cfset GTDay20= 1 + GTDay20>
			</cfif>	
			<cfif day21 is 'I'>
				<cfset CSTday21 = 1 + CSTday21>
				<cfset GTDay21 = 1 + GTDay21>
			</cfif>
			<cfif day22 is 'I'>
				<cfset CSTday22 = 1 + CSTday22>
				<cfset GTDay22 = 1 + GTDay22>
			</cfif>		
			<cfif day23 is 'I'>
				<cfset CSTday23 = 1 + CSTday23>
				<cfset GTDay23 = 1 + GTDay23>
			</cfif>
			<cfif day24 is 'I'>
				<cfset CSTday24 = 1 + CSTday24>
				<cfset GTDay24 = 1 + GTDay24>
			</cfif>	
			<cfif day25 is 'I'>
				<cfset CSTday25 = 1 + CSTday25>
				<cfset GTDay24 = 1 + GTDay25>
			</cfif>
			<cfif day26 is 'I'>
				<cfset CSTday26 = 1 + CSTday26>
				<cfset GTDay26 = 1 + GTDay26>
			</cfif>		
			<cfif day27 is 'I'>
				<cfset CSTday27 = 1 + CSTday27>
				<cfset GTDay27 = 1 + GTDay27>
			</cfif>
			<cfif day28 is 'I'>
				<cfset CSTday28 = 1 + CSTday28>
				<cfset GTDay28 = 1 + GTDay28>
			</cfif>	
			<cfif day29 is 'I'>
				<cfset CSTday29 = 1 + CSTday29>
				<cfset GTDay29 = 1 + GTDay29>
			</cfif>
			<cfif day30 is 'I'>
				<cfset CSTday30 = 1 + CSTday30>
				<cfset GTDay30 = 1 + GTDay30>
			</cfif>		
			<cfif day31 is 'I'>
				<cfset CSTday31 = 1 + CSTday31>
				<cfset GTDay31 = 1 + GTDay31>
			</cfif>
 				<cfset CSTTotal =   CSTday01 + CSTday02 +CSTday03 +CSTday04 +CSTday05 +CSTday06 +CSTday07 +CSTday08 +CSTday09 +CSTday10 +CSTday11 +CSTday12 +CSTday13 +CSTday14 +CSTday15 +CSTday16 +CSTday17 +CSTday18 +CSTday19 +CSTday20 +CSTday21 +CSTday22 +CSTday23 +CSTday24 +CSTday25 +CSTday26 +CSTday27 +CSTday28 +CSTday29 +CSTday30 +CSTday31>
			 	
<!---  --->			
			<cfif day01 is not 'I' and day01 is not '' and day01 is not ' '>
				<cfset LSTday01 = 1 + LSTday01>
			</cfif>
			<cfif day02 is not 'I' and day02 is not '' and day02 is not ' '>
				<cfset LSTday02 = 1 + LSTday02>
			</cfif>		
			<cfif day04 is not 'I' and day04 is not '' and day04 is not ' '>
				<cfset LSTday04 = 1 + LSTday04>
			</cfif>
			<cfif day05 is not 'I' and day05 is not '' and day05 is not ' '>
				<cfset LSTday05 = 1 + LSTday05>
			</cfif>	
			<cfif day03 is not 'I' and day03 is not '' and day03 is not ' '>
				<cfset LSTday03 = 1 + LSTday03>
			</cfif>
			<cfif day06 is not 'I' and day06 is not '' and day06 is not ' '>
				<cfset LSTday06 = 1 + LSTday06>
			</cfif>		
			<cfif day07 is not 'I' and day07 is not '' and day07 is not ' '>
				<cfset LSTday07 = 1 + LSTday07>
			</cfif>
			<cfif day08 is not 'I' and day08 is not '' and day08 is not ' '>
				<cfset LSTday08 = 1 + LSTday08>
			</cfif>	
			<cfif day09 is not 'I' and day09 is not '' and day09 is not ' '>
				<cfset LSTday09 = 1 + LSTday09>
			</cfif>
			<cfif day10 is not 'I' and day10 is not '' and day10 is not ' '>
				<cfset LSTday10 = 1 + LSTday10>
			</cfif>		
			<cfif day11 is not 'I' and day11 is not '' and day11 is not ' '>
				<cfset LSTday11 = 1 + LSTday11>
			</cfif>
			<cfif day12 is not 'I' and day12 is not '' and day12 is not ' '>
				<cfset LSTday12 = 1 + LSTday12>
			</cfif>	
			<cfif day13 is not 'I' and day13 is not '' and day13 is not ' '>
				<cfset LSTday13 = 1 + LSTday13>
			</cfif>
			<cfif day14 is not 'I' and day14 is not '' and day14 is not ' '>
				<cfset LSTday14 = 1 + LSTday14>
			</cfif>		
			<cfif day15 is not 'I' and day15 is not '' and day15 is not ' '>
				<cfset LSTday15 = 1 + LSTday15>
			</cfif>
			<cfif day16 is not 'I' and day16 is not '' and day16 is not ' '>
				<cfset LSTday16 = 1 + LSTday16>
			</cfif>		
			<cfif day17 is not 'I' and day17 is not '' and day17 is not ' '>
				<cfset LSTday17 = 1 + LSTday17>
			</cfif>
			<cfif day18 is not 'I' and day18 is not '' and day18 is not ' '>
				<cfset LSTday18 = 1 + LSTday18>
			</cfif>		
			<cfif day19 is not 'I' and day19 is not '' and day19 is not ' '>
				<cfset LSTday19 = 1 + LSTday19>
			</cfif>
			<cfif day20 is not 'I' and day20 is not '' and day20 is not ' '>
				<cfset LSTday20 = 1 + LSTday20>
			</cfif>	
			<cfif day21 is not 'I' and day21 is not '' and day21 is not ' '>
				<cfset LSTday21 = 1 + LSTday21>
			</cfif>
			<cfif day22 is not 'I' and day22 is not '' and day22 is not ' '>
				<cfset LSTday22 = 1 + LSTday22>
			</cfif>		
			<cfif day23 is not 'I' and day23 is not '' and day23 is not ' '>
				<cfset LSTday23 = 1 + LSTday23>
			</cfif>
			<cfif day24 is not 'I' and day24 is not '' and day24 is not ' '>
				<cfset LSTday24 = 1 + LSTday24>
			</cfif>	
			<cfif day25 is not 'I' and day25 is not '' and day25 is not ' '>
				<cfset LSTday25 = 1 + LSTday25>
			</cfif>
			<cfif day26 is not 'I' and day26 is not '' and day26 is not ' '>
				<cfset LSTday26 = 1 + LSTday26>
			</cfif>		
			<cfif day27 is not 'I' and day27 is not '' and day27 is not ' '>
				<cfset LSTday27 = 1 + LSTday27>
			</cfif>
			<cfif day28 is not 'I' and day28 is not '' and day28 is not ' '>
				<cfset LSTday028 = 1 + LSTday28>
			</cfif>	
			<cfif day29 is not 'I' and day29 is not '' and day29 is not ' '>
				<cfset LSTday29 = 1 + LSTday29>
			</cfif>
			<cfif day30 is not 'I' and day30 is not '' and day30 is not ' '>
				<cfset LSTday30 = 1 + LSTday30>
			</cfif>		
			<cfif day31 is not 'I' and day31 is not '' and day31 is not ' '>
				<cfset LSTday31 = 1 + LSTday31>
			</cfif>
			 
				<cfset LSTleave =   LSTday01 + LSTday02 +LSTday03 +LSTday04 +LSTday05 +LSTday06 +LSTday07 +LSTday08 +LSTday09 +LSTday10 +LSTday11 +LSTday12 +LSTday13 +LSTday14 +LSTday15 +LSTday16 +LSTday17 +LSTday18 +LSTday19 +LSTday20 +LSTday21 +LSTday22 +LSTday23 +LSTday24 +LSTday25 +LSTday26 +LSTday27 +LSTday28 +LSTday29 +LSTday30 +LSTday31>
			 										
		</cfoutput>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td  style="font-size:10px;font-weight:bold;">Leave Sub-Total</td>
				<td>&nbsp;</td>
				<td style="font-size:10px;">#LSTday01#</td>
				<td style="font-size:10px;">#LSTday02#</td>	
				<td style="font-size:10px;">#LSTday03#</td>
				<td style="font-size:10px;">#LSTday04#</td>	
				<td style="font-size:10px;">#LSTday05#</td>
				<td style="font-size:10px;">#LSTday06#</td>	
				<td style="font-size:10px;">#LSTday07#</td>
				<td style="font-size:10px;">#LSTday08#</td>	
				<td style="font-size:10px;">#LSTday09#</td>
				<td style="font-size:10px;">#LSTday10#</td>	
				<td style="font-size:10px;">#LSTday11#</td>
				<td style="font-size:10px;">#LSTday12#</td>	
				<td style="font-size:10px;">#LSTday13#</td>
				<td style="font-size:10px;">#LSTday14#</td>	
				<td style="font-size:10px;">#LSTday15#</td>
				<td style="font-size:10px;">#LSTday16#</td>
				<td style="font-size:10px;">#LSTday17#</td>
				<td style="font-size:10px;">#LSTday18#</td>	
				<td style="font-size:10px;">#LSTday19#</td>
				<td style="font-size:10px;">#LSTday20#</td>	
				<td style="font-size:10px;">#LSTday21#</td>
				<td style="font-size:10px;">#LSTday22#</td>	
				<td style="font-size:10px;">#LSTday23#</td>
				<td style="font-size:10px;">#LSTday24#</td>
				<td style="font-size:10px;">#LSTday25#</td>
				<td style="font-size:10px;">#LSTday26#</td>	
				<td style="font-size:10px;">#LSTday27#</td>
				<td style="font-size:10px;">#LSTday28#</td>	
				<td style="font-size:10px;">#LSTday29#</td>
				<td style="font-size:10px;">#LSTday30#</td>	
				<td style="font-size:10px;">#LSTday31#</td>
				<td style="font-size:10px;text-align:center;">#LSTleave#</td>
				<td style="font-size:10px;">&nbsp;</td>			
		</tr>
		<tr>
				<td style="font-size:10px;font-weight:bold;">Census Sub-Total</td>
				<td>&nbsp;</td>
				<td style="font-size:10px;">#CSTday01#</td>
				<td style="font-size:10px;">#CSTday02#</td>	
				<td style="font-size:10px;">#CSTday03#</td>
				<td style="font-size:10px;">#CSTday04#</td>	
				<td style="font-size:10px;">#CSTday05#</td>
				<td style="font-size:10px;">#CSTday06#</td>	
				<td style="font-size:10px;">#CSTday07#</td>
				<td style="font-size:10px;">#CSTday08#</td>	
				<td style="font-size:10px;">#CSTday09#</td>
				<td style="font-size:10px;">#CSTday10#</td>	
				<td style="font-size:10px;">#CSTday11#</td>
				<td style="font-size:10px;">#CSTday12#</td>	
				<td style="font-size:10px;">#CSTday13#</td>
				<td style="font-size:10px;">#CSTday14#</td>	
				<td style="font-size:10px;">#CSTday15#</td>
				<td style="font-size:10px;">#CSTday16#</td>
				<td style="font-size:10px;">#CSTday17#</td>
				<td style="font-size:10px;">#CSTday18#</td>	
				<td style="font-size:10px;">#CSTday19#</td>
				<td style="font-size:10px;">#CSTday20#</td>	
				<td style="font-size:10px;">#CSTday21#</td>
				<td style="font-size:10px;">#CSTday22#</td>	
				<td style="font-size:10px;">#CSTday23#</td>
				<td style="font-size:10px;">#CSTday24#</td>
				<td style="font-size:10px;">#CSTday25#</td>
				<td style="font-size:10px;">#CSTday26#</td>	
				<td style="font-size:10px;">#CSTday27#</td>
				<td style="font-size:10px;">#CSTday28#</td>	
				<td style="font-size:10px;">#CSTday29#</td>
				<td style="font-size:10px;">#CSTday30#</td>	
				<td style="font-size:10px;">#CSTday31#</td>
				<td>&nbsp;</td>
				<td style="font-size:10px;text-align:center;">#CSTTotal#</td>			
		</tr>		

		</cfoutput>
 	
		<cfoutput>
		<tr>
			<td>&nbsp;</td>
		</tr>		
		<tr>
				<td style="font-size:10px; font-weight:bold;">Leave Total</td>
				<td>&nbsp;</td>
				<td style="font-size:10px;">#LTDay01#</td>
				<td style="font-size:10px;">#LTDay02#</td>	
				<td style="font-size:10px;">#LTDay03#</td>
				<td style="font-size:10px;">#LTDay04#</td>	
				<td style="font-size:10px;">#LTDay05#</td>
				<td style="font-size:10px;">#LTDay06#</td>	
				<td style="font-size:10px;">#LTDay07#</td>
				<td style="font-size:10px;">#LTDay08#</td>	
				<td style="font-size:10px;">#LTDay09#</td>
				<td style="font-size:10px;">#LTDay10#</td>	
				<td style="font-size:10px;">#LTDay11#</td>
				<td style="font-size:10px;">#LTDay12#</td>	
				<td style="font-size:10px;">#LTDay13#</td>
				<td style="font-size:10px;">#LTDay14#</td>	
				<td style="font-size:10px;">#LTDay15#</td>
				<td style="font-size:10px;">#LTDay16#</td>
				<td style="font-size:10px;">#LTDay17#</td>
				<td style="font-size:10px;">#LTDay18#</td>	
				<td style="font-size:10px;">#LTDay19#</td>
				<td style="font-size:10px;">#LTDay20#</td>	
				<td style="font-size:10px;">#LTDay21#</td>
				<td style="font-size:10px;">#LTDay22#</td>	
				<td style="font-size:10px;">#LTDay23#</td>
				<td style="font-size:10px;">#LTDay24#</td>
				<td style="font-size:10px;">#LTDay25#</td>
				<td style="font-size:10px;">#LTDay26#</td>	
				<td style="font-size:10px;">#LTDay27#</td>
				<td style="font-size:10px;">#LTDay28#</td>	
				<td style="font-size:10px;">#LTDay29#</td>
				<td style="font-size:10px;">#LTDay30#</td>	
				<td style="font-size:10px;">#LTDay31#</td>
				<td style="font-size:10px;text-align:center;">#LSTleave#</td>
				<td>&nbsp;</td>			
		</tr>
	<cfset GTTotal = GTDay01 + GTDay02 + GTDay03 + GTDay04 + GTDay05 + GTDay06 + GTDay07 + GTDay08 + GTDay09 + GTDay10 	
	+GTDay11 + GTDay12 + GTDay13 + GTDay14 + GTDay15 + GTDay16 + GTDay17 + GTDay18 + GTDay19 + GTDay20 
	+ GTDay21 + GTDay22 + GTDay23 + GTDay24 + GTDay25 + GTDay26 + GTDay27 + GTDay28 + GTDay29 + GTDay30 + GTDay31>
		<tr>
				<td  style="font-size:10px;font-weight:bold;">Grand Total</td>
				<td>&nbsp;</td>
				<td style="font-size:10px;">#GTDay01#</td>
				<td style="font-size:10px;">#GTDay02#</td>	
				<td style="font-size:10px;">#GTDay03#</td>
				<td style="font-size:10px;">#GTDay04#</td>	
				<td style="font-size:10px;">#GTDay05#</td>
				<td style="font-size:10px;">#GTDay06#</td>	
				<td style="font-size:10px;">#GTDay07#</td>
				<td style="font-size:10px;">#GTDay08#</td>	
				<td style="font-size:10px;">#GTDay09#</td>
				<td style="font-size:10px;">#GTDay10#</td>	
				<td style="font-size:10px;">#GTDay11#</td>
				<td style="font-size:10px;">#GTDay12#</td>	
				<td style="font-size:10px;">#GTDay13#</td>
				<td style="font-size:10px;">#GTDay14#</td>	
				<td style="font-size:10px;">#GTDay15#</td>
				<td style="font-size:10px;">#GTDay16#</td>
				<td style="font-size:10px;">#GTDay17#</td>
				<td style="font-size:10px;">#GTDay18#</td>	
				<td style="font-size:10px;">#GTDay19#</td>
				<td style="font-size:10px;">#GTDay20#</td>	
				<td style="font-size:10px;">#GTDay21#</td>
				<td style="font-size:10px;">#GTDay22#</td>	
				<td style="font-size:10px;">#GTDay23#</td>
				<td style="font-size:10px;">#GTDay24#</td>
				<td style="font-size:10px;">#GTDay25#</td>
				<td style="font-size:10px;">#GTDay26#</td>	
				<td style="font-size:10px;">#GTDay27#</td>
				<td style="font-size:10px;">#GTDay28#</td>	
				<td style="font-size:10px;">#GTDay29#</td>
				<td style="font-size:10px;">#GTDay30#</td>	
				<td style="font-size:10px;">#GTDay31#</td>
				<td>&nbsp;</td>
				<td style="font-size:10px; text-align:center;">#GTTotal#</td>			
		</tr>		
		</cfoutput>		
 </tbody>
	</table>
	
 	<cfdocumentitem  type="footer" evalAtPrint="true">
		<cfoutput>
			<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>
				<table width="100%" style="border-bottom:1px solid black; border-right:1px solid black; border-left:1px solid black; border-top:1px solid black;">
					<tr>
						<td style=" font-weight:bold; text-align:center">
						H=Hospital Leave, I=In-House, M=Move-In, N=Move-Out, O=Other Leave</td>
					</tr>
				</table>
				<table width="100%">
					<tr>
						<td style="font-size:small; text-align:center; ">
							Enlivant&trade;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Printed: #dateformat(now(), 'mm/dd/yyyy')#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		CensusMonthlyReport.cfm
						</td>
					</tr>
				</table>
			<cfelse>			
				<table width="100%">
					<tr>
						<td style="font-size:small; ">
						Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
						</td>
					</tr>	
				</table>					
			</cfif>
		</cfoutput>	
	</cfdocumentitem>

	<cfoutput>  	
		<cfheader name="Content-Disposition"   
 		value="attachment;filename=MonthlyCensus-#HouseData.cname#-#prompt1#.pdf"> 
	</cfoutput>			

</cfdocument>	
</body>
</html>
