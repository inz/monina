package eu.indenica.config.runtime.generator.extensions

import java.util.logging.Logger

class MavenElementGenerator {
	private static Logger LOG = Logger::getLogger(typeof(MavenElementGenerator).canonicalName)
	
	def compilePom() '''
		«LOG.info("Generating launcher pom...")»
		«var id=System::currentTimeMillis»
		<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
			<modelVersion>4.0.0</modelVersion>
		
			<groupId>eu.indenica.runtime</groupId>
			<artifactId>control-infrastructure-«id»</artifactId>
			<version>0.0.1-SNAPSHOT</version>
			<packaging>jar</packaging>
		
			<name>VSP Monitoring and Adaptation Infrastructure</name>
			
			<properties>
				<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
			</properties>
			
		
			«pomDependencies»
			«pomBuildPlugins»
			«pomRepositories»
		</project>
	'''
	def pomDependencies() '''
		<dependencies>
			<dependency>
				<groupId>org.slf4j</groupId>
				<artifactId>slf4j-api</artifactId>
				<version>1.7.2</version>
			</dependency>
			<dependency>
				<groupId>eu.indenica.runtime</groupId>
				<artifactId>core</artifactId>
				<version>0.0.1-SNAPSHOT</version>
			</dependency>
			<dependency>
				<groupId>org.apache.activemq</groupId>
				<artifactId>activemq-optional</artifactId>
				<version>5.5.1</version>
			</dependency>
			<dependency>
				<groupId>ch.qos.logback</groupId>
				<artifactId>logback-classic</artifactId>
				<version>1.0.6</version>
			</dependency>
		</dependencies>
	'''

	
	def pomRepositories() '''
		<repositories>
			<repository>
				<id>indenica-tuv-snapshots</id>
				<url>https://raw.github.com/indenicatuv/snapshots/master/</url>
				<snapshots>
					<enabled>true</enabled>
				</snapshots>
			</repository>
			<repository>
				<id>indenica-tuv-releases</id>
				<url>https://raw.github.com/indenicatuv/releases/master/</url>
			</repository>
			<repository>
				<id>maven-repo</id>
				<name>maven-repo</name>
				<url>http://repo2.maven.org/maven2</url>
			</repository>
			<repository>
				<id>jboss-repo</id>
				<name>jboss-repo</name>
				<url>https://repository.jboss.org/nexus</url>
			</repository>
		</repositories>
	'''
		
	def pomBuildPlugins() '''
		<build>
			<plugins>
				<plugin>
					<groupId>org.codehaus.mojo</groupId>
					<artifactId>exec-maven-plugin</artifactId>
					<version>1.2.1</version>
					<executions>
						<execution>
							<goals>
								<goal>java</goal>
							</goals>
						</execution>
					</executions>
					<configuration>
						<mainClass>eu.indenica.runtime.Launch</mainClass>
						<!--
						<arguments>
							<argument>argument1</argument>
						</arguments>
						<systemProperties>
							<systemProperty>
								<key>myproperty</key>
								<value>myvalue</value>
							</systemProperty>
						</systemProperties>
						-->
					</configuration>
				</plugin>
			</plugins>
		</build>
	'''
	
}