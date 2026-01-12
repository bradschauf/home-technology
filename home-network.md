# Current Network Diagram
```mermaid
flowchart TB
    %% ===== Zones =====
    subgraph WAN_ZONE["Untrusted / ISP Network"]
        Internet((Internet))
        Modem[Cable Modem]
    end

    subgraph TRUST_BOUNDARY["Security Boundary<br/>(Routing / NAT / Firewall / DHCP)"]
        Firewalla["Firewalla Purple SE<br/>Router / Firewall / DHCP"]
    end

    subgraph LAN_ZONE["Trusted Home Network"]
        Switch["Gigabit Switch<br/>(Legrand Structured Media Box)"]
        DecoMain["Deco X55<br/>Primary Node<br/>(AP Mode)"]
        DecoNode1["Deco X55<br/>Mesh Node 1<br/>(AP Mode)"]
        DecoNode2["Deco X55<br/>Mesh Node 2<br/>(AP Mode)"]
        Clients["Client Devices<br/>(Wi-Fi & Wired)"]
    end

    %% ===== Links =====
    Internet -->|ISP| Modem
    Modem -->|WAN| Firewalla
    Firewalla -->|LAN| Switch
    Switch -->|Ethernet (Backhaul)| DecoMain
    Switch -->|Ethernet (Backhaul)| DecoNode1
    Switch -->|Ethernet (Backhaul)| DecoNode2
    DecoMain -.->|Wi-Fi Access| Clients

    %% ===== Legend =====
    subgraph LEGEND["Legend"]
        L1["Solid Arrow →  Wired Ethernet"]
        L2["Dotted Arrow ⇢  Wi-Fi Client Access"]
        L3["Security Boundary = All routing, NAT, firewalling, DHCP"]
        L4["Wired Backhaul = No wireless mesh links"]
    end
```