cd d:\plutus\plutus-core
gradle --daemon :env-server:compileJava
gradle --daemon :env-server:runnableJar
move D:\plutus\builds\gradle\env-server\libs\env-server-1.1.jar D:\plutus\runtimes\libs\
cd d:\plutus\plutus-scripts\dev