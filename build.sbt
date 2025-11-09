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
  "com.thesamet.scalapb" %% "scalapb-runtime"       % V.scalapb % "protobuf",
  "com.thesamet.scalapb" %% "scalapb-runtime-grpc"  % V.scalapb
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
import scalapb.GeneratorOption._
lazy val contracts = (project in file("modules/contracts"))
  .dependsOn(core)
  .enablePlugins(PekkoGrpcPlugin)                  
  .settings(commonSettings)
  .settings(
    name := "t2r2-contracts",
    libraryDependencies ++= protobufDeps ++ pekkoCoreDeps ++ persistenceDeps ++ httpAndGrpcDeps,
    // Configure Pekko gRPC code generation
    pekkoGrpcGeneratedSources := Seq(PekkoGrpc.Client, PekkoGrpc.Server),
    pekkoGrpcGeneratedLanguages := Seq(PekkoGrpc.Scala),
    // ScalaPB configuration for this project only
    Compile / PB.targets := Seq(
      scalapb.gen() -> (Compile / sourceManaged).value / "scalapb"
    )
  )

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