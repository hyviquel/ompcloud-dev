name := "matmul"

version := "0.2.0"

scalaVersion := "2.11.8"

libraryDependencies += "org.apache.spark" %% "spark-core" % "2.0.0" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.0.0" % "provided"

libraryDependencies += "org.llvm.openmp" %% "omptarget-spark" % "0.2.0-SNAPSHOT"
