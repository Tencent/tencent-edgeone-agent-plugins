# Zone & Domain Discovery

Nearly all EdgeOne API operations require a **ZoneId** (zone ID, in the format `zone-xxx123abc456`).
Below is the standard process for discovering ZoneIds and reverse-looking up domains.

## APIs Involved

| Action | Description | API Docs |
|---|---|---|
| DescribeZones | Query the list of zones | `curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/action/DescribeZones.md` |
| DescribeAccelerationDomains | Query the list of acceleration domains | `curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/action/DescribeAccelerationDomains.md` |

Check the API docs above before calling, to get the exact usage of Filters, pagination, and other parameters.

## 1. List All Zones

Call `DescribeZones` — the `Zones` array in the response contains each zone's `ZoneId`, `ZoneName` (zone domain), `Status`, and other info.

## 2. Query by Zone Name

When the user already knows the zone domain, call `DescribeZones` with `Filters` (`zone-name`) for an exact match.

## 3. Reverse-Lookup ZoneId from a Subdomain

When the user only provides a subdomain (e.g., `www.example.com`) and doesn't know the ZoneId:

1. First call `DescribeZones` to list all zones, and find the ZoneId corresponding to the root domain matching the subdomain
2. Then call `DescribeAccelerationDomains` with `Filters` (`domain-name`) to confirm the domain exists under the zone

## 4. List All Domains Under a Zone

Call `DescribeAccelerationDomains` with the `ZoneId`. Be sure to use pagination parameters to handle multi-page results.

## 5. ZoneId Caching Recommendation

Within the same session, previously discovered ZoneIds should be remembered and reused to avoid repeated calls to `DescribeZones`.
