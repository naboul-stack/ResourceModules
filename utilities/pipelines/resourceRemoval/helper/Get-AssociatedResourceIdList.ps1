function Get-AssociatedResourceIdList {

    [CmdletBinding()]
    param(
        [Parameter (Mandatory = $true)]
        [string] $ResourceGroupName, # TODO: Should be fetched from the resource ID

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

        # Fetch the lines that match '"id": "<desiredResourceId>"'
        $associatedResourceIds = (Get-Content -Path $resourceJsonFilePath | Select-String -Pattern '"id"').Line.Trim() | ForEach-Object {
            ($_ | Select-String ': "(.*)"').Matches.Groups[1].Value
        }
        return $associatedResourceIds
    } catch {
        throw $_
    } finally {
        if (Test-Path $resourceJsonFilePath) {
            Remove-Item $resourceJsonFilePath -Force
        }
    }
}
