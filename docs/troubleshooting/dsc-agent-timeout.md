# Incident: DSC Agent Provisioning Timeout

## Problem
During Session Host deployment in `rg-avd-compute`, host VMs remained stuck in `Provisioning` before failing with a DSC Agent extension timeout error.

<img width="1786" height="760" alt="Image" src="https://github.com/user-attachments/assets/945cbf6c-4ecd-4bef-a3f9-a43f4b86e5c3" />

## Root Cause
The session host subnet (`snet-avd-hosts`) lacked direct internet connectivity. Because session host VMs had no Public IPs and no outbound route, the automated AVD registration script couldn't reach Azure control plane endpoints to download the required agent binaries.

## Resolution
1. Provisioned `nat-avd-prod-01` with a static public IP (`pip-nat-avd-prod-01`).

<img width="1555" height="279" alt="Image" src="https://github.com/user-attachments/assets/dd626fc5-b93f-46bd-974d-1c74895f1cb8" />


2. Associated the NAT Gateway directly with `snet-avd-hosts`.

<img width="1275" height="404" alt="Image" src="https://github.com/user-attachments/assets/5ab5500d-0105-4ac9-8795-95fbcfa3a43f" />

4. Redeployed the session hosts; outbound traffic successfully routed via NAT, completing agent registration.
