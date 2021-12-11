function Get-AssociatedResourceIdList {

    [CmdletBinding()]
    param(
        [Parameter (Mandatory = $true)]
        [string] $ResourceGroupName,

        [Parameter (Mandatory = $true)]
        [string] $ParentResourceId
    )

    $resourceJsonFilePath = '{0}.json' -f (Join-Path $PSScriptRoot $ResourceGroupName)

    try {
        $inputObject = @{
            ResourceGroupName       = $ResourceGroupName
            Resource                = $ParentResourceId
            Path                    = $resourceJsonFilePath
            SkipAllParameterization = $true
        }
        $null = Export-AzResourceGroup @inputObject

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
    } catch {
        throw $_
    } finally {
        if (Test-Path $resourceJsonFilePath) {
            Remove-Item $resourceJsonFilePath -Force
        }
    }
}
