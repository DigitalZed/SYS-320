#starts the calculator app
Start-Process -FilePath '.\Calc.exe' 

#stops the calculator app
Stop-Process -Name "CalculatorApp"
