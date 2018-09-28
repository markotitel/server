variable pub_key {}

resource "digitalocean_ssh_key" "default" {
  name       = "terraform"
  public_key = "${file(var.ssh.pub_key)}"
}
