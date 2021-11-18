Try { 
Invoke-WebRequest -Uri 'http://169.254.169.254/latest/dynamic/instance-identity/document' -TimeoutSec 5 -OutFile 'C:\temp\ec2.json'
} Catch {} 