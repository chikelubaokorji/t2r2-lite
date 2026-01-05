CREATE TABLE IF NOT EXISTS contracts (
    id VARCHAR(255) PRIMARY KEY,
    producer_id VARCHAR(255) NOT NULL,
    consumer_id VARCHAR(255) NOT NULL,
    schema_uri TEXT NOT NULL,
    schema_sha256 VARCHAR(64) NOT NULL,
    schema_version VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);