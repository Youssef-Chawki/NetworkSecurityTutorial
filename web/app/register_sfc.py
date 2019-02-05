#!/usr/bin/python
import argparse
import requests,json
from requests.auth import HTTPBasicAuth
from subprocess import call
import time
import sys
import os

DEFAULT_PORT='8181'
USERNAME='admin'
PASSWORD='admin'

def post(host, port, uri, data, debug=False):
    '''Perform a POST rest operation, using the URL and data provided'''

    url='http://'+host+":"+port+uri
    headers = {'Content-type': 'application/yang.data+json',
               'Accept': 'application/yang.data+json'}
    if debug == True:
        print "POST %s" % url
        print json.dumps(data, indent=4, sort_keys=True)
    r = requests.post(url, data=json.dumps(data), headers=headers, auth=HTTPBasicAuth(USERNAME, PASSWORD))
    if debug == True:
        print r.text
    print "HTTP POST %s\nresult: %s" % (uri, r.status_code)
    r.raise_for_status()
    time.sleep(5)

def put(host, port, uri, data, debug=False):
    '''Perform a PUT rest operation, using the URL and data provided'''

    url='http://'+host+":"+port+uri

    headers = {'Content-type': 'application/yang.data+json',
               'Accept': 'application/yang.data+json'}
    if debug == True:
        print "PUT %s" % url
        print json.dumps(data, indent=4, sort_keys=True)
    r = requests.put(url, data=json.dumps(data), headers=headers, auth=HTTPBasicAuth(USERNAME, PASSWORD))
    if debug == True:
        print r.text
    print "HTTP PUT %s\nresult: %s" % (uri, r.status_code)
    r.raise_for_status()
    time.sleep(5)
    

def get(host, port, uri, debug=False):
    '''Perform a GET rest operation, using the URL and data provided'''

    url='http://'+host+":"+port+uri
    headers = {'Content-type': 'application/yang.data+json',
               'Accept': 'application/yang.data+json'}
    if debug == True:
        print "GET %s" % url
    r = requests.get(url, headers=headers, auth=HTTPBasicAuth(USERNAME, PASSWORD))
    if debug == True:
        print r.text
    print "HTTP GET %s\nresult: %s" % (uri, r.status_code)
    if r.status_code == 404:
        print "result equal 404"
        return None
        
    r.raise_for_status()
    time.sleep(5)
    return r.json()
    
    
def get_service_nodes_uri():
    return "/restconf/config/service-node:service-nodes"

def get_service_nodes_data(name,ip_addr):
    return {
    "service-nodes": {
        "service-node": [
            {
                "name": name,
                "service-function": [
                ],
                "ip-mgmt-address": ip_addr
            }
        ]
    }
}

def get_service_nodes_data2(name,ip_addr):
    return {
                "name": name,
                "service-function": [
                ],
                "ip-mgmt-address": ip_addr
}

def get_tunnel_uri(datapath):
    return "/restconf/config/opendaylight-inventory:nodes/node/openflow:"+datapath

def get_tunnel_data(datapath,ip_addr):
    return {
    "node": [
      {
        "id": "openflow:"+datapath,
        "ofoverlay:tunnel": [
          {
            "tunnel-type": "overlay:tunnel-type-vxlan",
            "node-connector-id": "openflow:"+datapath+":1",
            "ip": ip_addr,
            "port": 4789
          },
          {
            "tunnel-type": "overlay:tunnel-type-vxlan-gpe",
            "node-connector-id": "openflow:"+datapath+":2",
            "ip": ip_addr,
            "port": 6633
          }
          
        ]
      }
    ]
  }


def main():
    controller = sys.argv[1]
    datapath = sys.argv[2]
    name = sys.argv[3]
    ip_addr = sys.argv[4]
    
    print "controller :"+ controller
    print "datapath :"+ datapath
    print "name :"+ name
    print "ip_addr :"+ ip_addr
    

    
    print "sending service node"
    service_nodes = get(controller, DEFAULT_PORT, get_service_nodes_uri(), True)
    if service_nodes is None:
        print "service_nodes is none"
        put(controller, DEFAULT_PORT, get_service_nodes_uri(), get_service_nodes_data(name,ip_addr), True)
    else:
        #print "here are the existing service nodes : "+ json.dumps(service_nodes)

        print service_nodes['service-nodes']
        
        service_nodes ["service-nodes"]["service-node"].append(get_service_nodes_data2(name,ip_addr))

        #print "here are the new existing service nodes : "+json.dumps(service_nodes)

        print "sending service node"
        put(controller, DEFAULT_PORT, get_service_nodes_uri(), service_nodes, True)
    
    print "sending tunnel"
    datapath_int = int(datapath) #remove all zeros
    datapath_str = str(datapath_int)
    put(controller, DEFAULT_PORT, get_tunnel_uri(datapath_str), get_tunnel_data(datapath_str,ip_addr), True)
    
    
if __name__ == "__main__":
    main()