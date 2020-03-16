# Jahia jCustomer Docker image

## Build image
Build arg :
* `RELEASE_URL` : the url to fetch the release

## Use image
### Instanciate
Env vars:
* `MAXMIND_KEY` : The MAXMIND API key to fetch GeoLite DB (see https://dev.maxmind.com/geoip/geoip2/geolite2/). If not provided, the db won't be fetch.
* `unomi_env_var_*` : All unomi parameters that can be configured with env var can be defined with this prefix. If you want to specify multiple variables, an env file is strongly recomended instead of providing all of them one by one with -e docker option. The env var unomi_env_var_MY_UNOMI_PARAMATER will be converted to MY_UNOMI_PARAMATER and added to unomi process env vars. As the image doesn't embed any elasticsearch, the only required parameters are unomi_env_var_UNOMI_ELASTICSEARCH_ADDRESSES and unomi_env_var_UNOMI_ELASTICSEARCH_CLUSTERNAME

### Examples
#### basic run
```bash
docker run -d --env-file /path/to/my-env-file jahia/jcustomer:1.4.1
```

#### Basic env file example
```
unomi_env_var_UNOMI_ELASTICSEARCH_ADDRESSES=X.X.X.X:9300
unomi_env_var_UNOMI_ELASTICSEARCH_CLUSTERNAME=unomi-es-cluster-name
```

#### Example to configure a 3 unomi nodes cluster with an elasticsearch 5.6 docker image
##### Create docker network
``` bash
docker network create  -d bridge unomi-network
```
##### Create elasticsearch container
``` bash
docker run -d --name elasticsearch --net=unomi-net -e "discovery.type=single-node" -e xpack.security.enabled=false docker.elastic.co/elasticsearch/elasticsearch:5.6.16
```
##### Create env file
``` bash
unomi_env_var_UNOMI_ELASTICSEARCH_ADDRESSES=elasticsearch:9300
unomi_env_var_UNOMI_ELASTICSEARCH_CLUSTERNAME=docker-cluster
unomi_env_var_UNOMI_CLUSTER_PUBLIC_ADDRESS=http://public.address
unomi_env_var_UNOMI_CLUSTER_PRIVATE_ADDRESS=http://private.address
unomi_env_var_JAVA_MAX_MEM=2G
unomi_env_var_UNOMI_ROOT_PASSWORD=AnAwesomePassword
unomi_env_var_UNOMI_HAZELCAST_TCPIP_MEMBERS=unomi1,unomi2,unomi3
MAXMIND_KEY=XXXXXXXXXXXXXXXXX
```
##### Create unomi nodes
``` bash
docker run -d --name=unomi1 --hostname=unomi1 --net=unomi-net --env-file ./env_file jahia/jcustomer:1.4.1
docker run -d --name=unomi2 --hostname=unomi2 --net=unomi-net --env-file ./env_file jahia/jcustomer:1.4.1
docker run -d --name=unomi3 --hostname=unomi3 --net=unomi-net --env-file ./env_file jahia/jcustomer:1.4.1
```
