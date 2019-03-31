local config = {
  modules: {
    http_2xx: {
      prober: 'http',
    },
    http_2xx_insecure: {
      prober: 'http',
      http: {
        valid_status_codes: [],
        method: 'GET',
        no_follow_redirects: false,
        fail_if_ssl: false,
        fail_if_not_ssl: true,
        preferred_ip_protocol: 'ip4',
        tls_config: {
          insecure_skip_verify: true,
        },
      },
    },
    https_k8s_2xx: {
      prober: 'http',
      http: {
        bearer_token_file: '/var/run/secrets/kubernetes.io/serviceaccount/token',
        tls_config: {
          ca_file: '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt',
        },
      },
    },
    http_post_2xx: {
      prober: 'http',
      http: {
        method: 'POST',
      },
    },
    tcp_connect: {
      prober: 'tcp',
    },
    tls_connect: {
      prober: 'tcp',
      tcp: {
        tls: true,
      },
    },
    tls_connect_insecure: {
      prober: 'tcp',
      tcp: {
        tls: true,
        tls_config: {
          insecure_skip_verify: true,
        },
      },
    },
    smtp_starttls: {
      prober: 'tcp',
      timeout: '5s',
      tcp: {
        query_response: [
          {
            expect: '^220 ([^ ]+) ESMTP (.+)$',
          },
          {
            send: 'EHLO prober',
          },
          {
            expect: '^250-STARTTLS',
          },
          {
            send: 'STARTTLS',
          },
          {
            expect: '^220',
          },
          {
            starttls: true,
          },
          {
            send: 'EHLO prober',
          },
          {
            expect: '^250-AUTH',
          },
          {
            send: 'QUIT',
          },
        ],
      },
    },
    ssh_banner: {
      prober: 'tcp',
      tcp: {
        query_response: [
          {
            expect: '^SSH-2.0-',
          },
        ],
      },
    },
    icmp: {
      prober: 'icmp',
    },
  },
};
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'blackbox-config',
    namespace: 'monitoring',
  },
  data: {
    'config.yml': std.toString(config),
  },
}
