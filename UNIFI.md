# Ubiquiti USG Advanced Configuration

*SOURCE: https://gist.github.com/troyfontaine/a0a0098d6a8c333e5316ebf16db1c425*

# Ubiquiti USG Advanced Configuration

## Overview
### Integrated DNS Overview
When using a USG with Ubiquiti's Unifi Controller software (version 5.6 and earlier), the functionality of integrating the hostnames of clients (when they request a DHCP lease) into local DNS does not appear to work as you would find with Consumer grade routers.  To work around this limitation, we can add static host mappings to a configuration file that will be provisioned to the USG when either a configuration change is made or we force provisioning to the USG itself.

### Non-GUI Supported Dynamic DNS Providers
I've added in the necessary syntax for adding Cloudflare DDNS to the USG for VPN/Services setup courtesy of [this post](https://community.ubnt.com/t5/UniFi-Routing-Switching/Who-wants-Cloudflare-DDNS-support/m-p/2250738/highlight/true#M78497) by [britannic](https://community.ubnt.com/t5/user/viewprofilepage/user-id/258183) on the Ubiquiti Forums.

### Configuration File
On the CloudKey, the config file is located at `/usr/lib/unifi/data/sites/default/config.gateway.json`

### Cloudflare DNS
You MUST pre-create the A Record for the hostname you wish to use for the USG. Once the record is created, API calls can successfully modify the record.

## Later Releases

### Override
The configuration in this file is overridden in the Unifi Controller software after version 5.6 by DHCP reservations (which appears to provide similar functionality to consumer-grade routers in that you no longer need to provide a configuration and hostnames are captured when they request a DHCP lease).  It appears to be simply ignored.

### Static IPs
In Unifi Controller software after 5.6, setting a static IP in the configuration when using a USG and after a client has already received their DHCP assigned address, to update the built-in DNS you must release and renew the client's IP from the client to update the DNS configuration

## Troubleshooting
If the configuration doesn't seem to be applying-you may need to reboot your Controller/CloudKey.

# sample-with-cloudflare-api-v1.json

```
{
        "service": {
                "dns": {
                        "dynamic": {
                                "interface": {
                                        "eth0": {
                                                "service": {
                                                        "custom-cloudflare": {
                                                                "host-name": [
                                                                        "host.mydomain.tld"
                                                                ],
                                                                "login": "cloudflare@mydomain.tls",
                                                                "options": [
                                                                  "zone=mydomain.tld"
                                                                ],
                                                                "password": "MYAPIKEYGOESHERE",
                                                                "protocol": "cloudflare",
                                                                "server": "www.cloudflare.com"
                                                        }
                                                }
                                        }
                                }
                        }
                }
        },
        "system": {
                    "static-host-mapping": {
                        "host-name": {
                                "mynas.mynet.mydomain.com": {
                                        "alias": [
                                                "mynas"
                                        ],
                                        "inet": [
                                                "192.168.1.99"
                                        ]
                                },
                                "unifi.mynet.mydomain.com": {
                                        "alias": [
                                                "unifi"
                                        ],
                                        "inet": [
                                                "192.168.1.30"
                                        ]
                                }
                        }
                }
        }
}
```

# sample.json

```
{
        "system": {
                    "static-host-mapping": {
                        "host-name": {
                                "mynas.mynet.mydomain.com": {
                                        "alias": [
                                                "mynas"
                                        ],
                                        "inet": [
                                                "192.168.1.99"
                                        ]
                                },
                                "unifi.mynet.mydomain.com": {
                                        "alias": [
                                                "unifi"
                                        ],
                                        "inet": [
                                                "192.168.1.30"
                                        ]
                                }
                        }
                }
        }
}
```

# Cloudflare DDNS support?

```
{
  "service": {
    "dns": {
      "dynamic": {
        "interface": {
          "eth0": {
            "service": {
              "custom-cloudflare": {
                "host-name": [
                  "hostname.domain.tld"
                ],
                "login": "cloudflare@myemail.com",
                "options": [
                  "zone=domain.tld"
                ],
                "password": "cloudflare-api-key",
                "protocol": "cloudflare",
                "server": "api.cloudflare.com/client/v4"
              }
            }
          }
        }
      }
    }
  }
}
```

---

# UniFi - USG Advanced Configuration

https://help.ubnt.com/hc/en-us/articles/215458888-UniFi-How-to-further-customize-USG-configuration-with-config-gateway-json

---

# Setting up an Ubiquiti EdgeRouter to use CloudFlare for Dynamic DNS ( start here )

https://www.christiaanconover.com/blog/cloudflare-ubiquiti-dynamic-dns/

https://www.cloudflare.com/learning/dns/dns-records/dns-a-record/

---

# Migrate devices

https://help.ubnt.com/hc/en-us/articles/115002869188-UniFi-Migrating-Sites-with-Site-Export-Wizard


----

## 2019-02-03	EdgeRouter CNAME records	- Setup CNAME records

https://loganmarchione.com/2019/02/edgerouter-cname-records/

## 2017-10-03	Dyn DDNS on EdgeRouter	- Setup DynDNS

https://loganmarchione.com/2017/10/dyn-ddns-edgerouter/


## 2017-04-25	DuckDNS on EdgeRouter	- Setup DuckDNS

https://loganmarchione.com/2017/04/duckdns-on-edgerouter/

## 2017-01-08	Ubiquiti EdgeRouter serial console settings	- Serial console settings

https://loganmarchione.com/2017/01/ubiquiti-edgerouter-serial-console-settings/

## 2016-11-29	Ubiquiti UniFi controller setup on Raspberry Pi 3	- Install UniFi Controller

https://loganmarchione.com/2016/11/ubiquiti-unifi-controller-setup-raspberry-pi-3/

## 2016-08-30	EdgeRouter Lite Dnsmasq setup	- Setup dnsmasq

https://loganmarchione.com/2016/08/edgerouter-lite-dnsmasq-setup/

## 2016-06-13	EdgeRouter Lite software upgrade	- Firmware upgrade

https://loganmarchione.com/2016/06/edgerouter-lite-software-upgrade/

## 2016-05-12	EdgeRouter Lite OpenVPN setup	- OpenVPN server setup

https://loganmarchione.com/2016/05/edgerouter-lite-openvpn-setup/

## 2016-04-29	Ubiquiti EdgeRouter Lite setup	- Initial setup

https://loganmarchione.com/2016/04/ubiquiti-edgerouter-lite-setup/


## UniFi - Where is <unifi_base>?

https://help.ubnt.com/hc/en-us/articles/115004872967


## UniFi - USG Firewall: Introduction to Firewall Rules

https://help.ubnt.com/hc/en-us/articles/115003173168-UniFi-USG-Firewall-Introduction-to-Firewall-Rules

----

# TOC: UniFi Configuration

https://help.ubnt.com/hc/en-us/sections/200915540-UniFi-Configuration

* UniFi - USG: Configuring RADIUS Server
* UniFi - UAP: Configuring Access Policies for Wireless Clients
* UniFi - USG: How to Configure Custom DHCP Options
* [UniFi - USG: How to Adopt a USG into an Existing Network](https://help.ubnt.com/hc/en-us/articles/236281367-UniFi-USG-How-to-Adopt-a-USG-into-an-Existing-Network)
* UniFi - USG: Configuring Port Remapping
* UniFi - USW: Configuring Link Aggregation Groups (LAG)
* [UniFi - USG: Configuring Intrusion Prevention/Detection System (IPS/IDS)](https://help.ubnt.com/hc/en-us/articles/360006893234-UniFi-USG-Configuring-Intrusion-Prevention-Detection-System-IPS-IDS-)
* UniFi - USW: Configuring Spanning Tree Protocol
* UniFi - USG Advanced: Policy-Based Routing
* UniFi - USG VPN: How to Configure Site-to-Site VPN
* UniFi - Using Facebook Wi-Fi for Guest Authorization
* UniFi - USG: Configuring L2TP Remote Access VPN
* UniFi - USG Firewall: How to Disable InterVLAN Routing
* UniFi - 802.11 Basic & Supported Rate Controls
* UniFi - USG Addressing: How to Implement IPv6 with DHCPv6 and Prefix Delegation
* UniFi - Where is <unifi_base>?
* UniFi - USG Firewall: Introduction to Firewall Rules
* UniFi - How to Configure a Debian/Ubuntu Controller to use Oracle Java
* UniFi - Social Media Guest Authentication
* [UniFi - How to Tune the Controller for High Number of UniFi Devices](UniFi - How to Tune the Controller for High Number of UniFi Devices)
* UniFi - Group Configuration and Tags
* UniFi - USW: Configuring Access Policies (802.1X) for Wired Clients
* UniFi - USW: Powering a US-8 Switch and Connected Devices
* UniFi - Best Practices for Legacy Configurations
* [UniFi - USG Port Forward: Port Forwarding Configuration and Troubleshooting](https://help.ubnt.com/hc/en-us/articles/235723207-UniFi-USG-Port-Forward-Port-Forwarding-Configuration-and-Troubleshooting)
* UniFi - How To Use a Free Email Service as SMTP Server (Gmail)
* UniFi - Understanding and Implementing Minimum RSSI
* [UniFi - Using VLANs with UniFi Wireless, Routing & Switching Hardware](https://help.ubnt.com/hc/en-us/articles/219654087-UniFi-Using-VLANs-with-UniFi-Wireless-Routing-Switching-Hardware)
* [UniFi - USG Advanced Configuration](https://help.ubnt.com/hc/en-us/articles/215458888-UniFi-USG-Advanced-Configuration)
* [UniFi - VLAN Traffic Tagging](https://help.ubnt.com/hc/en-us/articles/204962144-UniFi-VLAN-Traffic-Tagging)

---

# TOC: UniFi Getting Started

* UniFi - Getting Started
* [UniFi - Getting Started FAQ](https://help.ubnt.com/hc/en-us/articles/360008240754#3)
* [UniFi - Accounts and Passwords for Controller, Cloud Key, and Other Devices](https://help.ubnt.com/hc/en-us/articles/204909374-UniFi-Accounts-and-Passwords-for-Controller-Cloud-Key-and-Other-Devices)
* [UniFi - Device Adoption](https://help.ubnt.com/hc/en-us/articles/360012622613-UniFi-Device-Adoption)
* [UniFi - How to Migrate from Cloud Key Gen 1 to Cloud Key Gen 2](https://help.ubnt.com/hc/en-us/articles/360008976393-UniFi-How-to-Migrate-from-Cloud-Key-Gen-1-to-Cloud-Key-Gen-2)
* [UniFi - Controller FAQ](https://help.ubnt.com/hc/en-us/articles/360008240754-UniFi-Controller-FAQ)
* [UniFi - Setting Up UniFi for Beginners](https://help.ubnt.com/hc/en-us/articles/219051528-UniFi-How-to-Setup-your-Cloud-Key-and-UniFi-Access-Point-for-beginners-)
* [UniFi - Device Adoption Methods for Remote UniFi Controllers](https://help.ubnt.com/hc/en-us/articles/204909754-UniFi-Device-Adoption-Methods-for-Remote-UniFi-Controllers)
* [UniFi - How to Manage & Upgrade your Cloud Key](https://help.ubnt.com/hc/en-us/articles/115004323048-UniFi-How-to-Manage-Upgrade-your-Cloud-Key)
* [UniFi - Changing the Firmware of a UniFi Device](https://help.ubnt.com/hc/en-us/articles/204910064-UniFi-Changing-the-Firmware-of-a-UniFi-Device)
* [UniFi - How to Enable Cloud Access for Remote Management](https://help.ubnt.com/hc/en-us/articles/115012240067-UniFi-How-to-Enable-Cloud-Access-for-Remote-Management)
* [UniFi - Advanced Adoption of a "Managed By Other" Device](https://help.ubnt.com/hc/en-us/articles/205146020-UniFi-Advanced-Adoption-of-a-Managed-By-Other-Device)
* [UniFi - Network Types](https://help.ubnt.com/hc/en-us/articles/115008206708-UniFi-Network-Types)
* UniFi - Elite Support Information
* UniFi - Fast Roaming
* UniFi - High Density WLAN Scenario Guide
* UniFi- Feature Guide: Wireless Uplink
* UniFi - UniFi Cloud & UniFi Elite Summary
* UniFi - How to Configure Auto Backup
* UniFi - How to Install and Update via APT on Debian or Ubuntu
* [UniFi - Ports Used](https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used)
* UniFi - Cloud Key's Device Management Limit
* UniFi - How to Change the Cloud Key's Controller Version via SSH
* [UniFi - Install a UniFi Cloud Controller on Amazon Web Services](https://help.ubnt.com/hc/en-us/articles/209376117-UniFi-Install-a-UniFi-Cloud-Controller-on-Amazon-Web-Services)
* [UniFi - UAP Status Meaning Definitions](https://help.ubnt.com/hc/en-us/articles/205231710-UniFi-UAP-Status-Meaning-Definitions)
* UniFi - Viewing Guest Connection Information
* [UniFi - Communication Protocol Between Controller and UAP](https://help.ubnt.com/hc/en-us/articles/204976094-UniFi-Communication-Protocol-Between-Controller-and-UAP)
* UniFi - WLAN Groups
* UniFi - Changing Default Ports for Controller and UAPs
* UniFi - Run the Controller as a Windows Service

#  TOC: UniFi System Management

* UniFi - How to Uninstall the UniFi Controller
* UniFi - Managing UniFi Cloud Controller Subscriptions - https://help.ubnt.com/hc/en-us/articles/360013022914-UniFi-Managing-UniFi-Cloud-Controller-Subscriptions
* UniFi - How to Install & Upgrade the UniFi Controller Software - https://help.ubnt.com/hc/en-us/articles/360012282453-UniFi-How-to-Install-Upgrade-the-UniFi-Controller-Software
* UniFi - Network Controller: Regenerating an IDS/IPS Token (Debian-Based Linux/Cloud Key) - https://help.ubnt.com/hc/en-us/articles/360012057973-UniFi-Network-Controller-Regenerating-an-IDS-IPS-Token-Debian-Based-Linux-Cloud-Key-
* UniFi - Network Controller: Association Failures - https://help.ubnt.com/hc/en-us/articles/360011032134-UniFi-Network-Controller-Association-Failures
* UniFi - How to Export and Delete Device Data - https://help.ubnt.com/hc/en-us/articles/360004619554-UniFi-How-to-Export-and-Delete-Device-Data
* UniFi - Best Practices for Managing Chromecast/Google Home on UniFi Network - https://help.ubnt.com/hc/en-us/articles/360001004034-UniFi-Best-Practices-for-Managing-Chromecast-Google-Home-on-UniFi-Network
* UniFi - How To Reload a UAS using the ISO and USB
* UniFi - How To Reload a UAS using the ISO and IPMI
* UniFi - RF Scan: Suggested Channels Feature
* UniFi - airTime: What's Eating your Wi-Fi Performance?
* UniFi - Server Hardware & Database Management - https://help.ubnt.com/hc/en-us/articles/115006614927-UniFi-Server-Hardware-Database-Management
* UniFi - Hotspot RADIUS Attributes
* UniFi - How to Purchase UniFi Elite
* UniFi - USG Firewall: How to Enable ICMP on the WAN Interface - https://help.ubnt.com/hc/en-us/articles/115003146787-UniFi-USG-Firewall-How-to-Enable-ICMP-on-the-WAN-Interface
* UniFi - Migrating Sites with Site Export Wizard - https://help.ubnt.com/hc/en-us/articles/115002869188-UniFi-Migrating-Sites-with-Site-Export-Wizard
* UniFi - BSSID to MAC Mapping
* UniFi - Managing Broadcast Traffic
* UniFi - Guest Network, Guest Portal and Hotspot System
* UniFi - USW: Supported PoE Output
* UniFi - Adding SSH Keys to UniFi Devices
* UniFi - Configuring the SELFRUN State
* UniFi - How to View Log Files - https://help.ubnt.com/hc/en-us/articles/204959834-UniFi-How-to-View-Log-Files
* UniFi - system.properties File Explanation - https://help.ubnt.com/hc/en-us/articles/205202580-UniFi-system-properties-File-Explanation
* UniFi - How to Create and Restore a Backup - https://help.ubnt.com/hc/en-us/articles/204952144-UniFi-How-to-Create-and-Restore-a-Backup
* UniFi - Explaining the config.properties File - https://help.ubnt.com/hc/en-us/articles/205146040-UniFi-Explaining-the-config-properties-File


# Unifi config so far

Guide: https://help.ubnt.com/hc/en-us/articles/215458888-UniFi-How-to-further-customize-USG-configuration-with-config-gateway-json

```
User Tips:
On Cloud Key install the path for the .json file is: /srv/unifi/data/sites/[site name/default]/
On an Ubuntu install the path for the .json file is: /usr/lib/unifi/data/sites/[site name/default]/
```

**/srv/unifi/data/sites/config.gateway.json:**

```
{
    "firewall": {
            "name": {
                    "WAN_IN": {
                            "rule": {
                                    "3002": {
                                            "log": "enable"
                                    }
                            }
                    },
                    "WAN_LOCAL": {
                            "rule": {
                                    "3002": {
                                            "log": "enable"
                                    }
                            }
                    }
            }
    },
    "system": {
        "static-host-mapping": {
            "host-name": {
                "weave.borglab.duckdns.org": {
                    "inet": "192.168.1.172"
                },
                "weave.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "scope.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "traefik-internal.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "whoami.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "echoserver.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "elasticsearch.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "elasticsearch-exporter.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "kibana.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "prometheus.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "grafana.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "alertmanager.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "registry.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "debug.registry.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "registry-ui.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "jenkins.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "syslog.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                },
                "fluent-bit-centralized.borglab.scarlettlab.home": {
                    "inet": "192.168.1.172"
                }
            }
        }
    }
}
```
