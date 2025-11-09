# Contracts (Pekko gRPC & .proto) and Evolution Guidelines

- `Artifact.proto`, `TaskSpec.proto`, and `RunSpec.proto` use forward-compatible field numbering, with comments describing their evolution.
- `ContractsService.proto` defines service interfaces containing Pekko-native gRPC service defs for ContractsService (ProposeContract, AgreeContract, GetContract, ListContracts).
- All use namespace defined under contracts (i.e. they use packages contracts)

# Proto File Layout
```bash
modules/contracts/src/main/protobuf/Artifact.proto
modules/contracts/src/main/protobuf/TaskSpec.proto
modules/contracts/src/main/protobuf/RunSpec.proto
modules/contracts/src/main/protobuf/ContractsService.proto
```

# Proto File Evolution Guidelines
This document outlines rules and best practices for evolving `.proto` files in this project. Adhering to these ensures forward compatibility, stable semantics, and maintainable contracts.
## General Principles
- **Forward Compatibility**: Field numbering must remain forward-compatible. Document field evolution with comments.
- **Service Definitions**: Service contracts are defined in `ContractsService.proto`. Other files (`Artifact.proto`, `TaskSpec.proto`, `RunSpec.proto`) follow the evolution rules below.
## Evolution Rules
- **Field Numbers**: Never reuse removed field numbers. Mark them as *reserved* to prevent accidental reuse and preserve compatibility.
- **Optional Fields**: Always prefer `optional` over `required`. Add new fields with new numbers rather than modifying existing ones.
- **Stable Semantics**: Once defined, a field’s meaning must remain stable. Avoid repurposing or redefining existing fields.
- **Auditability**: Use timestamps to track changes. Fields like hashes must remain immutable after creation.
- **Maps Usage**: Use maps only for non-critical or extensible metadata. Avoid them for core data requiring strict structure and stability.














