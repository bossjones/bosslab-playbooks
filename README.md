# bosslab-playbooks
bosslab homelab playbooks for the entire boss ansible suite


# ruby

```
sudo apt-add-repository ppa:brightbox/ruby-ng -y
sudo apt-get update

gem install bundler pry-byebug byebug pry pry-inline pry-state pry-theme pry-stack_explorer

sudo apt-get install ruby2.4 ruby2.4-dev

```


# mkcert

```
root@scarlett-k8-master-01  ~   mkcert -install                                                                                                                                                                                4.17 Dur  21:55:09
Created a new local CA at "/root/.local/share/mkcert" 💥
The local CA is now installed in the system trust store! ⚡️

Time: 0h:00m:18s

root@scarlett-k8-master-01  ~  mkcert example.com "*.example.org" myapp.dev localhost 127.0.0.1 ::1 scarlettlab.com "*.scarlettlab.org" bosslab.com "*.bosslab.org" rpilab.com "*.rpilab.org"
```
