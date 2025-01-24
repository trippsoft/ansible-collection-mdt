#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: directory
version_added: 1.0.0
author:
  - Jim Tarpley
short_description: Ensures an MDT deployment share directory is configured as expected
description:
  - Ensures an MDT deployment share directory is configured as expected.
attributes:
  check_mode:
    support: full
    details:
      - Fully supports check mode
options:
  installation_path:
    type: path
    required: false
    default: C:\\Program Files\\Microsoft Deployment Toolkit
    description:
      - The path to the MDT installation directory.
  path:
    type: str
    required: true
    description:
      - The path of the directory to manage within the MDT deployment share.
      - This is relative to the root of the MDT deployment share.
  mdt_share_path:
    type: path
    required: true
    description:
      - The path to the MDT directory.
  state:
    type: str
    required: false
    default: present
    choices:
      - present
      - absent
    description:
      - The expected state of the deployment share directory.
"""

EXAMPLES = r"""
- name: Create directory
  trippsc2.mdt.directory:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    path: Operating Systems\\Windows10
    mdt_share_path: C:\\MDTShare
    state: present

- name: Remove directory
  trippsc2.mdt.directory:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    path: Operating Systems\\Windows10
    mdt_share_path: C:\\MDTShare
    state: absent
"""

RETURN = r"""
"""
