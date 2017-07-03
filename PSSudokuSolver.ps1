function Get-CrossResult{

    param(
        $input1,
        $input2
    )

    foreach($i1 in $input1){

        foreach($i2 in $input2){
            "$i1$i2"
        }
    }
}


$script:digits   = '123456789'.ToCharArray()
$script:rows     = 'ABCDEFGHI'.ToCharArray()
$script:cols     = $script:digits

$script:squares  = Get-CrossResult -input1 $script:rows -input2 $script:cols

$unitList = $null

foreach($col in $script:cols){
    $unitList += ,(Get-CrossResult -input1 $script:rows -input2 $col)
}

foreach($row in $script:rows){
    $unitList += ,(Get-CrossResult -input1 $row -input2 $script:cols)
}


$gRows = ('A','B','C'),('D','E','F'),('G','H','I')
$gCols = ('1','2','3'),('4','5','6'),('7','8','9')

foreach($gRow in $gRows){

    foreach($gCol in $gCols){

        $unitList += ,(Get-CrossResult -input1 $gRow -input2 $gCol)
    }
}

$script:units = @{}

foreach($s in $script:squares){

    $script:units[$s] = @()

    foreach($uil in $unitList){

        if($s -in $uil){

            $newAL = New-Object -TypeName System.Collections.ArrayList
            foreach($temp in $uil){
                $null = $newAL.Add($temp)
            }
            
            $script:units[$s] += ,$newAL
        }
    }
}

$script:peers = @{}

foreach($square in $script:squares){
    $script:peers[$square] = @()

    foreach($unit in $script:units[$square]){

        foreach($cUnit in $unit){
            if($cUnit -ne $square -and $cUnit -notin $script:peers[$square]){
                $script:peers[$square] += ,$cUnit
            }
        }
    }
}

$squaresCount = ($script:squares | Measure-Object).Count

if($squaresCount -ne 81){
    Write-Warning "Square Measures should be 81, but is: $squaresCount"
}

$unitListCount = ($unitList | Measure-Object).Count

if($unitListCount -ne 27){
    Write-Warning "UnitList Measures should be 27, but is: $unitListCount"
}

foreach($s in $script:squares){

    $unitCount = ($script:units[$s] | Measure-Object).Count

    if($unitCount -ne 3){
        Write-Warning "Unit Measures should be 3, but is: $unitCount"
    }

}

foreach($s in $script:squares){

    $peerCount = ($script:peers[$s] | Measure-Object).Count

    if($peerCount -ne 20){
        Write-Warning "Unit Measures should be 20, but is: $peerCount"
    }

}

$testArray = ('A2', 'B2', 'C2', 'D2', 'E2', 'F2', 'G2', 'H2', 'I2'),
('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9'),
('A1', 'A2', 'A3', 'B1', 'B2', 'B3', 'C1', 'C2', 'C3')

$unitResult = (Compare-Object -ReferenceObject $script:units["C2"] -DifferenceObject $testArray)

if($unitResult -ne $null){
    Write-Warning "Unit Test should be null!"
}

$peerTestArray = 'A2', 'B2', 'D2', 'E2', 'F2', 'G2', 'H2', 'I2',
'C1', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9',
'A1', 'A3', 'B1', 'B3'


$peerResult = (Compare-Object -ReferenceObject $script:peers["C2"] -DifferenceObject $peerTestArray)

if($peerResult -ne $null){
    Write-Warning "Peer Test should be null!"
}


$gridString = "003020600900305001001806400008102900700000008006708200002609500800203009005010300"

function Get-ParsedGridAsString{

    param(
        $gridString,
        [ValidateSet("Basic","Enhanced")]
        $outputType
    )

    $gridCharArray = $gridString.Replace(".","0").ToCharArray()

    if($outputType -eq "Basic"){

        $counter1 = 0
        $counter2 = 8

        Write-Output ""

        foreach($number in (1..9)){

            Write-Output $gridCharArray[$counter1..$counter2]

            $counter1 += 9
            $counter2 += 9
        }

        Write-Output ""

    }
    elseif($outputType -eq "Enhanced"){
        
        $counter1 = 0
        $counter2 = 8
        $horizontalCounter = 0

        $horizontalTemplate = "- - - + - - - + - - -"

        Write-Output ""

        foreach($number in (1..9)){
            
            $charsToWorkOn = $gridCharArray[$counter1..$counter2]
            $firstPart = $charsToWorkOn[0..2]
            $secondPart = $charsToWorkOn[3..5]
            $thirdPart = $charsToWorkOn[6..8]

            $outputString = "$firstPart | $secondPart | $thirdPart"

            Write-Output $outputString

            $horizontalCounter++

            if($horizontalCounter -eq 3 -and $counter2 -lt 80){
                Write-Output $horizontalTemplate
                $horizontalCounter = 0
            }

            $counter1 += 9
            $counter2 += 9
        }

        Write-Output ""

    }
}


function Get-ValidGridHashTable{

    param(
        $gridString        
    )

    $validChars = "0.-123456789".ToCharArray()

    $outString = ""

    foreach($char in $gridString.ToCharArray()){
        if($char -in $validChars){
            $outString += $char
        }
    }

    $gridHT = @{}

    $outStringArray = $outString.ToCharArray()

    foreach($sq in $script:squares){

        $gridHT[$sq] = $outStringArray[$script:squares.IndexOf($sq)]

    }


    return $gridHT
}

function Get-ParsedGrid{

    param(
        $gridString        
    )

    $gridHT = Get-ValidGridHashTable -gridString $gridString
    
    $script:values = @{}

    foreach($sq in $script:squares){
        $script:values[$sq] = $script:digits -join ""
    }

    foreach($sq in $script:squares){

        $currentGridHTValue = $gridHT[$sq]

        if($currentGridHTValue -in $script:digits){
            Start-ValueAssignment -square $sq -digit $currentGridHTValue
        }
    }

    return $script:values
}

function Start-ValueAssignment{

    param(        
        $square,
        $digit
    )

    $otherValuesArray = $script:values[$square].Replace([string]$digit,"").ToCharArray()

    foreach($otherValue in $otherValuesArray){
            Start-ValueElimination -searchSquare $square -digitToEliminate $otherValue    
    }

}

function Start-ValueElimination{

    param(        
        $searchSquare,
        $digitToEliminate
    )

    if($digitToEliminate -notin $script:values[$searchSquare].ToCharArray()){
        Write-Warning "Already eliminated: $digitToEliminate in $searchSquare"
        return # Value already Eliminated, stop processing and go back
    }

    $script:values[([string]$searchSquare)] = $script:values[([string]$searchSquare)].Replace([string]$digitToEliminate,"")

    if(($script:values[$searchSquare].ToCharArray() | Measure-Object).Count -eq 0){
        throw "Contradiction: Removed the Last Value!" #Contratiction: Removed the last value
    }
    elseif(($script:values[$searchSquare].ToCharArray() | Measure-Object).Count -eq 1){

        $oneRemainingValue = $script:values[$searchSquare]
        $squarePeers = $script:peers[$searchSquare]
        foreach($peer in $squarePeers){
            
            Start-ValueElimination -searchSquare $peer -digitToEliminate $oneRemainingValue

        }
    }

    $squareUnits = $script:units[$searchSquare]
    foreach($unit in $squareUnits){

        [Array]$digitsPlaces = $null

        foreach($un in $unit){

            if($digitToEliminate -in $script:values[$un].ToCharArray()){
                [Array]$digitsPlaces += $un
            }
        }
        
        if(($digitsPlaces | Measure-Object).Count -eq 0){
            throw "Contradiction: No Place for this Value!" #Contradiction: No Place for this Value
        }
        elseif(($digitsPlaces | Measure-Object).Count -eq 1){
            
            Start-ValueAssignment -square $digitsPlaces -digit $digitToEliminate
        }
    }
}

Get-ParsedGrid -gridString $gridString

