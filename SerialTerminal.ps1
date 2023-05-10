# Baud-rate of the connected device
$baud = 115200
# Maximum response time of the device (in milliseconds)
# Depends on the connected device, baud-rate and maximum text length
# If you notice missing texts in some cases, you can try to increase this time
$pollTime = 100
# How long should we wait for a response until we consider the device to be "too slow"
$timeoutForResponse = 2500

$waitBeforeExit = $True
$sendEmptyLines = $False

function WaitExit
{
	if ($serialPort -ne $null)
	{
		$serialPort.close()
	}
	if ($waitBeforeExit)
	{
		Start-Sleep -Seconds 2.5
	}
	Exit
}

function SendToSerial
{
	param (
		[string]$message,
		[System.IO.Ports.SerialPort]$serialPort
	)
	$serialPort.WriteLine($message)
}

function HandleUserInput
{
	param (
		[System.IO.Ports.SerialPort]$serialPort
	)
	
	Write-Host "> " -NoNewline
	$userInput = Read-Host
	# Only send lines if we need to
	if (($($userInput.Length) -gt 0) -or $sendEmptyLines)
	{
		SendToSerial $userInput $serialPort
	}
	
	return $userInput
}

function PrintResponse
{
	param (
		[System.IO.Ports.SerialPort]$serialPort
	)
	$responseTime = 0
	$deviceFinishFlag = "ok" + [char]10
	$currentResponse = ""
	$completeResponse = ""
	
	$currentResponse = $serialPort.ReadExisting()
	$completeResponse += $currentResponse
	Write-Host "$currentResponse" -NoNewline
	
	# We try to read the response until the device responds with the deviceFinishFlag
	while ($completeResponse.EndsWith($deviceFinishFlag) -ne $True)
	{
		Start-Sleep -Milliseconds $pollTime
		$currentResponse = $serialPort.ReadExisting()
		$completeResponse += $currentResponse
		Write-Host "$currentResponse" -NoNewline
		
		if ($currentResponse.Length -lt 1)
		{
			# We had no response, this means the device might be idle or is still working
			$responseTime += $pollTime
			if ($responseTime -ge $timeoutForResponse)
			{
				# Timeout threshold reached
				Write-Host "Timeout: Device did not respond in the required $timeoutForResponse milliseconds."
				break
			}
		}
		else
		{
			# Reset response timer whenever we got a response from the device
			$responseTime = 0
		}
	}
	
	return "$completeResponse"
}

try
{
	# Get port names
	$portNames = [System.IO.Ports.SerialPort]::getportnames()
	If ($portNames.GetLength(0) -le 0)
	{
		throw "No ports available!"
	}
	Write-Host "Available serial ports:"
	Write-Host "$portNames"
	Write-Host "---"
	$chosenPortName = Read-Host "Choose a port (if left empty '$($portNames[0])' will be used)"
	If ($chosenPortName.Length -le 0) 
	{
		$chosenPortName = $($portNames[0])
	}
	Write-Host "Trying to connect to the serial port '$chosenPortName'..."
	$serialPort = new-Object System.IO.Ports.SerialPort $chosenPortName,$baud,None,8,one
	$serialPort.open()
	Write-Host "Connected to serial port."
	Write-Host "--- You can terminate the connection with [Ctrl] + [C] ---"
	Write-Host "--- You can start typing ---"
	while ($True)
	{
		$userInput = HandleUserInput $serialPort
		if (($($userInput.Length) -gt 0) -or $sendEmptyLines)
		{
			$completeResponse = PrintResponse $serialPort
		}
	}
	$serialPort.close()
	Write-Host "Closed serial port."
}
catch
{
	Write-Host "A problem occured:"
	Write-Host "$($_.Exception.Message)"
	# Prints detailed information about the error
	#Write-Output $_
}
finally
{
	Write-Host "" # New line (in case something did not end the line)
	Write-Host "Execution stopped!"
	WaitExit
}
