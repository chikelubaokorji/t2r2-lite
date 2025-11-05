# T2R2-lite

A multi-module Apache Pekko project demonstrating:
- Event-sourced audit trail
- Hash-based artifact integrity
- Protobuf data contracts
- DAG lineage building
- Observability hooks

## Technology Stack
- Apache Pekko (fork of Akka 2.6.x under Apache 2.0 license)
- Pekko HTTP
- Pekko gRPC
- Pekko Persistence
- Pekko Connectors (Alpakka equivalent)

## Quick start
```bash
sbt compile
sbt projects
sbt "project t2r2-gateway" run
```

## Migration from Akka
This project uses Apache Pekko instead of Akka to maintain true open-source licensing (Apache 2.0).
Key changes:
- Package names: `akka.*` → `org.apache.pekko.*`
- Dependencies: Pekko equivalents for all Akka libraries
- Configuration: `akka.*` → `pekko.*` in application.conf files
