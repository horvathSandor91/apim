output "network-output" {
  value = azurerm_virtual_network.sh-network 
}

output "subnet" {  
  value = azurerm_subnet.sh-subnet 
}

output "pip" {
  value = azurerm_public_ip.sh-pip
}