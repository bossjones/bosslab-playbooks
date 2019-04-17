#!/usr/bin/env python

# SOURCE: https://github.com/grafana/grafana/issues/10786

import argparse
import json
import urllib2
import base64

from collections import OrderedDict


def replace_dashboard_var(panel, vartype, name, label):
    if panel[vartype] == '${{{name}}}'.format(name=name):
        panel[vartype] = label


def main(template, foldername):
    with open(template) as f:
        jsondata = json.load(f, object_pairs_hook=OrderedDict)
        dashboard = jsondata['dashboard'] if 'dashboard' in jsondata else jsondata
        try:
            for inputvar in dashboard['__inputs']:
                name = inputvar['name']
                label = inputvar['label']
                vartype = inputvar['type']
                if name.startswith('DS_'):
                    # search and replace
                    for panel in dashboard['panels']:
                        if panel['type'] == 'row':
                            for rowpanel in panel['panels']:
                                replace_dashboard_var(rowpanel, vartype, name, label)
                        else:
                           replace_dashboard_var(panel, vartype, name, label)
                           pass
        except KeyError as ke:
            print(ke)
            pass

    if foldername is not None:
        req = urllib2.Request('http://localhost:3003/api/folders/{folder}'.format(folder=foldername))
        req.add_header("Authorization", "Basic {auth}".format(auth=base64.encodestring('admin:admin')[:-1]))
        handle = urllib2.urlopen(req)
        folderdata = json.loads(handle.read())
        folder_id = folderdata['id']

    if jsondata:
        with open(template, 'w') as outfile:
            data = {
              'dashboard': jsondata['dashboard'] if 'dashboard' in jsondata else jsondata,
              'folderId': folder_id if folder_id is not None else 'null'
            }
            json.dump(data, outfile, indent=2, separators=(',', ': '), ensure_ascii=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process Grafana dashboard template")
    parser.add_argument("-t", "--template", type=str, required=True, help="the dashboard template")
    parser.add_argument("-f", "--foldername", type=str, help="the foldername")
    args = parser.parse_args()

    main(args.template, args.foldername)
