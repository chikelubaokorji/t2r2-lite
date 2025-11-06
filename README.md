# T2R2-Lite: Distributed, Reproducible AI/Data Pipelines with Apache Pekko
T2R2-Lite is a portfolio-grade implementation of a distributed data pipeline architecture inspired by Llaama’s reproducibility-first approach to biopharma R&D. Built entirely with Apache Pekko, this project showcases how to design traceable, event-driven systems with DAG lineage, cryptographic integrity, and contract-driven data sharing.
Check out the [Llaama project on Akka.io](https://akka.io/customer-stories/llaama-helps-biopharma-companies-create-ai-driven-treatments-with-akka) for more details.

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


## Why Build This
T2R2-Lite proves that reproducibility, traceability, and compliance can be built into the foundation of AI/data systems—not bolted on later. It’s a hands-on demonstration of how Apache Pekko enables resilient, observable, and contract-driven pipelines for real-world domains like biopharma, finance, and research.