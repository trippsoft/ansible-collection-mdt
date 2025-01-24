#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: import_drivers
version_added: 1.0.0
author:
  - Jim Tarpley
short_description: Imports drivers into an MDT deployment share
description:
  - Imports drivers into an MDT deployment share.
  - When O(import_duplicates=false), the module is idempotent.  Otherwise, the module will always import the drivers.
  - The drivers can be imported from driver files within a source directory or from CAB files within a source directory.
attributes:
  check_mode:
    support: none
    details:
      - Check mode is not supported.
options:
  installation_path:
    type: path
    required: false
    default: C:\\Program Files\\Microsoft Deployment Toolkit
    description:
      - The path to the MDT installation directory.
  source_paths:
    type: list
    required: true
    elements: str
    description:
      - The list of source paths containing driver files or CAB files.
  path:
    type: str
    required: true
    description:
      - The path to which the drivers will be imported relative to the root of the MDT deployment share.
  import_duplicates:
    type: bool
    required: false
    default: false
    description:
      - Whether to import duplicate drivers.
  mdt_share_path:
    type: path
    required: true
    description:
      - The path to the MDT directory.
"""

EXAMPLES = r"""
- name: Import drivers
  trippsc2.mdt.import_drivers:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    source_paths:
      - C:\\Drivers1
      - C:\\Drivers2
    path: Out-of-Box Drivers
    mdt_share_path: C:\\MDTShare

- name: Import drivers
  trippsc2.mdt.import_drivers:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    source_paths:
      - C:\\Drivers
    path: Out-of-Box Drivers\\WinPE
    mdt_share_path: C:\\MDTShare
"""

RETURN = r"""
drivers:
  type: list
  elements: dict
  returned:
    - RV(changed=true)
  options:
    class:
      type: str
      description:
        - The driver class.
    guid:
      type: str
      description:
        - The GUID used to identify the driver within the MDT deployment share.
    hash:
      type: str
      description:
        - The SHA-256 hash of the driver file.
    name:
      type: str
      description:
        - The name of the driver.
    os_version:
      type: list
      elements: str
      description:
        - The list of OS versions supported by the driver.
    platform:
      type: list
      elements: str
      description:
        - The list of instruction set platforms supported by the driver.
    source:
      type: str
      description:
        - The source path of the driver files.
    version:
      type: str
      description:
        - The version of the driver.
    whql_signed:
      type: bool
      description:
        - Whether the driver is WHQL signed.
"""
