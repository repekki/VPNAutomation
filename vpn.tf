#data "ip_address" "ipv4" {
#  id = managed.digitalocean_droplet.vpn.ipv4_address
#}

resource "digitalocean_droplet" "vpn" {
  image = "ubuntu-18-04-x64"
  name = "vpn"
  region = "lon1"
  size = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]


  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.pvt_key)
    timeout = "2m"
  }


   provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
     # install updates, curl and expect
    
       "apt-get update",
       "apt-get -y install curl",
       "apt-get -y install expect",

       # Create new user, folder for ssh keys and add user to sudo group
       
       "useradd -u ${var.remote_uid} -g ${var.remote_group} -d /home/${var.remote_user} -s /bin/bash -p ${var.remote_password} ${var.remote_user}",
       "mkdir /home/${var.remote_user}",
       "chown ${var.remote_user} /home/${var.remote_user}",
       "mkdir /home/${var.remote_user}/.ssh/",
       "chown ${var.remote_user} /home/${var.remote_user}/.ssh/",
       "chmod 700 /home/${var.remote_user}/.ssh/",
       "usermod -aG sudo ${var.remote_user}",
       "sudo whoami"
    ]

   }
 
    #uploads vpnuser ssh key
    provisioner "file" {
      source = "~/.ssh/${var.remote_ssh_key}"
      destination = "/home/${var.remote_user}/.ssh/${var.remote_ssh_key}"

 }

    #adds pub key to authorised keys, so user can have access via ssh
    provisioner "remote-exec" {
        inline = [
            "export PATH=$PATH:/usr/bin",
            "chmod 644 /home/${var.remote_user}/.ssh/${var.remote_ssh_key}",
            "touch /home/${var.remote_user}/.ssh/authorized_keys",
            "cat /home/${var.remote_user}/.ssh/${var.remote_ssh_key} >> /home/${var.remote_user}/.ssh/authorized_keys"
        ]
    
    }

    #copies expect script file from local computer to droplet
    provisioner "file" {
      source = "~/Documents/script.exp"
      destination = "~/script.exp"

 }  

    provisioner "remote-exec" {

        inline = [
        #install wireguard. this is not the preferred method, as it is not a verified source
        "mv script.exp /home/${var.remote_user}/",
        "chown ${var.remote_user} /home/${var.remote_user}/script.exp",
        "cd /home/${var.remote_user}/",
        "curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh",
        "sudo chmod +x wireguard-install.sh",
        "sudo chmod +x script.exp",
        "sudo expect -d ./script.exp",
        "sudo mv /root/wg0-client-vpnclient.conf /home/${var.remote_user}/",
        "sudo chown ${var.remote_user} /home/${var.remote_user}/wg0-client-vpnclient.conf"

    ]
    
    }
 

    provisioner "local-exec" {
        
        command =  "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/${var.remote_ssh_key} -r ${var.remote_user}@${self.ipv4_address}:/home/${var.remote_user}/wg0-client-vpnclient.conf ~/Documents/"
    }



}

