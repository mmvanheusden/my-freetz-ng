# Check AVM's JUIS for new versions of firmware

Hier geht es zu einer deutschen Version dieser Datei: <https://github.com/PeterPawn/YourFritz/blob/main/juis/README_de.md>

**Purpose:**

This script may be used to query AVM's update information service (JUIS) for new versions.

Due to the ability to configure many (or most) parameters of such a query manually, it is
possible to look for fresh firmware for nearly all AVM devices.

Nevertheless it's still possible to call the script only with the IP address of an existing
(and locally reachable) FRITZ!OS-based router - then it simply will try to get all needed
parameters for the query from this device.

So it's still as easy as possible to look regularly, if a new firmware for your "beloved
router" was published meanwhile - even from outside of this device and if you want to avoid
any automatic discovery and installation of newer firmware versions, e.g. due to (reasonable)
security concerns.

**Usage:**

```text
   juis_check [ options ] [ -- ] [ optional parameters ]
```

Supported options are:

```text
-d, --debug                    - display debug info on STDERR; must prefix all other options
-h, --help                     - show this information (must be the first option)
-V, --version                  - show version and exit (must be the first option)
-n, --no-respawn               - do not respawn with 'bash', even if it's possible
-s, --save-response <filename> - save SOAP response to <filename> for further processing
-a, --show-response            - write SOAP response to STDERR
-i, --ignore-cfgfile           - skip configuration file processing
-c, --current                  - try to get current version URL ('Patch' - see below - gets decremented)
-l, --local                    - use data from local device, do not try to read via network
-p, --print-version            - show version number of found firmware on STDOUT
-r, --use-real-serial          - send real Serial value read from device
```

The script attempts to read a configuration file with its own name (or better expressed:
with the name, that was used to call it, because this may be a symbolic link, too) and an
extension of 'cfg' from the same location, where the script itself was found. This file will
be 'included' with a '.' (dot) command and may contain any shell statement - **please be aware,
that this may lead to a severe security threat, if anyone else may modify this file without your
knowledge**.

To use another file instead, add a value named ```JUIS_CHECK_CFG```, containing the name of a
configuration file, to the environment of this script. To skip all configuration file
processing, use the option ```--ignore-cfgfile``` (or ```-i```) from above.

This configuration file may be used to set one or more of the needed settings (see below)
from positional parameters on the command line and has to use the ```shift``` statement to
remove any processed entries from the parameters collection.

If the option ```--show-response``` is specified, the SOAP response (without HTTP headers) will be written to STDERR. This will be done using a XML formatter/linter, if present, and the default command looked up is ```xmllint``` from the ```libxml2``` project (<http://xmlsoft.org/index.html>). This default value may be replaced by an environment variable named ```XML_LINTER```.

---

Any remaining values from command line are expected to be a name/value pair for one of the
following known settings:

| name | | meaning |
| :---: | :---: | :--- |
| Version | | the firmware version to be assumed as the currently running one - this is the  combined version string, which overrules any of the following partial values: |
| - | Major | model-specific firmware version |
| - | Minor | main version number of FRITZ!OS |
| - | Patch | second part of version number |
| - | Buildnumber | an incrementing value, presumably the consecutive number for a whole build process, it's called ```Revision``` in older firmware (and in the ```jason_boxinfo.xml``` file) |
| Serial | | the serial number of the FRITZ!Box device (usually the same as ```maca```)<br />**If the value is read from device, only the first three bytes (the OUI) of it will be used, together with three random bytes, which will never be the same as in the real value. If you need/want to submit the original value of your device, you may call the script with '-r' option - data will be sent to vendor without further notification or information in this case.** |
| Name | | the product name |
| HW | | the hardware revision |
| OEM | | the OEM value used (also known as the "branding") |
| Lang | | the current language set |
| Annex | | the used annex for the DSL modem or ```Kabel``` for DOCSIS devices |
| Country | | the ITU recommended country code (E.164) |
| Flag | | a comma-delimited list of flags to be included into the request |
| | | |
| Buildtype | | this parameter is used by AVM to distinguish between various lines/series of firmware development.<br />The value is a number (with 1 to 5 digits) and may be specified this way, if the needed/wanted value is known. A missing value will be read from device usually (see ```Box``` below), but if it's left off intentionally (specified as ```empty```), a default value of ```1``` is used.<br />To make calls with a specific value more handy, some known values (formerly seen by AVM or others) are available to be used in place of a numeric value. A specified value is converted to upper case and compared to the names below. If a match was found, the corresponding numeric value will be used for the JUIS request. Due to different (well-known) names for the same value, some duplicates exist.<br />```RELEASE=1```<br />```LABOR=1001```<br />```BETA=1001```<br />```LABBETA=1001```<br />```PLUS=1007```<br />```LABPLUS=1007```<br />```INHOUSE=1000```<br />```INHAUS=1000```<br />```PHONE=1004```<br />```LABPHONE=1004``` |
| | | |
| Public | | ```1``` to check only for public versions, ```0``` to accept "inhouse builds" instead<br />**This parameter is deprecated now (since version 0.5), use 'Buildtype' (see above) instead.**<br />If it's still used (it's mutually exclusive with 'Buildtype'), a value of '1001' for 'Public=1' and '1000' for 'Public=0' will be used as 'Buildtype'. |
| | | |
| Nonce | | this parameter is strictly optional, its absence will not trigger any attempt to read from the ```Box``` device and its value isn't checked further (has to be a Base64 representation of 16 bytes with (preferably) random content; it may be used to set a caller specified ```nonce``` to randomize the SOAP response signature - this is required, if the caller wants to save the whole SOAP response (with ```-s``` option) and check its signature externally |
| | | |
| Box | | this variable can't be set from a name/value pair on the command line, but it's possible to define it in the (shell) environment for the script or it has to be set from a configuration file; if any parameter for the SOAP request is missing, after all name/value pairs from command line were set and the configuration file was processed, this variable has to contain the address of a FRITZ!Box device, which must provide further settings/parameters for the request |

The values for ```Major```, ```Minor```, ```Patch``` and ```Buildnumber``` may not be set from the command line, only from a configuration file. If you want to set a different version number while calling the script, use positional parameters with an appropriate configuration file or use the compound value ```Version``` to specify all parts at once.

If any of the above values isn't set after the configuration file was processed, the ```Box```
value has to be present - either containing an IP address or a DNS name of a FRITZ!Box
device, which will be accessed to retrieve missing values. Only if all of the values above
are already present, this read attempt will be skipped and the ```Box``` value will be ignored.

If no configuration file was found, a file containing the lines:

```shell
Box=$1
shift
```

is assumed instead - this means, the script expects the name or address of a FRITZ!OS device
as first (and only) parameter and tries to read all other settings from the specified device.

Each setting may be specified with the keyword ```detect``` (it has the same meaning as a missing
entry), a setting with this state will be read from the FRITZ!OS device. If the keyword ```empty``` is used, the parameter will be set to an empty string, but is seen as _present_ and not read from the device. If the keyword ```fixed:``` is used at the beginning of the value (or if any other keyword is absent), the string after the colon is used as value. If you want to use a parameter starting with the string ```detect```, you have to use ```fixed:detect``` to specify it in the right manner.

If you need to specify a setting with a value, which contains characters from the IFS value
(it's used for field splitting from POSIX-compatible shells), it has to be enclosed properly
in quotes. Or you may use the Unicode character ```ZERO WIDTH SPACE``` (U+200B) instead, each
occurrence of this character will be replace by a normal ```SPACE``` (U+0020), before the value
gets used in the SOAP request.
If you're using quotes, it doesn't matter, whether you're enclosing the parameter name and
its value within, or if only the value itself is quoted. That means, ```'Name=FRITZ!Box 7490 (UI)'``` and ```Name='FRITZ!Box 7490 (UI)'``` have the same outcome. You should avoid using double quotes ("), if there's not a special reason to use them - e.g. the substitution of variables within a value.

---

The exit code of this script may be used to distinguish between the results, the following
values are used:

| value | meaning |
|:--:|:--|
| 0 | new firmware found in vendor's answer, URL written to STDOUT |
| 1 | error during call (missing 'Box' value, invalid parameter, missing programs, etc.) |
| 2 | no newer firmware found, but processing finished without errors |
| 3 | incomplete parameters (usually an unreachable device with address from 'Box') |
| 4 | wrong SOAP call built with specified and/or read parameters - it's the inference based on a missing answer, a status code other than '200 OK' from AVM or a malformed answer, which has to be a valid SOAP response in case of success |
| 5 | network I/O error (host not found, no answer, etc.) |

---

If you've a license to use MS Office (the Desktop version, because the cloud-based variant doesn't support macros, as far as I know), you could also use the Excel-based version of this check (by @Chatty): <https://github.com/TheChatty/JUISinExcel>

And meanwhile there's also a Windows version with a GUI (and more features, e.g. searching for accessories firmware), it's discussed here: <https://www.ip-phone-forum.de/threads/update-check-juischeck-f%C3%BCr-windows.301927/post-2310055>
