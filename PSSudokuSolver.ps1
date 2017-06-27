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


$digits   = '123456789'.ToCharArray()
$rows     = 'ABCDEFGHI'.ToCharArray()
$cols     = $digits

$squares  = Get-CrossResult -input1 $rows -input2 $cols

$unitList = $null

foreach($col in $cols){
    $unitList += ,(Get-CrossResult -input1 $rows -input2 $col)
}

foreach($row in $rows){
    $unitList += ,(Get-CrossResult -input1 $row -input2 $cols)
}


$gRows = ('A','B','C'),('D','E','F'),('G','H','I')
$gCols = ('1','2','3'),('4','5','6'),('7','8','9')

foreach($gRow in $gRows){

    foreach($gCol in $gCols){

        $unitList += ,(Get-CrossResult -input1 $gRow -input2 $gCol)
    }
}

$units = @{}

foreach($s in $squares){

    $units[$s] = @()

    foreach($uil in $unitList){

        if($s -in $uil){
            $units[$s] += ,$uil
        }
    }
}

$peers = @{}

foreach($square in $squares){
    $peers[$square] = @()

    foreach($unit in $units[$square]){

        foreach($cUnit in $unit){
            if($cUnit -ne $square -and $cUnit -notin $peers[$square]){
                $peers[$square] += ,$cUnit
            }
        }
    }
}

$squaresCount = ($squares | Measure-Object).Count

if($squaresCount -ne 81){
    Write-Warning "Square Measures should be 81, but is: $squaresCount"
}

$unitListCount = ($unitList | Measure-Object).Count

if($unitListCount -ne 27){
    Write-Warning "UnitList Measures should be 27, but is: $unitListCount"
}

foreach($s in $squares){

    $unitCount = ($units[$s] | Measure-Object).Count

    if($unitCount -ne 3){
        Write-Warning "Unit Measures should be 3, but is: $unitCount"
    }

}

foreach($s in $squares){

    $peerCount = ($peers[$s] | Measure-Object).Count

    if($peerCount -ne 20){
        Write-Warning "Unit Measures should be 20, but is: $peerCount"
    }

}

$testArray = ('A2', 'B2', 'C2', 'D2', 'E2', 'F2', 'G2', 'H2', 'I2'),
('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9'),
('A1', 'A2', 'A3', 'B1', 'B2', 'B3', 'C1', 'C2', 'C3')

$unitResult = (Compare-Object -ReferenceObject $units["C2"] -DifferenceObject $testArray)

if($unitResult -ne $null){
    Write-Warning "Unit Test should be null!"
}

$peerTestArray = 'A2', 'B2', 'D2', 'E2', 'F2', 'G2', 'H2', 'I2',
'C1', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9',
'A1', 'A3', 'B1', 'B3'


$peerResult = (Compare-Object -ReferenceObject $peers["C2"] -DifferenceObject $peerTestArray)

if($peerResult -ne $null){
    Write-Warning "Peer Test should be null!"
}