# Current Network Diagram

```mermaid
flowchart TB
    %% ===== Zones =====
    subgraph WAN_ZONE["Untrusted - ISP Network"]
        Internet((Internet))
        Modem["Arris S34<br/>Cable Modem (Bridge Only)"]
    end

    subgraph LAN_ZONE["Trusted Home Network"]
        %% Layer 1 - Main Switch
        Switch["Gigabit Switch<br/>Legrand Structured Media Box"]

        %% Layer 2 - Living Room Switch
        LRSwitch["Switch<br/>Living Room"]

        %% Layer 3 - Decco Units
        DeccoMain["Decco X55<br/>Primary Node (Living Room)<br/>Router / NAT / Firewall / DHCP"]
        DeccoNode2["Decco X55<br/>Node 2 (Office)"]
        DeccoNode3["Decco X55<br/>Node 3 (Garage)"]

        %% Layer 4 - Client Devices
        ClientsMain["Client Devices<br/>Wi-Fi and Wired"]
        ClientsNode2["Client Devices<br/>Wi-Fi and Wired"]
        ClientsNode3["Client Devices<br/>Wi-Fi and Wired"]

        %% Layer 5 - IoT Devices
        subgraph IOT_ZONE["IoT Network — SSID: Indecision Ranch"]
            direction LR
            Brilliant["Brilliant Home<br/>Control Panel"] ~~~ GarageMain["Genie Garage Door<br/>Main Garage"] ~~~ GarageRV["Genie Garage Door<br/>RV Garage"] ~~~ ThermoMaster["Honeywell ProSeries<br/>Thermostat (Master)"] ~~~ ThermoGuest["Honeywell ProSeries<br/>Thermostat (Guest)"]
        end
    end

    %% ===== Links =====
    Internet <-->|ISP| Modem
    Modem <-->|WAN| Switch

    %% Layer 1 to Layer 2
    Switch <-->|Ethernet| LRSwitch
    Switch <-->|Ethernet Backhaul| DeccoNode2
    Switch <-->|Ethernet Backhaul| DeccoNode3

    %% Layer 2 to Layer 3
    LRSwitch <-->|Ethernet| DeccoMain

    %% Layer 3 to Layer 4 (5Ghz Wi-Fi)
    DeccoMain <-.->|Indecision Ranch 5Ghz| ClientsMain
    DeccoNode2 <-.->|Indecision Ranch 5Ghz| ClientsNode2
    DeccoNode3 <-.->|Indecision Ranch 5Ghz| ClientsNode3

    %% Layer 4 to Layer 5 (IoT Wi-Fi)
    DeccoMain <-.->|Indecision Ranch| IOT_ZONE
    DeccoNode2 <-.->|Indecision Ranch| IOT_ZONE
    DeccoNode3 <-.->|Indecision Ranch| IOT_ZONE
```

**Key facts:**
- The Arris S34 cable modem is a bridge only — no routing, no DHCP
- The Decco X55 primary node acts as the router, NAT gateway, firewall, and DHCP server
- All Decco nodes are in Router mode (not Access Point mode)
- IoT devices connect to a separate SSID: "Indecision Ranch"
- Primary client SSID: "Indecision Ranch 5Ghz"

## IoT Devices

| Device | Location | SSID |
|--------|----------|------|
| Brilliant Home Control Panel | — | Indecision Ranch |
| Genie Garage Door (Main) | Main Garage | Indecision Ranch |
| Genie Garage Door (RV) | RV Garage | Indecision Ranch |
| Honeywell ProSeries Thermostat (Master) | Master | Indecision Ranch |
| Honeywell ProSeries Thermostat (Guest) | Guest | Indecision Ranch |

## Final Topology

```
Arris S34 Cable Modem (bridge only)
    │
Gigabit Switch
    │
Decco X55 Primary (Living Room)  ← Router / NAT / Firewall / DHCP
    │
Decco X55 Nodes (Office, Garage — mesh backhaul via switch)
    │
Clients
```

# Troubleshooting

- Restart the modem manually
- Restart via the Xfinity app if this local restart does not fix the issue. DHCP gets reset when Xfinity resets the modem.
- If Decco does not get a WAN IP: power-cycle the modem, then the Decco primary. The modem may need to re-learn the new MAC address.
- If clients get 169.254.x.x addresses: confirm Decco DHCP is enabled in router mode settings.
- If old devices still have Firewalla-subnet IPs: release/renew DHCP or reboot the client.

# Cutover Procedure (Firewalla → Decco Router)

**Reason for change:** The Firewalla Purple SE has a 500 Mbps port limit, bottlenecking the connection. Removing it and returning the Decco X55 mesh to router mode eliminates this constraint.

## Phase 1 — Reconfigure Decco to Router Mode (Done)

1. Open the **Decco app**
2. Navigate to: **More → Advanced → Operation Mode → Router**
3. Apply the change
4. Reboot all Decco nodes

## Phase 2 — Physical Cutover (Planned Outage)

**Goal:** Remove the Firewalla from the network path and connect the Decco primary directly through the switch to the modem.

### Step 1 — Power Down

1. Power **off**:
   * Cable modem
   * All Decco units
2. Disconnect:
   * Cable modem → Firewalla WAN
   * Firewalla LAN → Switch

### Step 2 — Reconnect Without Firewalla

1. Connect:
   * **Cable modem → Switch** (using the port previously connected to Firewalla)
2. Verify:
   * **Decco primary WAN port → Switch** (should already be connected)
   * The switch passes traffic between modem and Decco primary as if directly connected

### Step 3 — Power-On Sequence

1. Power on **cable modem**
   * Wait until fully online (ISP lights stable)
2. Power on **Decco primary node**
   * Wait for the Decco to obtain a WAN IP from ISP via the modem
3. Power on **remaining Decco nodes**

## Phase 3 — Validation

1. Open the **Decco app** and confirm:
   * Internet status = **Connected**
   * WAN IP assigned by ISP
   * Router mode active, DHCP serving clients
2. Check a client device:
   * IP address from Decco subnet
   * Default gateway = Decco primary LAN IP
3. Verify:
   * No double NAT
   * No stale DHCP leases from Firewalla subnet
   * Speed test shows improvement over previous 500 Mbps cap

---

# Historical: Configuration With Firewalla Purple SE

**Status:** Retired — Firewalla Purple SE port limited to 500 Mbps, creating a bottleneck.

## Network Diagram

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
    Internet <-->|ISP| Modem
    Modem <-->|WAN| Firewalla
    Firewalla <-->|LAN| Switch

    Switch <-->|Ethernet Backhaul| DecoMain
    Switch <-->|Ethernet Backhaul| DecoNode1
    Switch <-->|Ethernet Backhaul| DecoNode2

    DecoMain <-.->|Indecision Ranch 5Ghz| ClientsMain
    DecoNode1 <-.->|Indecision Ranch 5Ghz| ClientsNode1
    DecoNode2 <-.->|Indecision Ranch 5Ghz| ClientsNode2
```

## Final Topology

```
Cable Modem
    │
Firewalla Purple SE  ← Router / DHCP / Firewall
    │
Switch (optional)
    │
Deco X55 Mesh (Access Point mode)
    │
Clients
```

## Implementation Notes

### Phase 1 — Pre-Stage the Deco Mesh (No Outage)

**Goal:** Remove all routing/DHCP behavior from the Deco system *before* inserting the new router.

1. Open the **Deco app**
2. Navigate to:
   **More → Advanced → Operation Mode → Access Point**
3. Apply the change
4. Reboot **all** Deco nodes
5. Verify:

   * Deco reports **Access Point mode**
   * Wi-Fi remains functional
   * No DHCP warnings appear on clients

Leave the Deco system powered on and connected LAN-side only.

### Phase 2 — Router Cutover (Planned Outage)

**Goal:** Insert Firewalla as the *only* Layer-3 device.

#### Step 1 — Physically Remove the Old Router Path

(The "old router" is the main Deco unit.)

1. Power **off**:

   * Cable modem
   * Firewalla
   * All Deco units
2. Disconnect the Ethernet cable between:

   * Cable modem → main Deco

At this point, the Deco system has **no WAN path**.

---

#### Step 2 — Insert Firewalla

1. Connect:

   * **Cable modem → Firewalla WAN**
2. Connect:

   * **Firewalla LAN → switch**
     **OR**
   * **Firewalla LAN → main Deco LAN port**

Do **not** power anything on yet.

---

#### Step 3 — Power-On Sequence (Critical)

1. Power on **cable modem**

   * Wait until fully online (ISP lights stable)
2. Power on **Firewalla Purple SE**

   * Firewalla automatically:

     * Acts as a DHCP client on WAN
     * Brings up a temporary LAN for onboarding
3. Leave Deco powered **off** for now

---

#### Step 4 — Firewalla First-Time Setup & WAN Confirmation

1. Open the **Firewalla mobile app**
2. Start **Add Firewalla**
3. Complete onboarding
4. Confirm in the app:

   * WAN status = **Connected**
   * WAN IP assigned by ISP
   * Internet access confirmed

If WAN is **not** connected:

* Power-cycle the modem
* Ensure only Firewalla is connected
* Retry onboarding

---

#### Step 5 — Bring the Deco Mesh Online

1. Power on **all Deco units**
2. Confirm in the Deco app:

   * System is in **Access Point mode**
   * All nodes are online
3. Clients should reconnect automatically

---

### Phase 3 — Validation & Stabilization

1. Check a client device:

   * IP address from Firewalla subnet
   * Default gateway = Firewalla LAN IP
2. Verify:

   * No double NAT
   * No duplicate DHCP servers
3. (Optional) Reserve IPs for:

   * TVs
   * Streaming devices
   * NAS / printers
