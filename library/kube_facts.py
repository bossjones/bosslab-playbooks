# -*- coding: utf-8 -*-

# (c) 2018, Will Thames <@willthames>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

# SOURCE: https://github.com/ansible/ansible/blob/b35ac8080f1749d341212be40615d591adc57ff9/lib/ansible/modules/clustering/k8s/k8s_facts.py
# import pdb
# pdb.set_trace()
from __future__ import absolute_import, division, print_function

try:
    import kubernetes
    import openshift
    from openshift.dynamic import DynamicClient
    from openshift.dynamic.exceptions import ResourceNotFoundError, ResourceNotUniqueError
    HAS_K8S_MODULE_HELPER = True
except ImportError:
    HAS_K8S_MODULE_HELPER = False

try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False

try:
    import dictdiffer
    HAS_DICTDIFFER = True
except ImportError:
    HAS_DICTDIFFER = False

try:
    import urllib3
    urllib3.disable_warnings()
except ImportError:
    pass

import os
import copy

from ansible.module_utils.six import items, string_types
from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.k8s.common import KubernetesAnsibleModule

__metaclass__ = type


ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = '''
module: kube_facts

short_description: Describe Kubernetes (K8s) objects

version_added: "2.0"

author:
    - "Will Thames (@willthames)"

description:
  - Use the OpenShift Python client to perform read operations on K8s objects.
  - Access to the full range of K8s APIs.
  - Authenticate using either a config file, certificates, password or token.
  - Supports check mode.

options:
  api_version:
    description:
    - Use to specify the API version. in conjunction with I(kind), I(name), and I(namespace) to identify a
      specific object.
    default: v1
    aliases:
    - api
    - version
  kind:
    description:
    - Use to specify an object model. Use in conjunction with I(api_version), I(name), and I(namespace) to identify a
      specific object.
    required: yes
  name:
    description:
    - Use to specify an object name.  Use in conjunction with I(api_version), I(kind) and I(namespace) to identify a
      specific object.
  namespace:
    description:
    - Use to specify an object namespace. Use in conjunction with I(api_version), I(kind), and I(name)
      to identify a specfic object.
  label_selectors:
    description: List of label selectors to use to filter results
  field_selectors:
    description: List of field selectors to use to filter results

extends_documentation_fragment:
  - k8s_auth_options

requirements:
  - "python >= 2.7"
  - "openshift >= 0.6"
  - "PyYAML >= 3.11"
'''

EXAMPLES = '''
- name: Get an existing Service object
  kube_facts:
    api_version: v1
    kind: Service
    name: web
    namespace: testing
  register: web_service

- name: Get a list of all service objects
  kube_facts:
    api_version: v1
    kind: Service
    namespace: testing
  register: service_list

- name: Get a list of all pods from any namespace
  kube_facts:
    kind: Pod
  register: pod_list

- name: Search for all Pods labelled app=web
  kube_facts:
    kind: Pod
    label_selectors:
      - app = web
      - tier in (dev, test)

- name: Search for all running pods
  kube_facts:
    kind: Pod
    field_selectors:
      - status.phase = running
'''

RETURN = '''
resources:
  description:
  - The object(s) that exists
  returned: success
  type: complex
  contains:
    api_version:
      description: The versioned schema of this representation of an object.
      returned: success
      type: str
    kind:
      description: Represents the REST resource this object represents.
      returned: success
      type: str
    metadata:
      description: Standard object metadata. Includes name, namespace, annotations, labels, etc.
      returned: success
      type: dict
    spec:
      description: Specific attributes of the object. Will vary based on the I(api_version) and I(kind).
      returned: success
      type: dict
    status:
      description: Current status details for the object.
      returned: success
      type: dict
'''


def list_dict_str(value):
    if isinstance(value, list):
        return value
    elif isinstance(value, dict):
        return value
    elif isinstance(value, string_types):
        return value
    raise TypeError


ARG_ATTRIBUTES_BLACKLIST = ('property_path',)

COMMON_ARG_SPEC = {
    'state': {
        'default': 'present',
        'choices': ['present', 'absent'],
    },
    'force': {
        'type': 'bool',
        'default': False,
    },
    'resource_definition': {
        'type': list_dict_str,
        'aliases': ['definition', 'inline']
    },
    'src': {
        'type': 'path',
    },
    'kind': {},
    'name': {},
    'namespace': {},
    'api_version': {
        'default': 'v1',
        'aliases': ['api', 'version'],
    },
}

AUTH_ARG_SPEC = {
    'kubeconfig': {
        'type': 'path',
    },
    'context': {},
    'host': {},
    'api_key': {
        'no_log': True,
    },
    'username': {},
    'password': {
        'no_log': True,
    },
    'verify_ssl': {
        'type': 'bool',
    },
    'ssl_ca_cert': {
        'type': 'path',
    },
    'cert_file': {
        'type': 'path',
    },
    'key_file': {
        'type': 'path',
    },
}


class K8sAnsibleMixin(object):
    _argspec_cache = None

    @property
    def argspec(self):
        """
        Introspect the model properties, and return an Ansible module arg_spec dict.
        :return: dict
        """
        if self._argspec_cache:
            return self._argspec_cache
        argument_spec = copy.deepcopy(COMMON_ARG_SPEC)
        argument_spec.update(copy.deepcopy(AUTH_ARG_SPEC))
        self._argspec_cache = argument_spec
        return self._argspec_cache

    def get_api_client(self, **auth_params):
        auth_args = AUTH_ARG_SPEC.keys()

        auth_params = auth_params or getattr(self, 'params', {})
        auth = copy.deepcopy(auth_params)

        # If authorization variables aren't defined, look for them in environment variables
        for key, value in items(auth_params):
            if key in auth_args and value is None:
                env_value = os.getenv('K8S_AUTH_{0}'.format(key.upper()), None)
                if env_value is not None:
                    auth[key] = env_value

        def auth_set(*names):
            return all([auth.get(name) for name in names])

        if auth_set('username', 'password', 'host') or auth_set('api_key', 'host'):
            # We have enough in the parameters to authenticate, no need to load incluster or kubeconfig
            pass
        elif auth_set('kubeconfig') or auth_set('context'):
            kubernetes.config.load_kube_config(
                auth.get('kubeconfig'), auth.get('context'))
        else:
            # First try to do incluster config, then kubeconfig
            try:
                kubernetes.config.load_incluster_config()
            except kubernetes.config.ConfigException:
                kubernetes.config.load_kube_config(
                    auth.get('kubeconfig'), auth.get('context'))

        # Override any values in the default configuration with Ansible parameters
        configuration = kubernetes.client.Configuration()
        for key, value in items(auth):
            if key in auth_args and value is not None:
                if key == 'api_key':
                    setattr(configuration, key, {
                            'authorization': "Bearer {0}".format(value)})
                else:
                    setattr(configuration, key, value)

        kubernetes.client.Configuration.set_default(configuration)
        return DynamicClient(kubernetes.client.ApiClient(configuration))

    def client_from_kubeconfig(self, config_file, context):
        try:
            return kubernetes.config.new_client_from_config(config_file, context)
        except (IOError, kubernetes.config.ConfigException):
            # If we failed to load the default config file then we'll return
            # an empty configuration
            # If one was specified, we will crash
            if not config_file:
                return kubernetes.client.ApiClient()
            raise

    def find_resource(self, kind, api_version, fail=False):
        for attribute in ['kind', 'name', 'singular_name']:
            try:
                return self.client.resources.get(**{'api_version': api_version, attribute: kind})
            except (ResourceNotFoundError, ResourceNotUniqueError):
                pass
        try:
            return self.client.resources.get(api_version=api_version, short_names=[kind])
        except (ResourceNotFoundError, ResourceNotUniqueError):
            if fail:
                self.fail(msg='Failed to find exact match for {0}.{1} by [kind, name, singularName, shortNames]'.format(
                    api_version, kind))

    def kubernetes_facts(self, kind, api_version, name=None, namespace=None, label_selectors=None, field_selectors=None):
        resource = self.find_resource(kind, api_version)
        if not resource:
            return dict(resources=[])
        try:
            result = resource.get(name=name,
                                  namespace=namespace,
                                  label_selector=','.join(label_selectors),
                                  field_selector=','.join(field_selectors)).to_dict()
        except openshift.dynamic.exceptions.NotFoundError:
            return dict(resources=[])

        if 'items' in result:
            return dict(resources=result['items'])
        else:
            return dict(resources=[result])

    def remove_aliases(self):
        """
        The helper doesn't know what to do with aliased keys
        """
        for k, v in items(self.argspec):
            if 'aliases' in v:
                for alias in v['aliases']:
                    if alias in self.params:
                        self.params.pop(alias)

    def load_resource_definitions(self, src):
        """ Load the requested src path """
        result = None
        path = os.path.normpath(src)
        if not os.path.exists(path):
            self.fail(
                msg="Error accessing {0}. Does the file exist?".format(path))
        try:
            with open(path, 'r') as f:
                result = list(yaml.safe_load_all(f))
        except (IOError, yaml.YAMLError) as exc:
            self.fail(msg="Error loading resource_definition: {0}".format(exc))
        return result

    @staticmethod
    def diff_objects(existing, new):
        if not HAS_DICTDIFFER:
            return False, []

        diffs = list(dictdiffer.diff(new, existing))
        match = len(diffs) == 0
        return match, diffs


class KubernetesAnsibleModuleImproved(AnsibleModule, K8sAnsibleMixin):
    resource_definition = None
    api_version = None
    kind = None

    def __init__(self, *args, **kwargs):

        kwargs['argument_spec'] = self.argspec
        AnsibleModule.__init__(self, *args, **kwargs)

        if not HAS_K8S_MODULE_HELPER:
            self.fail_json(
                msg="This module requires the OpenShift Python client. Try `pip install openshift`")
        self.openshift_version = openshift.__version__

        if not HAS_YAML:
            self.fail_json(
                msg="This module requires PyYAML. Try `pip install PyYAML`")

    def execute_module(self):
        raise NotImplementedError()

    def fail(self, msg=None):
        self.fail_json(msg=msg)


class KubernetesFactsModule(KubernetesAnsibleModuleImproved):

    def __init__(self, *args, **kwargs):
        KubernetesAnsibleModuleImproved.__init__(self, *args,
                                         supports_check_mode=True,
                                         **kwargs)

    def execute_module(self):
        self.client = self.get_api_client()

        self.exit_json(changed=False,
                       **self.kubernetes_facts(self.params['kind'],
                                               self.params['api_version'],
                                               self.params['name'],
                                               self.params['namespace'],
                                               self.params['label_selectors'],
                                               self.params['field_selectors']))

    @property
    def argspec(self):
        args = copy.deepcopy(AUTH_ARG_SPEC)
        args.update(
            dict(
                kind=dict(required=True),
                api_version=dict(default='v1', aliases=['api', 'version']),
                name=dict(),
                namespace=dict(),
                label_selectors=dict(type='list', default=[]),
                field_selectors=dict(type='list', default=[]),
            )
        )
        return args


def main():
    KubernetesFactsModule().execute_module()


if __name__ == '__main__':
    # import pdb
    # pdb.set_trace()
    main()
