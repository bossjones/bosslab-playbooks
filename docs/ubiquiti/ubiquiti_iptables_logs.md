Re: Analyzing USG firewall logs for attack visibility
Options
‎11-25-2017 01:17 PM

3. Setup analysis of collected logs

This was getting too long so is going to be a multi-part post.

3.1 Reading Unifi logs

I am using anonymized logs from my residential home network. I am not Unifi certified or a network security specliast, but I do have a software and networking background and was able to figure most of this out. Since my network does not run protocols such as IPv6, SCTP, etc this example is not 100% complete. I anonymized the MAC and IP addresses (the IPv4 addresses use RFC 5737 reserved IP addresses).

The Unifi device log format, after a standard log message header, varies depending on the process doing the logging. These are examples of the standard Unifi log messages you would receive with only standard remote logging enabled (firewall logging is covered further down).



# Unifi USG 3-port security gateway:
2017-11-24T01:15:31-05:00 NetworkSecurityUbiquitiUSGULAN system: Process has crashed, creating coredump : core=/var/core/core-ubnt-util-1234-01234567890.gz free-space=1238MB used-space=21%

# Unifi Switch 8 60W:
2017-11-23T09:57:09-05:00 192.0.2.2 ("US8P60,f09fc2001122,v3.9.6.7613") syslog: ace_reporter.reporter_set_managed(): [STATE] enter MANAGED

# Unifi AC-Lite access point:
2017-11-24T00:15:14-05:00 192.0.2.3 ("U7LT,802aa8001122,v3.9.3.7537") syslog: wevent.ubnt_custom_event(): EVENT_STA_LEAVE ath0: 00:11:22:33:44:55 / 4
These log messages follow a standard format: 'Timestamp DeviceHostnameOrIpAddress OptionalDeviceInfo FacilityCode: Message'



Timestamp - my rsyslogd configuration enables high precision timestamps for easier automated log analsys. This timestamp format is: year, month, day, 'T', hour, minute, second, +/- timezone offset (e.g. '-05:00').

The timezone offset changes around daylight savings. So in winter it would be '-05:00' for Eastern Standard, and in summer it would be '-04:00' for Eastern Daylight. These are the number of hours to subtract from the time to calculate UTC. So 00:15:14-05:00 = 00:15:14 - (-05:00) = 00:15:14 + 05:00 = 05:15:14 UTC.

Unifi device hostname or IP address - my USG returns its default hostname 'NetworkSecurityUbiquitiUSGULAN', while my switch and AP's return their device IP address e.g. '192.0.2.2'.

Optional Unifi device information - my switch and AP's return this optional field which is not provided by the USG. This field appears to be: ("DeviceType,DeviceMac,DeviceVersion"), where:
DeviceType: Unifi device type string e.g. U7LT = AC-Lite AP, US8P60 = Switch 8 60W
DeviceMac: Unifi device MAC address without colon separators
DeviceVersion: Unifi device current firmware version
Facility Code: the Unifi process/program on the device that created the log message. Extremely useful during log analysis to filter/parse log messages. The Facility Code always ends with a colon (':').

Message: the free-format log message. The contents and formatting vary, and there may be no space after the facility code colon. Some messages are more interesting/useful than others e.g. messages containing EVENT_STA_LEAVE, EVENT_STA_JOIN, EVENT_STA_IP show client interactions with the access points.


Once firewall logging is enable, the Unifi USG kernel process will log additional messages:

# WAN_LOCAL rule 3002 drop
2017-11-24T00:01:42-05:00 NetworkSecurityUbiquitiUSGULAN kernel: [WAN_LOCAL-3002-D]IN=eth0 OUT= MAC=80:2a:a8:00:11:33:00:11:22:33:44:66:08:00 src=203.0.113.1 DST=198.51.100.1 LEN=40 TOS=0x00 PREC=0x00 TTL=234 ID=13813 DF PROTO=TCP SPT=443 DPT=45137 WINDOW=0 RES=0x00 RST URGP=0

# WAN_LOCAL rule 4000 drop with repeat
2017-11-24T01:13:06-05:00 NetworkSecurityUbiquitiUSGULAN kernel: [WAN_LOCAL-4000-D]IN=eth0 OUT= MAC=80:2a:a8:00:11:33:00:11:22:33:44:66:08:00 src=203.0.113.2 DST=198.51.100.1 LEN=40 TOS=0x00 PREC=0x00 TTL=48 ID=64173 PROTO=TCP SPT=57142 DPT=23 WINDOW=61184 RES=0x00 SYN URGP=0
2017-11-24T01:13:56-05:00 NetworkSecurityUbiquitiUSGULAN kernel: last message repeated 2 times
Notice the last message - by default duplicate messages report a repeat count, and do not log the actual duplicate message.



The firewall log format follows the standard message format (without the optional device information), from the 'kernel' facility, and using a firewall specific message format: Timestamp DeviceHostname kernel: [Interface-RuleIndex-RuleAction]IN=...



Interface - is the firewall interface and direction, and matches the name in the webui. With my example configuration this is always WAN_LOCAL. This is described in the Unifi documentation as the WAN interface, with packets destined for the router i.e. not being passed through to the LAN interface.

RuleIndex - is the firewall rule index number for this interface. With my example configuration rule 3002 is the predefined invalid state drop rule, and rule 4000 is the default drop/log everything else rule.
Rule 3002 will log/drop incoming packets for recent or current connections that do not match the expected connection state e.g. TCP FIN or RST received after connection terminated. I only see Rule 3002 messages for ICMP and TCP protocols. As such many (but not all) of the Rule 3002 logs can be ignored.
Rule 4000 logs are for packets with no current connections, and I see them for ICMP, TCP, and UDP protocols. Some of the Rule 4000 UDP logs are for terminated connections where a last packet arrives late. So appropriate interpretation is required for all log messages.
RuleAction - is the firewall action taken on this packet. 'D' is Dropped, and 'A' is Accepted (if you log accepted connections). I've not seen it, but 'R' would be Rejected.
Following the firewall rule '[...]' field is a series of space separate Ethernet protocol level Variable=Value or Flag strings. My ISP encapsulation is Ethernet : IPv4 : protocol. I will describe what I have seen so far in my logs. Detailed interpretaion requires an understanding of Ethernet protocols such as IPv4, IPv6, ICMP, TCP, UDP, etc; and how TCP and UDP connections are established, managed, and terminated.



Summary: The most interesting protocol fields for analyzing WAN_LOCAL firewall logs are:

All protocols: SRC, DST, PROTO
ICMP: TYPE, CODE
TCP: SPT, DPT, flags (FIN, RST, SYN)
UDP: SPT, DPT


Detail: Introduction to USG understanding USG firewall logs



Interface and Ethernet layer fields:


Interface layer fields: IN=eth0 OUT=
IN=<interface> - USG input interface for this packet (blank value if dropped LAN>WAN). Will include VLAN ID if VLANs used. Will be a USG WAN port for WAN_LOCAL.
OUT=<interface> - USG output interface for this packet (blank value if dropped WAN>LAN). Will include VLAN ID if VLANs used. Will always be blank using my configuration.
Ethernet layer fields (WAN_LOCAL example): MAC=80:2a:a8:00:11:33:00:11:22:33:44:66:08:00
MAC=<EthernetHeader> - these fourteen hex bytes are the Ethernet packet header. For this example the MAC destination address is 80:2a:a8:00:11:33 (first fix bytes), MAC source address is 00:11:22:33:44:66 (next six bytes), and Ethertype is 08:00 (last two bytes).

On an incoming WAN link this information is not as useful since MAC destination is the USG, MAC source is the upstream router/gateway, and protocol is most likely to be IPv4 or IPv6 (which should also be obvious from the follwing message fields).

MAC addresses are six bytes with the first three bytes being the Organizationally Unique Identifiers (OUI), which is now called the IEEE MAC Address Block Large (MA-L). If public the OUI/MA-L can help identify the NIC manufacturer which is often the device manufacturer e.g. 80:2a:a8 (search as 802aa8) is Ubiquiti Networks Inc. Search the public IEEE MA-L registry, or download the public MA-L registry here in CSV format.

Ethertypes are two bytes identifying the next protocol used e.g. 08:00 (search as 0800) is IPv4. Search the public IEEE Ethertype registry, or download the public Ethertype registry here in CSV format.


IP layer fields:



IPv4 layer fields: src=203.0.113.2 DST=198.51.100.1 LEN=40 TOS=0x00 PREC=0x00 TTL=48 ID=64173 DF PROTO=TCP
Fields extracted from the packet's IPv4 protocol header:
SRC - Source IP address. For WAN_LOCAL this is the internet sender (server or client) of this packet.
DST - Destination IP address. For WAN_LOCAL this should be the internet IP address of your USG.
LEN - Total IP packet length. Knowing this can help to make educated guesses on what is being sent to the USG.
TOS and PREC - Appears to be IPv4 DSCP/ECN octet interpreted as the deprecated Type Of Service (TOS) and Precedence (PREC) fields (see Type of Service). If you want to analyze these values I recommend creating a new single byte value DSCP_ECN = (Precedence BINARY-OR TypeOfService), then calculating DSCP = (DSCP_ECN >> 2) & 0x3f and ECN = (DSCP_ECN) & 0x03.
TTL - Time to Live field, treated as a hop count, and decremented by each router. Packets are discarded when this reaches zero. Can analyse this field to attempt to determine if hop tracing is being used.
ID - Identification field. Used for IP fragmentation handing.
DF - (optional flag, no value) Don't fragment flag is set.
MF - (optional flag, no value) More fragments flag is set. I've not seen this, so don't know if it appears in the USG logs.
PROTO - Next layer IP protocol field. This is text, or (I think) a decimal value. I've seen ICMP, UDP, TCP and 47 (which would be Generic Routing Encapsulation). See List of IP protocol numbers.
IPv6 layer fields:
I do not have any IPv6 examples but expect similar fields to IPv4.


IP protocol layer fields - will only have one of these per log message:



ICMP layer fields: TYPE=8 CODE=0 ID=64366 SEQ=2165
Fields extracted from the packet's ICMP (Internet Control Message Protocol) protocol header.
TYPE and CODE - ICMP type and code fields that define the ICMP message e.g. 8:0 is Echo request (ping request). See link for details.
ID - Appears to be ICMP Echo Request/Response Identifier field.
SEQ - Appears to be ICMP Echo Request/Response Sequence Number field.
TCP layer fields: SPT=57142 DPT=23 WINDOW=61184 RES=0x00 SYN URGP=0
Fields extracted from the packet's TCP (Transmission Control Protocol) protocol header.
SPT - TCP source port.
DPT - TCP destination port.
WINDOW - Receive window size.
RES - Not sure, have seen values 0x00 (most common), 0x08, and 0x14.
flags - Between RES and URGP fields the USG lists any TCP flags that are set in the packet such as SYN, ACK, FIN, RST, PSH, URG, CWR, ECE, etc. The most common combinations in my logs are
'SYN', 'RST', 'ACK FIN', 'ACK SYN', 'ACK PSH FIN', 'ACK PSH', and 'ACK RST'.
URGP - Urgent Pointer (appears to be in decimal).
UDP layer fields: SPT=33532 DPT=33446 LEN=24
Fields extracted from the packet's UDP (User Datagram Protocol) protocol header.
SPT - UDP source port.
DPT - UDP destination port.
LEN - length in bytes of UDP header and payload.


I'm not sure what other protocols the USG recognizes and will extract fields for in the log messages. Likely SCTP, maybe others?



The next post will cover how to analyze the most interesting WAN_LOCAL firewall logs protocol fields:

All protocols: SRC, DST, PROTO
ICMP: TYPE, CODE
TCP: SPT, DPT, flags (FIN, RST, SYN)
UDP: SPT, DPT
