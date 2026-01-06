-- Standard Pekko Persistence JDBC Schema for Postgres
CREATE TABLE IF NOT EXISTS event_journal (
  ordering BIGSERIAL,
  persistence_id VARCHAR(255) NOT NULL,
  sequence_number BIGINT NOT NULL,
  deleted BOOLEAN DEFAULT FALSE NOT NULL,
  writer VARCHAR(255) NOT NULL,
  write_timestamp BIGINT NOT NULL,
  adapter_manifest VARCHAR(255) NOT NULL,
  event_payload BYTEA NOT NULL,
  event_manifest VARCHAR(255) NOT NULL,
  meta_payload BYTEA,
  meta_manifest VARCHAR(255),
  PRIMARY KEY(persistence_id, sequence_number)
);

CREATE UNIQUE INDEX event_journal_ordering_idx ON event_journal(ordering);

CREATE TABLE IF NOT EXISTS event_tag (
    event_id BIGINT NOT NULL,
    tag VARCHAR(256) NOT NULL,
    PRIMARY KEY(event_id, tag),
    CONSTRAINT fk_event_id FOREIGN KEY (event_id) REFERENCES event_journal(ordering) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS snapshot (
  persistence_id VARCHAR(255) NOT NULL,
  sequence_number BIGINT NOT NULL,
  created BIGINT NOT NULL,
  snapshot_payload BYTEA NOT NULL,
  snapshot_manifest VARCHAR(255) NOT NULL,
  PRIMARY KEY(persistence_id, sequence_number)
);