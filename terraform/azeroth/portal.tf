module "portal" {
    source = "../modules/container"

    name = "Portal"  
    node_name = "azeroth"
    vlan_id = 110
    user_ssh_keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQgUfn246Vrh/3PDjrPducW+owOe1B+IddR/8hbeUMW benjaminmn@benjamin-icecrown" ]

    download_file_url = "http://download.proxmox.com/images/system/archlinux-base_20260420-1_amd64.tar.zst"
    download_file_checksum = "a6af26c3760f5683ea17140aae9398e3a793f17e3c1586edcec56fb0ed1ba780722ce4c20eafdb5843899fa229cfe859a381c36b6c754b7e381f8337f2334352"
    download_datastore_id = "local"

    firewall = {
      enabled = true
      rules = [ {
        action = "ACCEPT"
        source = "+management"
        macro = "SSH"
      } ]
    }
}