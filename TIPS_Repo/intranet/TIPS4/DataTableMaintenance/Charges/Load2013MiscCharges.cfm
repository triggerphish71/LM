<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfset thisenddate = CreateODBCDateTime('2020-12-31')> 
<cfset thisstartdate = CreateODBCDateTime('2012-12-01')>
<cfset thisAcctdate = CreateODBCDateTime('2012-12-01')>
<cfset datenow = CreateODBCDateTime(now())>
<cfquery name="qryMiscCharges" datasource="#APPLICATION.datasource#">
select * 
 
from dbo.Charges chgs
where  chgs.ichargetype_id in (8
,12
,13
,14
,28
,31
,36
,42
,43
,44
,52
,57
,61
,66
,69
,77
,83
,96
,99
,1642
,1643
,1644
,1645
,1646
,1647
,1648
,1649
,1650
,1651
,1652
,1653
,1654
,1655
,1656
,1657
,1658
,1661
,1662
,1663
,1664
,1668
,1669
,1670
,1671
,1672
,1673
,1674
,1675
,1676
,1677
,1678
,1680
,1681
,1682
,1683
,1684
,1685
,1686
,1687
,1688
,1689
,1690
,1691
,1692
,1693
,1694
,1695
,1696
,1697
,1698
,1699
,1700
,1701
,1702
,1703
,1705
,1706
,1707
,1708
,1709
,1710
,1711
,1712
,1713
,1714
,1715
,1716
,1717
,1718
,1719
,1720
,1721
,1722
,1723
,1724
,1725
,1726
,1727
,1728
,1729
,1730
,1731
,1732
,1733
,1734
,1735
,1736
,1737
,1738
,1739
,1740
,1741
,1742
,1743
 )
  and chgs.cchargeset = '2012Jan'
  and chgs.dtrowdeleted is null
  order by chgs.ihouse_id, chgs.ichargetype_id 
</cfquery>
<body>
<cfset reccount = 0>
<cftransaction>
	<cfoutput >
		<cfloop query="qryMiscCharges">		
 
<!---   	<cfquery name="updatechg"  datasource="#APPLICATION.datasource#" >
					INSERT INTO [TIPS4].[dbo].[Charges]
							   ([iChargeType_ID] 
							   ,[iHouse_ID]
							   ,[cChargeSet]
							   ,[cDescription]
							   ,[mAmount]
							   ,[iQuantity]
							  <!---  ,[iResidencyType_ID] --->
							  <!---  ,[iAptType_ID] --->
							 <cfif iOccupancyPosition is not ''>   ,[iOccupancyPosition]</cfif>
							   ,[dtAcctStamp]
							   ,[dtEffectiveStart]
							   ,[dtEffectiveEnd]
							   ,[iRowStartUser_ID]
							   ,[dtRowStart]
							   ,[cRowStartUser_ID]
							<cfif iProductLine_ID is not ''>   , [iProductLine_ID]</cfif>
							  <cfif bIsMoveInCharge is not ''> ,[bIsMoveInCharge]</cfif>
							 )    
						 VALUES     --->                 
							(	 #iChargeType_ID# 						<!--- iChargeType_ID --->
							   ,#iHouse_ID#  			<!--- iHouse_ID ---> 
							   ,'2013Jan'   			<!--- cChargeSet --->
							   ,'#cDescription#' 	 <!--- cDescription --->
							   ,#mAmount#  		<!--- mAmount --->
							   ,1						<!--- iQuantity --->
							<!---   ,3						 iResidencyType_ID --->
							<!---   , 			 iAptType_ID --->
							 <cfif iOccupancyPosition is not ''>   ,#iOccupancyPosition#	</cfif>					<!--- iOccupancyPosition --->				
							   ,#thisAcctdate#			<!--- dtAcctStamp --->		
							   ,#thisstartdate# 		<!--- dtEffectiveStart --->
							   ,#thisenddate#			<!--- dtEffectiveEnd --->	
							   ,#session.userid#		<!--- iRowStartUser_ID --->
							   ,#datenow#				<!--- dtRowStart --->
							   ,'Jan2013 SFarmer MiscChgs 2012-12-04' <!---cRowStartUser_ID  --->
							 <cfif iProductLine_ID is not ''>   ,#iProductLine_ID# 	</cfif>					<!--- iProductLine_ID --->
							    <cfif bIsMoveInCharge is not ''> ,#bIsMoveInCharge# </cfif>
						 ) 
				<!---   </cfquery>   --->  <br />
				   <cfset reccount = reccount + 1>  
			</cfloop>
		</cfoutput>
	</cftransaction>
done  <cfoutput>Count: #reccount#</cfoutput>
</body>
</html>
