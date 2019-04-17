#!/usr/bin/env python
import argparse
import json
import urllib2
import sys, os
import textwrap

# SOURCE: https://github.com/mglen/grafana-tools/blob/master/grafana_import.py

# TODO: better arg names
# TODO: authorization optional? Is there a no-anonymous grafana setup?

parser = argparse.ArgumentParser(
        description='Export grafana dashboards to json files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""
        example commands:
          Export all dashboards to current directory:
            grafana_export http://grafana.example.net:3000

          Show what dashboards would be exported. Includes version and destination file names:
            grafana_export -n http://grafana.example.net:3000

          Export dashboards with tag "Network" to subfolder (+auth):
            grafana_export -k ""eyJrIjoiNksyVWRqWVZvbGppTkwwVEMzUmZlSnJaOU1DUHdYUlkiLCJuIjoiYWRmZGFzZiIsImlkIjoxfQ==" \\
            -t "Network" http://grafana.example.net:3000 dashboards/
        """))
parser.add_argument('url', help='Base Grafana server URL. ex: http://grafana.example.net:3000')
parser.add_argument('dest_dir', metavar='dir', nargs='?', default='.', help='Destination directory for json files (default %(default)s)')
parser.add_argument('-k', '--key', help='API Key for auth. Required if anonymous auth disabled')
parser.add_argument('-t', '--tags', nargs='*', dest='tags', help='Optional list of tags for filtering dashboard results')
parser.add_argument('-n', dest='no_dump', action='store_const', const=True, help='Do not write any files, just show what will be done (dry run)')
parser.add_argument('-f', '--force', dest='force', action='store_const', const=True, help='Force overwrite any existing files at destination')

args = parser.parse_args()

GRAFANA_SITE = args.url.rstrip('/')

def _request(url, data=None):
    req = urllib2.Request(GRAFANA_SITE + url, data=data)
    req.add_header('Content-Type', 'application/json')
    if args.key:
        req.add_header('Authorization', 'Bearer %s' % args.key)
    try:
        f = urllib2.urlopen(req)
    except urllib2.HTTPError as e:
        sys.stderr.write("HTTP Error {}: {}".format(e.code, e.read()))
        sys.exit(1)
    return json.loads(f.read())

def get_dashboards():
    dashboard_list = _request('/api/search/')
    if not args.tags:
        return dashboard_list
    result_list = []
    for item in dashboard_list:
        if any(i in item['tags'] for i in args.tags):
            result_list.append(item)
    return result_list

def get_dashboard(slug):
    return _request('/api/dashboards/' + slug)

if __name__ == '__main__':

    dashboard_results = []
    for dashboard in get_dashboards():
        dash_obj = get_dashboard(dashboard['uri'])
        dash_obj['dest_file'] = os.path.normpath(
                os.path.join(
                    os.path.expanduser(args.dest_dir),
                    dash_obj['meta']['slug'] + '.json')
            )
        dashboard_results.append(dash_obj)

    if args.no_dump:
        for dashboard in dashboard_results:
            print "Found dashboard: '{}', version: {}".format(dashboard['dashboard']['title'], dashboard['dashboard']['version'])
            print "      dest file: {}".format(dashboard['dest_file'])
        sys.exit(0)

    for dashboard in dashboard_results:
        if not args.force:
            if os.path.isfile(dashboard['dest_file']):
                print "Found existing file {}. If you intend to overwrite it, specify [-f,--force]".format(dashboard['dest_file'])
                sys.exit(1)

    # Create directories, if necessary
    if not os.path.isdir(args.dest_dir):
        os.makedirs(args.dest_dir)

    for dashboard in dashboard_results:
        print "Writing to: " + dashboard['dest_file']
        with open(dashboard['dest_file'], 'w') as f:
            f.write(json.dumps(dashboard['dashboard'], sort_keys=True, indent=2, separators=(',', ' : ')))

