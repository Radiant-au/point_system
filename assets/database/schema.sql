-- SQLite is a local rewards cache. The server remains the source of truth.
CREATE TABLE members (
  id TEXT PRIMARY KEY NOT NULL,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  membership_type TEXT NOT NULL,
  points_balance INTEGER NOT NULL CHECK (typeof(points_balance) = 'integer' AND points_balance >= 0),
  password_salt TEXT,
  password_hash TEXT
);

CREATE TABLE point_transactions (
  id TEXT PRIMARY KEY NOT NULL,
  member_id TEXT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  branch TEXT NOT NULL,
  points INTEGER NOT NULL CHECK (typeof(points) = 'integer' AND points != 0),
  occurred_at TEXT NOT NULL
);

CREATE INDEX transactions_by_member_date
  ON point_transactions(member_id, occurred_at DESC);

CREATE TABLE expiry_groups (
  id TEXT PRIMARY KEY NOT NULL,
  member_id TEXT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  points INTEGER NOT NULL CHECK (typeof(points) = 'integer' AND points > 0),
  expiry_date TEXT NOT NULL
);

CREATE INDEX expiry_by_member_date
  ON expiry_groups(member_id, expiry_date);
