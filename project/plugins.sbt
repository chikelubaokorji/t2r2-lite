addSbtPlugin("com.github.sbt" % "sbt-native-packager" % "1.10.0")
addSbtPlugin("com.eed3si9n"   % "sbt-assembly"        % "2.2.0")
addSbtPlugin("org.apache.pekko" % "pekko-grpc-sbt-plugin" % "1.0.2")
addSbtPlugin("com.thesamet"   % "sbt-protoc"          % "1.0.6")
addSbtPlugin("org.scalameta"  % "sbt-scalafmt"        % "2.5.2")

libraryDependencies += "com.thesamet.scalapb" %% "compilerplugin" % "0.11.17"
