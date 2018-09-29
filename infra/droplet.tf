variable pvt_key {}

resource "digitalocean_droplet" "web" {
  image = "debian-9-x64"
  name = "debian-s-1vcpu-1gb-ams3-01"
  region = "ams3"
  size = "1gb"

  private_networking = true
  resize_disk = true
  monitoring = true
  backups = true
  ipv6 = true

  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "sudo systemctl stop apt-daily.timer",
      "pkill apt",
      "sudo apt-get update",
      "sudo apt-get -y install mosh firewalld vim tree tmux git man nginx curl",
      "sudo systemctl enable firewalld",
      "sudo systemctl start firewalld",
      "sudo firewall-cmd --add-service=mosh",
      "sudo firewall-cmd --add-service=http",
      "sudo firewall-cmd --add-service=https",
      "sudo firewall-cmd --add-service=mosh --permanent",
      "sudo firewall-cmd --add-service=http --permanent",
      "sudo firewall-cmd --add-service=https --permanent",
      "git clone https://github.com/yoshuawuyts/server.git src/server",
      "./src/server/scripts/init",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "rm /root/.cloud-locale-test.skip",
      "sudo systemctl start apt-daily.timer",
    ]

    connection {
      user = "root"
      type = "ssh"
      agent = false
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
    }
  }
}

resource "digitalocean_volume_attachment" "persistent" {
  droplet_id = "${digitalocean_droplet.web.id}"
  volume_id = "${digitalocean_volume.persistent.id}"
}
