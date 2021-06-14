# VPN Automation

I wanted to create a VPN instance, I could use to access region locked content on Youtube and other such platforms,
which I could then discard after use to minimise costs. I decided to use Terraform to do this with Digital Ocean as my cloud provider, as I could automate the entire
installation process from creating the droplet itself, as well as any software installations I chose.

## Requirements

- Digital Ocean Account
- Terraform

## Usage

- Clone repository
- Create your own SSH keys and modify paths
- Make modifications to the droplet configuration, if you want
- init terraform
- terraform plan \ -var "do_token=${DO_PAT} \ -var "pvt_key=$HOME/.ssh/id_rsa"
- terraform apply \ -var "do_token=${DO_PAT} \ -var "pvt_key=$HOME/.ssh/id_rsa"

- If you want to get rid of the instance, use **terraform destroy**


