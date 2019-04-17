#!/usr/bin/env python
import argparse
import json
import urllib2
import sys, os
import textwrap

import collections
from collections import OrderedDict

# SOURCE: https://github.com/mglen/grafana-tools/blob/master/grafana_import.py

# Note:
#   json upload version must match version on server. If success:
#     {"slug":"mca-test-mmason","status":"success","version":17}
#   If failure:
#     {"message":"The dashboard has been changed by someone else","status":"version-mismatch"}
#

parser = argparse.ArgumentParser(description='Import grafana dashboard files into grafana server',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""
        example commands:
          Load single file into grafana server:
            grafana_import http://grafana.example.net:3000 new-dashboard.json

          Import all json files in current directory:
            grafana_import http://grafana.example.net:3000 *.json

          Using auth, upload all dashboard files to server, updating existing dashboards if they already exist:
            grafana_import -K "eyJrIjoiNksyVWRqWVZvbGppTkwwVEMzUmZlSnJaOU1DUHdYUlkiLCJuIjoiYWRmZGFzZiIsImlkIjoxfQ==" \\
              http://grafana.example.net:3000 *.json --force
        """))
parser.add_argument('url', help='Grafana server URL. ex: http://grafana.example.net:3000')
parser.add_argument('from_dir', nargs='+', help='Folder with Files to upload')
parser.add_argument('-k', '--key', dest="key", help='API Key for auth')
parser.add_argument('-n', dest='dry_run', action='store_const', const=True, help='Print results of actions taken without actually making any changes (dry run)')
parser.add_argument('-f', '--force', dest='force', action='store_const', const=True, help='Force overwrite of existing dashboards on the server (Default: create new dashboards only)')

args = parser.parse_args()

print(args)

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
    return _request('/api/search/')

def update_dashboard(dashboard_json):
    return _request('/api/dashboards/db', data=dashboard_json)

def replace_dashboard_var(panel, vartype, name, label):
    if panel[vartype] == '${{{name}}}'.format(name=name):
        # import pdb;pdb.set_trace()
        panel[vartype] = label

def recursive_variable_check(dashboard):
    # dashboard = dashboard.copy()
    try:
        for element in enumerate(dashboard.copy()):
            if '__inputs' in element:
                for inputs_index, inputs in enumerate(dashboard['__inputs']):
                    # print(dashboard)
                    name = dashboard['__inputs'][inputs_index]['name']
                    label = dashboard['__inputs'][inputs_index]['label']
                    vartype = dashboard['__inputs'][inputs_index]['type']
                    # import pdb;pdb.set_trace()

                    if name.startswith('DS_'):
                        if 'panels' in element:
                            for panel_index, panel in enumerate(dashboard['panels']):
                                # if 'datasource' in panel:
                                #     if panel['datasource'] == '${DS_PROMETHEUS}':
                                #         dashboard['panels'][panel_index]['datasource'] = 'Prometheus'
                                if panel['type'] == 'row':
                                    for rowpanel_index, rowpanel in enumerate(dashboard['panels']):
                                        replace_dashboard_var(rowpanel, vartype, name, label)
                                else:
                                    replace_dashboard_var(panel, vartype, name, label)
                                    pass
    except KeyError as ke:
        print(ke)
        pass

    #     for inputvar in dashboard['__inputs']:
    #         name = inputvar['name']
    #         label = inputvar['label']
    #         vartype = inputvar['type']
    #         # import pdb;pdb.set_trace()
    #         if name.startswith('DS_'):
    #             # search and replace
    #             for panel in dashboard['panels']:
    #                 if panel['type'] == 'row':
    #                     for rowpanel in panel['panels']:
    #                         replace_dashboard_var(rowpanel, vartype, name, label)
    #                 else:
    #                     replace_dashboard_var(panel, vartype, name, label)
    #                     pass
    # except KeyError as ke:
    #     print(ke)
    #     pass

    return dashboard

class OrdDictSub(collections.OrderedDict):
    def __init__(self, *args, **kwds):
        return super(OrdDictSub, self).__init__(*args, **kwds)

    def change_key(self, old, new):
        for _ in range(len(self)):
            k, v = self.popitem(False)
            self[new if old == k else k] = v

if __name__ == '__main__':
    json_files = []

    file_list = os.listdir(args.from_dir[0])

    # for f in file_list:
    #     base, ext = os.path.splitext(f)

    #     if os.path.isfile(f) and ext =='.json':
    #         fpath = os.path.join(args.from_dir[0], f)
    #         json_files.extend(fpath)
    #     else:
    #         pass

    json_files = [os.path.join(args.from_dir[0], f) for
            f in os.listdir(args.from_dir[0])
            if os.path.isfile(f) and f.endswith('.json')]

    print(json_files)

    dashboards = []
    for full_file in json_files:
        try:
            with open(full_file) as fh:
                # data = json.loads(fh.read())
                data = json.load(fh, object_pairs_hook=OrderedDict)
                data = recursive_variable_check(data)
                # dashboard = data['dashboard'] if 'dashboard' in data else data
                # print(dash)
                # import pdb;pdb.set_trace()
                dashboards.append({'dashboard':data,'file':full_file})
        except IOError as e:
            print("Could not open file: " + e)
        except ValueError as e:
            print("Could not parse file '{}' as json".format(full_file))

    if args.dry_run:
        for dashboard in dashboards:
            print("Will upload '{}' ({}) to {}".format(
                    dashboard['dashboard']['title'],
                    dashboard['file'],
                    GRAFANA_SITE))
        sys.exit(0)

    if not args.force:
        existing_dashboards = get_dashboards()
        for dashboard in dashboards:
            if any(dashboard['dashboard']['title'] == b['title'] for b in existing_dashboards):
                print("Found existing dashboard '{}' on server. If you intend to overwrite it, specify [-f,--force]".format(dashboard['dashboard']['title']))
                sys.exit(1)

    # import pdb;pdb.set_trace()
    for dashboard in dashboards:
        print("Uploading dashboard: " + dashboard['dashboard']['title'])
        try:
            del dashboard['file']
            update_dashboard(json.dumps(dashboard))
        except urllib2.HTTPError as e:
            print("Error: " + e.read())

