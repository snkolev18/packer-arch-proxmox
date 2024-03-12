variable "proxmox_api" {
  type = string
}

variable "proxmox_insecure_skip_tls_verify" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_password" {
  type = string
}

variable "proxmox_username" {
  type = string
}

variable "ssh_password" {
  type = string
}

variable "ssh_timeout" {
  type = string
}

variable "ssh_username" {
  type = string
}

variable "vm_description" {
  type = string
}

variable "vm_name" {
  type = string
}

source "proxmox" "proxmox-server" {
  cd_files = [
    "./http/user-data",
    "./http/meta-data",
    "./http/install.sh",
    "./http/install-chroot.sh",
    "./http/mirrorlist"
  ]
  boot_command = [
    "<enter><wait10><wait10><wait10><wait10>",
    "curl -O 'https://raw.githubusercontent.com/Themodem/packer-arch-proxmox/master/http/install{,-chroot}.sh'<enter><wait>",
    "bash install.sh<enter>",
    "bash install-chroot.sh<enter>",
    "systemctl reboot<enter>"
  ]
  cd_label = "cidata"
  boot_wait    = "10s"
  cores        = 4
  disks {
    disk_size         = "100G"
    storage_pool      = "local-data"
    storage_pool_type = "lvm-thin"
    type              = "scsi"
  }
  http_directory           = "http"
  insecure_skip_tls_verify = "${var.proxmox_insecure_skip_tls_verify}"
  iso_file                 = "local:iso/archlinux-2024.03.01-x86_64.iso"
  memory                   = 8192
  network_adapters {
    bridge = "vmbr10"
  }
  node                 = "${var.proxmox_node}"
  password             = "${var.proxmox_password}"
  proxmox_url          = "${var.proxmox_api}"
  ssh_username         = "${var.ssh_username}"
  ssh_password         = "${var.ssh_password}"
  ssh_timeout          = "${var.ssh_timeout}"
  template_description = "${var.vm_description}"
  username             = "${var.proxmox_username}"
  vm_name              = "${var.vm_name}"
}

build {
  sources = ["source.proxmox.proxmox-server"]
}
