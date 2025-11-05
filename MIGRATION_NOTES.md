# Akka to Pekko Migration Notes

## Package Name Changes
All imports need to be updated:
- `akka.*` → `org.apache.pekko.*`
- `com.typesafe.akka.*` → `org.apache.pekko.*`

## Configuration Changes
In all `application.conf` files:
- `akka { ... }` → `pekko { ... }`
- All nested akka.* paths need updating

## Dependency Changes
- Akka artifacts → Pekko artifacts (see build.sbt)
- Alpakka → Pekko Connectors
- Akka HTTP → Pekko HTTP
- Akka gRPC → Pekko gRPC

## API Compatibility
Pekko maintains binary compatibility with Akka 2.6.x, so most code should work with just import changes.

## Notable Differences
1. Repository: Maven Central (Apache) vs Lightbend repos
2. License: Apache 2.0 (no BSL restrictions)
3. Version numbering: Started fresh at 1.0.x

## Testing Migration
- Add Pekko testkit dependencies
- Update test configurations to use `pekko.*` paths
- Verify cluster and persistence tests work

## Resources
- Pekko Documentation: https://pekko.apache.org/docs/
- Migration Guide: https://pekko.apache.org/docs/pekko/current/project/migration-guides.html
