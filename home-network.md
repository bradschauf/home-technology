# Current Network Diagram
```mermaid
flowchart TB
    %% ===== Zones =====
    subgraph WAN_ZONE["Untrusted - ISP Network"]
        Internet((Internet))
        Modem[Cable Modem]
    end

    subgraph TRUST_BOUNDARY["Security Boundary<br/>Routing - NAT - Firewall - DHCP"]
        Firewalla["Firewalla Purple SE<br/>Router / Firewall / DHCP"]
    end

    subgraph LAN_ZONE["Trusted Home Network"]
        Switch["Gigabit Switch<br/>Legrand Structured Media Box"]

        DecoMain["Deco X55<br/>Primary Node<br/>AP Mode"]
        DecoNode1["Deco X55<br/>Node 1<br/>AP Mode"]
        DecoNode2["Deco X55<br/>Node 2<br/>AP Mode"]

        ClientsMain["Client Devices<br/>Wi-Fi and Wired"]
        ClientsNode1["Client Devices<br/>Wi-Fi and Wired"]
        ClientsNode2["Client Devices<br/>Wi-Fi and Wired"]
    end

    %% ===== Links =====
    Internet -->|ISP| Modem
    Modem -->|WAN| Firewalla
    Firewalla -->|LAN| Switch

    Switch -->|Ethernet Backhaul| DecoMain
    Switch -->|Ethernet Backhaul| DecoNode1
    Switch -->|Ethernet Backhaul| DecoNode2

    DecoMain -.->|Wi-Fi Access| ClientsMain
    DecoNode1 -.->|Wi-Fi Access| ClientsNode1
    DecoNode2 -.->|Wi-Fi Access| ClientsNode2

    %% ===== Legend =====
    subgraph LEGEND["Legend"]
        L1["Solid Arrow -> Wired Ethernet"]
        L2["Dotted Arrow -> Wi-Fi client access"]
        L3["Security Boundary = Routing, NAT, firewalling, DHCP"]
        L4["Ethernet Backhaul = No wireless mesh links"]
    end
```