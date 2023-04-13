


function show_prompt() {
    $choice = Read-Host -Prompt "Select an Option:
    0. Quit
    1. Show unning Processes and the path for each process.
    2. Show all registered services and the path to the executable controlling the service 
    3. Show all TCP network sockets
    4. Show all user account information 
    5. Show all NetworkAdapterConfiguration information.
    6. Show disk information
    7. Show groups
    8. Show Operating System 
    9. Show tasks
    10. Show expected results for tasks"
    $choice

    switch ($choice) 
    {
     0 { create_zip}
     1 {show_process}
     2 {show_service}
     3 {show_sock}
     4 {show_info}
     5 {show_adapter}
     6 {show_disk}
     7 {show_groups}
     8 {show_OS}
     9 {show_tasks}
     10 {show_results}
    }
}
#make results directory that all files are saved to
$myDir= "C:\Users\imktr\Desktop\Results"
function show_results() { # I tried to create an option to display results but for some reason even though these commands will execute perfectly as an indivdually, once they are put in this script the computer struggles to display them before executing the following function
$choice = Read-Host -Prompt "Which task would you like to see results for:
    0. Main Menu
    1. Show unning Processes and the path for each process.
    2. Show all registered services and the path to the executable controlling the service
    3. Show all TCP network sockets
    4. Show all user account information 
    5. Show all NetworkAdapterConfiguration information.
    6. Show disk information
    7. Show groups
    8. Show Operating System 
    9. Show tasks"
     switch ($choice) 
    {
     0 {show_prompt}
     1 {
     Get-Process | Select-Object Name, Path
     show_prompt
     }
     2 {
     Get-WmiObject win32_service | select Name, PathName
     show_prompt
     }
     3 {
     Get-NetTCPConnection | select LocalAddress, LocalPort
     show_prompt
     }
     4 {
     Get-WmiObject Win32_UserAccount | Select AccountType, Caption, Domain, SID, FullName, Name
     show_prompt
     }
     5 {
     Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE |select DHCPEnabled, IPAddress, DefaultIPGateway, DNSDomain, ServiceName, Description, Index
     show_prompt
     }
     6 {
     Get-WmiObject win32_DiskDrive | Select-Object size, partitions, status, model, name, mediatype, index, caption, deviceid
     show_prompt
     }
     7 {
     Get-LocalGroup
     show_prompt
     }
     8 {
     Get-CimInstance win32_OperatingSystem | Select SystemDirectory, Organization, BuildNumber, RegisteredUser, SerialNumber, Version
     show_prompt
     }
     9 {
     Get-ScheduledTask | Select-Object taskname, taskpath, author, actions, triggers, description, state | where Author -NotLike 'Microsoft*' | where Author -NE $null | where Author -NotLike '*@%SystemRoot%\*' 
     show_prompt
     }
    }
}

function create_zip() {
    $file="C:\Users\imktr\Desktop\results.zip"
    $compress = @{
      Path = $myDir
      CompressionLevel = "Fastest"
      DestinationPath = $file
    }
    Compress-Archive @compress
    $hash = Get-FileHash $file | Select-Object Hash
    Add-Content -Path "C:\Users\imktr\Desktop\zipChecksum.txt" -Value $hash 
    break
}

function show_process() {
    $file="$myDir\process.csv"
    Get-Process | Select-Object Name, Path | export-csv -NoTypeInfo -Path $file
    $hash = Get-FileHash $file | Select-Object Hash
    Add-Content -Path "$myDir\checksum.txt" -Value "$hash process.csv" 
    Write-Host "Created the file process.csv. Checksum: $hash"
    show_prompt
}

function show_service() {
    $file="$myDir\service.csv"
    Get-WmiObject win32_service | select Name, PathName | export-csv -NoTypeInfo -Path $file
    $hash = Get-FileHash $file | Select-Object Hash
    Add-Content -Path "$myDir\checksum.txt" -Value "$hash service.csv"
    Write-Host "Created the file service.csv. Checksum: $hash"
    show_prompt
}

function show_sock() {
    $file="$myDir\netSock.csv"
    Get-NetTCPConnection | select LocalAddress, LocalPort | export-csv -NoTypeInfo -Path $file
    $hash = Get-FileHash $file | Select-Object Hash
    Add-Content -Path "$myDir\checksum.txt" -Value "$hash netSock.csv"
    Write-Host "Created the file netSocks.csv. Checksum: $hash"
    show_prompt
}

function show_info() {
    $file="$myDir\userInfo.csv"
    Get-WmiObject Win32_UserAccount | Select AccountType, Caption, Domain, SID, FullName, Name | export-csv -NoTypeInfo -Path $file
    $hash = Get-FileHash $file | Select-Object Hash
    Add-Content -Path "$myDir\checksum.txt" -Value "$hash userInfo.csv"
    Write-Host "Created the file userInfo.csv. Checksum: $hash"
    show_prompt
}

function show_adapter() {
    $file="$myDir\netAdpater.csv"
    Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE |select DHCPEnabled, IPAddress, DefaultIPGateway, DNSDomain, ServiceName, Description, Index| export-csv -NoTypeInfo -Path $file
    $hash = Get-FileHash $file | Select-Object Hash
    Add-Content -Path "$myDir\checksum.txt" -Value "$hash netAdapter.csv"
    Write-Host "Created the file netAdapter.csv. Checksum: $hash"
    show_prompt
}

function show_disk() { #I chose this option so that you can have information about the disk which I think could be useful in incidence response
    $file="$myDir\disk.csv"
    Get-WmiObject win32_DiskDrive | Select-Object size, partitions, status, model, name, mediatype, index, caption, deviceid | export-csv -NoTypeInformation -Path $file
    $hash = Get-FileHash $file | Select-Object Hash
    Add-Content -Path "$myDir\checksum.txt" -Value "$hash disk.csv"
    Write-Host "Created the file disks.csv. Checksum: $hash"
    show_prompt
}

function show_groups() { #I chose this option because in incidence response I think it would be important to see what groups there are on the computer and make sure there are no unauthorized ones
    $file="$myDir\groups.csv"
    Get-LocalGroup | export-csv -NoTypeInfo -Path $file
    $hash = Get-FileHash $file | Select-Object Hash
    Add-Content -Path "$myDir\checksum.txt" -Value "$hash groups.csv"
    Write-Host "Created the file groups.csv. Checksum: $hash"
    show_prompt
}

function show_OS() { #I chose this command because I think it would be useful in incidence response to have information about the operating system such as it's version and how long it's been on
    $file="$myDir\OS.csv"
    Get-CimInstance win32_OperatingSystem | Select SystemDirectory, Organization, BuildNumber, RegisteredUser, SerialNumber, Version    | Select-Object Caption, Version, servicepackmajorversion, BuildNumber, CSName, LastBootUpTime | export-csv -NoTypeInfo -Path $file
    $hash = Get-FileHash $file | Select-Object Hash
    Add-Content -Path "$myDir\checksum.txt" -Value "$hash OS.csv"
    Write-Host "Created the file OS.csv. Checksum: $hash"
    show_prompt
}

function show_tasks() { #I chose this path because I thought it would be useful to see the 3rd party scheduled tasks on the computer 
    $file="$myDir\tasks.csv"
    Get-ScheduledTask | Select-Object taskname, taskpath, author, actions, triggers, description, state | where Author -NotLike 'Microsoft*' | where Author -NE $null | where Author -NotLike '*@%SystemRoot%\*' | export-csv -NoTypeInfo -Path $file
    $hash = Get-FileHash $file | Select-Object Hash
    Add-Content -Path "$myDir\checksum.txt" -Value "$hash tasks.csv"
    Write-Host "Created the file tasks.csv. Checksum: $hash"
    show_prompt
}
show_prompt
