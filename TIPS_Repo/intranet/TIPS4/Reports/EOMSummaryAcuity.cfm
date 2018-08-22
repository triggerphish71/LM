<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfparam name="prompt1" default="">
<cfif IsDefined('url.prompt1')and url.prompt1 is not ''>
	<cfset url.prompt1 = '201509'>
<cfelseif  IsDefined('form.prompt1')and form.prompt1 is not ''>
	<cfset form.prompt1 = '201509'>
<cfelse>
	<cfset prompt1 = '201509'>
</cfif>
<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID,H.cName, H.cNumber,h.caddressLine1, h.caddressline2
	, h.ccity, h.cstatecode, h.czipcode
	,h.cPhoneNumber1
	, OA.cNumber as OPS, R.cNumber as Region
	,hl.dtCurrentTipsmonth
	FROM	House H
	Join 	Houselog hl on h.ihouse_id = hl.ihouse_id
	JOIN	OPSArea OA ON OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R ON OA.iRegion_ID = R.iRegion_ID
	WHERE	H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>
<cfoutput>

<cfdump var="#HouseData#" label="HouseData">
<cfquery name="spRentTable" DATASOURCE="#APPLICATION.datasource#">
		EXEC rw.sp_RentTable
			  @iHouse_ID =  #SESSION.qSelectedHouse.iHouse_ID#  , 
			@cPeriod =   '#prompt1#'  
</cfquery>
#prompt1#<br />
</cfoutput>
<body>

<cfset   TwoPerson_0= 0>
<cfset   TwoPerson_1= 0>
<cfset   TwoPerson_2= 0>
<cfset  TwoPerson_3= 0>
<cfset    TwoPerson_4= 0>
<cfset   TwoPerson_5= 0>
<cfset   TwoPerson_6= 0>
<cfset Studio_0= 0> 
<cfset Studio_1= 0>
<cfset Studio_2= 0>
<cfset Studio_3= 0>
<cfset Studio_4= 0>
<cfset Studio_5= 0>
<cfset Studio_6= 0>
<cfset  StudioDeluxe_0= 0>
<cfset  StudioDeluxe_1= 0>
<cfset  StudioDeluxe_2= 0>
<cfset  StudioDeluxe_3= 0>
<cfset  StudioDeluxe_4= 0>
<cfset  StudioDeluxe_5= 0>
<cfset  StudioDeluxe_6= 0>
<cfset  OneB_0= 0> 
<cfset  OneB_1= 0>
<cfset  OneB_2= 0>
<cfset  OneB_3= 0>
<cfset  OneB_4= 0>
<cfset  OneB_5= 0>
<cfset  OneB_6= 0>
<cfset  TwoB_0= 0>
<cfset  TwoB_1= 0>
<cfset  TwoB_2= 0>
<cfset  TwoB_3= 0>
<cfset  TwoB_4= 0>
<cfset  TwoB_5= 0>
<cfset  TwoB_6= 0>
<cfset Deluxe_0= 0>  
<cfset Deluxe_1= 0>
<cfset Deluxe_2= 0>
<cfset Deluxe_3= 0>
<cfset Deluxe_4= 0>
<cfset Deluxe_5= 0>
<cfset Deluxe_6= 0>
<cfset  Alcove_0= 0> 
<cfset  Alcove_1= 0>
<cfset  Alcove_2= 0>
<cfset  Alcove_3= 0>
<cfset Alcove_4= 0>
<cfset Alcove_5= 0>
<cfset Alcove_6= 0>
<cfset  Efficiency_0= 0> 
<cfset  Efficiency_1= 0>
<cfset  Efficiency_2= 0>
<cfset  Efficiency_3= 0>
<cfset  Efficiency_4= 0>
<cfset  Efficiency_5= 0>
<cfset  Efficiency_6= 0>
<cfset  Duplex_0= 0> 
<cfset  Duplex_1= 0>
<cfset  Duplex_2= 0>
<cfset  Duplex_3= 0>
<cfset  Duplex_4= 0>
<cfset  Duplex_5= 0>
<cfset  Duplex_6= 0>
<cfset  HHR_0= 0> 
<cfset  HHR_1= 0>
<cfset  HHR_2= 0>
<cfset  HHR_3= 0>
<cfset  HHR_4= 0>
<cfset  HHR_5= 0>
<cfset  HHR_6= 0>
<cfset  Double_0= 0> 
<cfset  Double_1= 0>
<cfset  Double_2= 0>
<cfset  Double_3= 0>
<cfset  Double_4= 0>
<cfset  Double_5= 0>
<cfset  Double_6= 0>
<cfset  CompanionStudio_0= 0> 
<cfset  CompanionStudio_1= 0>
<cfset  CompanionStudio_2= 0>
<cfset  CompanionStudio_3= 0>
<cfset  CompanionStudio_4= 0>
<cfset  CompanionStudio_5= 0>
<cfset  CompanionStudio_6= 0>
<cfset  CompSD_0= 0> 
<cfset  CompSD_1= 0>
<cfset  CompSD_2= 0>
<cfset  CompSD_3= 0>
<cfset CompSD_4= 0>
<cfset CompSD_5= 0>
<cfset CompSD_6= 0>
<cfset  Comp1BD_0= 0> 
<cfset  Comp1BD_1= 0>
<cfset  Comp1BD_2= 0>
<cfset  Comp1BD_3= 0>
<cfset Comp1BD_4= 0>
<cfset Comp1BD_5= 0>
<cfset Comp1BD_6= 0>
<cfset  Comp2BD_0= 0> 
<cfset  Comp2BD_1= 0>
<cfset  Comp2BD_2= 0>
<cfset  Comp2BD_3= 0>
<cfset Comp2BD_4= 0>
<cfset Comp2BD_5= 0>
<cfset Comp2BD_6= 0>
<cfset  CompDX_0= 0> 
<cfset  CompDX_1= 0>
<cfset  CompDX_2= 0>
<cfset  CompDX_3= 0>
<cfset CompDX_4= 0>
<cfset CompDX_5= 0>
<cfset CompDX_6= 0>
<cfset  CompAL_0= 0> 
<cfset  CompAL_1= 0>
<cfset  CompAL_2= 0>
<cfset  CompAL_3= 0>
<cfset CompAL_4= 0>
<cfset CompAL_5= 0>
<cfset CompAL_6= 0>
<cfset  CompEff_0= 0> 
<cfset  CompEff_1= 0>
<cfset  CompEff_2= 0>
<cfset  CompEff_3= 0>
<cfset CompEff_4= 0>
<cfset CompEff_5= 0>
<cfset CompEff_6= 0>
<cfset  CompDup_0= 0> 
<cfset  CompDup_1= 0>
<cfset  CompDup_2= 0>
<cfset  CompDup_3= 0>
<cfset CompDup_4= 0>
<cfset CompDup_5= 0>
<cfset CompDup_6= 0>
<cfset  CompHHR_0= 0> 
<cfset  CompHHR_1= 0>
<cfset  CompHHR_2= 0>
<cfset  CompHHR_3= 0>
<cfset CompHHR_4= 0>
<cfset CompHHR_5= 0>
<cfset CompHHR_6= 0>
<cfset  CompDbl_0= 0> 
<cfset  CompDbl_1= 0>
<cfset  CompDbl_2= 0>
<cfset  CompDbl_3= 0>
<cfset CompDbl_4= 0>
<cfset CompDbl_5= 0>
<cfset CompDbl_6= 0>
<cfset  OneBedDeluxe_0= 0> 
<cfset  OneBedDeluxe_1= 0>
<cfset  OneBedDeluxe_2= 0>
<cfset  OneBedDeluxe_3= 0>
<cfset OneBedDeluxe_4= 0>
<cfset OneBedDeluxe_5= 0>
<cfset OneBedDeluxe_6= 0>
<cfset  TwoBedRoomDeluxe_0= 0> 
<cfset  TwoBedRoomDeluxe_1= 0>
<cfset  TwoBedRoomDeluxe_2= 0>
<cfset  TwoBedRoomDeluxe_3= 0>
<cfset TwoBedRoomDeluxe_4= 0>
<cfset TwoBedRoomDeluxe_5= 0>
<cfset TwoBedRoomDeluxe_6= 0>
<cfset  StudioSuite_0= 0> 
<cfset  StudioSuite_1= 0>
<cfset  StudioSuite_2= 0>
<cfset  StudioSuite_3= 0>
<cfset  StudioSuite_4= 0>
<cfset  StudioSuite_5= 0>
<cfset  StudioSuite_6= 0>
<cfset  StudioKitchen_0= 0> 
<cfset  StudioKitchen_1= 0>
<cfset  StudioKitchen_2= 0>
<cfset  StudioKitchen_3= 0>
<cfset  StudioKitchen_4= 0>
<cfset  StudioKitchen_5= 0>
<cfset  StudioKitchen_6= 0>
<cfset  County_0= 0> 
<cfset  County_1= 0>
<cfset  County_2= 0>
<cfset  County_3= 0>
<cfset  County_4= 0>
<cfset  County_5= 0>
<cfset  County_6= 0>
<cfset  TwoBedTwoBath_0= 0> 
<cfset  TwoBedTwoBath_1= 0>
<cfset  TwoBedTwoBath_2= 0>
<cfset  TwoBedTwoBath_3= 0>
<cfset  TwoBedTwoBath_4= 0>
<cfset  TwoBedTwoBath_5= 0>
<cfset  TwoBedTwoBath_6= 0>
<cfset  TwoBedTwoBathDeluxe_0= 0> 
<cfset  TwoBedTwoBathDeluxe_1= 0>
<cfset  TwoBedTwoBathDeluxe_2= 0>
<cfset  TwoBedTwoBathDeluxe_3= 0>
<cfset  TwoBedTwoBathDeluxe_4= 0>
<cfset  TwoBedTwoBathDeluxe_5= 0>
<cfset  TwoBedTwoBathDeluxe_6= 0>
<cfset  OneBedroomAddition_0= 0> 
<cfset  OneBedroomAddition_1= 0>
<cfset  OneBedroomAddition_2= 0>
<cfset  OneBedroomAddition_3= 0>
<cfset  OneBedroomAddition_4= 0>
<cfset  OneBedroomAddition_5= 0>
<cfset  OneBedroomAddition_6= 0>
<cfset  OneBedroomALA_0= 0> 
<cfset  OneBedroomALA_1= 0>
<cfset  OneBedroomALA_2= 0>
<cfset  OneBedroomALA_3= 0>
<cfset  OneBedroomALA_4= 0>
<cfset  OneBedroomALA_5= 0>
<cfset  OneBedroomALA_6= 0>
<cfset  OneBedroomALB_0= 0>
<cfset  OneBedroomALB_1= 0>
<cfset  OneBedroomALB_2= 0>
<cfset  OneBedroomALB_3= 0>
<cfset  OneBedroomALB_4= 0>
<cfset  OneBedroomALB_5= 0>
<cfset  OneBedroomALB_6= 0>
<cfset  OneBedroomALC_0= 0>
<cfset  OneBedroomALC_1= 0>
<cfset  OneBedroomALC_2= 0>
<cfset  OneBedroomALC_3= 0>
<cfset  OneBedroomALC_4= 0>
<cfset  OneBedroomALC_5= 0>
<cfset  OneBedroomALC_6= 0>
<cfset  OneBedroomALD_0= 0>
<cfset  OneBedroomALD_1= 0>
<cfset  OneBedroomALD_2= 0>
<cfset  OneBedroomALD_3= 0>
<cfset  OneBedroomALD_4= 0>
<cfset  OneBedroomALD_5= 0>
<cfset  OneBedroomALD_6= 0>
<cfset  OneBedroomALE_0= 0>
<cfset  OneBedroomALE_1= 0>
<cfset  OneBedroomALE_2= 0>
<cfset  OneBedroomALE_3= 0>
<cfset  OneBedroomALE_4= 0>
<cfset  OneBedroomALE_5= 0>
<cfset  OneBedroomALE_6= 0>
<cfset  OneBedroomILA_0= 0> 
<cfset  OneBedroomILA_1= 0>
<cfset  OneBedroomILA_2= 0>
<cfset  OneBedroomILA_3= 0>
<cfset  OneBedroomILA_4= 0>
<cfset  OneBedroomILA_5= 0>
<cfset  OneBedroomILA_6= 0>
<cfset  OneBedroomILB_0= 0> 
<cfset  OneBedroomILB_1= 0>
<cfset  OneBedroomILB_2= 0>
<cfset  OneBedroomILB_3= 0>
<cfset  OneBedroomILB_4= 0>
<cfset  OneBedroomILB_5= 0>
<cfset  OneBedroomILB_6= 0>
<cfset  OneBedroomILC_0= 0>
<cfset  OneBedroomILC_1= 0>
<cfset  OneBedroomILC_2= 0>
<cfset  OneBedroomILC_3= 0>
<cfset  OneBedroomILC_4= 0>
<cfset  OneBedroomILC_5= 0>
<cfset  OneBedroomILC_6= 0>
<cfset  OneBedroomILD_0= 0>
<cfset  OneBedroomILD_1= 0>
<cfset  OneBedroomILD_2= 0>
<cfset  OneBedroomILD_3= 0>
<cfset  OneBedroomILD_4= 0>
<cfset  OneBedroomILD_5= 0>
<cfset  OneBedroomILD_6= 0>
<cfset  OneBedroomILE_0= 0>
<cfset  OneBedroomILE_1= 0>
<cfset  OneBedroomILE_2= 0>
<cfset  OneBedroomILE_3= 0>
<cfset  OneBedroomILE_4= 0>
<cfset  OneBedroomILE_5= 0>
<cfset  OneBedroomILE_6= 0>
<cfset  StudioALA_0= 0>
<cfset  StudioALA_1= 0>
<cfset  StudioALA_2= 0>
<cfset  StudioALA_3= 0>
<cfset  StudioALA_4= 0>
<cfset  StudioALA_5= 0>
<cfset  StudioALA_6= 0>
<cfset  StudioALB_0= 0>
<cfset  StudioALB_1= 0>
<cfset  StudioALB_2= 0>
<cfset  StudioALB_3= 0>
<cfset  StudioALB_4= 0>
<cfset  StudioALB_5= 0>
<cfset  StudioALB_6= 0>
<cfset  StudioALC_0= 0> 
<cfset  StudioALC_1= 0>
<cfset  StudioALC_2= 0>
<cfset  StudioALC_3= 0>
<cfset  StudioALC_4= 0>
<cfset  StudioALC_5= 0>
<cfset  StudioALC_6= 0>
<cfset  StudioILA_0= 0>
<cfset  StudioILA_1= 0>
<cfset  StudioILA_2= 0>
<cfset  StudioILA_3= 0>
<cfset  StudioILA_4= 0>
<cfset  StudioILA_5= 0>
<cfset  StudioILA_6= 0>
<cfset  TwoBedroomALA_0= 0>
<cfset  TwoBedroomALA_1= 0>
<cfset  TwoBedroomALA_2= 0>
<cfset  TwoBedroomALA_3= 0>
<cfset  TwoBedroomALA_4= 0>
<cfset  TwoBedroomALA_5= 0>
<cfset  TwoBedroomALA_6= 0>
<cfset  TwoBedroomALB_0= 0>
<cfset  TwoBedroomALB_1= 0>
<cfset  TwoBedroomALB_2= 0>
<cfset  TwoBedroomALB_3= 0>
<cfset  TwoBedroomALB_4= 0>
<cfset  TwoBedroomALB_5= 0>
<cfset  TwoBedroomALB_6= 0>
<cfset  TwoBedroomILA_0= 0>
<cfset  TwoBedroomILA_1= 0>
<cfset  TwoBedroomILA_2= 0>
<cfset  TwoBedroomILA_3= 0>
<cfset  TwoBedroomILA_4= 0>
<cfset  TwoBedroomILA_5= 0>
<cfset  TwoBedroomILA_6= 0>
<cfset  TwoBedroomILB_0= 0>
<cfset  TwoBedroomILB_1= 0>
<cfset  TwoBedroomILB_2= 0>
<cfset  TwoBedroomILB_3= 0>
<cfset  TwoBedroomILB_4= 0>
<cfset  TwoBedroomILB_5= 0>
<cfset  TwoBedroomILB_6= 0>
<cfset  ILStudio_0= 0> 
<cfset  ILStudio_1= 0>
<cfset  ILStudio_2= 0>
<cfset  ILStudio_3= 0>
<cfset  ILStudio_4= 0>
<cfset  ILStudio_5= 0>
<cfset  ILStudio_6= 0>
<cfset ILOneBedroom_0 = 0> 
<cfset ILOneBedroom_1= 0>
<cfset ILOneBedroom_2= 0>
<cfset ILOneBedroom_3= 0>
<cfset ILOneBedroom_4= 0>
<cfset ILOneBedroom_5= 0>
<cfset ILOneBedroom_6= 0>
<cfset  ILTwoBedroom_0= 0> 
<cfset  ILTwoBedroom_1= 0>
<cfset  ILTwoBedroom_2= 0>
<cfset  ILTwoBedroom_3= 0>
<cfset  ILTwoBedroom_4= 0>
<cfset  ILTwoBedroom_5= 0>
<cfset  ILTwoBedroom_6= 0>
<cfset IL2BedroomDlx_0= 0> 
<cfset IL2BedroomDlx_1= 0>
<cfset IL2BedroomDlx_2= 0>
<cfset IL2BedroomDlx_3= 0>
<cfset IL2BedroomDlx_4= 0>
<cfset IL2BedroomDlx_5= 0>
<cfset IL2BedroomDlx_6= 0>
<cfset IL2BedroomDlxComb_0 = 0> 
<cfset IL2BedroomDlxComb_1= 0>
<cfset IL2BedroomDlxComb_2= 0>
<cfset IL2BedroomDlxComb_3= 0>
<cfset IL2BedroomDlxComb_4= 0>
<cfset IL2BedroomDlxComb_5= 0>
<cfset IL2BedroomDlxComb_6= 0>
<cfset IL1BedroomC_0= 0> 
<cfset IL1BedroomC_1= 0>
<cfset IL1BedroomC_2= 0>
<cfset IL1BedroomC_3= 0>
<cfset IL1BedroomC_4= 0>
<cfset IL1BedroomC_5= 0>
<cfset IL1BedroomC_6= 0>
<cfset IL1BedroomDlxC_0= 0> 
<cfset IL1BedroomDlxC_1= 0>
<cfset IL1BedroomDlxC_2= 0>
<cfset IL1BedroomDlxC_3= 0>
<cfset IL1BedroomDlxC_4= 0>
<cfset IL1BedroomDlxC_5= 0>
<cfset IL1BedroomDlxC_6= 0>
<cfset IL2BedroomC_0= 0> 
<cfset IL2BedroomC_1= 0>
<cfset IL2BedroomC_2= 0>
<cfset IL2BedroomC_3= 0>
<cfset IL2BedroomC_4= 0>
<cfset IL2BedroomC_5= 0>
<cfset IL2BedroomC_6= 0>
<cfset  IL2BedroomDlxC_0= 0> 
<cfset  IL2BedroomDlxC_1= 0>
<cfset  IL2BedroomDlxC_2= 0>
<cfset  IL2BedroomDlxC_3= 0>
<cfset  IL2BedroomDlxC_4= 0>
<cfset  IL2BedroomDlxC_5= 0>
<cfset  IL2BedroomDlxC_6= 0>
<cfset  ILInvest1Bedroom_0= 0> 
<cfset  ILInvest1Bedroom_1= 0>
<cfset  ILInvest1Bedroom_2= 0>
<cfset  ILInvest1Bedroom_3= 0>
<cfset  ILInvest1Bedroom_4= 0>
<cfset  ILInvest1Bedroom_5= 0>
<cfset  ILInvest1Bedroom_6= 0>
<cfset  ILInvest2Bedroom_0= 0> 
<cfset  ILInvest2Bedroom_1= 0>
<cfset  ILInvest2Bedroom_2= 0>
<cfset  ILInvest2Bedroom_3= 0>
<cfset  ILInvest2Bedroom_4= 0>
<cfset  ILInvest2Bedroom_5= 0>
<cfset  ILInvest2Bedroom_6= 0>
<cfset  ILInvest2BedroomDlx_0= 0> 
<cfset  ILInvest2BedroomDlx_1= 0>
<cfset  ILInvest2BedroomDlx_2= 0>
<cfset  ILInvest2BedroomDlx_3= 0>
<cfset  ILInvest2BedroomDlx_4= 0>
<cfset  ILInvest2BedroomDlx_5= 0>
<cfset  ILInvest2BedroomDlx_6= 0>
<cfset  ILInvest2BedroomLux_0= 0> 
<cfset  ILInvest2BedroomLux_1= 0>
<cfset  ILInvest2BedroomLux_2= 0>
<cfset  ILInvest2BedroomLux_3= 0>
<cfset  ILInvest2BedroomLux_4= 0>
<cfset  ILInvest2BedroomLux_5= 0>
<cfset  ILInvest2BedroomLux_6= 0>
<cfset  StudioPrem_0= 0> 
<cfset  StudioPrem_1= 0>
<cfset  StudioPrem_2= 0>
<cfset  StudioPrem_3= 0>
<cfset  StudioPrem_4= 0>
<cfset  StudioPrem_5= 0>
<cfset  StudioPrem_6= 0>
<cfset  OneBedroomPrem_0= 0> 
<cfset  OneBedroomPrem_1= 0>

<cfset  OneBedroomPrem_2= 0>

<cfset  OneBedroomPrem_3= 0>

<cfset  OneBedroomPrem_4= 0>

<cfset  OneBedroomPrem_5= 0>

<cfset  OneBedroomPrem_6= 0>

<cfset  TwoBedroomPrem_0= 0> 

<cfset  TwoBedroomPrem_1= 0>

<cfset  TwoBedroomPrem_2= 0>

<cfset  TwoBedroomPrem_3= 0>

<cfset  TwoBedroomPrem_4= 0>

<cfset  TwoBedroomPrem_5= 0>

<cfset  TwoBedroomPrem_6= 0>

<cfset  Comp1BedroomDlx_0= 0> 

<cfset  Comp1BedroomDlx_1= 0>

<cfset  Comp1BedroomDlx_2= 0>

<cfset  Comp1BedroomDlx_3= 0>

<cfset  Comp1BedroomDlx_4= 0>

<cfset  Comp1BedroomDlx_5= 0>

<cfset  Comp1BedroomDlx_6= 0>

<cfset  Comp2BedroomDlx_0= 0> 

<cfset  Comp2BedroomDlx_1= 0>

<cfset  Comp2BedroomDlx_2= 0>

<cfset  Comp2BedroomDlx_3= 0>

<cfset  Comp2BedroomDlx_4= 0>

<cfset  Comp2BedroomDlx_5= 0>

<cfset  Comp2BedroomDlx_6= 0>

<cfset  Comp2BedroomALA_0= 0> 

<cfset  Comp2BedroomALA_1= 0>

<cfset  Comp2BedroomALA_2= 0>

<cfset  Comp2BedroomALA_3= 0>

<cfset  Comp2BedroomALA_4= 0>

<cfset  Comp2BedroomALA_5= 0>

<cfset  Comp2BedroomALA_6= 0>

<cfset  OneBedroomPremPlus_0= 0> 

<cfset  OneBedroomPremPlus_1= 0>

<cfset  OneBedroomPremPlus_2= 0>

<cfset  OneBedroomPremPlus_3= 0>

<cfset  OneBedroomPremPlus_4= 0>

<cfset  OneBedroomPremPlus_5= 0>

<cfset  OneBedroomPremPlus_6= 0>

<cfset  OneBedroomPremPlus_0= 0> 

<cfset  OneBedroomPremPlus_1= 0>

<cfset  OneBedroomPremPlus_2= 0>

<cfset  OneBedroomPremPlus_3= 0>

<cfset  OneBedroomPremPlus_4= 0>

<cfset  OneBedroomPremPlus_5= 0>

<cfset  OneBedroomPremPlus_6= 0>

<cfset  CompStudioPrem_0= 0> 

<cfset  CompStudioPrem_1= 0>

<cfset  CompStudioPrem_2= 0>

<cfset  CompStudioPrem_3= 0>

<cfset  CompStudioPrem_4= 0>

<cfset  CompStudioPrem_5= 0>

<cfset  CompStudioPrem_6= 0>

<cfset  CompStudioPrem_0= 0> 

<cfset  CompStudioPrem_1= 0>

<cfset  CompStudioPrem_2= 0>

<cfset  CompStudioPrem_3= 0>

<cfset  CompStudioPrem_4= 0>

<cfset  CompStudioPrem_5= 0>

<cfset  CompStudioPrem_6= 0>

<cfset  ILStudioPrem_0= 0> 

<cfset  ILStudioPrem_1= 0>

<cfset  ILStudioPrem_2= 0>

<cfset  ILStudioPrem_3= 0>

<cfset  ILStudioPrem_4= 0>

<cfset  ILStudioPrem_5= 0>

<cfset  ILStudioPrem_6= 0>

<cfset  IL1BedroomPrem_0= 0> 

<cfset  IL1BedroomPrem_1= 0>

<cfset  IL1BedroomPrem_2= 0>

<cfset  IL1BedroomPrem_3= 0>

<cfset  IL1BedroomPrem_4= 0>

<cfset  IL1BedroomPrem_5= 0>

<cfset  IL1BedroomPrem_6= 0>

<cfset  IL2BedroomPrem_0= 0> 

<cfset  IL2BedroomPrem_1= 0>

<cfset  IL2BedroomPrem_2= 0>

<cfset  IL2BedroomPrem_3= 0>

<cfset  IL2BedroomPrem_4= 0>

<cfset  IL2BedroomPrem_5= 0>

<cfset  IL2BedroomPrem_6= 0>

<cfset  Comp2BedroomPrem_0= 0> 

<cfset  Comp2BedroomPrem_1= 0>

<cfset  Comp2BedroomPrem_2= 0>

<cfset  Comp2BedroomPrem_3= 0>

<cfset  Comp2BedroomPrem_4= 0>

<cfset  Comp2BedroomPrem_5= 0>

<cfset  Comp2BedroomPrem_6= 0>

<cfset  MCStudio_0= 0> 

<cfset  MCStudio_1= 0>

<cfset  MCStudio_2= 0>

<cfset  MCStudio_3= 0>

<cfset  MCStudio_4= 0>

<cfset  MCStudio_5= 0>

<cfset  MCStudio_6= 0>

<cfset  MCStudioDlx_0= 0> 

<cfset  MCStudioDlx_1= 0>

<cfset  MCStudioDlx_2= 0>

<cfset  MCStudioDlx_3= 0>

<cfset  MCStudioDlx_4= 0>

<cfset  MCStudioDlx_5= 0>

<cfset  MCStudioDlx_6= 0>

<cfset  MCCompStudio_0= 0> 

<cfset  MCCompStudio_1= 0>

<cfset  MCCompStudio_2= 0>

<cfset  MCCompStudio_3= 0>

<cfset  MCCompStudio_4= 0>

<cfset  MCCompStudio_5= 0>

<cfset  MCCompStudio_6= 0>

<cfset  MCCompStudioDlx_0= 0> 

<cfset  MCCompStudioDlx_1= 0>

<cfset  MCCompStudioDlx_2= 0>

<cfset  MCCompStudioDlx_3= 0>

<cfset  MCCompStudioDlx_4= 0>

<cfset  MCCompStudioDlx_5= 0>

<cfset  MCCompStudioDlx_6= 0>

<cfset  MCOneBedroom_0= 0> 

<cfset  MCOneBedroom_1= 0>

<cfset  MCOneBedroom_2= 0>

<cfset  MCOneBedroom_3= 0>

<cfset  MCOneBedroom_4= 0>

<cfset  MCOneBedroom_5= 0>

<cfset  MCOneBedroom_6= 0>

<cfset  MCCompanionOneBedroom_0= 0> 

<cfset  MCCompanionOneBedroom_1= 0>

<cfset  MCCompanionOneBedroom_2= 0>

<cfset  MCCompanionOneBedroom_3= 0>

<cfset  MCCompanionOneBedroom_4= 0>

<cfset  MCCompanionOneBedroom_5= 0>

<cfset  MCCompanionOneBedroom_6= 0>

<cfset  MCTwoBedroom_0= 0> 

<cfset  MCTwoBedroom_1= 0>

<cfset  MCTwoBedroom_2= 0>

<cfset  MCTwoBedroom_3= 0>

<cfset  MCTwoBedroom_4= 0>

<cfset  MCTwoBedroom_5= 0>

<cfset  MCTwoBedroom_6= 0>

<cfset  MCCompanionTwoBedroom_0= 0> 

<cfset  MCCompanionTwoBedroom_1= 0>

<cfset  MCCompanionTwoBedroom_2= 0>

<cfset  MCCompanionTwoBedroom_3= 0>

<cfset  MCCompanionTwoBedroom_4= 0>

<cfset  MCCompanionTwoBedroom_5= 0>

<cfset  MCCompanionTwoBedroom_6= 0>

<!--- <!--- <!--- <!--- <!--- <!--- <!--- <!--- <!--- <!--- <!---  ---> ---> ---> ---> ---> ---> ---> ---> ---> ---> --->
<cfoutput>
<cfquery  name="qryRentTable" datasource="spRentTable">
select * from spRentTable where acuity in (0,1,2,3,4,5,6)
</cfquery>

<cfloop query="spRentTable">

<!--- @TwoPerson_0 --->
<cfif Acuity is '0' and iOccupancyPosition is 2>
<cfset   TwoPerson_0 = TotalRent>TwoPerson_0
</cfif>
<!--- @TwoPerson_1 --->
<cfif Acuity is '1' and iOccupancyPosition is 2>
<cfset   TwoPerson_1 = TotalRent>
</cfif>
<!--- @TwoPerson_2 --->
<cfif Acuity is '2' and iOccupancyPosition is 2>
<cfset   TwoPerson_2 = TotalRent>
</cfif>
<!--- @TwoPerson_3 --->
<cfif Acuity is '3' and iOccupancyPosition is 2>
<cfset  TwoPerson_3 = TotalRent>
</cfif>
<!--- @TwoPerson_4 --->
<cfif Acuity is '4' and iOccupancyPosition is 2>
<cfset    TwoPerson_4 = TotalRent>
</cfif>
<!--- @TwoPerson_5 --->
<cfif Acuity is '5' and iOccupancyPosition is 2>
<cfset   TwoPerson_5 = TotalRent>
</cfif>
<!--- @TwoPerson_6 --->
<cfif Acuity is '6' and iOccupancyPosition is 2>
<cfset   TwoPerson_6 = TotalRent>
</cfif>	

<!--- @Studio_0 --->
<cfif  iAptType_ID is 1 and Acuity is '0' and iOccupancyPosition is 1>
      <cfset Studio_0 = TotalRent>Studio_0
</cfif>

<!--- @Studio_1 --->
<cfif iAptType_ID is 1 and Acuity is '1' and iOccupancyPosition is 1>
<cfset Studio_1 = TotalRent>
</cfif>

<!--- @Studio_2 --->
<cfif  iAptType_ID is 1 and Acuity is '2' and iOccupancyPosition is 1>
<cfset Studio_2 = TotalRent>
</cfif>

<!--- @Studio_3 --->
<cfif  iAptType_ID is 1 and Acuity is '3' and iOccupancyPosition is 1>
<cfset Studio_3 = TotalRent>
</cfif>

<!--- @Studio_4 --->
<cfif  iAptType_ID is 1 and Acuity is '4' and iOccupancyPosition is 1 >
<cfset Studio_4 = TotalRent>
</cfif>

<!--- @Studio_5 --->
<cfif  iAptType_ID is 1 and Acuity is '5' and iOccupancyPosition is 1>
<cfset Studio_5 = TotalRent>
</cfif>
 
<!--- @Studio_6 --->
<cfif  iAptType_ID is 1 and Acuity is '6' and iOccupancyPosition is 1>
<cfset Studio_6 = TotalRent>
</cfif>

<!--- @StudioDeluxe_0 --->
<cfif iAptType_ID  is 2 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  StudioDeluxe_0    =   TotalRent >StudioDeluxe_0
</cfif>
<!--- @StudioDeluxe_1 --->
<cfif iAptType_ID  is 2 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  StudioDeluxe_1    =   TotalRent >
</cfif>
<!--- @StudioDeluxe_2 --->
<cfif iAptType_ID  is 2 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  StudioDeluxe_2    =   TotalRent >
</cfif>
<!--- @StudioDeluxe_3 --->
<cfif iAptType_ID  is 2 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  StudioDeluxe_3    =   TotalRent >
</cfif>
<!--- @StudioDeluxe_4 --->
<cfif iAptType_ID  is 2 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  StudioDeluxe_4    =   TotalRent >
</cfif>
<!--- @StudioDeluxe_5 --->
<cfif iAptType_ID  is 2 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  StudioDeluxe_5    =   TotalRent >
</cfif>
<!--- @StudioDeluxe_6 --->
<cfif iAptType_ID  is 2 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  StudioDeluxe_6    =   TotalRent >
</cfif>


<!--- @OneB_0 --->
<cfif iAptType_ID  is 3 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneB_0    =   TotalRent >OneB_0
</cfif>
<!--- @OneB_1 --->
<cfif iAptType_ID  is 3 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneB_1    =   TotalRent >
</cfif>
<!--- @OneB_2 --->
<cfif iAptType_ID  is 3 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneB_2    =   TotalRent >
</cfif>
<!--- @OneB_3 --->
<cfif iAptType_ID  is 3 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneB_3    =   TotalRent >
</cfif>
<!--- @OneB_4 --->
<cfif iAptType_ID  is 3 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneB_4    =   TotalRent >
</cfif>
<!--- @OneB_5 --->
<cfif iAptType_ID  is 3 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneB_5    =   TotalRent >
</cfif>
<!--- @OneB_6 --->
<cfif iAptType_ID  is 3 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneB_6    =   TotalRent >
</cfif>

<!--- @TwoB_0 --->
<cfif iAptType_ID  is 4 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  TwoB_0    =   TotalRent >TwoB_0
</cfif>
<!--- @TwoB_1 --->
<cfif iAptType_ID  is 4 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  TwoB_1    =   TotalRent >
</cfif>
<!--- @TwoB_2 --->
<cfif iAptType_ID  is 4 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  TwoB_2    =   TotalRent >
</cfif>
<!--- @TwoB_3 --->
<cfif iAptType_ID  is 4 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  TwoB_3    =   TotalRent >
</cfif>
<!--- @TwoB_4 --->
<cfif iAptType_ID  is 4 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  TwoB_4    =   TotalRent >
</cfif>
<!--- @TwoB_5 --->
<cfif iAptType_ID  is 4 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  TwoB_5    =   TotalRent >
</cfif>
<!--- @TwoB_6 --->
<cfif iAptType_ID  is 4 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  TwoB_6    =   TotalRent >
</cfif>

<!--- @Deluxe_0 --->
<cfif iAptType_ID is 5 and  Acuity  is '0' and  iOccupancyPosition is 1>
<cfset Deluxe_0 = TotalRent >Deluxe_0 
</cfif>
<!--- @Deluxe_1 --->
<cfif iAptType_ID is 5 and  Acuity  is '1' and  iOccupancyPosition is 1>
<cfset Deluxe_1 = TotalRent >
</cfif>
<!--- @Deluxe_2 --->
<cfif iAptType_ID is 5 and  Acuity  is '2' and  iOccupancyPosition is 1>
<cfset Deluxe_2 = TotalRent >
</cfif>
<!--- @Deluxe_3 --->
<cfif iAptType_ID is 5 and  Acuity  is '3' and  iOccupancyPosition is 1>
<cfset Deluxe_3 = TotalRent >
</cfif>
<!--- @Deluxe_4 --->
<cfif iAptType_ID is 5 and  Acuity  is '4' and  iOccupancyPosition is 1>
<cfset Deluxe_4 = TotalRent >
</cfif>
<!--- @Deluxe_5 --->
<cfif iAptType_ID is 5 and  Acuity  is '5' and  iOccupancyPosition is 1>
<cfset Deluxe_5 = TotalRent >
</cfif>
<!--- @Deluxe_6 --->
<cfif iAptType_ID is 5 and  Acuity  is '6' and  iOccupancyPosition is 1>
<cfset Deluxe_6 = TotalRent >
</cfif>

<!--- @Alcove_0 --->
<cfif iAptType_ID  is 6 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  Alcove_0    =   TotalRent > 
</cfif>
<!--- @Alcove_1 --->
<cfif iAptType_ID  is 6 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  Alcove_1    =   TotalRent >
</cfif>
<!--- @Alcove_2 --->
<cfif iAptType_ID  is 6 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  Alcove_2    =   TotalRent >
</cfif>
<!--- @Alcove_3 --->
<cfif iAptType_ID  is 6 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  Alcove_3    =   TotalRent >
</cfif>
<!--- @Alcove_4 --->
<cfif iAptType_ID  is 6 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset Alcove_4 =   TotalRent >
</cfif>
<!--- @Alcove_5 --->
<cfif iAptType_ID  is 6 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset Alcove_5  =   TotalRent >
</cfif>
<!--- @Alcove_6 --->
<cfif iAptType_ID  is 6 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset Alcove_6  =   TotalRent >
</cfif>

<!--- @Efficiency_0 --->
<cfif iAptType_ID  is 8 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  Efficiency_0    =   TotalRent >Efficiency_0
</cfif>
<!--- @Efficiency_1 --->
<cfif iAptType_ID  is 8 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  Efficiency_1    =   TotalRent >
</cfif>
<!--- @Efficiency_2 --->
<cfif iAptType_ID  is 8 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  Efficiency_2    =   TotalRent >
</cfif>
<!--- @Efficiency_3 --->
<cfif iAptType_ID  is 8 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  Efficiency_3    =   TotalRent >
</cfif>
<!--- @Efficiency_4 --->
<cfif iAptType_ID  is 8 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  Efficiency_4    =   TotalRent >
</cfif>
<!--- @Efficiency_5 --->
<cfif iAptType_ID  is 8 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  Efficiency_5    =   TotalRent >
</cfif>
<!--- @Efficiency_6 --->
<cfif iAptType_ID  is 8 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  Efficiency_6    =   TotalRent >
</cfif>
<!--- @Duplex_0 --->
<cfif iAptType_ID  is 9 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  Duplex_0    =   TotalRent >Duplex_0
</cfif>
<!--- @Duplex_1 --->
<cfif iAptType_ID  is 9 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  Duplex_1    =   TotalRent >
</cfif>
<!--- @Duplex_2 --->
<cfif iAptType_ID  is 9 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  Duplex_2    =   TotalRent >
</cfif>
<!--- @Duplex_3 --->
<cfif iAptType_ID  is 9 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  Duplex_3    =   TotalRent >
</cfif>
<!--- @Duplex_4 --->
<cfif iAptType_ID  is 9 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  Duplex_4    =   TotalRent >
</cfif>
<!--- @Duplex_5 --->
<cfif iAptType_ID  is 9 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  Duplex_5    =   TotalRent >
</cfif>
<!--- @Duplex_6 --->
<cfif iAptType_ID  is 9 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  Duplex_6    =   TotalRent >
</cfif>




<!--- @HHR_0 --->
<cfif iAptType_ID  is 11 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  HHR_0    =   TotalRent >One BedroomILE_0
</cfif>
<!--- @HHR_1 --->
<cfif iAptType_ID  is 11 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  HHR_1    =   TotalRent >
</cfif>
<!--- @HHR_2 --->
<cfif iAptType_ID  is 11 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  HHR_2    =   TotalRent >
</cfif>
<!--- @HHR_3 --->
<cfif iAptType_ID  is 11 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  HHR_3    =   TotalRent >
</cfif>
<!--- @HHR_4 --->
<cfif iAptType_ID  is 11 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  HHR_4    =   TotalRent >
</cfif>
<!--- @HHR_5 --->
<cfif iAptType_ID  is 11 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  HHR_5    =   TotalRent >
</cfif>
<!--- @HHR_6 --->
<cfif iAptType_ID  is 11 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  HHR_6    =   TotalRent >
</cfif>

<!--- @Double_0 --->
<cfif iAptType_ID  is 14 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  Double_0    =   TotalRent > 
</cfif>
<!--- @Double_1 --->
<cfif iAptType_ID  is 14 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  Double_1    =   TotalRent >
</cfif>
<!--- @Double_2 --->
<cfif iAptType_ID  is 14 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  Double_2    =   TotalRent >
</cfif>
<!--- @Double_3 --->
<cfif iAptType_ID  is 14 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  Double_3    =   TotalRent >
</cfif>
<!--- @Double_4 --->
<cfif iAptType_ID  is 14 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  Double_4    =   TotalRent >
</cfif>
<!--- @Double_5 --->
<cfif iAptType_ID  is 14 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  Double_5    =   TotalRent >
</cfif>
<!--- @Double_6 --->
<cfif iAptType_ID  is 14 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  Double_6    =   TotalRent >
</cfif>

<!--- @CompanionStudio_0 --->
<cfif iAptType_ID  is 16 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  CompanionStudio_0    =   TotalRent > 
</cfif>
<!--- @CompanionStudio_1 --->
<cfif iAptType_ID  is 16 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  CompanionStudio_1    =   TotalRent >
</cfif>
<!--- @CompanionStudio_2 --->
<cfif iAptType_ID  is 16 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  CompanionStudio_2    =   TotalRent >
</cfif>
<!--- @CompanionStudio_3 --->
<cfif iAptType_ID  is 16 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  CompanionStudio_3    =   TotalRent >
</cfif>
<!--- @CompanionStudio_4 --->
<cfif iAptType_ID  is 16 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  CompanionStudio_4    =   TotalRent >
</cfif>
<!--- @CompanionStudio_5 --->
<cfif iAptType_ID  is 16 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  CompanionStudio_5    =   TotalRent >
</cfif>
<!--- @CompanionStudio_6 --->
<cfif iAptType_ID  is 16 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  CompanionStudio_6    =   TotalRent >
</cfif>

<!--- @CompSD_0 --->
<cfif iAptType_ID  is 18 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  CompSD_0    =   TotalRent > 
</cfif>
<!--- @CompSD_1 --->
<cfif iAptType_ID  is 18 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  CompSD_1    =   TotalRent >
</cfif>
<!--- @CompSD_2 --->
<cfif iAptType_ID  is 18 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  CompSD_2    =   TotalRent >
</cfif>
<!--- @CompSD_3 --->
<cfif iAptType_ID  is 18 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  CompSD_3    =   TotalRent >
</cfif>
<!--- @CompSD_4 --->
<cfif iAptType_ID  is 18 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset CompSD_4 =   TotalRent >
</cfif>
<!--- @CompSD_5 --->
<cfif iAptType_ID  is 18 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset CompSD_5  =   TotalRent >
</cfif>
<!--- @CompSD_6 --->
<cfif iAptType_ID  is 18 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset CompSD_6  =   TotalRent >
</cfif>

<!--- @Comp1BD_0 --->
<cfif iAptType_ID  is 20 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  Comp1BD_0    =   TotalRent > 
</cfif>
<!--- @Comp1BD_1 --->
<cfif iAptType_ID  is 20 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  Comp1BD_1    =   TotalRent >
</cfif>
<!--- @Comp1BD_2 --->
<cfif iAptType_ID  is 20 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  Comp1BD_2    =   TotalRent >
</cfif>
<!--- @Comp1BD_3 --->
<cfif iAptType_ID  is 20 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  Comp1BD_3    =   TotalRent >
</cfif>
<!--- @Comp1BD_4 --->
<cfif iAptType_ID  is 20 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset Comp1BD_4 =   TotalRent >
</cfif>
<!--- @Comp1BD_5 --->
<cfif iAptType_ID  is 20 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset Comp1BD_5  =   TotalRent >
</cfif>
<!--- @Comp1BD_6 --->
<cfif iAptType_ID  is 20 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset Comp1BD_6  =   TotalRent >
</cfif>

<!--- @Comp2BD_0 --->
<cfif iAptType_ID  is 22 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  Comp2BD_0    =   TotalRent > 
</cfif>
<!--- @Comp2BD_1 --->
<cfif iAptType_ID  is 22 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  Comp2BD_1    =   TotalRent >
</cfif>
<!--- @Comp2BD_2 --->
<cfif iAptType_ID  is 22 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  Comp2BD_2    =   TotalRent >
</cfif>
<!--- @Comp2BD_3 --->
<cfif iAptType_ID  is 22 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  Comp2BD_3    =   TotalRent >
</cfif>
<!--- @Comp2BD_4 --->
<cfif iAptType_ID  is 22 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset Comp2BD_4 =   TotalRent >
</cfif>
<!--- @Comp2BD_5 --->
<cfif iAptType_ID  is 22 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset Comp2BD_5  =   TotalRent >
</cfif>
<!--- @Comp2BD_6 --->
<cfif iAptType_ID  is 22 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset Comp2BD_6  =   TotalRent >
</cfif>

<!--- @CompDX_0 --->
<cfif iAptType_ID  is 24 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  CompDX_0    =   TotalRent > 
</cfif>
<!--- @CompDX_1 --->
<cfif iAptType_ID  is 24 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  CompDX_1    =   TotalRent >
</cfif>
<!--- @CompDX_2 --->
<cfif iAptType_ID  is 24 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  CompDX_2    =   TotalRent >
</cfif>
<!--- @CompDX_3 --->
<cfif iAptType_ID  is 24 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  CompDX_3    =   TotalRent >
</cfif>
<!--- @CompDX_4 --->
<cfif iAptType_ID  is 24 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset CompDX_4 =   TotalRent >
</cfif>
<!--- @CompDX_5 --->
<cfif iAptType_ID  is 24 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset CompDX_5  =   TotalRent >
</cfif>
<!--- @CompDX_6 --->
<cfif iAptType_ID  is 24 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset CompDX_6  =   TotalRent >
</cfif>

<!--- @CompAL_0 --->
<cfif iAptType_ID  is 26 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  CompAL_0    =   TotalRent > 
</cfif>
<!--- @CompAL_1 --->
<cfif iAptType_ID  is 26 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  CompAL_1    =   TotalRent >
</cfif>
<!--- @CompAL_2 --->
<cfif iAptType_ID  is 26 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  CompAL_2    =   TotalRent >
</cfif>
<!--- @CompAL_3 --->
<cfif iAptType_ID  is 26 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  CompAL_3    =   TotalRent >
</cfif>
<!--- @CompAL_4 --->
<cfif iAptType_ID  is 26 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset CompAL_4 =   TotalRent >
</cfif>
<!--- @CompAL_5 --->
<cfif iAptType_ID  is 26 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset CompAL_5  =   TotalRent >
</cfif>
<!--- @CompAL_6 --->
<cfif iAptType_ID  is 26 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset CompAL_6  =   TotalRent >
</cfif>

<!--- @CompEff_0 --->
<cfif iAptType_ID  is 27 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  CompEff_0    =   TotalRent > 
</cfif>
<!--- @CompEff_1 --->
<cfif iAptType_ID  is 27 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  CompEff_1    =   TotalRent >
</cfif>
<!--- @CompEff_2 --->
<cfif iAptType_ID  is 27 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  CompEff_2    =   TotalRent >
</cfif>
<!--- @CompEff_3 --->
<cfif iAptType_ID  is 27 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  CompEff_3    =   TotalRent >
</cfif>
<!--- @CompEff_4 --->
<cfif iAptType_ID  is 27 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset CompEff_4 =   TotalRent >
</cfif>
<!--- @CompEff_5 --->
<cfif iAptType_ID  is 27 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset CompEff_5  =   TotalRent >
</cfif>
<!--- @CompEff_6 --->
<cfif iAptType_ID  is 27 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset CompEff_6  =   TotalRent >
</cfif>

<!--- @CompDup_0 --->
<cfif iAptType_ID  is 28 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  CompDup_0    =   TotalRent > 
</cfif>
<!--- @CompDup_1 --->
<cfif iAptType_ID  is 28 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  CompDup_1    =   TotalRent >
</cfif>
<!--- @CompDup_2 --->
<cfif iAptType_ID  is 28 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  CompDup_2    =   TotalRent >
</cfif>
<!--- @CompDup_3 --->
<cfif iAptType_ID  is 28 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  CompDup_3    =   TotalRent >
</cfif>
<!--- @CompDup_4 --->
<cfif iAptType_ID  is 28 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset CompDup_4 =   TotalRent >
</cfif>
<!--- @CompDup_5 --->
<cfif iAptType_ID  is 28 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset CompDup_5  =   TotalRent >
</cfif>
<!--- @CompDup_6 --->
<cfif iAptType_ID  is 28 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset CompDup_6  =   TotalRent >
</cfif>


<!--- @CompHHR_0 --->
<cfif iAptType_ID  is 29 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  CompHHR_0    =   TotalRent > 
</cfif>
<!--- @CompHHR_1 --->
<cfif iAptType_ID  is 29 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  CompHHR_1    =   TotalRent >
</cfif>
<!--- @CompHHR_2 --->
<cfif iAptType_ID  is 29 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  CompHHR_2    =   TotalRent >
</cfif>
<!--- @CompHHR_3 --->
<cfif iAptType_ID  is 29 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  CompHHR_3    =   TotalRent >
</cfif>
<!--- @CompHHR_4 --->
<cfif iAptType_ID  is 29 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset CompHHR_4 =   TotalRent >
</cfif>
<!--- @CompHHR_5 --->
<cfif iAptType_ID  is 29 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset CompHHR_5  =   TotalRent >
</cfif>
<!--- @CompHHR_6 --->
<cfif iAptType_ID  is 29 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset CompHHR_6  =   TotalRent >
</cfif>


<!--- @CompDbl_0 --->
<cfif iAptType_ID  is 30 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  CompDbl_0    =   TotalRent > 
</cfif>
<!--- @CompDbl_1 --->
<cfif iAptType_ID  is 30 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  CompDbl_1    =   TotalRent >
</cfif>
<!--- @CompDbl_2 --->
<cfif iAptType_ID  is 30 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  CompDbl_2    =   TotalRent >
</cfif>
<!--- @CompDbl_3 --->
<cfif iAptType_ID  is 30 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  CompDbl_3    =   TotalRent >
</cfif>
<!--- @CompDbl_4 --->
<cfif iAptType_ID  is 30 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset CompDbl_4 =   TotalRent >
</cfif>
<!--- @CompDbl_5 --->
<cfif iAptType_ID  is 30 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset CompDbl_5  =   TotalRent >
</cfif>
<!--- @CompDbl_6 --->
<cfif iAptType_ID  is 30 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset CompDbl_6  =   TotalRent >
</cfif>

<!--- @OneBedDeluxe_0 --->
<cfif iAptType_ID  is 31 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedDeluxe_0    =   TotalRent > 
</cfif>
<!--- @OneBedDeluxe_1 --->
<cfif iAptType_ID  is 31 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedDeluxe_1    =   TotalRent >
</cfif>
<!--- @OneBedDeluxe_2 --->
<cfif iAptType_ID  is 31 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedDeluxe_2    =   TotalRent >
</cfif>
<!--- @OneBedDeluxe_3 --->
<cfif iAptType_ID  is 31 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedDeluxe_3    =   TotalRent >
</cfif>
<!--- @OneBedDeluxe_4 --->
<cfif iAptType_ID  is 31 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset OneBedDeluxe_4 =   TotalRent >
</cfif>
<!--- @OneBedDeluxe_5 --->
<cfif iAptType_ID  is 31 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset OneBedDeluxe_5  =   TotalRent >
</cfif>
<!--- @OneBedDeluxe_6 --->
<cfif iAptType_ID  is 31 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset OneBedDeluxe_6  =   TotalRent >
</cfif>


<!--- @TwoBedRoomDeluxe_0 --->
<cfif iAptType_ID  is 32 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  TwoBedRoomDeluxe_0    =   TotalRent > 
</cfif>
<!--- @TwoBedRoomDeluxe_1 --->
<cfif iAptType_ID  is 32 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  TwoBedRoomDeluxe_1    =   TotalRent >
</cfif>
<!--- @TwoBedRoomDeluxe_2 --->
<cfif iAptType_ID  is 32 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  TwoBedRoomDeluxe_2    =   TotalRent >
</cfif>
<!--- @TwoBedRoomDeluxe_3 --->
<cfif iAptType_ID  is 32 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  TwoBedRoomDeluxe_3    =   TotalRent >
</cfif>
<!--- @TwoBedRoomDeluxe_4 --->
<cfif iAptType_ID  is 32 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset TwoBedRoomDeluxe_4 =   TotalRent >
</cfif>
<!--- @TwoBedRoomDeluxe_5 --->
<cfif iAptType_ID  is 32 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset TwoBedRoomDeluxe_5  =   TotalRent >
</cfif>
<!--- @TwoBedRoomDeluxe_6 --->
<cfif iAptType_ID  is 32 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset TwoBedRoomDeluxe_6  =   TotalRent >
</cfif>


<!--- @StudioSuite_0 --->
<cfif iAptType_ID  is 33 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  StudioSuite_0    =   TotalRent > 
</cfif>
<!--- @StudioSuite_1 --->
<cfif iAptType_ID  is 33 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  StudioSuite_1    =   TotalRent >
</cfif>
<!--- @StudioSuite_2 --->
<cfif iAptType_ID  is 33 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  StudioSuite_2    =   TotalRent >
</cfif>
<!--- @StudioSuite_3 --->
<cfif iAptType_ID  is 33 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  StudioSuite_3    =   TotalRent >
</cfif>
<!--- @StudioSuite_4 --->
<cfif iAptType_ID  is 33 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  StudioSuite_4    =   TotalRent >
</cfif>
<!--- @StudioSuite_5 --->
<cfif iAptType_ID  is 33 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  StudioSuite_5    =   TotalRent >
</cfif>
<!--- @StudioSuite_6 --->
<cfif iAptType_ID  is 33 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  StudioSuite_6    =   TotalRent >
</cfif>

<!--- @StudioKitchen_0 --->
<cfif iAptType_ID  is 33 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  StudioKitchen_0    =   TotalRent > 
</cfif>
<!--- @StudioKitchen_1 --->
<cfif iAptType_ID  is 33 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  StudioKitchen_1    =   TotalRent >
</cfif>
<!--- @StudioKitchen_2 --->
<cfif iAptType_ID  is 33 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  StudioKitchen_2    =   TotalRent >
</cfif>
<!--- @StudioKitchen_3 --->
<cfif iAptType_ID  is 33 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  StudioKitchen_3    =   TotalRent >
</cfif>
<!--- @StudioKitchen_4 --->
<cfif iAptType_ID  is 33 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  StudioKitchen_4    =   TotalRent >
</cfif>
<!--- @StudioKitchen_5 --->
<cfif iAptType_ID  is 33 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  StudioKitchen_5    =   TotalRent >
</cfif>
<!--- @StudioKitchen_6 --->
<cfif iAptType_ID  is 33 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  StudioKitchen_6    =   TotalRent >
</cfif>
<!--- @County_0 --->
<cfif iAptType_ID  is 35 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  County_0    =   TotalRent > 
</cfif>
<!--- @County_1 --->
<cfif iAptType_ID  is 35 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  County_1    =   TotalRent >
</cfif>
<!--- @County_2 --->
<cfif iAptType_ID  is 35 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  County_2    =   TotalRent >
</cfif>
<!--- @County_3 --->
<cfif iAptType_ID  is 35 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  County_3    =   TotalRent >
</cfif>
<!--- @County_4 --->
<cfif iAptType_ID  is 35 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  County_4    =   TotalRent >
</cfif>
<!--- @County_5 --->
<cfif iAptType_ID  is 35 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  County_5    =   TotalRent >
</cfif>
<!--- @County_6 --->
<cfif iAptType_ID  is 35 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  County_6    =   TotalRent >
</cfif>
 
<!--- @TwoBedTwoBath_0 --->
<cfif iAptType_ID  is 36 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBath_0    =   TotalRent > 
</cfif>
<!--- @TwoBedTwoBath_1 --->
<cfif iAptType_ID  is 36 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBath_1    =   TotalRent >
</cfif>
<!--- @TwoBedTwoBath_2 --->
<cfif iAptType_ID  is 36 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBath_2    =   TotalRent >
</cfif>
<!--- @TwoBedTwoBath_3 --->
<cfif iAptType_ID  is 36 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBath_3    =   TotalRent >
</cfif>
<!--- @TwoBedTwoBath_4 --->
<cfif iAptType_ID  is 36 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBath_4    =   TotalRent >
</cfif>
<!--- @TwoBedTwoBath_5 --->
<cfif iAptType_ID  is 36 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBath_5    =   TotalRent >
</cfif>
<!--- @TwoBedTwoBath_6 --->
<cfif iAptType_ID  is 36 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBath_6    =   TotalRent >
</cfif>

 
<!--- @TwoBedTwoBathDeluxe_0 --->
<cfif iAptType_ID  is 37 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBathDeluxe_0    =   TotalRent > 
</cfif>
<!--- @TwoBedTwoBathDeluxe_1 --->
<cfif iAptType_ID  is 37 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBathDeluxe_1    =   TotalRent >
</cfif>
<!--- @TwoBedTwoBathDeluxe_2 --->
<cfif iAptType_ID  is 37 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBathDeluxe_2    =   TotalRent >
</cfif>
<!--- @TwoBedTwoBathDeluxe_3 --->
<cfif iAptType_ID  is 37 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBathDeluxe_3    =   TotalRent >
</cfif>
<!--- @TwoBedTwoBathDeluxe_4 --->
<cfif iAptType_ID  is 37 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBathDeluxe_4    =   TotalRent >
</cfif>
<!--- @TwoBedTwoBathDeluxe_5 --->
<cfif iAptType_ID  is 37 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBathDeluxe_5    =   TotalRent >
</cfif>
<!--- @TwoBedTwoBathDeluxe_6 --->
<cfif iAptType_ID  is 37 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  TwoBedTwoBathDeluxe_6    =   TotalRent >
</cfif>

<!--- @OneBedroomAddition_0 --->
<cfif iAptType_ID  is 38 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomAddition_0    =   TotalRent > 
</cfif>
<!--- @OneBedroomAddition_1 --->
<cfif iAptType_ID  is 38 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomAddition_1    =   TotalRent >
</cfif>
<!--- @OneBedroomAddition_2 --->
<cfif iAptType_ID  is 38 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomAddition_2    =   TotalRent >
</cfif>
<!--- @OneBedroomAddition_3 --->
<cfif iAptType_ID  is 38 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomAddition_3    =   TotalRent >
</cfif>
<!--- @OneBedroomAddition_4 --->
<cfif iAptType_ID  is 38 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomAddition_4    =   TotalRent >
</cfif>
<!--- @OneBedroomAddition_5 --->
<cfif iAptType_ID  is 38 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomAddition_5    =   TotalRent >
</cfif>
<!--- @OneBedroomAddition_6 --->
<cfif iAptType_ID  is 38 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomAddition_6    =   TotalRent >
</cfif>


<!--- @OneBedroomALA_0 --->
<cfif iAptType_ID  is 40 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomALA_0    =   TotalRent > 
</cfif>
<!--- @OneBedroomALA_1 --->
<cfif iAptType_ID  is 40 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomALA_1    =   TotalRent >
</cfif>
<!--- @OneBedroomALA_2 --->
<cfif iAptType_ID  is 40 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomALA_2    =   TotalRent >
</cfif>
<!--- @OneBedroomALA_3 --->
<cfif iAptType_ID  is 40 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomALA_3    =   TotalRent >
</cfif>
<!--- @OneBedroomALA_4 --->
<cfif iAptType_ID  is 40 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomALA_4    =   TotalRent >
</cfif>
<!--- @OneBedroomALA_5 --->
<cfif iAptType_ID  is 40 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomALA_5    =   TotalRent >
</cfif>
<!--- @OneBedroomALA_6 --->
<cfif iAptType_ID  is 40 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomALA_6    =   TotalRent >
</cfif>

<!--- @One BedroomALB_0 --->
<cfif iAptType_ID  is 41 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomALB_0    =   TotalRent >OneBedroomALB_0
</cfif>
<!--- @One BedroomALB_1 --->
<cfif iAptType_ID  is 41 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomALB_1    =   TotalRent >
</cfif>
<!--- @One BedroomALB_2 --->
<cfif iAptType_ID  is 41 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomALB_2    =   TotalRent >
</cfif>
<!--- @One BedroomALB_3 --->
<cfif iAptType_ID  is 41 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomALB_3    =   TotalRent >
</cfif>
<!--- @One BedroomALB_4 --->
<cfif iAptType_ID  is 41 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomALB_4    =   TotalRent >
</cfif>
<!--- @One BedroomALB_5 --->
<cfif iAptType_ID  is 41 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomALB_5    =   TotalRent >
</cfif>
<!--- @One BedroomALB_41 --->
<cfif iAptType_ID  is 41 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomALB_6    =   TotalRent >
</cfif>

<!--- @OneBedroomALC_0 --->
<cfif iAptType_ID  is 42 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomALC_0    =   TotalRent >OneBedroomALC_0
</cfif>
<!--- @OneBedroomALC_1 --->
<cfif iAptType_ID  is 42 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomALC_1    =   TotalRent >
</cfif>
<!--- @OneBedroomALC_2 --->
<cfif iAptType_ID  is 42 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomALC_2    =   TotalRent >
</cfif>
<!--- @OneBedroomALC_3 --->
<cfif iAptType_ID  is 42 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomALC_3    =   TotalRent >
</cfif>
<!--- @OneBedroomALC_4 --->
<cfif iAptType_ID  is 42 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomALC_4    =   TotalRent >
</cfif>
<!--- @OneBedroomALC_5 --->
<cfif iAptType_ID  is 42 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomALC_5    =   TotalRent >
</cfif>
<!--- @OneBedroomALC_41 --->
<cfif iAptType_ID  is 42 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomALC_6    =   TotalRent >
</cfif>

<!--- @OneBedroomALD_0 --->
<cfif iAptType_ID  is 43 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomALD_0    =   TotalRent >OneBedroomALD_0
</cfif>
<!--- @OneBedroomALD_1 --->
<cfif iAptType_ID  is 43 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomALD_1    =   TotalRent >
</cfif>
<!--- @OneBedroomALD_2 --->
<cfif iAptType_ID  is 43 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomALD_2    =   TotalRent >
</cfif>
<!--- @OneBedroomALD_3 --->
<cfif iAptType_ID  is 43 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomALD_3    =   TotalRent >
</cfif>
<!--- @OneBedroomALD_4 --->
<cfif iAptType_ID  is 43 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomALD_4    =   TotalRent >
</cfif>
<!--- @OneBedroomALD_5 --->
<cfif iAptType_ID  is 43 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomALD_5    =   TotalRent >
</cfif>
<!--- @OneBedroomALD_41 --->
<cfif iAptType_ID  is 43 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomALD_6    =   TotalRent >
</cfif>

<!--- @OneBedroomALE_0 --->
<cfif iAptType_ID  is 44 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomALE_0    =   TotalRent >OneBedroomALE_0
</cfif>
<!--- @OneBedroomALE_1 --->
<cfif iAptType_ID  is 44 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomALE_1    =   TotalRent >
</cfif>
<!--- @OneBedroomALE_2 --->
<cfif iAptType_ID  is 44 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomALE_2    =   TotalRent >
</cfif>
<!--- @OneBedroomALE_3 --->
<cfif iAptType_ID  is 44 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomALE_3    =   TotalRent >
</cfif>
<!--- @OneBedroomALE_4 --->
<cfif iAptType_ID  is 44 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomALE_4    =   TotalRent >
</cfif>
<!--- @OneBedroomALE_5 --->
<cfif iAptType_ID  is 44 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomALE_5    =   TotalRent >
</cfif>
<!--- @OneBedroomALE_41 --->
<cfif iAptType_ID  is 44 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomALE_6    =   TotalRent >
</cfif>

<!--- @OneBedroomILA_0 --->
<cfif iAptType_ID  is 45 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomILA_0    =   TotalRent > 
</cfif>
<!--- @OneBedroomILA_1 --->
<cfif iAptType_ID  is 45 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomILA_1    =   TotalRent >
</cfif>
<!--- @OneBedroomILA_2 --->
<cfif iAptType_ID  is 45 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomILA_2    =   TotalRent >
</cfif>
<!--- @OneBedroomILA_3 --->
<cfif iAptType_ID  is 45 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomILA_3    =   TotalRent >
</cfif>
<!--- @OneBedroomILA_4 --->
<cfif iAptType_ID  is 45 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomILA_4    =   TotalRent >
</cfif>
<!--- @OneBedroomILA_5 --->
<cfif iAptType_ID  is 45 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomILA_5    =   TotalRent >
</cfif>
<!--- @OneBedroomILA_6 --->
<cfif iAptType_ID  is 45 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomILA_6    =   TotalRent >
</cfif>

<!--- @OneBedroomILB_0 --->
<cfif iAptType_ID  is 46 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomILB_0    =   TotalRent > 
</cfif>
<!--- @OneBedroomILB_1 --->
<cfif iAptType_ID  is 46 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomILB_1    =   TotalRent >
</cfif>
<!--- @OneBedroomILB_2 --->
<cfif iAptType_ID  is 46 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomILB_2    =   TotalRent >
</cfif>
<!--- @OneBedroomILB_3 --->
<cfif iAptType_ID  is 46 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomILB_3    =   TotalRent >
</cfif>
<!--- @OneBedroomILB_4 --->
<cfif iAptType_ID  is 46 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomILB_4    =   TotalRent >
</cfif>
<!--- @OneBedroomILB_5 --->
<cfif iAptType_ID  is 46 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomILB_5    =   TotalRent >
</cfif>
<!--- @OneBedroomILB_6 --->
<cfif iAptType_ID  is 46 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomILB_6    =   TotalRent >
</cfif>

<!--- @OneBedroomALE_0 --->
<cfif iAptType_ID  is 47 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomILC_0    =   TotalRent >One BedroomILC_0
</cfif>
<!--- @One BedroomILC_1 --->
<cfif iAptType_ID  is 47 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomILC_1    =   TotalRent >
</cfif>
<!--- @One BedroomILC_2 --->
<cfif iAptType_ID  is 47 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomILC_2    =   TotalRent >
</cfif>
<!--- @One BedroomILC_3 --->
<cfif iAptType_ID  is 47 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomILC_3    =   TotalRent >
</cfif>
<!--- @One BedroomILC_4 --->
<cfif iAptType_ID  is 47 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomILC_4    =   TotalRent >
</cfif>
<!--- @One BedroomILC_5 --->
<cfif iAptType_ID  is 47 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomILC_5    =   TotalRent >
</cfif>
<!--- @One BedroomILC_41 --->
<cfif iAptType_ID  is 47 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomILC_6    =   TotalRent >
</cfif>

<!--- @OneBedroomILD_0 --->
<cfif iAptType_ID  is 48 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomILD_0    =   TotalRent >One BedroomILD_0
</cfif>
<!--- @One BedroomILD_1 --->
<cfif iAptType_ID  is 48 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomILD_1    =   TotalRent >
</cfif>
<!--- @One BedroomILD_2 --->
<cfif iAptType_ID  is 48 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomILD_2    =   TotalRent >
</cfif>
<!--- @One BedroomILD_3 --->
<cfif iAptType_ID  is 48 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomILD_3    =   TotalRent >
</cfif>
<!--- @One BedroomILD_4 --->
<cfif iAptType_ID  is 48 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomILD_4    =   TotalRent >
</cfif>
<!--- @One BedroomILD_5 --->
<cfif iAptType_ID  is 48 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomILD_5    =   TotalRent >
</cfif>
<!--- @One BedroomILD_41 --->
<cfif iAptType_ID  is 48 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomILD_6    =   TotalRent >
</cfif>

<!--- @OneBedroomILE_0 --->
<cfif iAptType_ID  is 49 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomILE_0    =   TotalRent >One BedroomILE_0
</cfif>
<!--- @One BedroomILE_1 --->
<cfif iAptType_ID  is 49 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomILE_1    =   TotalRent >
</cfif>
<!--- @One BedroomILE_2 --->
<cfif iAptType_ID  is 49 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomILE_2    =   TotalRent >
</cfif>
<!--- @One BedroomILE_3 --->
<cfif iAptType_ID  is 49 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomILE_3    =   TotalRent >
</cfif>
<!--- @One BedroomILE_4 --->
<cfif iAptType_ID  is 49 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomILE_4    =   TotalRent >
</cfif>
<!--- @One BedroomILE_5 --->
<cfif iAptType_ID  is 49 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomILE_5    =   TotalRent >
</cfif>
<!--- @One BedroomILE_6 --->
<cfif iAptType_ID  is 49 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomILE_6    =   TotalRent >
</cfif>

<!--- @StudioALA_0 --->
<cfif iAptType_ID  is 50 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  StudioALA_0    =   TotalRent >One BedroomILE_0
</cfif>
<!--- @StudioALA_1 --->
<cfif iAptType_ID  is 50 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  StudioALA_1    =   TotalRent >
</cfif>
<!--- @StudioALA_2 --->
<cfif iAptType_ID  is 50 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  StudioALA_2    =   TotalRent >
</cfif>
<!--- @StudioALA_3 --->
<cfif iAptType_ID  is 50 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  StudioALA_3    =   TotalRent >
</cfif>
<!--- @StudioALA_4 --->
<cfif iAptType_ID  is 50 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  StudioALA_4    =   TotalRent >
</cfif>
<!--- @StudioALA_5 --->
<cfif iAptType_ID  is 50 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  StudioALA_5    =   TotalRent >
</cfif>
<!--- @StudioALA_6 --->
<cfif iAptType_ID  is 50 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  StudioALA_6    =   TotalRent >
</cfif>


<!--- @StudioALB_0 --->
<cfif iAptType_ID  is 51 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  StudioALB_0    =   TotalRent >One BedroomILE_0
</cfif>
<!--- @StudioALB_1 --->
<cfif iAptType_ID  is 51 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  StudioALB_1    =   TotalRent >
</cfif>
<!--- @StudioALB_2 --->
<cfif iAptType_ID  is 51 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  StudioALB_2    =   TotalRent >
</cfif>
<!--- @StudioALB_3 --->
<cfif iAptType_ID  is 51 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  StudioALB_3    =   TotalRent >
</cfif>
<!--- @StudioALB_4 --->
<cfif iAptType_ID  is 51 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  StudioALB_4    =   TotalRent >
</cfif>
<!--- @StudioALB_5 --->
<cfif iAptType_ID  is 51 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  StudioALB_5    =   TotalRent >
</cfif>
<!--- @StudioALB_6 --->
<cfif iAptType_ID  is 51 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  StudioALB_6    =   TotalRent >
</cfif>

<!--- @StudioALC_0 --->
<cfif iAptType_ID  is 52 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  StudioALC_0    =   TotalRent > 
</cfif>
<!--- @StudioALC_1 --->
<cfif iAptType_ID  is 52 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  StudioALC_1    =   TotalRent >
</cfif>
<!--- @StudioALC_2 --->
<cfif iAptType_ID  is 52 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  StudioALC_2    =   TotalRent >
</cfif>
<!--- @StudioALC_3 --->
<cfif iAptType_ID  is 52 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  StudioALC_3    =   TotalRent >
</cfif>
<!--- @StudioALC_4 --->
<cfif iAptType_ID  is 52 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  StudioALC_4    =   TotalRent >
</cfif>
<!--- @StudioALC_5 --->
<cfif iAptType_ID  is 52 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  StudioALC_5    =   TotalRent >
</cfif>
<!--- @StudioALC_6 --->
<cfif iAptType_ID  is 52 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  StudioALC_6    =   TotalRent >
</cfif>

<!--- @StudioILA_0 --->
<cfif iAptType_ID  is 53 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  StudioILA_0    =   TotalRent >One BedroomILE_0
</cfif>
<!--- @StudioILA_1 --->
<cfif iAptType_ID  is 53 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  StudioILA_1    =   TotalRent >
</cfif>
<!--- @StudioILA_2 --->
<cfif iAptType_ID  is 53 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  StudioILA_2    =   TotalRent >
</cfif>
<!--- @StudioILA_3 --->
<cfif iAptType_ID  is 53 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  StudioILA_3    =   TotalRent >
</cfif>
<!--- @StudioILA_4 --->
<cfif iAptType_ID  is 53 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  StudioILA_4    =   TotalRent >
</cfif>
<!--- @StudioILA_5 --->
<cfif iAptType_ID  is 53 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  StudioILA_5    =   TotalRent >
</cfif>
<!--- @StudioILA_6 --->
<cfif iAptType_ID  is 53 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  StudioILA_6    =   TotalRent >
</cfif>


<!--- @TwoBedroomALA_0 --->
<cfif iAptType_ID  is 54 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALA_0    =   TotalRent >One BedroomILE_0
</cfif>
<!--- @TwoBedroomALA_1 --->
<cfif iAptType_ID  is 54 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALA_1    =   TotalRent >
</cfif>
<!--- @TwoBedroomALA_2 --->
<cfif iAptType_ID  is 54 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALA_2    =   TotalRent >
</cfif>
<!--- @TwoBedroomALA_3 --->
<cfif iAptType_ID  is 54 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALA_3    =   TotalRent >
</cfif>
<!--- @TwoBedroomALA_4 --->
<cfif iAptType_ID  is 54 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALA_4    =   TotalRent >
</cfif>
<!--- @TwoBedroomALA_5 --->
<cfif iAptType_ID  is 54 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALA_5    =   TotalRent >
</cfif>
<!--- @TwoBedroomALA_6 --->
<cfif iAptType_ID  is 54 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALA_6    =   TotalRent >
</cfif>

<!--- @TwoBedroomALB_0 --->
<cfif iAptType_ID  is 55 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALB_0    =   TotalRent >One BedroomILE_0
</cfif>
<!--- @TwoBedroomALB_1 --->
<cfif iAptType_ID  is 55 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALB_1    =   TotalRent >
</cfif>
<!--- @TwoBedroomALB_2 --->
<cfif iAptType_ID  is 55 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALB_2    =   TotalRent >
</cfif>
<!--- @TwoBedroomALB_3 --->
<cfif iAptType_ID  is 55 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALB_3    =   TotalRent >
</cfif>
<!--- @TwoBedroomALB_4 --->
<cfif iAptType_ID  is 55 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALB_4    =   TotalRent >
</cfif>
<!--- @TwoBedroomALB_5 --->
<cfif iAptType_ID  is 55 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALB_5    =   TotalRent >
</cfif>
<!--- @TwoBedroomALB_6 --->
<cfif iAptType_ID  is 55 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  TwoBedroomALB_6    =   TotalRent >
</cfif>


<!--- @TwoBedroomILA_0 --->
<cfif iAptType_ID  is 56 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILA_0    =   TotalRent >One BedroomILE_0
</cfif>
<!--- @TwoBedroomILA_1 --->
<cfif iAptType_ID  is 56 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILA_1    =   TotalRent >
</cfif>
<!--- @TwoBedroomILA_2 --->
<cfif iAptType_ID  is 56 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILA_2    =   TotalRent >
</cfif>
<!--- @TwoBedroomILA_3 --->
<cfif iAptType_ID  is 56 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILA_3    =   TotalRent >
</cfif>
<!--- @TwoBedroomILA_4 --->
<cfif iAptType_ID  is 56 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILA_4    =   TotalRent >
</cfif>
<!--- @TwoBedroomILA_5 --->
<cfif iAptType_ID  is 56 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILA_5    =   TotalRent >
</cfif>
<!--- @TwoBedroomILA_6 --->
<cfif iAptType_ID  is 56 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILA_6    =   TotalRent >
</cfif>

<!--- @TwoBedroomILB_0 --->
<cfif iAptType_ID  is 57 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILB_0    =   TotalRent >One BedroomILE_0
</cfif>
<!--- @TwoBedroomILB_1 --->
<cfif iAptType_ID  is 57 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILB_1    =   TotalRent >
</cfif>
<!--- @TwoBedroomILB_2 --->
<cfif iAptType_ID  is 57 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILB_2    =   TotalRent >
</cfif>
<!--- @TwoBedroomILB_3 --->
<cfif iAptType_ID  is 57 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILB_3    =   TotalRent >
</cfif>
<!--- @TwoBedroomILB_4 --->
<cfif iAptType_ID  is 57 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILB_4    =   TotalRent >
</cfif>
<!--- @TwoBedroomILB_5 --->
<cfif iAptType_ID  is 57 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILB_5    =   TotalRent >
</cfif>
<!--- @TwoBedroomILB_6 --->
<cfif iAptType_ID  is 57 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  TwoBedroomILB_6    =   TotalRent >
</cfif>

<!--- @ILStudio_0 --->
<cfif iAptType_ID  is 58 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  ILStudio_0    =   TotalRent > 
</cfif>
<!--- @ILStudio_1 --->
<cfif iAptType_ID  is 58 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  ILStudio_1    =   TotalRent >
</cfif>
<!--- @ILStudio_2 --->
<cfif iAptType_ID  is 58 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  ILStudio_2    =   TotalRent >
</cfif>
<!--- @ILStudio_3 --->
<cfif iAptType_ID  is 58 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  ILStudio_3    =   TotalRent >
</cfif>
<!--- @ILStudio_4 --->
<cfif iAptType_ID  is 58 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  ILStudio_4    =   TotalRent >
</cfif>
<!--- @ILStudio_5 --->
<cfif iAptType_ID  is 58 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  ILStudio_5    =   TotalRent >
</cfif>
<!--- @ILStudio_6 --->
<cfif iAptType_ID  is 58 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  ILStudio_6    =   TotalRent >
</cfif>

<!--- @OneBedroomALD_0 --->
<cfif iAptType_ID  is 59 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset ILOneBedroom_0    =   TotalRent > 
</cfif>
<!--- @OneBedroomALD_1 --->
<cfif iAptType_ID  is 59 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset ILOneBedroom_1    =   TotalRent >
</cfif>
<!--- @OneBedroomALD_2 --->
<cfif iAptType_ID  is 59 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset ILOneBedroom_2    =   TotalRent >
</cfif>
<!--- @OneBedroomALD_3 --->
<cfif iAptType_ID  is 59 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset ILOneBedroom_3    =   TotalRent >
</cfif>
<!--- @OneBedroomALD_4 --->
<cfif iAptType_ID  is 59 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset ILOneBedroom_4    =   TotalRent >
</cfif>
<!--- @OneBedroomALD_5 --->
<cfif iAptType_ID  is 59 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset ILOneBedroom_5    =   TotalRent >
</cfif>
<!--- @OneBedroomALD_6 --->
<cfif iAptType_ID  is 59 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset ILOneBedroom_6    =   TotalRent >
</cfif>

<!--- @ILTwoBedroom_0 --->
<cfif iAptType_ID  is 60 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  ILTwoBedroom_0    =   TotalRent > 
</cfif>
<!--- @ILTwoBedroom_1 --->
<cfif iAptType_ID  is 60 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  ILTwoBedroom_1    =   TotalRent >
</cfif>
<!--- @ILTwoBedroom_2 --->
<cfif iAptType_ID  is 60 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  ILTwoBedroom_2    =   TotalRent >
</cfif>
<!--- @ILTwoBedroom_3 --->
<cfif iAptType_ID  is 60 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  ILTwoBedroom_3    =   TotalRent >
</cfif>
<!--- @ILTwoBedroom_4 --->
<cfif iAptType_ID  is 60 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  ILTwoBedroom_4    =   TotalRent >
</cfif>
<!--- @ILTwoBedroom_5 --->
<cfif iAptType_ID  is 60 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  ILTwoBedroom_5    =   TotalRent >
</cfif>
<!--- @ILTwoBedroom_6 --->
<cfif iAptType_ID  is 60 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  ILTwoBedroom_6    =   TotalRent >
</cfif>

<!--- @IL2BedroomDlxC_0 --->
<cfif iAptType_ID  is 61 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlx_0    =   TotalRent > 
</cfif>
<!--- @IL2BedroomDlxC_1 --->
<cfif iAptType_ID  is 61 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlx_1    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_2 --->
<cfif iAptType_ID  is 61 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlx_2    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_3 --->
<cfif iAptType_ID  is 61 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlx_3    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_4 --->
<cfif iAptType_ID  is 61 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlx_4    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_5 --->
<cfif iAptType_ID  is 61 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlx_5    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_6 --->
<cfif iAptType_ID  is 61 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlx_6    =   TotalRent >
</cfif>

<!--- @IL2BedroomDlxC_0 --->
<cfif iAptType_ID  is 62 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlxComb_0    =   TotalRent > 
</cfif>
<!--- @IL2BedroomDlxC_1 --->
<cfif iAptType_ID  is 62 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlxComb_1    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_2 --->
<cfif iAptType_ID  is 62 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlxComb_2    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_3 --->
<cfif iAptType_ID  is 62 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlxComb_3    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_4 --->
<cfif iAptType_ID  is 62 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlxComb_4    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_5 --->
<cfif iAptType_ID  is 62 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlxComb_5    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_6 --->
<cfif iAptType_ID  is 62 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset IL2BedroomDlxComb_6    =   TotalRent >
</cfif>

<!--- @IL2BedroomDlxC_0 --->
<cfif iAptType_ID  is 63 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset IL1BedroomC_0    =   TotalRent > 
</cfif>
<!--- @IL2BedroomDlxC_1 --->
<cfif iAptType_ID  is 63 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset IL1BedroomC_1    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_2 --->
<cfif iAptType_ID  is 63 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset IL1BedroomC_2    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_3 --->
<cfif iAptType_ID  is 63 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset IL1BedroomC_3    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_4 --->
<cfif iAptType_ID  is 63 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset IL1BedroomC_4    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_5 --->
<cfif iAptType_ID  is 63 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset IL1BedroomC_5    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_6 --->
<cfif iAptType_ID  is 63 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset IL1BedroomC_6    =   TotalRent >
</cfif>

<!--- @IL2BedroomDlxC_0 --->
<cfif iAptType_ID  is 64 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset IL1BedroomDlxC_0    =   TotalRent > 
</cfif>
<!--- @IL2BedroomDlxC_1 --->
<cfif iAptType_ID  is 64 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset IL1BedroomDlxC_1    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_2 --->
<cfif iAptType_ID  is 64 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset IL1BedroomDlxC_2    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_3 --->
<cfif iAptType_ID  is 64 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset IL1BedroomDlxC_3    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_4 --->
<cfif iAptType_ID  is 64 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset IL1BedroomDlxC_4    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_5 --->
<cfif iAptType_ID  is 64 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset IL1BedroomDlxC_5    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_6 --->
<cfif iAptType_ID  is 64 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset IL1BedroomDlxC_6    =   TotalRent >
</cfif>

<!--- @IL2BedroomDlxC_0 --->
<cfif iAptType_ID  is 65 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset IL2BedroomC_0    =   TotalRent > 
</cfif>
<!--- @IL2BedroomDlxC_1 --->
<cfif iAptType_ID  is 65 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset IL2BedroomC_1    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_2 --->
<cfif iAptType_ID  is 65 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset IL2BedroomC_2    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_3 --->
<cfif iAptType_ID  is 65 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset IL2BedroomC_3    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_4 --->
<cfif iAptType_ID  is 65 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset IL2BedroomC_4    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_5 --->
<cfif iAptType_ID  is 65 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset IL2BedroomC_5    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_6 --->
<cfif iAptType_ID  is 65 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset IL2BedroomC_6    =   TotalRent >
</cfif>


<!--- @IL2BedroomDlxC_0 --->
<cfif iAptType_ID  is 66 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  IL2BedroomDlxC_0    =   TotalRent > 
</cfif>
<!--- @IL2BedroomDlxC_1 --->
<cfif iAptType_ID  is 66 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  IL2BedroomDlxC_1    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_2 --->
<cfif iAptType_ID  is 66 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  IL2BedroomDlxC_2    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_3 --->
<cfif iAptType_ID  is 66 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  IL2BedroomDlxC_3    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_4 --->
<cfif iAptType_ID  is 66 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  IL2BedroomDlxC_4    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_5 --->
<cfif iAptType_ID  is 66 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  IL2BedroomDlxC_5    =   TotalRent >
</cfif>
<!--- @IL2BedroomDlxC_6 --->
<cfif iAptType_ID  is 66 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  IL2BedroomDlxC_6    =   TotalRent >
</cfif>

<!--- @ILInvest1Bedroom_0 --->
<cfif iAptType_ID  is 67 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  ILInvest1Bedroom_0    =   TotalRent > 
</cfif>
<!--- @ILInvest1Bedroom_1 --->
<cfif iAptType_ID  is 67 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  ILInvest1Bedroom_1    =   TotalRent >
</cfif>
<!--- @ILInvest1Bedroom_2 --->
<cfif iAptType_ID  is 67 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  ILInvest1Bedroom_2    =   TotalRent >
</cfif>
<!--- @ILInvest1Bedroom_3 --->
<cfif iAptType_ID  is 67 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  ILInvest1Bedroom_3    =   TotalRent >
</cfif>
<!--- @ILInvest1Bedroom_4 --->
<cfif iAptType_ID  is 67 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  ILInvest1Bedroom_4    =   TotalRent >
</cfif>
<!--- @ILInvest1Bedroom_5 --->
<cfif iAptType_ID  is 67 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  ILInvest1Bedroom_5    =   TotalRent >
</cfif>
<!--- @ILInvest1Bedroom_6 --->
<cfif iAptType_ID  is 67 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  ILInvest1Bedroom_6    =   TotalRent >
</cfif>

<!--- @ILInvest2Bedroom_0 --->
<cfif iAptType_ID  is 68 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  ILInvest2Bedroom_0    =   TotalRent > 
</cfif>
<!--- @ILInvest2Bedroom_1 --->
<cfif iAptType_ID  is 68 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  ILInvest2Bedroom_1    =   TotalRent >
</cfif>
<!--- @ILInvest2Bedroom_2 --->
<cfif iAptType_ID  is 68 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  ILInvest2Bedroom_2    =   TotalRent >
</cfif>
<!--- @ILInvest2Bedroom_3 --->
<cfif iAptType_ID  is 68 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  ILInvest2Bedroom_3    =   TotalRent >
</cfif>
<!--- @ILInvest2Bedroom_4 --->
<cfif iAptType_ID  is 68 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  ILInvest2Bedroom_4    =   TotalRent >
</cfif>
<!--- @ILInvest2Bedroom_5 --->
<cfif iAptType_ID  is 68 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  ILInvest2Bedroom_5    =   TotalRent >
</cfif>
<!--- @ILInvest2Bedroom_6 --->
<cfif iAptType_ID  is 68 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  ILInvest2Bedroom_6    =   TotalRent >
</cfif>

<!--- @ILInvest2BedroomDlx_0 --->
<cfif iAptType_ID  is 69 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomDlx_0    =   TotalRent > 
</cfif>
<!--- @ILInvest2BedroomDlx_1 --->
<cfif iAptType_ID  is 69 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomDlx_1    =   TotalRent >
</cfif>
<!--- @ILInvest2BedroomDlx_2 --->
<cfif iAptType_ID  is 69 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomDlx_2    =   TotalRent >
</cfif>
<!--- @ILInvest2BedroomDlx_3 --->
<cfif iAptType_ID  is 69 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomDlx_3    =   TotalRent >
</cfif>
<!--- @ILInvest2BedroomDlx_4 --->
<cfif iAptType_ID  is 69 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomDlx_4    =   TotalRent >
</cfif>
<!--- @ILInvest2BedroomDlx_5 --->
<cfif iAptType_ID  is 69 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomDlx_5    =   TotalRent >
</cfif>
<!--- @ILInvest2BedroomDlx_6 --->
<cfif iAptType_ID  is 69 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomDlx_6    =   TotalRent >
</cfif>

<!--- @ILInvest2BedroomLux_0 --->
<cfif iAptType_ID  is 70 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomLux_0    =   TotalRent > 
</cfif>
<!--- @ILInvest2BedroomLux_1 --->
<cfif iAptType_ID  is 70 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomLux_1    =   TotalRent >
</cfif>
<!--- @ILInvest2BedroomLux_2 --->
<cfif iAptType_ID  is 70 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomLux_2    =   TotalRent >
</cfif>
<!--- @ILInvest2BedroomLux_3 --->
<cfif iAptType_ID  is 70 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomLux_3    =   TotalRent >
</cfif>
<!--- @ILInvest2BedroomLux_4 --->
<cfif iAptType_ID  is 70 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomLux_4    =   TotalRent >
</cfif>
<!--- @ILInvest2BedroomLux_5 --->
<cfif iAptType_ID  is 70 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomLux_5    =   TotalRent >
</cfif>
<!--- @ILInvest2BedroomLux_6 --->
<cfif iAptType_ID  is 70 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  ILInvest2BedroomLux_6    =   TotalRent >
</cfif>

<!--- @StudioPrem_0 --->
<cfif iAptType_ID  is 71 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  StudioPrem_0    =   TotalRent > 
</cfif>
<!--- @StudioPrem_1 --->
<cfif iAptType_ID  is 71 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  StudioPrem_1    =   TotalRent >
</cfif>
<!--- @StudioPrem_2 --->
<cfif iAptType_ID  is 71 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  StudioPrem_2    =   TotalRent >
</cfif>
<!--- @StudioPrem_3 --->
<cfif iAptType_ID  is 71 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  StudioPrem_3    =   TotalRent >
</cfif>
<!--- @StudioPrem_4 --->
<cfif iAptType_ID  is 71 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  StudioPrem_4    =   TotalRent >
</cfif>
<!--- @StudioPrem_5 --->
<cfif iAptType_ID  is 71 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  StudioPrem_5    =   TotalRent >
</cfif>
<!--- @StudioPrem_6 --->
<cfif iAptType_ID  is 71 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  StudioPrem_6    =   TotalRent >
</cfif>

<!--- @OneBedroomPrem_0 --->
<cfif iAptType_ID  is 72 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomPrem_0    =   TotalRent > 
</cfif>
<!--- @OneBedroomPrem_1 --->
<cfif iAptType_ID  is 72 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomPrem_1    =   TotalRent >
</cfif>
<!--- @OneBedroomPrem_2 --->
<cfif iAptType_ID  is 72 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomPrem_2    =   TotalRent >
</cfif>
<!--- @OneBedroomPrem_3 --->
<cfif iAptType_ID  is 72 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomPrem_3    =   TotalRent >
</cfif>
<!--- @OneBedroomPrem_4 --->
<cfif iAptType_ID  is 72 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomPrem_4    =   TotalRent >
</cfif>
<!--- @OneBedroomPrem_5 --->
<cfif iAptType_ID  is 72 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomPrem_5    =   TotalRent >
</cfif>
<!--- @OneBedroomPrem_6 --->
<cfif iAptType_ID  is 72 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomPrem_6    =   TotalRent >
</cfif>

<!--- @TwoBedroomPrem_0 --->
<cfif iAptType_ID  is 73 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  TwoBedroomPrem_0    =   TotalRent > 
</cfif>
<!--- @TwoBedroomPrem_1 --->
<cfif iAptType_ID  is 73 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  TwoBedroomPrem_1    =   TotalRent >
</cfif>
<!--- @TwoBedroomPrem_2 --->
<cfif iAptType_ID  is 73 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  TwoBedroomPrem_2    =   TotalRent >
</cfif>
<!--- @TwoBedroomPrem_3 --->
<cfif iAptType_ID  is 73 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  TwoBedroomPrem_3    =   TotalRent >
</cfif>
<!--- @TwoBedroomPrem_4 --->
<cfif iAptType_ID  is 73 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  TwoBedroomPrem_4    =   TotalRent >
</cfif>
<!--- @TwoBedroomPrem_5 --->
<cfif iAptType_ID  is 73 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  TwoBedroomPrem_5    =   TotalRent >
</cfif>
<!--- @TwoBedroomPrem_6 --->
<cfif iAptType_ID  is 73 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  TwoBedroomPrem_6    =   TotalRent >
</cfif>


<!--- @Comp1BedroomDlx_0 --->
<cfif iAptType_ID  is 74 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  Comp1BedroomDlx_0    =   TotalRent > 
</cfif>
<!--- @Comp1BedroomDlx_1 --->
<cfif iAptType_ID  is 74 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  Comp1BedroomDlx_1    =   TotalRent >
</cfif>
<!--- @Comp1BedroomDlx_2 --->
<cfif iAptType_ID  is 74 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  Comp1BedroomDlx_2    =   TotalRent >
</cfif>
<!--- @Comp1BedroomDlx_3 --->
<cfif iAptType_ID  is 74 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  Comp1BedroomDlx_3    =   TotalRent >
</cfif>
<!--- @Comp1BedroomDlx_4 --->
<cfif iAptType_ID  is 74 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  Comp1BedroomDlx_4    =   TotalRent >
</cfif>
<!--- @Comp1BedroomDlx_5 --->
<cfif iAptType_ID  is 74 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  Comp1BedroomDlx_5    =   TotalRent >
</cfif>
<!--- @Comp1BedroomDlx_6 --->
<cfif iAptType_ID  is 74 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  Comp1BedroomDlx_6    =   TotalRent >
</cfif>

<!--- @Comp2BedroomDlx_0 --->
<cfif iAptType_ID  is 75 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomDlx_0    =   TotalRent > 
</cfif>
<!--- @Comp2BedroomDlx_1 --->
<cfif iAptType_ID  is 75 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomDlx_1    =   TotalRent >
</cfif>
<!--- @Comp2BedroomDlx_2 --->
<cfif iAptType_ID  is 75 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomDlx_2    =   TotalRent >
</cfif>
<!--- @Comp2BedroomDlx_3 --->
<cfif iAptType_ID  is 75 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomDlx_3    =   TotalRent >
</cfif>
<!--- @Comp2BedroomDlx_4 --->
<cfif iAptType_ID  is 75 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomDlx_4    =   TotalRent >
</cfif>
<!--- @Comp2BedroomDlx_5 --->
<cfif iAptType_ID  is 75 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomDlx_5    =   TotalRent >
</cfif>
<!--- @Comp2BedroomDlx_6 --->
<cfif iAptType_ID  is 75 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomDlx_6    =   TotalRent >
</cfif>

<!--- @Comp2BedroomALA_0 --->
<cfif iAptType_ID  is 76 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomALA_0    =   TotalRent > 
</cfif>
<!--- @Comp2BedroomALA_1 --->
<cfif iAptType_ID  is 76 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomALA_1    =   TotalRent >
</cfif>
<!--- @Comp2BedroomALA_2 --->
<cfif iAptType_ID  is 76 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomALA_2    =   TotalRent >
</cfif>
<!--- @Comp2BedroomALA_3 --->
<cfif iAptType_ID  is 76 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomALA_3    =   TotalRent >
</cfif>
<!--- @Comp2BedroomALA_4 --->
<cfif iAptType_ID  is 76 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomALA_4    =   TotalRent >
</cfif>
<!--- @Comp2BedroomALA_5 --->
<cfif iAptType_ID  is 76 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomALA_5    =   TotalRent >
</cfif>
<!--- @Comp2BedroomALA_6 --->
<cfif iAptType_ID  is 76 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomALA_6    =   TotalRent >
</cfif>

<!--- @OneBedroomPremPlus_0 --->
<cfif iAptType_ID  is 77 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_0    =   TotalRent > 
</cfif>
<!--- @OneBedroomPremPlus_1 --->
<cfif iAptType_ID  is 77 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_1    =   TotalRent >
</cfif>
<!--- @OneBedroomPremPlus_2 --->
<cfif iAptType_ID  is 77 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_2    =   TotalRent >
</cfif>
<!--- @OneBedroomPremPlus_3 --->
<cfif iAptType_ID  is 77 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_3    =   TotalRent >
</cfif>
<!--- @OneBedroomPremPlus_4 --->
<cfif iAptType_ID  is 77 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_4    =   TotalRent >
</cfif>
<!--- @OneBedroomPremPlus_5 --->
<cfif iAptType_ID  is 77 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_5    =   TotalRent >
</cfif>
<!--- @OneBedroomPremPlus_6 --->
<cfif iAptType_ID  is 77 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_6    =   TotalRent >
</cfif>

<!--- @OneBedroomPremPlus_0 --->
<cfif iAptType_ID  is 78 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_0    =   TotalRent > 
</cfif>
<!--- @OneBedroomPremPlus_1 --->
<cfif iAptType_ID  is 78 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_1    =   TotalRent >
</cfif>
<!--- @OneBedroomPremPlus_2 --->
<cfif iAptType_ID  is 78 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_2    =   TotalRent >
</cfif>
<!--- @OneBedroomPremPlus_3 --->
<cfif iAptType_ID  is 78 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_3    =   TotalRent >
</cfif>
<!--- @OneBedroomPremPlus_4 --->
<cfif iAptType_ID  is 78 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_4    =   TotalRent >
</cfif>
<!--- @OneBedroomPremPlus_5 --->
<cfif iAptType_ID  is 78 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_5    =   TotalRent >
</cfif>
<!--- @OneBedroomPremPlus_6 --->
<cfif iAptType_ID  is 78 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  OneBedroomPremPlus_6    =   TotalRent >
</cfif>

<!--- @CompStudioPrem_0 --->
<cfif iAptType_ID  is 79 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_0    =   TotalRent > 
</cfif>
<!--- @CompStudioPrem_1 --->
<cfif iAptType_ID  is 79 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_1    =   TotalRent >
</cfif>
<!--- @CompStudioPrem_2 --->
<cfif iAptType_ID  is 79 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_2    =   TotalRent >
</cfif>
<!--- @CompStudioPrem_3 --->
<cfif iAptType_ID  is 79 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_3    =   TotalRent >
</cfif>
<!--- @CompStudioPrem_4 --->
<cfif iAptType_ID  is 79 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_4    =   TotalRent >
</cfif>
<!--- @CompStudioPrem_5 --->
<cfif iAptType_ID  is 79 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_5    =   TotalRent >
</cfif>
<!--- @CompStudioPrem_6 --->
<cfif iAptType_ID  is 79 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_6    =   TotalRent >
</cfif>

<!--- @CompStudioPrem_0 --->
<cfif iAptType_ID  is 80 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_0    =   TotalRent > 
</cfif>
<!--- @CompStudioPrem_1 --->
<cfif iAptType_ID  is 80 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_1    =   TotalRent >
</cfif>
<!--- @CompStudioPrem_2 --->
<cfif iAptType_ID  is 80 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_2    =   TotalRent >
</cfif>
<!--- @CompStudioPrem_3 --->
<cfif iAptType_ID  is 80 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_3    =   TotalRent >
</cfif>
<!--- @CompStudioPrem_4 --->
<cfif iAptType_ID  is 80 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_4    =   TotalRent >
</cfif>
<!--- @CompStudioPrem_5 --->
<cfif iAptType_ID  is 80 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_5    =   TotalRent >
</cfif>
<!--- @CompStudioPrem_6 --->
<cfif iAptType_ID  is 80 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  CompStudioPrem_6    =   TotalRent >
</cfif>

<!--- @ILStudioPrem_0 --->
<cfif iAptType_ID  is 81 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  ILStudioPrem_0    =   TotalRent > 
</cfif>
<!--- @ILStudioPrem_1 --->
<cfif iAptType_ID  is 81 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  ILStudioPrem_1    =   TotalRent >
</cfif>
<!--- @ILStudioPrem_2 --->
<cfif iAptType_ID  is 81 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  ILStudioPrem_2    =   TotalRent >
</cfif>
<!--- @ILStudioPrem_3 --->
<cfif iAptType_ID  is 81 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  ILStudioPrem_3    =   TotalRent >
</cfif>
<!--- @ILStudioPrem_4 --->
<cfif iAptType_ID  is 81 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  ILStudioPrem_4    =   TotalRent >
</cfif>
<!--- @ILStudioPrem_5 --->
<cfif iAptType_ID  is 81 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  ILStudioPrem_5    =   TotalRent >
</cfif>
<!--- @ILStudioPrem_6 --->
<cfif iAptType_ID  is 81 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  ILStudioPrem_6    =   TotalRent >
</cfif>

<!--- @IL1BedroomPrem_0 --->
<cfif iAptType_ID  is 82 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  IL1BedroomPrem_0    =   TotalRent > 
</cfif>
<!--- @IL1BedroomPrem_1 --->
<cfif iAptType_ID  is 82 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  IL1BedroomPrem_1    =   TotalRent >
</cfif>
<!--- @IL1BedroomPrem_2 --->
<cfif iAptType_ID  is 82 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  IL1BedroomPrem_2    =   TotalRent >
</cfif>
<!--- @IL1BedroomPrem_3 --->
<cfif iAptType_ID  is 82 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  IL1BedroomPrem_3    =   TotalRent >
</cfif>
<!--- @IL1BedroomPrem_4 --->
<cfif iAptType_ID  is 82 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  IL1BedroomPrem_4    =   TotalRent >
</cfif>
<!--- @IL1BedroomPrem_5 --->
<cfif iAptType_ID  is 82 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  IL1BedroomPrem_5    =   TotalRent >
</cfif>
<!--- @IL1BedroomPrem_6 --->
<cfif iAptType_ID  is 82 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  IL1BedroomPrem_6    =   TotalRent >
</cfif>

<!--- @IL2BedroomPrem_0 --->
<cfif iAptType_ID  is 83 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  IL2BedroomPrem_0    =   TotalRent > 
</cfif>
<!--- @IL2BedroomPrem_1 --->
<cfif iAptType_ID  is 83 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  IL2BedroomPrem_1    =   TotalRent >
</cfif>
<!--- @IL2BedroomPrem_2 --->
<cfif iAptType_ID  is 83 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  IL2BedroomPrem_2    =   TotalRent >
</cfif>
<!--- @IL2BedroomPrem_3 --->
<cfif iAptType_ID  is 83 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  IL2BedroomPrem_3    =   TotalRent >
</cfif>
<!--- @IL2BedroomPrem_4 --->
<cfif iAptType_ID  is 83 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  IL2BedroomPrem_4    =   TotalRent >
</cfif>
<!--- @IL2BedroomPrem_5 --->
<cfif iAptType_ID  is 83 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  IL2BedroomPrem_5    =   TotalRent >
</cfif>
<!--- @IL2BedroomPrem_6 --->
<cfif iAptType_ID  is 83 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  IL2BedroomPrem_6    =   TotalRent >
</cfif>

<!--- @Comp2BedroomPrem_0 --->
<cfif iAptType_ID  is 84 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomPrem_0    =   TotalRent > 
</cfif>
<!--- @Comp2BedroomPrem_1 --->
<cfif iAptType_ID  is 84 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomPrem_1    =   TotalRent >
</cfif>
<!--- @Comp2BedroomPrem_2 --->
<cfif iAptType_ID  is 84 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomPrem_2    =   TotalRent >
</cfif>
<!--- @Comp2BedroomPrem_3 --->
<cfif iAptType_ID  is 84 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomPrem_3    =   TotalRent >
</cfif>
<!--- @Comp2BedroomPrem_4 --->
<cfif iAptType_ID  is 84 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomPrem_4    =   TotalRent >
</cfif>
<!--- @Comp2BedroomPrem_5 --->
<cfif iAptType_ID  is 84 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomPrem_5    =   TotalRent >
</cfif>
<!--- @Comp2BedroomPrem_6 --->
<cfif iAptType_ID  is 84 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  Comp2BedroomPrem_6    =   TotalRent >
</cfif>

<!--- @MCStudio_0 --->
<cfif iAptType_ID  is 85 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  MCStudio_0    =   TotalRent > 
</cfif>
<!--- @MCStudio_1 --->
<cfif iAptType_ID  is 85 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  MCStudio_1    =   TotalRent >
</cfif>
<!--- @MCStudio_2 --->
<cfif iAptType_ID  is 85 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  MCStudio_2    =   TotalRent >
</cfif>
<!--- @MCStudio_3 --->
<cfif iAptType_ID  is 85 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  MCStudio_3    =   TotalRent >
</cfif>
<!--- @MCStudio_4 --->
<cfif iAptType_ID  is 85 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  MCStudio_4    =   TotalRent >
</cfif>
<!--- @MCStudio_5 --->
<cfif iAptType_ID  is 85 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  MCStudio_5    =   TotalRent >
</cfif>
<!--- @MCStudio_6 --->
<cfif iAptType_ID  is 85 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  MCStudio_6    =   TotalRent >
</cfif>

<!--- @MCStudioDlx_0 --->
<cfif iAptType_ID  is 86 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  MCStudioDlx_0    =   TotalRent > 
</cfif>
<!--- @MCStudioDlx_1 --->
<cfif iAptType_ID  is 86 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  MCStudioDlx_1    =   TotalRent >
</cfif>
<!--- @MCStudioDlx_2 --->
<cfif iAptType_ID  is 86 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  MCStudioDlx_2    =   TotalRent >
</cfif>
<!--- @MCStudioDlx_3 --->
<cfif iAptType_ID  is 86 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  MCStudioDlx_3    =   TotalRent >
</cfif>
<!--- @MCStudioDlx_4 --->
<cfif iAptType_ID  is 86 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  MCStudioDlx_4    =   TotalRent >
</cfif>
<!--- @MCStudioDlx_5 --->
<cfif iAptType_ID  is 86 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  MCStudioDlx_5    =   TotalRent >
</cfif>
<!--- @MCStudioDlx_6 --->
<cfif iAptType_ID  is 86 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  MCStudioDlx_6    =   TotalRent >
</cfif>

<!--- @MCCompStudio_0 --->
<cfif iAptType_ID  is 87 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  MCCompStudio_0    =   TotalRent > 
</cfif>
<!--- @MCCompStudio_1 --->
<cfif iAptType_ID  is 87 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  MCCompStudio_1    =   TotalRent >
</cfif>
<!--- @MCCompStudio_2 --->
<cfif iAptType_ID  is 87 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  MCCompStudio_2    =   TotalRent >
</cfif>
<!--- @MCCompStudio_3 --->
<cfif iAptType_ID  is 87 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  MCCompStudio_3    =   TotalRent >
</cfif>
<!--- @MCCompStudio_4 --->
<cfif iAptType_ID  is 87 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  MCCompStudio_4    =   TotalRent >
</cfif>
<!--- @MCCompStudio_5 --->
<cfif iAptType_ID  is 87 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  MCCompStudio_5    =   TotalRent >
</cfif>
<!--- @MCCompStudio_6 --->
<cfif iAptType_ID  is 87 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  MCCompStudio_6    =   TotalRent >
</cfif>

<!--- @MCCompStudioDlx_0 --->
<cfif iAptType_ID  is 88 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  MCCompStudioDlx_0    =   TotalRent > 
</cfif>
<!--- @MCCompStudioDlx_1 --->
<cfif iAptType_ID  is 88 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  MCCompStudioDlx_1    =   TotalRent >
</cfif>
<!--- @MCCompStudioDlx_2 --->
<cfif iAptType_ID  is 88 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  MCCompStudioDlx_2    =   TotalRent >
</cfif>
<!--- @MCCompStudioDlx_3 --->
<cfif iAptType_ID  is 88 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  MCCompStudioDlx_3    =   TotalRent >
</cfif>
<!--- @MCCompStudioDlx_4 --->
<cfif iAptType_ID  is 88 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  MCCompStudioDlx_4    =   TotalRent >
</cfif>
<!--- @MCCompStudioDlx_5 --->
<cfif iAptType_ID  is 88 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  MCCompStudioDlx_5    =   TotalRent >
</cfif>
<!--- @MCCompStudioDlx_6 --->
<cfif iAptType_ID  is 88 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  MCCompStudioDlx_6    =   TotalRent >
</cfif>

<!--- @MCOneBedroom_0 --->
<cfif iAptType_ID  is 89 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  MCOneBedroom_0    =   TotalRent > 
</cfif>
<!--- @MCOneBedroom_1 --->
<cfif iAptType_ID  is 89 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  MCOneBedroom_1    =   TotalRent >
</cfif>
<!--- @MCOneBedroom_2 --->
<cfif iAptType_ID  is 89 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  MCOneBedroom_2    =   TotalRent >
</cfif>
<!--- @MCOneBedroom_3 --->
<cfif iAptType_ID  is 89 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  MCOneBedroom_3    =   TotalRent >
</cfif>
<!--- @MCOneBedroom_4 --->
<cfif iAptType_ID  is 89 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  MCOneBedroom_4    =   TotalRent >
</cfif>
<!--- @MCOneBedroom_5 --->
<cfif iAptType_ID  is 89 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  MCOneBedroom_5    =   TotalRent >
</cfif>
<!--- @MCOneBedroom_6 --->
<cfif iAptType_ID  is 89 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  MCOneBedroom_6    =   TotalRent >
</cfif>

<!--- @MCCompanionOneBedroom_0 --->
<cfif iAptType_ID  is 90 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  MCCompanionOneBedroom_0    =   TotalRent > 
</cfif>
<!--- @MCCompanionOneBedroom_1 --->
<cfif iAptType_ID  is 90 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  MCCompanionOneBedroom_1    =   TotalRent >
</cfif>
<!--- @MCCompanionOneBedroom_2 --->
<cfif iAptType_ID  is 90 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  MCCompanionOneBedroom_2    =   TotalRent >
</cfif>
<!--- @MCCompanionOneBedroom_3 --->
<cfif iAptType_ID  is 90 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  MCCompanionOneBedroom_3    =   TotalRent >
</cfif>
<!--- @MCCompanionOneBedroom_4 --->
<cfif iAptType_ID  is 90 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  MCCompanionOneBedroom_4    =   TotalRent >
</cfif>
<!--- @MCCompanionOneBedroom_5 --->
<cfif iAptType_ID  is 90 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  MCCompanionOneBedroom_5    =   TotalRent >
</cfif>
<!--- @MCCompanionOneBedroom_6 --->
<cfif iAptType_ID  is 90 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  MCCompanionOneBedroom_6    =   TotalRent >
</cfif>

<!--- @MCTwoBedroom_0 --->
<cfif iAptType_ID  is 91 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  MCTwoBedroom_0    =   TotalRent > 
</cfif>
<!--- @MCTwoBedroom_1 --->
<cfif iAptType_ID  is 91 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  MCTwoBedroom_1    =   TotalRent >
</cfif>
<!--- @MCTwoBedroom_2 --->
<cfif iAptType_ID  is 91 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  MCTwoBedroom_2    =   TotalRent >
</cfif>
<!--- @MCTwoBedroom_3 --->
<cfif iAptType_ID  is 91 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  MCTwoBedroom_3    =   TotalRent >
</cfif>
<!--- @MCTwoBedroom_4 --->
<cfif iAptType_ID  is 91 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  MCTwoBedroom_4    =   TotalRent >
</cfif>
<!--- @MCTwoBedroom_5 --->
<cfif iAptType_ID  is 91 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  MCTwoBedroom_5    =   TotalRent >
</cfif>
<!--- @MCTwoBedroom_6 --->
<cfif iAptType_ID  is 91 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  MCTwoBedroom_6    =   TotalRent >
</cfif>


<!--- @MCCompanionTwoBedroom_0 --->
<cfif iAptType_ID  is 92 and  Acuity is '0' and  iOccupancyPosition is 1>
<cfset  MCCompanionTwoBedroom_0    =   TotalRent > 
</cfif>
<!--- @MCCompanionTwoBedroom_1 --->
<cfif iAptType_ID  is 92 and  Acuity is '1' and  iOccupancyPosition is 1>
<cfset  MCCompanionTwoBedroom_1    =   TotalRent >
</cfif>
<!--- @MCCompanionTwoBedroom_2 --->
<cfif iAptType_ID  is 92 and  Acuity is '2' and  iOccupancyPosition is 1>
<cfset  MCCompanionTwoBedroom_2    =   TotalRent >
</cfif>
<!--- @MCCompanionTwoBedroom_3 --->
<cfif iAptType_ID  is 92 and  Acuity is '3' and  iOccupancyPosition is 1>
<cfset  MCCompanionTwoBedroom_3    =   TotalRent >
</cfif>
<!--- @MCCompanionTwoBedroom_4 --->
<cfif iAptType_ID  is 92 and  Acuity is '4' and  iOccupancyPosition is 1>
<cfset  MCCompanionTwoBedroom_4    =   TotalRent >
</cfif>
<!--- @MCCompanionTwoBedroom_5 --->
<cfif iAptType_ID  is 92 and  Acuity is '5' and  iOccupancyPosition is 1>
<cfset  MCCompanionTwoBedroom_5    =   TotalRent >
</cfif>
<!--- @MCCompanionTwoBedroom_6 --->
<cfif iAptType_ID  is 92 and  Acuity is '6' and  iOccupancyPosition is 1>
<cfset  MCCompanionTwoBedroom_6    =   TotalRent >
</cfif>

</cfloop>
<div>
 TwoPerson :  #TwoPerson_0# #TwoPerson_1# #TwoPerson_2# #TwoPerson_3#  #TwoPerson_4# #TwoPerson_5#   #TwoPerson_6#<br />
Studio : #Studio_0#  #Studio_1# #Studio_2# #Studio_3# #Studio_4# #Studio_5# #Studio_6#<br />
 StudioDeluxe : #StudioDeluxe_0#  #StudioDeluxe_1#  #StudioDeluxe_2#  #StudioDeluxe_3#  #StudioDeluxe_4#  #StudioDeluxe_5#
  #StudioDeluxe_6#<br />
OneB  #OneB_0#   #OneB_1#  #OneB_2#  #OneB_3#  #OneB_4#  #OneB_5#  #OneB_6#<br />
TwoB :  #TwoB_0#  #TwoB_1#  #TwoB_2#  #TwoB_3#  #TwoB_4#  #TwoB_5#  #TwoB_6#<br />
Deluxe : #Deluxe_0#  #Deluxe_1# #Deluxe_2# #Deluxe_3# #Deluxe_4# #Deluxe_5# #Deluxe_6#<br />
 Alcove_0: #Alcove_0#   #Alcove_1#  #Alcove_2#  #Alcove_3# #Alcove_4# #Alcove_5# #Alcove_6#<br />
 Efficiency:  
  #Efficiency_0#   #Efficiency_1#  #Efficiency_2#  #Efficiency_3#  #Efficiency_4#  #Efficiency_5#  #Efficiency_6#<br />
 Duplex : #Duplex_0#   #Duplex_1#  #Duplex_2#  #Duplex_3#  #Duplex_4#  #Duplex_5#  #Duplex_6#<br />
HHR: #HHR_0# 
#HHR_1#
#HHR_2#
#HHR_3#
#HHR_4#
#HHR_5#
#HHR_6#<br />
Double:#Double_0# 
#Double_1#
#Double_2#
#Double_3#
#Double_4#
#Double_5#
#Double_6#<br />
CompanionStudio:#CompanionStudio_0# 
#CompanionStudio_1#
#CompanionStudio_2#
#CompanionStudio_3#
#CompanionStudio_4#
#CompanionStudio_5#
#CompanionStudio_6#<br />
CompSD:#CompSD_0# 
#CompSD_1#
#CompSD_2#
#CompSD_3#
#CompSD_4#
#CompSD_5#
#CompSD_6#<br />
Comp1BD:#Comp1BD_0# 
#Comp1BD_1#
#Comp1BD_2#
#Comp1BD_3#
#Comp1BD_4#
#Comp1BD_5#
#Comp1BD_6#<br />
Comp2BD:#Comp2BD_0# 
#Comp2BD_1#
#Comp2BD_2#
#Comp2BD_3#
#Comp2BD_4#
#Comp2BD_5#
#Comp2BD_6#<br />
CompDX: #CompDX_0# 
#CompDX_1#
#CompDX_2#
#CompDX_3#
#CompDX_4#
#CompDX_5#
#CompDX_6#<br />
CompAL#CompAL_0# 
#CompAL_1#
#CompAL_2#
#CompAL_3#
#CompAL_4#
#CompAL_5#
#CompAL_6#<br />
CompEff:#CompEff_0# 
#CompEff_1#
#CompEff_2#
#CompEff_3#
#CompEff_4#
#CompEff_5#
#CompEff_6#<br />
CompDup: #CompDup_0# 
#CompDup_1#
#CompDup_2#
#CompDup_3#
#CompDup_4#
#CompDup_5#
#CompDup_6#<br />
CompHHR:#CompHHR_0# 
#CompHHR_1#
#CompHHR_2#
#CompHHR_3#
#CompHHR_4#
#CompHHR_5#
#CompHHR_6#<br />
CompDbl: #CompDbl_0# 
#CompDbl_1#
#CompDbl_2#
#CompDbl_3#
#CompDbl_4#
#CompDbl_5#
#CompDbl_6#<br />
OneBedDeluxe:#OneBedDeluxe_0# 
#OneBedDeluxe_1#
#OneBedDeluxe_2#
#OneBedDeluxe_3#
#OneBedDeluxe_4#
#OneBedDeluxe_5#
#OneBedDeluxe_6#<br />
TwoBedRoomDeluxe: #TwoBedRoomDeluxe_0# 
#TwoBedRoomDeluxe_1#
#TwoBedRoomDeluxe_2#
#TwoBedRoomDeluxe_3#
#TwoBedRoomDeluxe_4#
#TwoBedRoomDeluxe_5#
#TwoBedRoomDeluxe_6#<br />
StudioSuite:#StudioSuite_0# 
#StudioSuite_1#
#StudioSuite_2#
#StudioSuite_3#
#StudioSuite_4#
#StudioSuite_5#
#StudioSuite_6#<br />
StudioKitchen: #StudioKitchen_0# 
#StudioKitchen_1#
#StudioKitchen_2#
#StudioKitchen_3#
#StudioKitchen_4#
#StudioKitchen_5#
#StudioKitchen_6#<br />
County: #County_0# 
#County_1#
#County_2#
#County_3#
#County_4#
#County_5#
#County_6#<br />
TwoBedTwoBath: #TwoBedTwoBath_0# 
#TwoBedTwoBath_1#
#TwoBedTwoBath_2#
#TwoBedTwoBath_3#
#TwoBedTwoBath_4#
#TwoBedTwoBath_5#
#TwoBedTwoBath_6#<br />
TwoBedTwoBathDeluxe: #TwoBedTwoBathDeluxe_0# 
#TwoBedTwoBathDeluxe_1#
#TwoBedTwoBathDeluxe_2#
#TwoBedTwoBathDeluxe_3#
#TwoBedTwoBathDeluxe_4#
#TwoBedTwoBathDeluxe_5#
#TwoBedTwoBathDeluxe_6#<br />
OneBedroomAddition: #OneBedroomAddition_0# 
#OneBedroomAddition_1#
#OneBedroomAddition_2#
#OneBedroomAddition_3#
#OneBedroomAddition_4#
#OneBedroomAddition_5#
#OneBedroomAddition_6#<br />
OneBedroomALA#OneBedroomALA_0# 
#OneBedroomALA_1#
#OneBedroomALA_2#
#OneBedroomALA_3#
#OneBedroomALA_4#
#OneBedroomALA_5#
#OneBedroomALA_6#<br />
OneBedroomALB: #OneBedroomALB_0#
#OneBedroomALB_1#
#OneBedroomALB_2#
#OneBedroomALB_3#
#OneBedroomALB_4#
#OneBedroomALB_5#
#OneBedroomALB_6#<br />
OneBedroomALC: #OneBedroomALC_0#
#OneBedroomALC_1#
#OneBedroomALC_2#
#OneBedroomALC_3#
#OneBedroomALC_4#
#OneBedroomALC_5#
#OneBedroomALC_6#<br />
OneBedroomALD: #OneBedroomALD_0#
#OneBedroomALD_1#
#OneBedroomALD_2#
#OneBedroomALD_3#
#OneBedroomALD_4#
#OneBedroomALD_5#
#OneBedroomALD_6#<br />
OneBedroomALE: #OneBedroomALE_0#
#OneBedroomALE_1#
#OneBedroomALE_2#
#OneBedroomALE_3#
#OneBedroomALE_4#
#OneBedroomALE_5#
#OneBedroomALE_6#<br />
OneBedroomILA: #OneBedroomILA_0# 
#OneBedroomILA_1#
#OneBedroomILA_2#
#OneBedroomILA_3#
#OneBedroomILA_4#
#OneBedroomILA_5#
#OneBedroomILA_6#<br />
OneBedroomILB: #OneBedroomILB_0# 
#OneBedroomILB_1#
#OneBedroomILB_2#
#OneBedroomILB_3#
#OneBedroomILB_4#
#OneBedroomILB_5#
#OneBedroomILB_6#<br />
OneBedroomILC: #OneBedroomILC_0#
#OneBedroomILC_1#
#OneBedroomILC_2#
#OneBedroomILC_3#
#OneBedroomILC_4#
#OneBedroomILC_5#
#OneBedroomILC_6#<br />
OneBedroomILD: #OneBedroomILD_0#
#OneBedroomILD_1#
#OneBedroomILD_2#
#OneBedroomILD_3#
#OneBedroomILD_4#
#OneBedroomILD_5#
#OneBedroomILD_6#<br />
OneBedroomILE: #OneBedroomILE_0#
#OneBedroomILE_1#
#OneBedroomILE_2#
#OneBedroomILE_3#
#OneBedroomILE_4#
#OneBedroomILE_5#
#OneBedroomILE_6#<br />
StudioALA:#StudioALA_0#
#StudioALA_1#
#StudioALA_2#
#StudioALA_3#
#StudioALA_4#
#StudioALA_5#
#StudioALA_6#<br />
StudioALB: #StudioALB_0#
#StudioALB_1#
#StudioALB_2#
#StudioALB_3#
#StudioALB_4#
#StudioALB_5#
#StudioALB_6#<br />
StudioALC:#StudioALC_0# 
#StudioALC_1#
#StudioALC_2#
#StudioALC_3#
#StudioALC_4#
#StudioALC_5#
#StudioALC_6#<br />
StudioILA: #StudioILA_0#
#StudioILA_1#
#StudioILA_2#
#StudioILA_3#
#StudioILA_4#
#StudioILA_5#
#StudioILA_6#<br />
TwoBedroomALA: #TwoBedroomALA_0#
#TwoBedroomALA_1#
#TwoBedroomALA_2#
#TwoBedroomALA_3#
#TwoBedroomALA_4#
#TwoBedroomALA_5#
#TwoBedroomALA_6#<br />
TwoBedroomALB: #TwoBedroomALB_0#
#TwoBedroomALB_1#
#TwoBedroomALB_2#
#TwoBedroomALB_3#
#TwoBedroomALB_4#
#TwoBedroomALB_5#
#TwoBedroomALB_6#<br />
TwoBedroomILA: #TwoBedroomILA_0#
#TwoBedroomILA_1#
#TwoBedroomILA_2#
#TwoBedroomILA_3#
#TwoBedroomILA_4#
#TwoBedroomILA_5#
#TwoBedroomILA_6#<br />
TwoBedroomILB: #TwoBedroomILB_0#
#TwoBedroomILB_1#
#TwoBedroomILB_2#
#TwoBedroomILB_3#
#TwoBedroomILB_4#
#TwoBedroomILB_5#
#TwoBedroomILB_6#<br />
ILStudio:#ILStudio_0# 
#ILStudio_1#
#ILStudio_2#
#ILStudio_3#
#ILStudio_4#
#ILStudio_5#
#ILStudio_6#<br />
ILOneBedroom: #ILOneBedroom_0#  
#ILOneBedroom_1#
#ILOneBedroom_2#
#ILOneBedroom_3#
#ILOneBedroom_4#
#ILOneBedroom_5#
#ILOneBedroom_6#<br />
ILTwoBedroom: #ILTwoBedroom_0# 
#ILTwoBedroom_1#
#ILTwoBedroom_2#
#ILTwoBedroom_3#
#ILTwoBedroom_4#
#ILTwoBedroom_5#
#ILTwoBedroom_6#<br />
IL2BedroomDlx: #IL2BedroomDlx_0# 
#IL2BedroomDlx_1#
#IL2BedroomDlx_2#
#IL2BedroomDlx_3#
#IL2BedroomDlx_4#
#IL2BedroomDlx_5#
#IL2BedroomDlx_6#<br />
IL2BedroomDlxComb: #IL2BedroomDlxComb_0#  
#IL2BedroomDlxComb_1#
#IL2BedroomDlxComb_2#
#IL2BedroomDlxComb_3#
#IL2BedroomDlxComb_4#
#IL2BedroomDlxComb_5#
#IL2BedroomDlxComb_6#<br />
IL1BedroomC: #IL1BedroomC_0# 
#IL1BedroomC_1#
#IL1BedroomC_2#
#IL1BedroomC_3#
#IL1BedroomC_4#
#IL1BedroomC_5#
#IL1BedroomC_6#<br />
IL1BedroomDlxC: #IL1BedroomDlxC_0# 
#IL1BedroomDlxC_1#
#IL1BedroomDlxC_2#
#IL1BedroomDlxC_3#
#IL1BedroomDlxC_4#
#IL1BedroomDlxC_5#
#IL1BedroomDlxC_6#<br />
IL2BedroomC: #IL2BedroomC_0# 
#IL2BedroomC_1#
#IL2BedroomC_2#
#IL2BedroomC_3#
#IL2BedroomC_4#
#IL2BedroomC_5#
#IL2BedroomC_6#<br />
IL2BedroomDlxC: #IL2BedroomDlxC_0# 
#IL2BedroomDlxC_1#
#IL2BedroomDlxC_2#
#IL2BedroomDlxC_3#
#IL2BedroomDlxC_4#
#IL2BedroomDlxC_5#
#IL2BedroomDlxC_6#<br />
ILInvest1Bedroom: #ILInvest1Bedroom_0# 
#ILInvest1Bedroom_1#
#ILInvest1Bedroom_2#
#ILInvest1Bedroom_3#
#ILInvest1Bedroom_4#
#ILInvest1Bedroom_5#
#ILInvest1Bedroom_6#<br />
ILInvest2Bedroom: #ILInvest2Bedroom_0# 
#ILInvest2Bedroom_1#
#ILInvest2Bedroom_2#
#ILInvest2Bedroom_3#
#ILInvest2Bedroom_4#
#ILInvest2Bedroom_5#
#ILInvest2Bedroom_6#<br />
ILInvest2BedroomDlx: #ILInvest2BedroomDlx_0# 
#ILInvest2BedroomDlx_1#
#ILInvest2BedroomDlx_2#
#ILInvest2BedroomDlx_3#
#ILInvest2BedroomDlx_4#
#ILInvest2BedroomDlx_5#
#ILInvest2BedroomDlx_6#<br />
ILInvest2BedroomLux: #ILInvest2BedroomLux_0# 
#ILInvest2BedroomLux_1#
#ILInvest2BedroomLux_2#
#ILInvest2BedroomLux_3#
#ILInvest2BedroomLux_4#
#ILInvest2BedroomLux_5#
#ILInvest2BedroomLux_6#<br />
StudioPrem: #StudioPrem_0# 
#StudioPrem_1#
#StudioPrem_2#
#StudioPrem_3#
#StudioPrem_4#
#StudioPrem_5#
#StudioPrem_6#<br />
OneBedroomPrem: #OneBedroomPrem_0# 
#OneBedroomPrem_1#
#OneBedroomPrem_2#
#OneBedroomPrem_3#
#OneBedroomPrem_4#
#OneBedroomPrem_5#
#OneBedroomPrem_6#<br />
TwoBedroomPrem: #TwoBedroomPrem_0# 
#TwoBedroomPrem_1#
#TwoBedroomPrem_2#
#TwoBedroomPrem_3#
#TwoBedroomPrem_4#
#TwoBedroomPrem_5#
#TwoBedroomPrem_6#<br />
Comp1BedroomDlx: #Comp1BedroomDlx_0# 
#Comp1BedroomDlx_1#
#Comp1BedroomDlx_2#
#Comp1BedroomDlx_3#
#Comp1BedroomDlx_4#
#Comp1BedroomDlx_5#
#Comp1BedroomDlx_6#<br />
Comp2BedroomDlx: #Comp2BedroomDlx_0# 
#Comp2BedroomDlx_1#
#Comp2BedroomDlx_2#
#Comp2BedroomDlx_3#
#Comp2BedroomDlx_4#
#Comp2BedroomDlx_5#
#Comp2BedroomDlx_6#<br />
Comp2BedroomALA: #Comp2BedroomALA_0# 
#Comp2BedroomALA_1#
#Comp2BedroomALA_2#
#Comp2BedroomALA_3#
#Comp2BedroomALA_4#
#Comp2BedroomALA_5#
#Comp2BedroomALA_6#<br />
OneBedroomPremPlus: #OneBedroomPremPlus_0# 
#OneBedroomPremPlus_1#
#OneBedroomPremPlus_2#
#OneBedroomPremPlus_3#
#OneBedroomPremPlus_4#
#OneBedroomPremPlus_5#
#OneBedroomPremPlus_6#<br />
OneBedroomPremPlus: #OneBedroomPremPlus_0# 
#OneBedroomPremPlus_1#
#OneBedroomPremPlus_2#
#OneBedroomPremPlus_3#
#OneBedroomPremPlus_4#
#OneBedroomPremPlus_5#
#OneBedroomPremPlus_6#<br />
CompStudioPrem: #CompStudioPrem_0# 
#CompStudioPrem_1#
#CompStudioPrem_2#
#CompStudioPrem_3#
#CompStudioPrem_4#
#CompStudioPrem_5#
#CompStudioPrem_6#<br />
CompStudioPrem: #CompStudioPrem_0# 
#CompStudioPrem_1#
#CompStudioPrem_2#
#CompStudioPrem_3#
#CompStudioPrem_4#
#CompStudioPrem_5#
#CompStudioPrem_6#<br />
ILStudioPrem: #ILStudioPrem_0# 
#ILStudioPrem_1#
#ILStudioPrem_2#
#ILStudioPrem_3#
#ILStudioPrem_4#
#ILStudioPrem_5#
#ILStudioPrem_6#<br />
IL1BedroomPrem: #IL1BedroomPrem_0# 
#IL1BedroomPrem_1#
#IL1BedroomPrem_2#
#IL1BedroomPrem_3#
#IL1BedroomPrem_4#
#IL1BedroomPrem_5#
#IL1BedroomPrem_6#<br />
IL2BedroomPrem: #IL2BedroomPrem_0# 
#IL2BedroomPrem_1#
#IL2BedroomPrem_2#
#IL2BedroomPrem_3#
#IL2BedroomPrem_4#
#IL2BedroomPrem_5#
#IL2BedroomPrem_6#<br />
Comp2BedroomPrem: #Comp2BedroomPrem_0# 
#Comp2BedroomPrem_1#
#Comp2BedroomPrem_2#
#Comp2BedroomPrem_3#
#Comp2BedroomPrem_4#
#Comp2BedroomPrem_5#
#Comp2BedroomPrem_6#<br />
MCStudio: #MCStudio_0# 
#MCStudio_1#
#MCStudio_2#
#MCStudio_3#
#MCStudio_4#
#MCStudio_5#
#MCStudio_6#<br />
MCStudioDlx: #MCStudioDlx_0# 
#MCStudioDlx_1#
#MCStudioDlx_2#
#MCStudioDlx_3#
#MCStudioDlx_4#
#MCStudioDlx_5#
#MCStudioDlx_6#<br />
MCCompStudio: #MCCompStudio_0# 
#MCCompStudio_1#
#MCCompStudio_2#
#MCCompStudio_3#
#MCCompStudio_4#
#MCCompStudio_5#
#MCCompStudio_6#<br />
MCCompStudioDlx: #MCCompStudioDlx_0# 
#MCCompStudioDlx_1#
#MCCompStudioDlx_2#
#MCCompStudioDlx_3#
#MCCompStudioDlx_4#
#MCCompStudioDlx_5#
#MCCompStudioDlx_6#<br />
MCOneBedroom: #MCOneBedroom_0# 
#MCOneBedroom_1#
#MCOneBedroom_2#
#MCOneBedroom_3#
#MCOneBedroom_4#
#MCOneBedroom_5#
#MCOneBedroom_6#<br />
MCCompanionOneBedroom: #MCCompanionOneBedroom_0# 
#MCCompanionOneBedroom_1#
#MCCompanionOneBedroom_2#
#MCCompanionOneBedroom_3#
#MCCompanionOneBedroom_4#
#MCCompanionOneBedroom_5#
#MCCompanionOneBedroom_6#<br />
MCTwoBedroom: #MCTwoBedroom_0# 
#MCTwoBedroom_1#
#MCTwoBedroom_2#
#MCTwoBedroom_3#
#MCTwoBedroom_4#
#MCTwoBedroom_5#
#MCTwoBedroom_6#<br />
MCCompanionTwoBedroom: #MCCompanionTwoBedroom_0# 
#MCCompanionTwoBedroom_1#
#MCCompanionTwoBedroom_2#
#MCCompanionTwoBedroom_3#
#MCCompanionTwoBedroom_4#
#MCCompanionTwoBedroom_5#
#MCCompanionTwoBedroom_6#<br />

</cfoutput>

</body>
</html>
