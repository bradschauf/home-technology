```mermaid
flowchart TB
    Internet((Internet))
    Modem[Cable Modem]
    Firewalla[Firewalla Purple SE<br/>Router / Firewall / DHCP]
    Switch[LAN Switch<br/>(Optional)]
    DecoMain[Deco X55<br/>Primary Node<br/>(AP Mode)]
    DecoNode1[Deco X55<br/>Mesh Node<br/>(AP Mode)]
    Clients[Client Devices]

    Internet --> Modem --> Firewalla --> Switch --> DecoMain
    DecoMain --> DecoNode1
    DecoMain --> Clients
