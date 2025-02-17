#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: driver_info
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Gets information about an MDT driver
description:
  - Gets information about an MDT driver.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode
  - trippsc2.mdt.common
options:
  guid:
    type: str
    required: false
    description:
      - The GUID of the driver.
      - This is mutually exclusive with O(name).  One of the two must be provided.
  name:
    type: str
    required: false
    description:
      - The name of the driver.
      - This is mutually exclusive with O(guid).  One of the two must be provided.
"""

EXAMPLES = r"""
- name: Get driver info by name
  trippsc2.mdt.driver_info:
    mdt_share_path: C:\\MDTShare
    name: AVAGO TECH. SCSIAdapter MegaSas35.inf 7.723.02.00

- name: Get driver info by GUID
  trippsc2.mdt.driver_info:
    mdt_share_path: C:\\MDTShare
    guid: "{12345678-1234-1234-1234-123456789012}"
"""

RETURN = r"""
exists:
  type: bool
  returned: success
  description:
    - Whether the driver exists.
driver:
  type: dict
  returned: RV(exists=true)
  description:
      - The driver information.
  contains:
    guid:
      type: str
      description:
        - The driver GUID.
    name:
      type: str
      description:
        - The full name of the driver.
    paths:
      type: list
      elements: str
      description:
        - The list of paths relative to the V(Out-of-Box Drivers) folder where the driver exists.
    class:
      type: str
      description:
        - The driver device class.
    comments:
      type: str
      description:
        - The driver comments.
    files_path:
      type: str
      description:
        - The physical directory of the driver files.
    hash:
      type: str
      description:
        - The SHA256 hash of the driver files.
    manufacturer:
      type: str
      description:
        - The driver manufacturer.
    os_version:
      type: list
      elements: str
      description:
        - The list of OS versions supported by the driver.
    platform:
      type: list
      elements: str
      description:
        - The list of platforms supported by the driver.
    pnp_ids:
      type: list
      elements: str
      description:
        - The list of Plug and Play IDs supported by the driver.
    version:
      type: str
      description:
        - The driver version.
    whql_signed:
      type: bool
      description:
        - Whether the driver is WHQL signed.
    enabled:
      type: bool
      description:
        - Whether the driver is enabled.
    hidden:
      type: bool
      description:
        - Whether the driver is hidden.
"""
