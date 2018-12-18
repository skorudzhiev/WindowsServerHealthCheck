### Healthcheck showing server Uptime, 3389 Port Status, TermService and ProfSvc status
### To Run the script create file named "server-list.txt", 
### containing the list of server names and place it in the script's directory. 
### Execute the script. When it is finished it will create results.txt file in the same directory

$names = Get-Content ".\server-list.txt" 
        @( 
           foreach ($name in $names) 
          { 
            if ( Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue )  
          { 
            $wmi = gwmi Win32_OperatingSystem -computer $name 
            $LBTime = $wmi.ConvertToDateTime($wmi.Lastbootuptime) 
            [TimeSpan]$uptime = New-TimeSpan $LBTime $(get-date)

            Write-output "$name" 
            Write-output "Uptime is:  $($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds"
            Write-output "`n"
            $t = New-Object System.Net.Sockets.TcpClient "$name", 3389; 
              if($t.Connected) 
               {
                "Port 3389 is Open and Connected"
               }
            $TermServiceStatus = (Get-Service -ComputerName "$name" -Name "TermService").Status
            $UserProfileStatus = (Get-Service -ComputerName "$name" -Name "ProfSvc").Status
            Write-Output "Remote Desktop Service is in Status: $TermServiceStatus" 
            Write-Output "User Profile Service is in Status: $UserProfileStatus"
            Write-Output "---------------------------------------------------------------------------------" 
          } 
             else { 
                Write-output "$name is not pinging" 
                  } 
               } 
         ) | Out-file -FilePath ".\results.txt"
