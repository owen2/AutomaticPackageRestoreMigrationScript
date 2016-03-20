Param(
   [switch]$RemoveSolutionDirProperty
)

. (Join-Path $PSScriptRoot "Get-FileEncoding.ps1")

########################################
# Regex Patterns for Really Bad Things!
$listOfBadStuff = New-Object System.Collections.ArrayList
[void]$listOfBadStuff.AddRange((
	#sln regex
	"\s*(\.nuget\\NuGet\.(exe|targets)) = \1",
	#*proj regexes
	"\s*<Import Project=""\$\(SolutionDir\)\\\.nuget\\NuGet\.targets"".*?/>",
	"\s*<Target Name=""EnsureNuGetPackageBuildImports"" BeforeTargets=""PrepareForBuild"">(.|\n)*?</Target>",
	"\s*<RestorePackages>\w*</RestorePackages>"))


if ($RemoveSolutionDirProperty) {
[void]$listOfBadStuff.Add("\s*<SolutionDir Condition=""\$\(SolutionDir\) == '' Or \$\(SolutionDir\) == '\*Undefined\*'"">\.\.\\</SolutionDir>")
}

#######################
# Delete NuGet.targets

ls -Recurse -include 'NuGet.exe','NuGet.targets' |
  foreach { 
    remove-item $_ -recurse -force
    write-host deleted $_
}

#########################################################################################
# Fix Project and Solution Files to reverse damage done by "Enable NuGet Package Restore"

ls -Recurse -include *.csproj, *.sln, *.fsproj, *.vbproj, *.wixproj, *.vcxproj |
  foreach {
    $content = cat $_.FullName | Out-String
    $origContent = $content
    foreach($badStuff in $listOfBadStuff){
        $content = $content -replace $badStuff, ""
    }
    if ($origContent -ne $content)
    {
        $encoding = Get-FileEncoding $_.FullName

        [System.IO.File]::WriteAllText($_.FullName, $content, $encoding)
        write-host messed with $_.Name
    }		    
}