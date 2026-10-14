# Rewards API contract

Configure `API_BASE_URL` with a trailing slash (the client also adds it if missing).
The client issues:

```http
GET /api/members/1900190000956102/rewards
Accept: application/json
```

Example complete response:

```json
{
  "member": {
    "id": "1900190000956102",
    "name": "Tint Zaw Htun",
    "phone": "+959 780 131 914",
    "type": "Platinum"
  },
  "balance": 1450,
  "transactions": [
    {
      "id": "txn-1",
      "branch": "Star City Branch",
      "points": 50,
      "occurred_at": "2026-10-14T04:00:00Z"
    },
    {
      "id": "txn-2",
      "branch": "Hlaing Branch",
      "points": -100,
      "occurred_at": "2026-10-13T07:45:00Z"
    }
  ],
  "expiry_groups": [
    {"id": "expiry-1", "points": 120, "expiry_date": "2026-11-08"},
    {"id": "expiry-2", "points": 200, "expiry_date": "2026-11-08"}
  ]
}
```

All fields are required. Send empty arrays when there are no transactions/groups.
This endpoint returns a full snapshot, not a paginated or incremental response;
successful sync removes previously cached child rows absent from that snapshot.

Strings must be non-empty. Balance must be a non-negative integer. Transaction
points must be non-zero integers; positive means earned, negative means redeemed.
Expiry points must be positive integers and their total cannot exceed the balance.
Record IDs must be unique within each list and globally unique within their table.
The member ID must match the requested member. Timestamps include a timezone;
expiry dates must be real `YYYY-MM-DD` dates. Display formatting stays in Flutter.

`RewardsApi.fetch()` validates the complete body before saving. `AppDatabase.save()`
then writes the member and both child tables inside one SQLite transaction, so a
failed write leaves the earlier cache intact. A configurable `dioProvider` is the
place to add your backend's authentication/interceptors. No backend service or
authentication endpoint is assumed by this contract.
