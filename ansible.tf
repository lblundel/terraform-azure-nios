resource "ansible_group" "nios" {
  name = "nios"
}

resource "ansible_host" "nios_vm" {
  for_each            = var.instances
  name = azurerm_linux_virtual_machine.nios_vm[each.key].name
  groups             = [ansible_group.nios.name]
  variables = {
    # public_ip_fqdn     = join(".", [azurerm_public_ip.public_ip[each.key].domain_name_label, var.location, "cloudapp.azure.com"])
    public_ip_fqdn     = azurerm_public_ip.public_ip[each.key].fqdn
    ansible_user       = var.admin_username
    ansible_host       = azurerm_public_ip.public_ip[each.key].ip_address
  }
}

/*
resource "ansible_playbook" "dns_playbook" {
  playbook = pathexpand("~/scm/ansible/site.yml")
  name = ansible_host.rockylinux9_vm.name
  check_mode = true
  diff_mode = true
  verbosity = 1
  replayable              = true
  ansible_playbook_binary = "/home/liamtess/.local/bin/ansible-playbook"
  vault_password_file     = "/home/liamtess/scm/ansible/.vaultpass"
  tags =["bind"]
}
*/

