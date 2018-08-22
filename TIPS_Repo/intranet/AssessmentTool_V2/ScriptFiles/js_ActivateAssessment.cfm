<cfoutput>
<script language="javascript">
	function ActivateAssessment(residentType){
		//first get the activebilling date
		var billingActiveDate = document.getElementsByName('activeBillingDate')[0].value;
		// get move in date 		
		var moveInDate = document.getElementById("moveindate").value;		
		// check to make sure move in date is not empty
		if(moveInDate.length == 10){
			//create an array
			dtArray = moveInDate.split("-");
			// check to make sure all three parts are numbers 
			if(!isNaN(dtArray[0]) && !isNaN(dtArray[1]) && !isNaN(dtArray[2])){
				//create a new date				
				var mDt = new Date(dtArray[0],(dtArray[1]-1),dtArray[2]);						
				//check date to make sure its valid
				if(!isNaN(mDt)){
					// compare the two dates.
					if(compareDate(mDt,billingActiveDate) == false){
						//if the moveindate is after the activate date stop process.
						return;
					}
				}
			}
		}

		var numOfDays = DaysBetween(billingActiveDate);
		if(numOfDays >30){
			alert("The Assessment Activate Billing Date has to be within 30 days as of today.");
			window.location=window.location.href(-1);
		}	
		else{	

			//now set a url to redirect to
			if(residentType == 'Tenant')
			{
				var theUrl = 'index.cfm?fuse=activateAssessment&assessmentId=#Assessment.GetId()#&billingActiveDate=' + billingActiveDate;
			}
			else
			{	
				var theUrl = 'index.cfm?fuse=activateAssessmentWithoutBilling&assessmentId=#Assessment.GetId()#&billingActiveDate=' + billingActiveDate;
			}
			window.location = theUrl;			
		}
	}

  

function DaysBetween(date1){
    //today 
	var today = new Date();	
	var chosenDate = new Date(date1);	

	//Get 1 day in milliseconds
	var one_day = 1000*60*60*24;

	//convert both dates to milliseconds
	var date1_ms = chosenDate.getTime();
	var date2_ms = today.getTime();

	//calculate the difference in milliseconds
	var difference_ms = date2_ms - date1_ms;

	//convert back to day
	return Math.round(difference_ms/one_day);
}



function compareDate(date1,date2){	
	// date one is always movein date
	var dtOne = new Date(date1);
	// date two is billing active date 
	var dtTwo = new Date(date2);
	// format the date in mm/dd/yyyy mask
	var dtOneFormatted = (dtOne.getMonth()+1)+"/"+dtOne.getDate()+"/"+dtOne.getFullYear();

	//check if date 1 is after date 2 if so alert the error and stop processing.
	if(dtOne > dtTwo){
		alert("Activate date cannot be before physical move in date\n Physical move in date is: "+ dtOneFormatted);
		return false;
	}
	return true
}
	
</script>
</cfoutput>