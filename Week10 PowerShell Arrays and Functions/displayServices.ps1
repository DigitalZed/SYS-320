  do{ 
    $logChoice = Read-Host -Prompt "Would you like to view [A]ll/[R]unning/[S]topped services or [Q]uit?"
    $logChoice=$logChoice.ToUpper()

    $inputs = @("A","S","R","Q")
    if($inputs -match $logChoice){
        if($logChoice -match "^[Q]$") {
        break #end the program
        }

        if($logChoice -match "^[A]$") {
            $all #show all logs
        }

        if($logChoice -match "^[S]$") {
            $stopped #show stopped logs
        }

        if($logChoice -match "^[R]$") {
            $running #show running logs
        }
    }
    else {
    Write-Host "Please enter a valid input"
    }
}while($logChoice -notmatch "^[qQ]$")
