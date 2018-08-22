<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>TIPS4 EFT Fee Maintenance</title>
</head>

	<cfoutput>
		<cfquery name="EFTFeeUpdate" datasource="#application.datasource#">
			UPDATE [TIPS4].[dbo].[EFTFees]
			   SET [iFromDay] = #iFromDay#  
				  ,[iThruDay] =  #iThruDay# 
				  ,[mFeeAmount] = #mFeeAmount# 
			 WHERE iEFTFee_ID = #FeeID#
		</cfquery>
		<cfif ((IsDefined('dropthisone')) and (dropthisone is 'X'))> 
			<cfquery name="EFTFeeUpdate" datasource="#application.datasource#">
				UPDATE [TIPS4].[dbo].[EFTFees]
				   SET dtRowEnd = #CreateODBCDateTime(now())# 
				 WHERE iEFTFee_ID = #FeeID#
			</cfquery>		
		</cfif>	
	</cfoutput>	
  	<cflocation url="dsp_EFTFeeMaintenance.cfm" ADDTOKEN="No"> 			
			
 
