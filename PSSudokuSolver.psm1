function Get-CrossResult{

    param(
        $input1,
        $input2
    )

    $input1Array = $input1.ToCharArray()
    $input2Array = $input2.ToCharArray()

    foreach($i1 in $input1Array){

        foreach($i2 in $input2Array){
            "$i1$i2"
        }

    }
}


$digits   = '123456789'
$rows     = 'ABCDEFGHI'
$cols     = $digits

$squares  = Get-CrossResult -input1 $digits -input2 $rows




unitlist = ([cross(rows, c) for c in cols] +
            [cross(r, cols) for r in rows] +
            [cross(rs, cs) for rs in ('ABC','DEF','GHI') for cs in ('123','456','789')])
units = dict((s, [u for u in unitlist if s in u]) 
             for s in squares)
peers = dict((s, set(sum(units[s],[]))-set([s]))
             for s in squares)



