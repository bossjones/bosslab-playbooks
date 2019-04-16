#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import time
import argparse
import json


class Bgcolors:
    def __init__(self):
        self.get = {
            'HEADER': '\033[95m',
            'OKBLUE': '\033[94m',
            'OKGREEN': '\033[92m',
            'WARNING': '\033[93m',
            'FAIL': '\033[91m',
            'ENDC': '\033[0m',
            'BOLD': '\033[1m',
            'UNDERLINE': '\033[4m'
        }


def search_grafana_user(gurl, g_user, g_password, email):
    g_protocol = gurl.split(':')[0]
    g_url = gurl.split('//')[1]

    get_data_req = requests.get(
        g_protocol + '://' + g_user + ':' + g_password + '@' + g_url + '/api/users?perpage=10&page=1')
    pars_json = json.loads(get_data_req.text)
    for user in pars_json:
        if user['email'] == email:
            account_id = user['id']
        else:
            account_id = -1

    return account_id


def get_grafana_users(gurl, g_user, g_password):
    users_array = []

    g_protocol = gurl.split(':')[0]
    g_url = gurl.split('//')[1]

    get_data_req = requests.get(g_protocol + '://' + g_user + ':' + g_password + '@' + g_url + '/api/users')
    pars_json = json.loads(get_data_req.text)
    for user in pars_json:
        users_array.append(user['email'])
        # print (user)

    return users_array


def add_grafana_user(gurl, g_user, g_password, created_email, created_password):
    g_protocol = gurl.split(':')[0]
    g_url = gurl.split('//')[1]

    grafana_users = get_grafana_users(gurl, g_user, g_password)
    for user in grafana_users:
        if user == created_email:
            print(Bgcolors().get['FAIL'] + 'User already exist: ', user, '\nUse another name!' + Bgcolors().get['ENDC'])
            exit(0)
    data = {"name": created_email,
            "email": created_email,
            "login": created_email,
            "password": created_password,
            }

    get_data_req = requests.post(g_protocol + '://' + g_user + ':' + g_password + '@' + g_url + '/api/admin/users',
                                 data)
    pars_json = json.loads(get_data_req.text)
    print(pars_json)
    print('URL: ' + gurl, '\nemail: ' + created_email, '\npassword: ' + created_password)

    return add_grafana_user


def update_grafana_users(gurl, g_user, g_password, email):
    g_protocol = gurl.split(':')[0]
    g_url = gurl.split('//')[1]

    state_of_admin = str.lower('True')
    data_put = {"Accept": "application/json",
                "Content-Type": "application/json",
                "isGrafanaAdmin": state_of_admin,
                }

    account_id = search_grafana_user(gurl, g_user, g_password, email)
    if account_id != -1:
        get_data_req = requests.put(
            g_protocol + '://' + g_user + ':' + g_password + '@' + g_url + '/api/admin/users/%s/permissions' % account_id,
            data=data_put)
        pars_json = json.loads(get_data_req.text)
        print(pars_json)

        get_data_req = requests.get(
            g_protocol + '://' + g_user + ':' + g_password + '@' + g_url + '/api/users?perpage=10&page=1')
        pars_json = json.loads(get_data_req.text)
        for user in pars_json:
            if user['email'] == email:
                print(user)
    else:
        print('Unfortunately, I cant find [%s] email in grafana to update role!' % email)
        print('Please, use current EMAIL!')
        exit(0)

    return update_grafana_users


def update_grafana_user_password(gurl, g_user, g_password, email):
    g_protocol = gurl.split(':')[0]
    g_url = gurl.split('//')[1]

    data_put = {"password": "password"}
    account_id = search_grafana_user(gurl, g_user, g_password, email)
    if account_id != -1:
        get_data_req = requests.put(
            g_protocol + '://' + g_user + ':' + g_password + '@' + g_url + '/api/admin/users/%s/password' % account_id,
            data=data_put)
        pars_json = json.loads(get_data_req.text)
        print(pars_json)

    else:
        print('Unfortunately, I cant find [%s] email in grafana to update PW!' % email)
        print('Please, use current EMAIL!')
        exit(0)

    return update_grafana_users


def delete_grafana_users(gurl, g_user, g_password, email):
    g_protocol = gurl.split(':')[0]
    g_url = gurl.split('//')[1]

    account_id = search_grafana_user(gurl, g_user, g_password, email)
    get_data_req = requests.delete(
        g_protocol + '://' + g_user + ':' + g_password + '@' + g_url + '/api/admin/users/%s' % account_id)
    pars_json = json.loads(get_data_req.text)
    print(pars_json)

    get_data_req = requests.get(g_protocol + '://' + g_user + ':' + g_password + '@' + g_url + '/api/users')
    pars_json = json.loads(get_data_req.text)
    for user in pars_json:
        print(user)

    return update_grafana_users


def main():
    start__time = time.time()
    parser = argparse.ArgumentParser(prog='python3 script_name.py -h',
                                     usage='python3 script_name.py {ARGS}',
                                     add_help=True,
                                     prefix_chars='--/',
                                     epilog='''created by Vitalii Natarov''')
    parser.add_argument('--version', action='version', version='v1.0.5')
    parser.add_argument('--gtoken', '--token', dest='gtoken', help='Token of grafana server', default=None)
    parser.add_argument('--gurl', '--url', dest='gurl', help='URL from grafana', default=None)
    parser.add_argument('--glogin', dest='glogin', help='A login to grafana', default=None)
    parser.add_argument('--gpassword', dest='gpassword', help='A password of grafana user', default=None)
    parser.add_argument('--email', dest='email', help='A email to create a new user in grafana', default=None)
    parser.add_argument('--password', dest='password', help='A password of grafana user which need to create',
                        default=None)

    group = parser.add_mutually_exclusive_group(required=False)
    group.add_argument('--show', dest='show', help='Show grafana users', action='store_true')
    group.add_argument('--s', dest='show', help='Show grafana users', action='store_true')

    group2 = parser.add_mutually_exclusive_group(required=False)
    group2.add_argument('--add', dest='add', help='Add grafana user', action='store_true')
    group2.add_argument('--a', dest='add', help='Add grafana user', action='store_true')

    group3 = parser.add_mutually_exclusive_group(required=False)
    group3.add_argument('--update', dest='update', help='Update grafana user', action='store_true')
    group3.add_argument('--u', dest='update', help='Update grafana user', action='store_true')

    group4 = parser.add_mutually_exclusive_group(required=False)
    group4.add_argument('--cpassword', dest='changepassword', help='Change grafana user PW', action='store_true')
    group4.add_argument('--changepw', dest='changepassword', help='Change grafana user PW', action='store_true')

    group5 = parser.add_mutually_exclusive_group(required=False)
    group5.add_argument('--delete', dest='delete', help='Delete grafana user', action='store_true')
    group5.add_argument('--d', dest='delete', help='Delete grafana user', action='store_true')

    results = parser.parse_args()
    grafana_url = results.gurl
    grafana_login = results.glogin
    grafana_password = results.gpassword
    user_email = results.email
    user_password = results.password

    if results.add:
        if (grafana_url is not None) and (user_email is not None) and (user_password is not None):
            add_grafana_user(grafana_url, grafana_login, grafana_password, user_email, user_password)
        else:
            print('Please add [--gurl] or [--email] or [--password]')
            print('For help, use: script_name.py -h')
            exit(0)

    elif results.update:
        if user_email is not None:
            update_grafana_users(grafana_url, grafana_login, grafana_password, user_email)
        else:
            print('Please add [--gurl] or [--email]')
            print('For help, use: script_name.py -h')
            exit(0)

    elif results.changepassword:
        if user_email is not None:
            update_grafana_user_password(grafana_url, grafana_login, grafana_password, user_email)
        else:
            print('Please add [--gurl] or [--email]')
            print('For help, use: script_name.py -h')
            exit(0)
    elif results.delete:
        if user_email is not None:
            delete_grafana_users(grafana_url, grafana_login, grafana_password, user_email)
        else:
            print('Please add [--gurl] or [--email]')
            print('For help, use: script_name.py -h')
            exit(0)
    elif results.show:
        if (grafana_url is not None) and (grafana_login is not None) and (grafana_password is not None):
            # print(get_grafana_users(grafana_url, grafana_login, grafana_password))
            users = get_grafana_users(grafana_url, grafana_login, grafana_password)
            for user in users:
                print(user)
        else:
            print('Please add [--gurl] or [--email] or [--password]')
            print('For help, use: script_name.py -h')
            exit(0)
    else:
        print('For help, use: script_name.py -h')
        exit(0)

    end__time = round(time.time() - start__time, 2)
    print("--- %s seconds ---" % end__time)

    print(
        Bgcolors().get['OKGREEN'], "============================================================",
        Bgcolors().get['ENDC'])
    print(
        Bgcolors().get['OKGREEN'], "==========================FINISHED==========================",
        Bgcolors().get['ENDC'])
    print(
        Bgcolors().get['OKGREEN'], "============================================================",
        Bgcolors().get['ENDC'])


if __name__ == '__main__':
    main()
