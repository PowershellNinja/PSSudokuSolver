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

$gridString = "003020600900305001001806400008102900700000008006708200002609500800203009005010300"
$gridString2 = "4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......"

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
    
    $values = @{}

    foreach($sq in $script:squares){
        $values[$sq] = $script:digits -join ""
    }

    foreach($sq in $script:squares){

        $currentGridHTValue = $gridHT[$sq]

        if($currentGridHTValue -in $script:digits){
            $values = Start-ValueAssignment -square $sq -digit $currentGridHTValue -values $values
        }
    }

    return $values
}

function Start-ValueAssignment{

    param(        
        $square,
        $digit,
        $values
    )

    Write-Verbose "Start-ValueAssignment, Square: $square, Digit: $digit"

    $otherValuesArray = $values[$square].Replace([string]$digit,"").ToCharArray()
    

    foreach($otherValue in $otherValuesArray){
            
            if([String]$otherValue -ne [String]$digit){
                $values = Start-ValueElimination -searchSquare $square -digitToEliminate $otherValue -values $values
            }
    }

    return $values
}

function Start-ValueElimination{

    param(
        [string]$searchSquare,
        [string]$digitToEliminate,
        $values
    )

    Write-Verbose "Start-ValueElimination, SearchSquare: $searchSquare, DigitToEliminate: $digitToEliminate"

    if([string]$digitToEliminate -notin $values[$searchSquare].ToCharArray()){
        Write-Warning "Already eliminated: $digitToEliminate in $searchSquare"
        return $values # Value already Eliminated, stop processing and return $values
    }

    $values[([string]$searchSquare)] = $values[([string]$searchSquare)].Replace([string]$digitToEliminate,"")

    if(($values[$searchSquare].ToCharArray() | Measure-Object).Count -eq 0){
        #Contradiction: Removed the last value
        throw "Contradiction: Removed the Last Value!"
    }
    elseif(($values[$searchSquare].ToCharArray() | Measure-Object).Count -eq 1){

        $oneRemainingValue = $values[$searchSquare]
        $squarePeers = $script:peers[$searchSquare]
        foreach($peer in $squarePeers){
            
            $values = Start-ValueElimination -searchSquare $peer -digitToEliminate $oneRemainingValue -values $values

        }
    }

    $squareUnits = $script:units[$searchSquare]
    foreach($unit in $squareUnits){

        [Array]$digitsPlaces = $null

        foreach($un in $unit){

            if($digitToEliminate -in $values[$un].ToCharArray()){
                [Array]$digitsPlaces += $un
            }
        }
        
        if(($digitsPlaces | Measure-Object).Count -eq 0){
            #Contradiction: No Place for this Value
            throw "Contradiction: No Place for this Value!"
        }
        elseif(($digitsPlaces | Measure-Object).Count -eq 1){
            
            $values = Start-ValueAssignment -square $digitsPlaces -digit $digitToEliminate -values $values
        }
    }

    return $values
}

#Just need this function because I tend to forget to use "478" String indicators when manually debugging... ;-P
#(And Int.Length is always 1)
function Start-ValueConversionToString{

    param(
        $values
    )

    $values.Keys | Where-Object{$values["$_"].GetType().Name -like "*int*"} | ForEach-Object{$values["$_"] = [string]$values["$_"]}

    return $values
}


function Start-ValueSearch{

    param(
        $values
    )

    Write-Verbose "Start-ValueSearch"

    #Just to be sure
    $values = Start-ValueConversionToString -values $values

    $allUnsolvedValues = $values.Values | Where-Object{$_.Length -gt 1}
    $allUnsolvedSquares =  $values.Keys | Foreach-Object{

        if($values["$_"].Length -gt 1){
            $_ #If the Square has more than 1 possible numbers left, return the square
        }
        #If not, the square is already solved 
    }

    $allUnsolvedValuesCount = 0
    $allUnsolvedValuesCount = ($allUnsolvedValues | Measure-Object).Count

    if($allUnsolvedValuesCount -eq 0){
        return $values #already solved the puzzle, no unsolved squares left
    }

    $lowestFoundCount = 9
    $lowestFoundSquare = ""

    foreach($unsolvedSquare in $allUnsolvedSquares){

        $squareValueLength = $values["$unsolvedSquare"].Length

        if($squareValueLength -lt $lowestFoundCount){
            $lowestFoundCount = $squareValueLength
            $lowestFoundSquare = $unsolvedSquare
        }
    }
    
    $lowestFoundSquareValues = $values[$lowestFoundSquare].ToCharArray()

    foreach($lValue in $lowestFoundSquareValues){
        $result = Start-ValueSearch -values (Start-ValueAssignment -values ($values.Clone()) -square $lowestFoundSquare -digit $lValue)
    }

    
    return $result
}


$parseResult = Get-ParsedGrid -gridString $gridString2
$searchResult = Start-ValueSearch -values $parseResult

function rembp{
    Get-PSBreakPoint | Remove-PSBreakPoint
}
rembp
Set-PSBreakPoint -Script "C:\Github\Repos\PSSudokuSolver\PSSudokuSolver_Search.ps1" -Command "Start-ValueAssignment" -Action {if($square -eq "D6"){break}}

