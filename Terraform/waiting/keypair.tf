### KEYPAIR ###
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "keypair" {
  key_name   = "moreamkeylinux"
  public_key = tls_private_key.key_pair.public_key_openssh
}

resource "local_file" "moream5_ssh_key" {
  filename = "${aws_key_pair.keypair.key_name}.pem"
  content  = tls_private_key.keypair.private_key_pem
}
