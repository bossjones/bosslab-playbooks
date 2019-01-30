# SOURCE: https://dev.to/jrop/creating-an-alerting-callback-plugin-in-ansible---part-i-1h0n
from ansible.plugins.callback import CallbackBase


class CallbackModule(CallbackBase):
  CALLBACK_VERSION = 2.0
  CALLBACK_TYPE = 'aggregate'
  CALLBACK_NAME = 'is'

  def v2_playbook_on_play_start(self, play):
    self.vm = play.get_variable_manager()

  def v2_runner_on_ok(self, result):
    # This will call the callback on every play!
    # import pdb
    # pdb.set_trace()
    if self.vm.get_vars()['ansible_check_mode']:
      return

    host_vars = self.vm.get_vars()['hostvars'][result._host.name]
    if 'notify_on_change' in host_vars and result.is_changed():
      pass
      # TODO: Post Slack message
