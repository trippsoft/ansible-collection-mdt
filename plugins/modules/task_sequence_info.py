#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: task_sequence_info
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Gets information about an MDT task sequence
description:
  - Gets information about an MDT task sequence.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode_read_only
  - trippsc2.mdt.common
options:
  id:
    type: str
    required: false
    description:
      - The ID of the task sequence.
      - This is mutually exclusive with O(name).  One of the two must be provided
  name:
    type: str
    required: false
    description:
      - The name of the task sequence.
      - This is mutually exclusive with O(id).  One of the two must be provided.
  include_secrets:
    type: bool
    required: false
    default: false
    description:
      - Whether to include secrets in the output.
"""

EXAMPLES = r"""
- name: Get task sequence info by name
  trippsc2.mdt.task_sequence_info:
    mdt_share_path: C:\\MDTShare
    name: Windows 11 Enterprise

- name: Get task sequence info by ID with secrets
  trippsc2.mdt.task_sequence_info:
    mdt_share_path: C:\\MDTShare
    id: WIN11-ENT
    include_secrets: true
"""

RETURN = r"""
exists:
  type: bool
  returned: success
  description:
    - Whether the task sequence exists.
task_sequence:
  type: dict
  returned: RV(exists=true)
  description:
      - The task sequence information.
  contains:
    guid:
      type: str
      description:
        - The GUID of the task sequence.
    id:
      type: str
      description:
        - The ID of the task sequence.
    name:
      type: str
      description:
        - The name of the task sequence.
    template:
      type: str
      description:
        - The template file name from which the task sequence was imported.
    operating_system:
      type: dict
      description:
        - The operating system information for the task sequence.
      contains:
        guid:
          type: str
          description:
            - The GUID of the operating system.
        name:
          type: str
          description:
            - The name of the operating system.
    version:
      type: str
      description:
        - The version of the task sequence.
    product_key_type:
      type: str
      description:
        - The type of private key supplied to the MDT task sequence (retail or mak).
    product_key:
      type: str
      returned: |
        RV(task_sequence.product_key_type=retail) or RV(task_sequence.product_key_type=mak)
        O(include_secrets=true)
      description:
        - The private key supplied to the MDT task sequence.
    admin_password:
      type: str
      returned: |
        admin password is supplied
        O(include_secrets=true)
      description:
        - The administrator password supplied to the MDT task sequence.
    full_name:
      type: str
      description:
        - The full name of the task sequence.
    organization:
      type: str
      description:
        - The organization name for the task sequence.
    ie_home_page:
      type: str
      description:
        - The home page for Internet Explorer.
    paths:
      type: list
      elements: str
      description:
        - The paths at which the task sequence is found.
    comments:
      type: str
      description:
        - Comments about the task sequence.
    enabled:
      type: bool
      description:
        - Whether the task sequence is enabled.
    hidden:
      type: bool
      description:
        - Whether the task sequence is hidden.
"""
