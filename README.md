JVML
====

ds84182's bullshit JVM


Requirements
====

Ant is required to build the runtime library for JVML (cc_rt.jar)

To compile a java source file and ensure proper checking against the CCLib runtime, instead of the one shipped with the jdk, use the bootclasspath option

```
javac -bootclasspath CCLib/build/jar/cc_rt.jar MyFirstProgram.java
```
