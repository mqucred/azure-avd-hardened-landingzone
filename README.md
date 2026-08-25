# Enterprise Zero Trust Azure Virtual Desktop (AVD) Landing Zone

<img width="5086" height="3958" alt="Image" src="https://github.com/user-attachments/assets/c1bde482-1e95-4a9d-9236-0ba99257311d" />

## Enterprise Governance & ALZ Hierarchy

To align with Microsoft Cloud Adoption Framework (CAF) best practices, the environment is governed under a structured Enterprise Scale Management Group hierarchy.

<img width="1753" height="789" alt="Image" src="https://github.com/user-attachments/assets/24a81356-308f-4c9a-a4f4-a38a1796f963" />

* **Management Group Structure:** Established dedicated hierarchy branches (`Platform`, `Workloads`, `Sandbox`) under `Contoso Enterprise Root` (`mg-contoso-root`).
* **Subscription Placement:** Positioned the platform subscription (`sub-ent-platform-prod`) under `Platform` > `Connectivity` (`mg-connectivity`) to enforce strict governance and centralized policy inheritance for network infrastructure.

## Executive Summary

This project demonstrates an enterprise-grade, Zero Trust-compliant Azure Virtual Desktop (AVD) deployment using Microsoft Entra ID Join and private network topology. Session hosts are isolated from direct inbound internet exposure, utilizing reverse-connect transport for remote user sessions and a dedicated Azure NAT Gateway for deterministic outbound outbound egress.

```
[ AVD Web Client ] ---> ( Azure Control Plane ) ---> [ Reverse Connect ]
                                                             |
                                                             v
[ Private Subnet ] ---> [ Session Host VMs ] ---> [ NAT Gateway ] ---> ( Internet Egress )

```

---

## Architectural Highlights


* **Zero Inbound Surface:** Session hosts deployed without public IPs; RDP traffic is brokered over TLS via Azure's reverse-connect architecture.
* **Deterministic Egress:** Outbound internet traffic (Entra ID tokens, AVD agent communication, CRL checks) is strictly routed through a dedicated static NAT Gateway IP (`pip-nat-avd-prod-01`).
* **Cloud-Native Identity:** Session hosts join Microsoft Entra ID directly, eliminating domain controller overhead while enforcing fine-grained Role-Based Access Control (RBAC).
* **Enterprise Isolation:** Decoupled resource architecture separating control plane assets (`rg-avd-management`) from compute workloads (`rg-avd-compute`).

---

## Architecture Topology

---

## Resource Organization

| Resource Group | Category | Contained Resources |
| --- | --- | --- |
| **`rg-avd-management`** | Control Plane | Workspace (`ws-avd-prod-01`), Host Pool (`hp-avd-pooled-01`), Desktop Application Group (`dag-avd-desktop-01`) |
| **`rg-avd-compute`** | Compute Workloads | Session Host VMs (`vm-avd-sh-0`, `vm-avd-sh-1`), Managed Disks, Network Interfaces |
| **`rg-avd-network`** | Connectivity | Virtual Network (`vnet-avd-prod-01`), Subnets, NAT Gateway (`nat-avd-prod-01`), Public IP |

---

## Deployment & Implementation Stages

### Phase 1: Network Foundation & Egress Security

1. Provisioned `vnet-avd-prod-01` with an isolated host subnet (`snet-avd-hosts`).
2. Configured `nat-avd-prod-01` associated with static public IP `pip-nat-avd-prod-01`.
3. Linked NAT Gateway to `snet-avd-hosts` to secure all outbound traffic.

### Phase 2: AVD Control Plane Provisioning

1. Created pooled host pool (`hp-avd-pooled-01`) using Windows 11 Enterprise Multi-Session.
2. Formed Desktop Application Group (`dag-avd-desktop-01`) and registered it to workspace (`ws-avd-prod-01`).
3. Configured custom RDP properties to enable cloud identity authentication:
```text
targetisaadjoined:i:1;

```



### Phase 3: Compute Infrastructure

1. Deployed session hosts (`vm-avd-sh-0`, `vm-avd-sh-1`) without public IP addresses into `rg-avd-compute`.
2. Executed Entra ID Join post-deployment extension and registered hosts to the host pool.

### Phase 4: Identity & Access Management (RBAC)

1. Assigned **`Virtual Machine User Login`** role at the `rg-avd-compute` resource group scope for targeted user groups.
2. Assigned test identity to **`dag-avd-desktop-01`** for workspace desktop publishing.

### Phase 5: Client Connection Validation

1. Navigated to the modern Windows App web client portal (`[https://windows.cloud.microsoft](https://windows.cloud.microsoft)`).
2. Authenticated via native Entra ID user account.
3. Launched **SessionDesktop** remote session and verified reverse-connect handshake and hostname resolution (`vm-avd-sh-0`).

---

## Key Troubleshooting Insights

* **DSC Agent Download Timeout:** Initial session host deployments timed out during post-provisioning agent setup due to missing default internet access in private subnets. Resolved by establishing the NAT Gateway prior to session host provisioning.
* **RDP Credential Validation Failure:** Web client logins initially failed at the OS boundary due to legacy Kerberos/NTLM authentication attempts. Resolved by adding `targetisaadjoined:i:1` to host pool custom RDP properties.

---

## Validation Proof
Published workspace and `SessionDesktop` entitlement view.

<img width="1835" height="1078" alt="Image" src="https://github.com/user-attachments/assets/acd46c86-a143-4b6d-a634-f5e3691d0741" />

Active remote desktop session in browser displaying `hostname` execution (`vm-avd-sh-0`).

<img width="1841" height="1078" alt="Image" src="https://github.com/user-attachments/assets/5ee7144e-bccf-4978-b9b9-9dc2eb99ee4a" />
