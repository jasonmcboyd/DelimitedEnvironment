enum Ensure
{
    Absent
    Present
}

[DscResource()]
class DelimitedEnvironment {
    [DscProperty(Key)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Name

    [DscProperty(Key)]
    [ValidateNotNull()]
    [String]
    $Value = [String]::Empty

    [DscProperty(Key)]
    [ValidateSet('Machine', 'Process', 'User')]
    [String]
    $Target = ('Machine', 'Process', 'User')

    [DscProperty(Mandatory)]
    [Ensure] 
    $Ensure = 'Present'
    
    [DscProperty(Mandatory)]    
    [char]
    $Delimiter = ';'

    <#
        This method is equivalent of the Set-TargetResource script function.
        It sets the resource to the desired state.
    #>
    [void] 
    Set()
    {
        $values = [System.Environment]::GetEnvironmentVariable($this.Name, $this.Target)

        if ($values -eq $null) {
            if ($this.Ensure -eq 'Present') {
                $values = $this.Value
            }
        }
        else {
            $values = $values -split $this.Delimiter

            if ($this.Ensure -eq 'Absent') {
                $values = $values | Where-Object { $_ -ne $this.Value }
            }
            else {
                if ($values -notcontains $this.Value) {
                    $values += $this.Value
                }
            }
        }
        $values = $values -join $this.Delimiter
        [System.Environment]::SetEnvironmentVariable($this.Name, $values, $this.Name)
    }

    <#
        This method is equivalent of the Test-TargetResource script function.
        It should return True or False, showing whether the resource
        is in a desired state.
    #>
    [bool] 
    Test()
    {
        $current = $this.Get()
        return $current.Ensure -eq $this.Ensure
    }

    <#
        This method is equivalent of the Get-TargetResource script function.
        The implementation should use the keys to find appropriate resources.
        This method returns an instance of this class with the updated key
        properties.
    #>
    [DelimitedEnvironment] 
    Get()
    {
        $values = [System.Environment]::GetEnvironmentVariable($this.Name, $this.Target)

        $result = [DelimitedEnvironment]::new()
        $result.Name = $this.Name
        $result.Value = $this.Value
        $result.Target = $this.Target
        $result.Delimiter = $this.Delimiter
        
        if ($values -eq $null) {
            $result.Ensure = 'Absent'
        }
        else {
            $values = $values -split $this.Delimiter
            $this.Ensure = if ($values -contains $this.Value) { 'Present' } else { 'Absent' }
        }
        return $result
    }
}
