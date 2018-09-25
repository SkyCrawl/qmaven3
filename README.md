# QMaven3

Provides automatic, smart and convenient installation of [Maven 3](https://maven.apache.org/index.html) for owners of QNAP devices. The main problem to solve was Maven's dependency on Java, because there are several Java QPKGs available. All of QJDK7 to QJDK10 are supported. The JRE package is NOT supported because it isn't compatible with Maven (it only contains JRE, not a JDK). However, it is tolerated if installed because some packages (e.g. Qsirch) may require it.

Features:
* Automatic detection and handling of Java dependency.
* Automatic setup of both Java and Maven environments, both at boot-time and when a user logs into the NAS.
* A simple and convenient option to further configure both environments.
* A simple and convenient option to override Java environment for a particular session.
	- E.g. to quickly switch from Java 8 to Java 7.
* Separate folders for application and configuration.
	- This is a design choice that allows preservation of configuration even if the QPKG is removed or upgraded.
* Tested on TS-269L.

The above applies not only to QTS (QNAP firmware) but also to [Entware](https://github.com/Entware/Entware/wiki/Install-on-QNAP-NAS) (standard installation), when QNAP's default SSH server is replaced with the `openssh-server` package.

Known limitations:
* This package was not tested and will likely not work with alternative installation of [Entware](https://github.com/Entware/Entware/wiki/Install-on-QNAP-NAS). However, it shouldn't be too difficult to add support for that too, if requested.

## Requirements

Documented by each [release](https://github.com/SkyCrawl/qmaven3/releases).

## Installation

Method #1: via QNAP Club:
1. [Link your App Center with QNAP Club](https://www.qnapclub.eu/en/howto/1).
2. Install QMaven3 via App Center/QNAP Club.

Method #2: manually (but still easily):
1. Pick a [release](https://github.com/SkyCrawl/qmaven3/releases) that would suit you and download the QPKG.
2. Login to your QNAP, open App Center and install the QPKG.
	* __Hint:__ click on the "Install manually" icon in the top right corner.

In the unlikely event that installation fails or something doesn't work as expected, here's what you should do:
1. SSH (or sFTP) into your QNAP.
2. Retrieve the installation log (details over [here](https://github.com/SkyCrawl/qmaven3/wiki)).
3. Submit a new issue here on GitHub and provide me with the log.

## Upgrading

1. Open App Center.
2. Uninstall the current version.
	* __Note:__ don't worry, the important stuff is preserved.
3. Install the latest version (see the [installation](#installation) section).
	
If you get a warning telling you to look here, you must have previously made manual modifications to some of the configuration files and the program doesn't dare replace them. In such an event, your previous versions will have been saved in the [data folder](https://github.com/SkyCrawl/qmaven3/wiki) (e.g. `settings.xml.5AE3`) and I kindly ask you to merge them with the new ones (e.g. `settings.xml`).

## How to use

Once you SSH into your QNAP, the `java` and `mvn` commands will be made available to you automatically (beside others). But in case you need to tweak something:
1. Navigate into the `<data-folder>` (see [here](https://github.com/SkyCrawl/qmaven3/wiki)).
2. Do what you need to do (see some hints below).

### FAQ #1: default Java QPKG

If you have multiple Java QPKGs installed and want to set one of them (e.g. QJDK8) as default:
1. Open `<data-folder>/supported_java` in a text editor.
2. And make sure that QJDK8 is the first returned QPKG. For example:

```
echo "QJDK8 ..."
```

This list not only defines all supported Java QPKGs for the currently installed version of QMaven, but also allows you to specify your preferred order. For example, if the first defined QPKG is not installed, the "default" status is assumed by the second defined QPKG (if installed). And so on, so forth.

### FAQ #2: override Java QPKG (for the current session)

If you need to temporarily override the default Java environment (e.g. QJDK8) with another one (e.g. QJDK7), execute:

```
source set_env_java QJDK7
```

### FAQ #3: restore default Java QPKG (for the current session)

If you need to restore the default Java environment (e.g. QJDK8), execute either of:

```
source set_env_java
source set_env_java QJDK8
```

### FAQ #4: new Java QPKG

If there's a new Java QPKG (e.g. `QJDK11`) not yet supported by QMaven and you want to try manually adding support for it:
1. Open `<data-folder>/supported_java` in a text editor.
2. Add `QJDK11` into the list and save.

__However, this will only work when the QPKG's install path directly contains the Java distribution. This is the case for all of QJDK7 to QJDK10 available via QNAP Club and it should be safe to assume the same for future editions.__

### FAQ #5: environment configuration (Maven or Java)

If you need to alter the configuration of your Java or Maven environment:
1. Open `<data-folder>/maven_opts` in a text editor.
2. Add the desired CLI options into the `MAVEN_OPTS` variable and save.
3. Execute:

```
source set_env_mvn
```

### FAQ #6: environment configuration (Maven only)

If you need to alter the configuration of your Maven environment:
1. Open `<data-folder>/settings.xml` in a text editor.
2. Add the desired configuration and save.

## I'm your ally

If you have any issues, questions or requests, feel free to submit an issue here on GitHub.
