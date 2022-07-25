resource "null_resource" "playbook" {

  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory.ini ../ansible/provision.yml"
  }

  depends_on = [
    local_file.ansible_inventory
  ]
}
