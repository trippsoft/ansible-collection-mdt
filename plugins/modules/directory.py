#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: directory
version_added: 1.0.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Ensures an MDT deployment share directory is configured as expected
description:
  - Ensures an MDT deployment share directory is configured as expected.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode
  - trippsc2.mdt.common
options:
  path:
    type: str
    required: true
    description:
      - The path of the directory to manage within the MDT deployment share.
      - This is relative to the root of the MDT deployment share.
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
    mdt_share_path: C:\\MDTShare
    path: Operating Systems\\Windows10
    state: present

- name: Remove directory
  trippsc2.mdt.directory:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    mdt_share_path: C:\\MDTShare
    path: Operating Systems\\Windows10
    state: absent
"""

RETURN = r"""
"""
