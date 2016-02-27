##############################################################################
##
## Get-FileEncoding
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################
function Get-FileEncoding {     
    <#
     
    .SYNOPSIS
     
    Gets the encoding of a file
     
    .EXAMPLE
     
    Get-FileEncoding.ps1 .\UnicodeScript.ps1
     
    BodyName          : unicodeFFFE
    EncodingName      : Unicode (Big-Endian)
    HeaderName        : unicodeFFFE
    WebName           : unicodeFFFE
    WindowsCodePage   : 1200
    IsBrowserDisplay  : False
    IsBrowserSave     : False
    IsMailNewsDisplay : False
    IsMailNewsSave    : False
    IsSingleByte      : False
    EncoderFallback   : System.Text.EncoderReplacementFallback
    DecoderFallback   : System.Text.DecoderReplacementFallback
    IsReadOnly        : True
    CodePage          : 1201
     
    #>
    [CmdletBinding()]
    param(
        ## The path of the file to get the encoding of.
        $Path
    )
     
    Set-StrictMode -Version Latest
     
    ## The hashtable used to store our mapping of encoding bytes to their
    ## name. For example, "255-254 = Unicode"
    $encodings = @{}
     
    ## Find all of the encodings understood by the .NET Framework. For each,
    ## determine the bytes at the start of the file (the preamble) that the .NET
    ## Framework uses to identify that encoding.
    $encodingMembers = [System.Text.Encoding] |
        Get-Member -Static -MemberType Property
     
    $encodingMembers | Foreach-Object {
        $encodingBytes = [System.Text.Encoding]::($_.Name).GetPreamble() -join '-'
        $encodings[$encodingBytes] = $_.Name
    }
     
    ## Find out the lengths of all of the preambles.
    $encodingLengths = $encodings.Keys | Where-Object { $_ } |
        Foreach-Object { ($_ -split "-").Count }
     
    ## Assume the encoding is UTF7 by default
    $result = "UTF7"
     
    ## Go through each of the possible preamble lengths, read that many
    ## bytes from the file, and then see if it matches one of the encodings
    ## we know about.
    foreach($encodingLength in $encodingLengths | Sort -Descending)
    {
        $bytes = (Get-Content -encoding byte -readcount $encodingLength $path)[0]
        $encoding = $encodings[$bytes -join '-']
     
        ## If we found an encoding that had the same preamble bytes,
        ## save that output and break.
        if($encoding)
        {
            $result = $encoding
            break
        }
    }
     
    ## Finally, output the encoding.
    Return [System.Text.Encoding]::$result
}