#
# The state will take a freshly installed Ubuntu 16.04.2 image and apply some simple
# requirements for the contrail server-manager lite installer
#
# fix this to include only information about this contrail cluster as defined
# in the pillar / top.sls file
# something like using a hostname glob
#
# 'contrail*':
#   - cluster_a.sls
#
#

{% for m in pillar["contrail"]["servers"] %}

add_{{ m['name'] }}_to_hosts:
  host.present:
    - names: 
      - {{ m["name"] }}.{{ pillar['contrail']['cluster']['domain'] }}
      - {{ m["name"] }}
    - ip: {{ m["ip"] }}

{% endfor %}

remove_default_host:
  host.absent:
    - name: ubuntu
    - ip: 127.0.1.1

# search domain just plain doesn't work in salt 2017.7 :-/
configure_network:
  network.system:
   - enabled: True
   - hostname: {{ grains['id'] }}
#   - domainname: {{ pillar['contrail']['cluster']['domain'] }}
#   - searchdomain: {{ pillar['contrail']['cluster']['domain'] }}
#   - search: {{ pillar['contrail']['cluster']['domain'] }}
   - require_reboot: False
   - apply_hostname: True

# hack around the above brokeness
set_resvol_conf:
  file.line:
    - name: /etc/resolv.conf
    - mode: replace
    - match: search openstacklocal
    - content: search {{ pillar['contrail']['cluster']['domain'] }}

# wistar will only configure the first interface for us, ensure the second is up
# fixme - extend pillar model to include the network interface info if needed
set_ens4_up:
  cmd.run:
    - name: 'ip link set ens4 up'

