name := "matmul"

version := "0.2.0"

scalaVersion := "2.11.11"

val sparkVersion = "2.2.0"

libraryDependencies += "org.apache.spark" %% "spark-core" % sparkVersion % "provided"
libraryDependencies += "org.apache.spark" %% "spark-sql" % sparkVersion % "provided"

libraryDependencies += "org.llvm.openmp" %% "omptarget-spark" % "0.2.0-SNAPSHOT"
