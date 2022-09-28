# zabbix-workshop
This repo can be used to setup a latest version of zabbix server, zabbix proxy server, zabbix frontend and zabbix agent on local machine for testing/workshop purpose. Mysql is used as backend db. 
All container images except mysql pulled are official zabbix container images.

## Podman
As container engine, podman is used to setup this environment. By modifying `setup_srv_proxy_agent.sh` slightly, docker can also be used as container engine.   

All containers deployed in this setup share the same podman network. Podman 4.x comes with builtin dns server to service container dns requests and enable containers to resolve other containers by their names. To check if dns is enabled:

```sh
xxx@xxx-laptop zabbix-workshop (main)$ podman network inspect podman
[
     {
          "name": "podman",
          "id": "xxxxxxxxxxxxxxxx",
          "driver": "bridge",
          "network_interface": "podman0",
          "created": "2022-08-22T23:01:33.711120093+02:00",
          "subnets": [
               {
                    "subnet": "xx.xx.0.0/16",
                    "gateway": "xx.xx.0.1"
               }
          ],
          "ipv6_enabled": false,
          "internal": false,
          "dns_enabled": true,
          "ipam_options": {
               "driver": "host-local"
          }
     }
] 
```
if not enabled, then add `"dns_enabled": true` and save the configuration to `$HOME/.local/share/containers/storage/networks/podman.json`
After that containers resolve other containers by `<container_name>.dns.podman`

Containers to be deployed:

- mysql.dns.podman
- zabbix-server.dns.podman
- zabbix-web.dns.podman
- zabbix-proxy.dns.podman
- zabbix-agent.dns.podman

Zabbix proxy and agent starts in active mode.

To test userparams with zabbix agent:

- stop the agent.
- restart it with userparam.conf in this repo mounted.

```sh
xxx@xxx-laptop zabbix-workshop (main)$ podman rm zabbix-agent -f
xxx@xxx-laptop zabbix-workshop (main)$ podman run --name zabbix-agent -v $(pwd)/userparam.conf:/etc/zabbix/zabbix_agentd.d/userparam.conf:Z -e ZBX_HOSTNAME="zabbix-agent.dns.podman"  --network podman -e ZBX_SERVER_HOST="zabbix-proxy.dns.podman" -d docker.io/zabbix/zabbix-agent 
```

## Zabbix frontend

Zabbix frontend will be available `127.0.0.1:8080`. Default username and pwd is used to access zabbix frontend. 
After logging in the frontend, a zabbix proxy named `zabbix-proxy.dns.podman` and a zabbix host `zabbix-agent.dns.podman` should be created. This process can be automated by ansible.

  
