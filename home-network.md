flowchart TB
    Internet((Internet))
    Modem[Cable Modem<br/>(Bridge / ISP Edge)]
    Firewalla[Firewalla Purple SE<br/>• NAT<br/>• DHCP<br/>• DNS<br/>• Firewall]
    Deco[TP-Link Deco X55 Mesh<br/>• Wi-Fi Only<br/>• Access Point Mode]
    Clients[End Devices<br/>(Wired & Wireless)]

    Internet --> Modem --> Firewalla --> Deco --> Clients
