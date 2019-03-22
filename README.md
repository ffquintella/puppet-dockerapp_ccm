
# dockerapp_ccm


#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with dockerapp_ccm](#setup)
    * [What dockerapp_ccm affects](#what-dockerapp_ccm-affects)
    * [Beginning with dockerapp_ccm](#beginning-with-dockerapp_ccm)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

The Configuration and Credential Manager is an app designed to be able to handle other apps configurations. This module installs and configures it using a docker container and a default directory structure.

## Setup

### What dockerapp_ccm affects **OPTIONAL**

This module creates some directories under /srv with the service_name provided

### Beginning with dockerapp_ccm

To use this module you install it and follor the instructions in usage

## Usage

Basic use of the module

```
class {'dockerapp_ccm':
  
}

```


## Limitations

This module is only tested for RedHat 7 derivations and Debian

## Development

Just fork and open change requests. Be shure all the tests are passing using pkd test unit and pdk validate 


