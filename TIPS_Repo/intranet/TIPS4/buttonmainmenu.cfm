<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| Button Main Menu                                                                             |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| mlaw       | 05/02/2006 | Add Flower Box                                                     |
|            |            | Add Census Button                                                  |
| mlaw       | 10/02/2006 | re-arrange Census Button                                           |
| ranklam    | 06/08/2007 | changed assessment tool link                                       |
| ssanapina  | 02/11/2008 | restrict access to cashreciepts.cfm to ar admin group              |
----------------------------------------------------------------------------------------------->

<style>
	.barTD{ padding: 5px 0px 5px 0px;}
	img { margin: -5px -5px -5px -5px; }
</style>

<table border="0" style="width:1%;border-collapse:collapse;border:none;background:transparent;padding:0px;text-align:center;">
	<tr>
		<td class="barTD">
			<a href="/intranet/tips4/mainmenu.cfm">
				<img name="Smainscreen" src="/intranet/tips4/images/FTtipsmainscreen.jpg" border="0"
				alt="TIPS Main Screen" width="65" height="76"
				onMouseOver="src='/intranet/tips4/images/FTtipsmainscreen-over.jpg';"
				onMouseOut="src = '/intranet/tips4/images/FTtipsmainscreen.jpg';">
			</a>
		</td>

		<td class="barTD">
			<a href="/intranet/tips4/Registration/Registration.cfm">
				<img name="Snewapplicant" src="/intranet/tips4/images/FTinquiry.jpg" border="0"
				alt="Inquiry/Move-In" width="65" height="76"
				onMouseOver="src='/intranet/tips4/images/FTinquiry-over.jpg';"
				onMouseOut="src='/intranet/tips4/images/FTinquiry.jpg';">
			</a>
		</td>

		<td class="barTD">
			<a href="/intranet/tips4/Census/Census.cfm">
				<img name="Scensus" src="/intranet/tips4/images/FTcensus.jpg" border="0"
				alt="Census" width="65" height="76"
				onMouseOver="src='/intranet/tips4/images/FTcensus-over.jpg';"
				onMouseOut="src='/intranet/tips4/images/FTcensus.jpg';" />
			</a>
		</td>

		<td class="barTD">
			<a href="/intranet/tips4/Relocate/RelocateTenant.cfm">
				<img name="Srelocate" src="/intranet/tips4/images/FTrelocate.jpg" border="0"
				alt="Relocate Resident" width="65" height="76"
				onMouseOver="src='/intranet/tips4/images/FTrelocate-over.jpg';"
				onMouseOut="src='/intranet/tips4/images/FTrelocate.jpg';">
			</a>
		</td>

		<td class="barTD">
			<a href="/intranet/tips4/Charges/Charges.cfm">
				<img name="Scharges" src="/intranet/tips4/images/FTcharges.jpg" border="0"
				alt="Charges/Credits" width="65" height="76"
				onMouseOver="src='/intranet/tips4/images/FTcharges-over.jpg';"
				onMouseOut="src='/intranet/tips4/images/FTcharges.jpg';">
			</a>
		</td>

		<td class="barTD">
			<a href="/intranet/tips4/RecurringCharges/Recurring.cfm">
				<img name="Srecurringcharges" src="/intranet/tips4/images/FTrecurring.jpg" border="0" alt="Recurring Charges/Credits"
				width="65" height="76"
				onMouseOver="src='/intranet/tips4/images/FTrecurring-over.jpg';"
				onMouseOut="src='/intranet/tips4/images/FTrecurring.jpg';">
			</a>
		</td>

		<td class="barTD">
			<a href="/intranet/tips4/Reports/Menu.cfm">
				<img name="Sreports" src="/intranet/tips4/images/FTreports.jpg" border="0"
				alt="Reports" width="65" height="76"
				onMouseOver="src='/intranet/tips4/images/FTreports-over.jpg';"
				onMouseOut="src='/intranet/tips4/images/FTreports.jpg';">
			</a>
		</td>

		<td class="barTD">
			<a href="/intranet/tips4/Admin/Menu.cfm">
				<img name="Sadministration" src="/intranet/tips4/images/FTadministration.jpg" border="0"
				alt="Administration" width="65" height="76"
				onMouseOver="src='/intranet/tips4/images/FTadministration-over.jpg';"
				onMouseOut="src='/intranet/tips4/images/FTadministration.jpg';">
			</a>
		</td>

		<td class="barTD">
			<a href="/intranet/AssessmentTool_v2/index.cfm" target="_aTool">
				<img name="Sassessment" src="/intranet/tips4/images/FTassessment.jpg" border="0"
				alt="Assessment Tool" width="65" height="76"
				onMouseOver="src='/intranet/tips4/images/FTassessment-over.jpg';"
				onMouseOut="src='/intranet/tips4/images/FTassessment.jpg';">
			</a>
		</td>
	</tr>
</table>