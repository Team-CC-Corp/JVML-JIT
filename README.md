JVML
====

ds84182's really nice and polite JVM
(JIT by Yevano)


Requirements
====

Ant is required to build the runtime library for JVML (cc_rt.jar)

To compile a java source file and ensure proper checking against the CCLib runtime, instead of the one shipped with the jdk, use the bootclasspath option

```
javac -bootclasspath CCLib/build/jar/cc_rt.jar MyFirstProgram.java
```

You will also need Yevano's LuaAssemblyTools fork (https://github.com/Yevano/LuaAssemblyTools) for the JIT compilation. For now, there's no robust searching or anything like that, so you'll need the LASM directory to be placed in the root directory for JVML to find it.
