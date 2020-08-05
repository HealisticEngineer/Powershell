function Get-InfluxDBData {
    param(
        [Parameter()]
        $Url = 'http://localhost:8086/query?db=performance_data',
        [Parameter()]
        $Query
    )

    $Results = (Invoke-RestMethod -Uri "$Url&q=$Query").results.series
    $results | ForEach-Object {
        $ResultSeries = @{
            Fields = new-object system.collections.stack
        }
        foreach($tag in $_.tags.PSObject.Properties) {
            $ResultSeries[$tag.Name] = $Tag.Value
        }
        $Columns = $_.columns
        $_.values | ForEach-Object {
            $Result = @{}
            for($i = 0; $i -lt $Columns.Length; $i++) {
                if ($Columns[$i] -eq 'time') {
                    $result.time = [DateTime]$_[$i]
                } else {
                    $Result[$columns[$i]] = $_[$i]
                }
            }
            $ResultSeries.fields.push($result)
        }
    }
    return $ResultSeries.Fields
}

$query = 'SELECT * FROM "win_cpu"'
$Url ='http://192.168.1.204:8086/query?db=performance_data'
$data = Get-InfluxDB -Url $Url -Query $query
