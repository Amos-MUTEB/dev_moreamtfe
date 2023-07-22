## Create Instance EC2
resource "aws_instance" "TerFKeypair010623" {
  ami           = "ami-04f1014c8adcfa670"
  instance_type = "t2.small"
  key_name      = aws_key_pair.keypair.key_name
  user_data     = file("shellcmd.sh")
  subnet_id    = aws_subnet.moream_subnet_az1a.id
#  vpc_security_group_ids = ["<desired_security_group_id>"]

  vpc_security_group_ids = [aws_security_group.terraformdocker_sg.id]

  tags = {
    Name = "terF_Inst&KeyP220623_ajout"
  }
}
