# Site Onboarding Wizard

End-to-end domain onboarding to EdgeOne: confirm plan → create zone → verify ownership → add acceleration domain → apply for and deploy certificate.

## End-to-End Process Overview

```
1. Confirm plan (`DescribePlans` / `DescribeAvailablePlans` / `CreatePlan`)
       ↓
2. Create zone (`CreateZone`)
   ├─ NS access: switch DNS servers
   └─ CNAME access: add TXT record or file verification
       ↓
3. Verify ownership (`VerifyOwnership`) — can be skipped, verify later
       ↓
4. Add acceleration domain (`CreateAccelerationDomain`)
       ↓
5. Apply for and deploy HTTPS certificate (see cert-manager.md)
       ↓
   Onboarding complete
```

> You can check verification status at any time via `DescribeIdentifications`.
> For certificate queries and operations, see [cert-manager.md](cert-manager.md).

## Scenario A: Confirm Plan

**Trigger**: The first step in the process — a plan must be confirmed before creating a zone.

### A1: Query Existing Plans (`DescribePlans`)

Call `DescribePlans` to query the list of plans under the account.

#### Filtering Logic

From the returned plan list, filter for available plans using the following conditions:

1. **Bindable**: `Bindable == "true"`
2. **Normal status**: `Status == "normal"`
3. **Sufficient quota**: Number of bound zones < zone quota limit

> Only plans meeting all 3 conditions above can be used for binding.

#### Available Plans Found

> **No automatic binding**: Binding a plan consumes a zone quota slot. You **must** show the plan info to the user first and wait for the user to explicitly choose before binding — never decide on your own.

Show the available plans to the user and ask which one to bind:

- If there is **only 1 plan**: still require user confirmation before using it
- If there are **multiple plans**: show plan type, service region, and zone quota usage, then wait for the user to choose
- The user may also choose to **not bind an existing plan** and go to A2 to purchase a new one

#### No Available Plans

Go to A2.

### A2: Purchase a New Plan (`DescribeAvailablePlans` → `CreatePlan`)

Call `DescribeAvailablePlans` to query purchasable plan types for the current account, and show the available options to the user.

> **No automatic purchase**: Purchasing a plan incurs actual charges. You **must** show the plan type and pricing info to the user and wait for explicit confirmation before calling `CreatePlan`. Never skip confirmation or decide to purchase on your own.

After the user explicitly confirms, call `CreatePlan` to purchase the plan.

If the user decides not to purchase, remind them: **A zone requires a bound plan to provide service** — zones without a bound plan will remain in `init` status and will not take effect.

### Next Step

After plan confirmation, proceed to [Scenario B: Create Zone](#scenario-b-create-zone) with the PlanId.

## Scenario B: Create Zone

**Trigger**: User says "onboard example.com to EdgeOne", "create a zone", "create a new zone", or as the follow-up step after plan confirmation.

> If the user triggers this scenario directly (without going through Scenario A), guide them to complete [Scenario A: Confirm Plan](#scenario-a-confirm-plan) first before continuing.

> **No automatic creation**: Creating a zone consumes a plan's zone quota. You **must** confirm the zone domain, access mode, and service region with the user before execution — never decide on your own.

**Call** `CreateZone`. The user needs to provide: zone domain, access mode, service region. It is recommended to pass the PlanId directly when creating.

> Without a PlanId, the zone will be in `init` status and will need to be bound later via `BindZoneToPlan`.
>
> **No automatic binding**: Whether passing PlanId via `CreateZone` or later calling `BindZoneToPlan`, you **must** obtain explicit user confirmation beforehand — never decide which plan to bind on your own.

### Next Steps for NS Access

Inform the user that they need to change the DNS servers at their domain registrar to the NameServers returned in the response, then go to [Scenario C: Verify Ownership](#scenario-c-verify-ownership).

### Next Steps for CNAME Access

Inform the user of two verification methods (choose either one), with verification info from the response:

1. **DNS verification**: Add a TXT record in DNS
2. **File verification**: Place a verification file in the origin server's root directory

Wait for the user to confirm the configuration is complete, then go to [Scenario C: Verify Ownership](#scenario-c-verify-ownership).

## Scenario C: Verify Ownership

**Trigger**: User says "verify the zone", "check DNS switch", "ownership verification", or as the follow-up step after zone creation.

> The user can choose to skip ownership verification and go directly to [Scenario D: Add Acceleration Domain](#scenario-d-add-acceleration-domain), returning to verify later.

### C1: Query Verification Status (`DescribeIdentifications`)

Before triggering verification, first call `DescribeIdentifications` to query the current verification status.

**Decision**:
- If `Status` is `finished`, no need to verify again — proceed to the next step
- If `Status` is `pending`, inform the user to configure a DNS TXT record or file verification based on the verification info in the response

### C2: Trigger Verification (`VerifyOwnership`)

After the user confirms they have completed the DNS / file configuration, call `VerifyOwnership`.

**NS access scenario**: Verifies whether the DNS servers have been successfully switched. DNS switching typically takes 24–48 hours to propagate globally — if verification fails, suggest the user retry later.

**CNAME access scenario**: Verifies whether the TXT record or file is correctly configured. Once the zone passes ownership verification, subsequent domain additions won't require re-verification.

## Scenario D: Add Acceleration Domain

**Trigger**: User says "add a domain", "configure acceleration domain", "onboard a subdomain", or as the follow-up step after ownership verification (or skip).

### D1: Collect Parameters

Before calling, confirm the following information with the user:

1. **Acceleration domain** (DomainName): the subdomain to onboard, e.g., `www.example.com`
2. **IPv6 access** (IPv6Status): whether to enable IPv6 access
3. **Origin configuration** (OriginInfo), including:
   - **Origin type** (OriginType)
   - **Origin address** (Origin): fill in IP, domain, COS bucket domain, origin group ID, etc., depending on origin type
   - If private object storage origin access is needed, confirm PrivateAccess and authentication parameters
4. **Origin protocol** (OriginProtocol, optional): FOLLOW / HTTP / HTTPS
5. **Origin port** (optional): HTTP origin port / HTTPS origin port

### D2: Call `CreateAccelerationDomain`

> **No automatic addition**: Adding an acceleration domain changes live DNS configuration. You **must** complete parameter collection in D1 and obtain explicit user confirmation before execution — never decide on your own.

After user confirmation, call `CreateAccelerationDomain`.

**Next step**: Inform the user that they need to add a CNAME record in DNS, pointing the domain to the CNAME address assigned by EdgeOne (obtainable by querying the `Cname` field via `DescribeAccelerationDomains`).

## Scenario E: Apply for and Deploy HTTPS Certificate

**Trigger**: After domain addition, user says "configure HTTPS", "apply for certificate", or as the final step in the onboarding process.

> For complete certificate management (CNAME manual verification, deploy custom certificates, batch inspection, etc.), see [cert-manager.md](cert-manager.md).

### E1: NS Access / DNSPod Hosting (Auto Verification, One Step)

> **No automatic deployment**: Deploying a certificate directly affects the domain's HTTPS service. You **must** explain which domains will receive which certificate, and wait for explicit user confirmation before calling `ModifyHostsCertificate`.

### E2: CNAME Access (Manual Verification)

CNAME access requires applying for the certificate first, completing domain verification, and then deploying — the process is longer. See the complete steps in [cert-manager.md Scenario B2](cert-manager.md#b2-cname-access-manual-verification).

## Scenario F: Check Onboarding Status

**Trigger**: User says "check zone status", "is the domain onboarded yet".

Call `DescribeZones` to query the target zone's status.

> See [../api/zone-discovery.md](../api/zone-discovery.md) for more query methods.
