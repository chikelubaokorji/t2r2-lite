#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="t2r2-lite"
ORG="io.t2r2"

echo "Scaffolding $PROJECT_NAME with Apache Pekko..."

# ---- directories
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

mkdir -p project .vscode .github/workflows

# Create module structure
MODULES=(core contracts orchestrator tracker dag gateway ui)
for module in "${MODULES[@]}"; do
  mkdir -p "modules/$module/src/main/scala"
  mkdir -p "modules/$module/src/main/resources"
  mkdir -p "modules/$module/src/test/scala"
  mkdir -p "modules/$module/src/test/resources"
done

# Protobuf directories
mkdir -p modules/core/src/main/protobuf
mkdir -p modules/contracts/src/main/protobuf

# ---- .gitignore
cat > .gitignore <<'EOF'
# sbt / scala
target/
project/target/
project/project/
metals.sbt
.metals/
.bloop/
.idea/
.cache/
.vscode/.history

# Java/Scala
*.class
*.log

# OS
.DS_Store

# Node (if you later add UI)
node_modules/
dist/

# Environment Settings 
**/application.conf
!**/application.conf.template
EOF

# ---- README
cat > README.md <<'EOF'
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
EOF

# ---- build.sbt
cat > build.sbt <<EOF
// ==============================
// build.sbt  (Scala / Apache Pekko multi-module)
// ==============================

ThisBuild / organization := "io.t2r2"
ThisBuild / version := "0.1.0-SNAPSHOT"
ThisBuild / scalaVersion := "2.13.14"         

// ---- Global compiler flags (tweak to taste)
lazy val commonScalacOptions = Seq(
  "-deprecation", "-feature", "-unchecked", "-Wconf:any:warning-verbose",
  "-Xlint:_", "-Ywarn-dead-code", "-Ywarn-value-discard", "-encoding", "utf8"
)

ThisBuild / resolvers ++= Seq(
  Resolver.mavenCentral,
  "Apache Snapshots".at("https://repository.apache.org/snapshots/"),
  "Apache Releases".at("https://repository.apache.org/content/repositories/releases/")
)

// ---- Versions in one place
lazy val V = new {
  val pekko                = "1.0.3"           // Apache Pekko
  val pekkoHttp            = "1.0.1"           // Pekko HTTP
  val pekkoGrpc            = "1.0.2"           // Pekko gRPC
  val pekkoProjection      = "1.0.0"           // Pekko Projection
  val pekkoConnectors      = "1.0.2"           // Pekko Connectors (formerly Alpakka)
  val pekkoConnectorsKafka = "1.0.0"           // Pekko Kafka Connector
  val persistenceJdbc      = "1.0.0"           // Pekko Persistence JDBC
  val slick                = "3.3.3"
  val flyway               = "10.18.2"
  val postgres             = "42.7.4"
  val scalapb              = "0.11.17"
  val grpcNetty            = "1.65.1"
  val otelApi              = "1.43.0"
  val otelSdk              = "1.43.0"
  val otelSemconv          = "1.28.0-alpha"
  val otelOtlp             = "1.43.0"
  val logback              = "1.5.6"
  val scalaLogging         = "3.9.5"
  val pureconfig           = "0.17.6"
  val testcontainers       = "0.41.4"
  val scalatest            = "3.2.19"
}

// ---- Common deps for most modules
lazy val pekkoCoreDeps = Seq(
  "org.apache.pekko" %% "pekko-actor-typed"         % V.pekko,
  "org.apache.pekko" %% "pekko-cluster-typed"       % V.pekko,
  "org.apache.pekko" %% "pekko-serialization-jackson" % V.pekko,
  "org.apache.pekko" %% "pekko-stream"              % V.pekko,
  "org.apache.pekko" %% "pekko-discovery"           % V.pekko,
  "org.apache.pekko" %% "pekko-slf4j"               % V.pekko,
  "ch.qos.logback"    % "logback-classic"           % V.logback
)

lazy val persistenceDeps = Seq(
  "org.apache.pekko" %% "pekko-persistence-jdbc"    % V.persistenceJdbc,
  "org.apache.pekko" %% "pekko-persistence-typed"   % V.pekko,
  "org.apache.pekko" %% "pekko-projection-eventsourced" % V.pekkoProjection,
  "org.apache.pekko" %% "pekko-projection-jdbc"     % V.pekkoProjection,
  "org.postgresql"    % "postgresql"                % V.postgres,
  "com.typesafe.slick" %% "slick"                   % V.slick,
  "com.typesafe.slick" %% "slick-hikaricp"          % V.slick,
  "org.flywaydb"      % "flyway-core"               % V.flyway,
  "org.flywaydb"      % "flyway-database-postgresql" % V.flyway
)

lazy val httpAndGrpcDeps = Seq(
  "org.apache.pekko" %% "pekko-http"                % V.pekkoHttp,
  "org.apache.pekko" %% "pekko-grpc-runtime"        % V.pekkoGrpc,
  "io.grpc"           % "grpc-netty"                % V.grpcNetty
)

lazy val connectorsAndKafkaDeps = Seq(
  "org.apache.pekko" %% "pekko-connectors-s3"       % V.pekkoConnectors,
  "org.apache.pekko" %% "pekko-connectors-kafka"    % V.pekkoConnectorsKafka
)

lazy val protobufDeps = Seq(
  "com.thesamet.scalapb" %% "scalapb-runtime"       % V.scalapb % "protobuf"
)

lazy val configAndLoggingDeps = Seq(
  "com.github.pureconfig" %% "pureconfig"           % V.pureconfig,
  "com.typesafe.scala-logging" %% "scala-logging"   % V.scalaLogging
)

lazy val otelDeps = Seq(
  "io.opentelemetry" % "opentelemetry-api"          % V.otelApi,
  "io.opentelemetry" % "opentelemetry-sdk"          % V.otelSdk,
  "io.opentelemetry" % "opentelemetry-semconv"      % V.otelSemconv,
  "io.opentelemetry" % "opentelemetry-exporter-otlp"% V.otelOtlp
)

lazy val testDeps = Seq(
  "org.scalatest"     %% "scalatest"                 % V.scalatest % Test,
  "org.apache.pekko"  %% "pekko-actor-testkit-typed" % V.pekko % Test,
  "org.apache.pekko"  %% "pekko-stream-testkit"      % V.pekko % Test,
  "org.apache.pekko"  %% "pekko-http-testkit"        % V.pekkoHttp % Test,
  "com.dimafeng"      %% "testcontainers-scala-postgresql" % V.testcontainers % Test,
  "com.dimafeng"      %% "testcontainers-scala-munit"      % V.testcontainers % Test,
  "com.dimafeng"      %% "testcontainers-scala-localstack" % V.testcontainers % Test
)

// ---- Common settings applied to all JVM subprojects
lazy val commonSettings = Seq(
  scalacOptions ++= commonScalacOptions,
  Test / parallelExecution := false,
  // Assembly merge rules can go here if using sbt-assembly
  libraryDependencies ++= configAndLoggingDeps ++ testDeps
)

// ==============================
// Root project (aggregator)
// ==============================
lazy val root = (project in file("."))
  .aggregate(core, contracts, orchestrator, tracker, dag, gateway)
  .settings(
    name := "t2r2-lite-root",
    publish / skip := true
  )

// ==============================
// :core  (domain, messages, shared utils)
// ==============================
lazy val core = (project in file("modules/core"))
  .settings(commonSettings)
  .settings(
    name := "t2r2-core",
    libraryDependencies ++= pekkoCoreDeps ++ protobufDeps ++ otelDeps
  )
  .enablePlugins(PekkoGrpcPlugin) // generated classes if you add .proto here

// ==============================
// :contracts  (protobuf schemas, contract validation)
// ==============================
lazy val contracts = (project in file("modules/contracts"))
  .dependsOn(core)
  .settings(commonSettings)
  .settings(
    name := "t2r2-contracts",
    libraryDependencies ++= protobufDeps ++ pekkoCoreDeps ++ persistenceDeps
  )
  .enablePlugins(PekkoGrpcPlugin)

// ==============================
// :orchestrator  (cluster-sharded run + task orchestration)
// ==============================
lazy val orchestrator = (project in file("modules/orchestrator"))
  .dependsOn(core, contracts)
  .settings(commonSettings)
  .settings(
    name := "t2r2-orchestrator",
    libraryDependencies ++= pekkoCoreDeps ++ persistenceDeps ++ httpAndGrpcDeps ++
      connectorsAndKafkaDeps ++ otelDeps
  )

// ==============================
// :tracker  (event-sourced audit trail, projections/materialized views)
// ==============================
lazy val tracker = (project in file("modules/tracker"))
  .dependsOn(core, contracts)
  .settings(commonSettings)
  .settings(
    name := "t2r2-tracker",
    libraryDependencies ++= pekkoCoreDeps ++ persistenceDeps ++ httpAndGrpcDeps ++ otelDeps
  )

// ==============================
// :dag  (lineage graph builder + query API)
// ==============================
lazy val dag = (project in file("modules/dag"))
  .dependsOn(core, tracker)
  .settings(commonSettings)
  .settings(
    name := "t2r2-dag",
    libraryDependencies ++= pekkoCoreDeps ++ persistenceDeps ++ httpAndGrpcDeps ++ otelDeps
  )

// ==============================
// :gateway  (Pekko HTTP/gRPC APIs: submit runs, DAG, replay, contracts)
// ==============================
lazy val gateway = (project in file("modules/gateway"))
  .dependsOn(core, orchestrator, tracker, dag, contracts)
  .settings(commonSettings)
  .settings(
    name := "t2r2-gateway",
    libraryDependencies ++= pekkoCoreDeps ++ httpAndGrpcDeps ++ persistenceDeps ++ otelDeps
  )

// ==============================
// Protobuf / gRPC generation settings
// ==============================
import org.apache.pekko.grpc.sbt.PekkoGrpcPlugin
Compile / PB.targets := Seq(
  scalapb.gen() -> (Compile / sourceManaged).value / "scalapb"
)
PB.externalIncludePath := (Compile / sourceDirectory).value / "protobuf"

// Recommended to keep proto sources under: modules/{core,contracts}/src/main/protobuf
// Example: modules/contracts/src/main/protobuf/Artifact.proto

// ==============================
// Assembly settings (fat JARs for each service)
// Requires: addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "2.2.0") in project/plugins.sbt
// ==============================
import sbtassembly.AssemblyPlugin.autoImport.{assembly, assemblyMergeStrategy, MergeStrategy}
import sbtassembly.PathList

ThisBuild / assemblyMergeStrategy := {
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case x if x.endsWith("module-info.class") => MergeStrategy.discard
  case x if x.contains("pekko") && x.endsWith(".conf") => MergeStrategy.concat
  case x => MergeStrategy.first
}
EOF

# ---- project/plugins.sbt
mkdir -p project
cat > project/plugins.sbt <<'EOF'
addSbtPlugin("com.github.sbt" % "sbt-native-packager" % "1.10.0")
addSbtPlugin("com.eed3si9n"   % "sbt-assembly"        % "2.2.0")
addSbtPlugin("org.apache.pekko" % "pekko-grpc-sbt-plugin" % "1.0.2")
addSbtPlugin("com.thesamet"   % "sbt-protoc"          % "1.0.6")

libraryDependencies += "com.thesamet.scalapb" %% "compilerplugin" % "0.11.17"
EOF

# ---- project/build.properties
echo "sbt.version=1.9.7" > project/build.properties

# ---- prometheus.yml
cat > prometheus.yml <<'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 't2r2-services'
    static_configs:
      - targets: ['host.docker.internal:8080', 'host.docker.internal:8081']
        labels:
          group: 't2r2'
EOF

# ---- docker-compose.yml
cat > docker-compose.yml <<'EOF'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: appdb
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d appdb"]
      interval: 10s
      timeout: 5s
      retries: 5

  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minio
      MINIO_ROOT_PASSWORD: minio123
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio-data:/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

  jaeger:
    image: jaegertracing/all-in-one:1.46
    environment:
      COLLECTOR_OTLP_ENABLED: "true"
    ports:
      - "6831:6831/udp"
      - "16686:16686"
      - "14268:14268"
      - "4317:4317"
      - "4318:4318"

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana-data:/var/lib/grafana
    depends_on:
      - prometheus

  neo4j:
    image: neo4j:5
    environment:
      NEO4J_AUTH: neo4j/password123
      NEO4J_PLUGINS: '["apoc"]'
      NEO4J_dbms_security_procedures_unrestricted: apoc.*
    ports:
      - "7474:7474"
      - "7687:7687"
    volumes:
      - neo4j-data:/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "cypher-shell -u neo4j -p password123 'RETURN 1'"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres-data:
  minio-data:
  prometheus-data:
  grafana-data:
  neo4j-data:
EOF

# ---- Sample application.conf template
cat > modules/core/src/main/resources/application.conf.template <<'EOF'
# Pekko Configuration Template
# Copy this to application.conf and customize

pekko {
  loglevel = "INFO"
  
  actor {
    provider = cluster
    
    serialization-bindings {
      "io.t2r2.YourSerializable" = jackson-json
    }
  }
  
  cluster {
    seed-nodes = [
      "pekko://t2r2@127.0.0.1:2551"
    ]
    
    downing-provider-class = "org.apache.pekko.cluster.sbr.SplitBrainResolverProvider"
  }
  
  persistence {
    journal.plugin = "jdbc-journal"
    snapshot-store.plugin = "jdbc-snapshot-store"
  }
  
  http {
    server {
      preview.enable-http2 = on
    }
  }
}

# JDBC configuration
jdbc-journal {
  slick = \${slick}
}

jdbc-snapshot-store {
  slick = \${slick}
}

slick {
  profile = "slick.jdbc.PostgresProfile$"
  db {
    host = "localhost"
    port = 5432
    name = "appdb"
    user = "user"
    password = "password"
    driver = "org.postgresql.Driver"
    numThreads = 5
    maxConnections = 5
    minConnections = 1
  }
}

# Neo4j configuration (for DAG/lineage graph)
neo4j {
  uri = "bolt://localhost:7687"
  username = "neo4j"
  password = "password123"
  
  connection {
    max-pool-size = 50
    connection-timeout = 30s
    max-transaction-retry-time = 30s
  }
}

# MinIO/S3 configuration
s3 {
  endpoint = "http://localhost:9000"
  access-key = "minio"
  secret-key = "minio123"
  bucket = "t2r2-artifacts"
  region = "us-east-1"
}

# OpenTelemetry configuration
otel {
  service-name = "t2r2"
  jaeger {
    endpoint = "http://localhost:4317"
  }
}
EOF

# ---- CI Workflow
mkdir -p .github/workflows
cat > .github/workflows/ci.yml <<'EOF'
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: user
          POSTGRES_PASSWORD: password
          POSTGRES_DB: appdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '11'
          cache: 'sbt'

      - name: Setup SBT
        uses: sbt/setup-sbt@v1

      - name: Cache SBT
        uses: actions/cache@v4
        with:
          path: |
            ~/.ivy2/cache
            ~/.sbt
            ~/.coursier
          key: ${{ runner.os }}-sbt-${{ hashFiles('**/build.sbt', 'project/build.properties', 'project/plugins.sbt') }}
          restore-keys: |
            ${{ runner.os }}-sbt-

      - name: Compile
        run: sbt clean compile

      - name: Run tests
        run: sbt test

      - name: Check formatting (optional)
        run: sbt scalafmtCheckAll || true
        continue-on-error: true
EOF

# ---- Environment Setup
echo "Installing SBT..."
sudo apt-get update
sudo apt-get install apt-transport-https curl gnupg -yqq
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo -H gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import
sudo chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg
sudo apt-get update
sudo apt-get install sbt
echo "SBT version installed:"
sbt sbtVersion

echo ""
echo "Scaffold complete!"
echo "Next steps:"
echo "   1. cd $PROJECT_NAME"
echo "   2. Review MIGRATION_NOTES.md for code migration guidance"
echo "   3. Copy modules/core/src/main/resources/application.conf.template to application.conf"
echo "      'cp modules/core/src/main/resources/application.conf.template modules/core/src/main/resources/application.conf'"
echo "   4. Run 'docker-compose up -d' to start infrastructure"
echo "   5. Run 'sbt compile' to verify the build"
echo ""
echo "Project uses Apache Pekko (Apache 2.0 license) instead of Akka BSL"