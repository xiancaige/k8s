echo "-------init------"

chown 1000 /var/run/docker.sock

mkdir /data/kubernetes/jenkins_home/agent -p

chown 1000 /data/kubernetes/jenkins_home/agent

mkdir /data/kubernetes/jenkins_home/.m2 -p

cat > /data/kubernetes/jenkins_home/.m2/settings-docker.xml <<EOF 
   <?xml version="1.0" encoding="UTF-8"?>
   <settings xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
    xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <localRepository>/data/kubernetes/jenkins_home/.m2/repository</localRepository>
    <interactiveMode>true</interactiveMode>
    <usePluginRegistry>false</usePluginRegistry>
    <offline>false</offline>
    <mirrors>
        <mirror>
            <id>nexus-aliyun</id>
            <mirrorOf>central</mirrorOf>
            <name>Nexus aliyun</name>
            <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
        </mirror>
    </mirrors>
    <profiles>
        <profile>
            <id>default</id>
            <activation>
                <activeByDefault>true</activeByDefault>
                <jdk>1.8</jdk>
            </activation>
            <repositories>
                <repository>
                    <id>spring-milestone</id>
                    <name>Spring Milestone Repository</name>
                    <url>http://repo.spring.io/milestone</url>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                    <snapshots>
                        <enabled>false</enabled>  
                    </snapshots>  
                    <layout>default</layout>  
                </repository>  
                <repository>  
                    <id>spring-snapshot</id>  
                    <name>Spring Snapshot Repository</name>  
                    <url>http://repo.spring.io/snapshot</url>  
                    <releases>  
                        <enabled>false</enabled>  
                    </releases>  
                    <snapshots>  
                        <enabled>true</enabled>  
                    </snapshots>  
                    <layout>default</layout>  
                </repository>  
            </repositories>  
        </profile>  
    </profiles>  
</settings>
EOF

chown 1000 /data/kubernetes/jenkins_home/.m2

echo "-------init end------"
