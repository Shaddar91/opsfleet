#Global write forwarding on an Aurora secondary cluster as its own resource: on when created, off when destroyed, through files/write-forwarding.sh.
resource "terraform_data" "write_forwarding" {
  input = {
    region  = var.region
    cluster = var.cluster_identifier
    script  = "${path.module}/files/write-forwarding.sh"
  }

  provisioner "local-exec" {
    command     = "bash ${self.input.script} on"
    environment = { REGION = self.input.region, CLUSTER = self.input.cluster }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "bash ${self.input.script} off"
    environment = { REGION = self.input.region, CLUSTER = self.input.cluster }
  }
}
