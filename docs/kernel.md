# Kernel Tuning (Borrowing this to learn)

[](TOC)

- [Kernel Tuning (Borrowing this to learn)](#kernel-tuning-borrowing-this-to-learn)
  - [sysctl settings](#sysctl-settings)
    - [Source routing](#source-routing)
    - [Buffers](#buffers)
      - [Max size](#max-size)
      - [Min and initial sizes](#min-and-initial-sizes)
      - [Low latency](#low-latency)
      - [Monitoring](#monitoring)
    - [`net.core.somaxconn`](#netcoresomaxconn)
    - [`net.ipv4.tcp_max_syn_backlog`](#netipv4tcpmaxsynbacklog)
    - [`net.ipv4.ip_local_port_range`](#netipv4iplocalportrange)
    - [`net.ipv4.tcp_tw_reuse`](#netipv4tcptwreuse)
    - [`net.ipv4.tcp_window_scaling`](#netipv4tcpwindowscaling)
    - [`net.core.netdev_max_backlog`](#netcorenetdevmaxbacklog)
    - [`net.ipv4.tcp_mtu_probing`](#netipv4tcpmtuprobing)
    - [`net.ipv4.tcp_slow_start_after_idle`](#netipv4tcpslowstartafteridle)
  - [sysctl settings (do not touch)](#sysctl-settings-do-not-touch)
    - [`net.ipv4.tcp_moderate_rcvbuf`](#netipv4tcpmoderatercvbuf)
    - [`net.netfilter.nf_conntrack_buckets`](#netnetfilternfconntrackbuckets)
    - [`net.netfilter.nf_conntrack_max`](#netnetfilternfconntrackmax)
    - [`net.ipv4.tcp_mem`](#netipv4tcpmem)
    - [`net.ipv4.tcp_no_metrics_save`](#netipv4tcpnometricssave)
    - [`fs.file-max`](#fsfile-max)
    - [Example /etc/sysctl.d/perf.conf](#example-etcsysctldperfconf)

[](TOC)

## sysctl settings

Documentation for each of these can be found in the Linux kernel documentation
- [`networking/ip-sysctl.txt`](https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/ip-sysctl.txt)
- [`networking/nf_conntrack-sysctl.txt`](https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/nf_conntrack-sysctl.txt)
- [`sysctl/fs.txt`](https://github.com/torvalds/linux/blob/v4.19/Documentation/sysctl/fs.txt)
- [`sysctl/net.txt`](https://github.com/torvalds/linux/blob/v4.19/Documentation/sysctl/net.txt)

General networking resources
- [Monitoring and Tuning the Linux Networking Stack: Receiving Data](https://blog.packagecloud.io/eng/2016/06/22/monitoring-tuning-linux-networking-stack-receiving-data)
- [Monitoring and Tuning the Linux Networking Stack: Sending Data](https://blog.packagecloud.io/eng/2017/02/06/monitoring-tuning-linux-networking-stack-sending-data/)
- [Case study: Network bottlenecks on a Linux server: Part 2 — The Kernel](https://medium.com/@oscar.eriks/case-study-network-bottlenecks-on-a-linux-server-part-2-the-kernel-88cf614aae70)
- [Tuning 10Gb network cards on Linux](https://www.kernel.org/doc/ols/2009/ols2009-pages-169-184.pdf)
- [Oracle VM 3: 10GbE Network Performance Tuning](https://www.oracle.com/technetwork/server-storage/vm/ovm3-10gbe-perf-1900032.pdf)
- [High Performance Browser Networking](https://hpbn.co)

### Source routing

Our hosts aren't routers, so we can lock them down a bit.

Covers the following settings
- `net.ipv4.conf.all.accept_source_route`
- `net.ipv4.conf.all.send_redirects`
- `net.ipv4.conf.default.send_redirects`
- `net.ipv4.conf.all.secure_redirects`
- `net.ipv4.conf.default.secure_redirects`
- `net.ipv4.conf.default.accept_redirects`

**References**

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security_guide/sect-security_guide-server_security-disable-source-routing

### Buffers

Covers the following settings
- `net.core.rmem_default`
- `net.core.wmem_default`
- `net.core.rmem_max`
- `net.core.wmem_max`
- `net.ipv4.tcp_rmem`
- `net.ipv4.tcp_wmem`

We choose high throughput over low latency for the following reasons
1. Our data plane handles a wide variety of workloads, including bulk data transfer.
2. Optimizing for high throughput still gives services the choice to optimize for low latency. The converse is not true.

High throughput is achieved, in part, with large buffers. The default network
buffers sizes are dynamic based on memory, but are way too low. The max receive
buffer size on a server in a normal client-server scenario should at least match
the Bandwidth Delay Product (BDP) between it and the client. This allows the
client to put as much data as it can on the wire and the server to buffer it all
to avoid congestion control kicking in.

Our proxies are both server and client:

1. As a server to downstream clients the normal receive buffer sizing to BDP applies.
1. As a client to upstream servers the send buffer needs tuned.
1. As a client to upstream servers there also needs to be enough room in the receive buffer for receiving upstream data.

#### Max size

These buffers are **per socket** meaning we need the max of 1, 2, and 3 above
and to be aware that this applies to both envoy and tenant services.

A sample of Round Trip Time (RTT) between instances (inter-AZ) that support
10Gbps was `~0.65ms`. This was not done on a production cluster so this value
may be too optimistic and needs resampled on a real cluster.

Rounding it up to `1ms` seemed reasonable. Recall it needs to be *at least* BDP.

```
(BDP = 10Gpbs * RTT)
BDP = 10 * 10^9 * 0.001

10000000 bytes rounded up to the nearest MiB is 10MiB
```

#### Min and initial sizes

The minimum size matches the default of 4096.

The initial size was chosen to somewhat arbitrarily as the midpoint. This likely
needs tuned based on real production data.

`net.ipv4.tcp_moderate_rcvbuf` (see below) regulates the actual size in between
min and max.

#### Low latency

Individual services can override buffer defaults with `SO_RCVBUF` and
`SO_SNDBUF`, usually to a much lower amount to avoid spikes in TCP collapse
latency.

Services optimizing for low latency will also want look at the following socket options
- `TCP_NODELAY` Disable Nagle's algorithm
- `SO_INCOMING_CPU` Pin a socket to a CPU
- `SO_REUSEPORT` For multi-threaded programs, do the above and bind to the same port
- `SO_BUSY_POLL` Spend CPU cycles to reduce latency. Requires `CAP_NET_ADMIN` so check cluster capabilities first.
- `SO_PRIORITY` Use by the default qdisc to prioritize **egress** traffic

Additional, host-wide settings such as SMP IRQ affinity should be considered for
operators choosing low latency over high throughput overall. See the above
general resources for more.

#### Monitoring

Buffer issues can be seen with `netstat -st | grep buffer`

```
<N> packets dropped from out-of-order queue because of socket buffer overrun
<N> packets pruned from receive queue because of socket buffer overrun
<N> packets collapsed in receive queue due to low socket buffer
```

The corresponding metrics are

- `node_netstat_TcpExt_OfoPruned` packets dropped from out-of-order queue because of socket buffer overrun
- `node_netstat_TcpExt_PruneCalled` packets pruned from receive queue because of socket buffer overrun
- `node_netstat_TcpExt_TCPRcvCollapsed` packets collapsed in receive queue due to low socket buffer

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/ip-sysctl.txt

https://github.com/torvalds/linux/blob/v4.19/Documentation/sysctl/net.txt

http://man7.org/linux/man-pages/man7/tcp.7.html

http://man7.org/linux/man-pages/man7/socket.7.html

https://www.lartc.org/howto/lartc.qdisc.classful.html

### `net.core.somaxconn`

The default of 128 isn't designed for servers.

A consequence (and the decision) is that it's better to have increased client
latency than fail a request because the socket backlog is full.

`netstat -st | grep listen` will show the following when this limit is hit

```
<N> SYNs to LISTEN sockets dropped
<N> times the listen queue of a socket overflowed
```

The corresponding metrics are

- `node_netstat_TcpExt_ListenDrops` SYNs to LISTEN sockets dropped
- `node_netstat_TcpExt_ListenOverflows` times the listen queue of a socket overflowed

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/ip-sysctl.txt#L202-L205

http://veithen.io/2014/01/01/how-tcp-backlog-works-in-linux.html

https://blog.cloudflare.com/syn-packet-handling-in-the-wild/

https://linux.die.net/man/2/listen

### `net.ipv4.tcp_max_syn_backlog`

System-wide (i.e. across all sockets) backlog of connections in the `SYN_RCVD` state

Default is 2048.

Raised for the same reason as `net.core.somaxconn`

Double `net.core.somaxconn` because envoy isn't the only socket on the machine.

While we expect only envoy to have a SYN backlog (if one exists) this provides
some buffer for the aggregate backlog of all other sockets on the machine.

Another way to say that is that no socket's `net.core.somaxconn` would be hit if
the value were identical to `net.ipv4.tcp_max_syn_backlog`

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/ip-sysctl.txt#L378-L383

https://linux.die.net/man/2/listen

http://veithen.io/2014/01/01/how-tcp-backlog-works-in-linux.html

https://blog.cloudflare.com/syn-packet-handling-in-the-wild/

### `net.ipv4.ip_local_port_range`

`1024 - 65535`

Expanded so we don't run out of ephemeral ports, which are used by containers in
BRIDGE mode (the default) and all outgoing connections from containers and our
proxy

The range starts at 1024 because 0-1023 are System Ports

### `net.ipv4.tcp_tw_reuse`

Sockets sitting around in TIME_WAIT take up resources. This allows them to be
reused

Depending on what we observe under load we may need to lower
`net.netfilter.nf_conntrack_tcp_timeout_time_wait` as well

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/ip-sysctl.txt#L679-L687

### `net.ipv4.tcp_window_scaling`

This is especially important for proxying host to host.

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/ip-sysctl.txt#L689-L690

https://hpbn.co/building-blocks-of-tcp/#window-scaling-rfc-1323

### `net.core.netdev_max_backlog`

Provably too low if the second column value for each CPU entry in
`/proc/net/softnet_stat` is greater than 0.

Here's an example where this limit **has not** been hit (note the second column
is all `00000000`)

```
$ cat /proc/net/softnet_stat
00dcf493 00000000 00000002 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00e16896 00000000 00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00e1208f 00000000 00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00e1cab6 00000000 00000016 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
```

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/sysctl/net.txt#L230-L234

https://github.com/torvalds/linux/blob/v4.19/net/core/net-procfs.c#L162-L167

https://www.kernel.org/doc/ols/2009/ols2009-pages-169-184.pdf

https://www.oracle.com/technetwork/server-storage/vm/ovm3-10gbe-perf-1900032.pdf

### `net.ipv4.tcp_mtu_probing`

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/ip-sysctl.txt#L421-L426

### `net.ipv4.tcp_slow_start_after_idle`

This applies to sending (active open) TCP connections which means it primarily
applies to Keep-Alive connections from envoy to its upstreams.

Worst case this isn't actually doing anything for us because the Keep-Alive
timeout from envoy to upstreams kicks in first.

Best case this avoids slow starts in the future if we change the Keep-Alive
timeout.

In any case there's no reason to assume that network conditions have changed
between hosts which is the reason this functionality (and default setting)
exists.

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/ip-sysctl.txt#L550-L555

https://hpbn.co/building-blocks-of-tcp/#slow-start-restart

## sysctl settings (do not touch)

There are interesting settings you'll see in `sysctl` and articles around Linux
network tuning. These are some we've chosen to omit and provide justification
here.

Many are set set dynamically by the kernel to values we're ok with, typically
based on available memory. Denoted by `^Dynamic`

### `net.ipv4.tcp_moderate_rcvbuf`

On by default

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/ip-sysctl.txt#L415-L419

### `net.netfilter.nf_conntrack_buckets`

`^Dynamic`

Set to 65536 on any instance we'd be running.

Also requires a change to `/sys/module/nf_conntrack/parameters/hashsize`

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/nf_conntrack-sysctl.txt#L10-L16

### `net.netfilter.nf_conntrack_max`

`^Dynamic`

`net.netfilter.nf_conntrack_buckets * 4`

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/nf_conntrack-sysctl.txt#L95-L97

### `net.ipv4.tcp_mem`

`^Dynamic`

A page in Linux is typically 4KiB. That's confirmed by `getconf PAGE_SIZE` yet
adjustments here are not adding up.

Additionally `cat /proc/net/sockstat` shows nowhere near the page count usage
under heavy network I/O so leave this one alone unless it's better understood.

We can monitor for OOM by looking for the following kernel messages

```
too many orphaned sockets
```

```
out of memory -- consider tuning tcp_mem
```

There are also the following metrics (note: there's nothing for orphaned sockets in netstat)

- `node_netstat_TcpExt_TCPAbortOnMemory` connections aborted due to memory pressure
- `node_netstat_TcpExt_TCPAbortFailed` times unable to send RST due to no memory

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/ip-sysctl.txt#L393-L405

https://blog.tsunanet.net/2011/03/out-of-socket-memory.html

https://github.com/torvalds/linux/blob/v4.19/net/ipv4/tcp_timer.c#L71-L130

https://github.com/torvalds/linux/blob/v4.19/net/ipv4/tcp.c#L2297-L2309

### `net.ipv4.tcp_no_metrics_save`

`0` by default meaning metrics are saved.

This is what we want from a proxy perspective. This allows for the Congestion
Window, Smoothed RTT, etc. to be saved for new connections to the same
destination. It also benefits tenant services' connections to their
dependencies.

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/networking/ip-sysctl.txt#L438-L444

### `fs.file-max`

`^Dynamic`

On the instances we run this is typically much higher than the number of sockets
that can exist so we don't tune it.

Provably too low if `VFS: file-max limit ...` is seen in `dmesg`

**References**

https://github.com/torvalds/linux/blob/v4.19/Documentation/sysctl/fs.txt#L95-L114

https://github.com/torvalds/linux/blob/v4.19/fs/file_table.c#L376-L389


### Example /etc/sysctl.d/perf.conf

```
#
# see docs/kernel.md for details
# update the docs if updating this file
#
net.core.somaxconn=16384
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.default.secure_redirects=0
net.ipv4.ip_local_port_range=1024 65535
net.core.rmem_default=1048576
net.core.wmem_default=1048576
net.core.rmem_max=10485760
net.core.wmem_max=10485760
net.ipv4.tcp_rmem=4096 5242880 10485760
net.ipv4.tcp_wmem=4096 5242880 10485760
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_max_syn_backlog=32768
net.ipv4.tcp_window_scaling=1
net.core.netdev_max_backlog=300000
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_slow_start_after_idle=0
kernel.core_pattern=|/dev/null
```
