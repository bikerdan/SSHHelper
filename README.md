# SSHHelper
Script to make ssh and scp to many remote servers easy

## Setup:
Copy the ssh_env.sh.sample to ssh_env.sh and modify contents to match your environment.

## Usage:

ssh.sh [environment] [host] [[scp_from] [scp_to]]

If the parameters are not given, you will be prompted for them.  To ssh to a host, only the first two parameters are required.  To scp a resource to the remote host, include the scp_from and scp_to parameters.

