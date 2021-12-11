function Get-AssociatedResourceIdList {

    [CmdletBinding()]
    param(
        [Parameter (Mandatory = $true)]
        $ResourceGroupName,

        [Parameter (Mandatory = $true)]
        $ParentResourceId
    )
    $resourceJsonFilePath = (Join-Path $PSScriptRoot $ResourceGroupName) + '.json'

    Export-AzResourceGroup -ResourceGroupName $ResourceGroupName `
        -Resource $ParentResourceId `
        -SkipAllParameterization `
        -Path $resourceJsonFilePath `
        -Confirm:$false -Force | Out-Null
    $filteredIds = (Get-Content -Path $resourceJsonFilePath | Select-String -Pattern '"id"') -replace '\s+'
    if ($filteredIds) {
        Write-Verbose '--------------------------Getting associated resources--------------------------'
        # Write-Verbose "Filtered Ids:`n$($filteredIds | Out-String)"
        foreach ($associatedResourceId in $filteredIds) {
            Write-Verbose "Found: $associatedResourceId"
            [Array]$associatedResourceIds += $associatedResourceId.Split('"')[3]
        }
        Return $associatedResourceIds
    } else {
        Write-Verbose "No further associated resource ids found in the parent resource: '$ParentResourceId'."
        Return $null
    }
}
