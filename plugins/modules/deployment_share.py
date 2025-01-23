#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: deployment_share
version_added: 1.0.0
author:
  - Jim Tarpley
short_description: Ensures an MDT deployment share is configured as expected
description:
  - Ensures an MDT deployment share is configured as expected.
  - This module will not delete the deployment share contents when O(state=absent).
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
  name:
    type: str
    required: false
    description:
      - The name of the deployment share.
      - Mutually exclusive with O(path).
      - Only used when O(state=absent).
  path:
    type: str
    required: false
    description:
      - The path to the deployment share.
      - Mutually exclusive with O(name).
      - When O(state=present), this is required.
      - If the path does not exist, it will be created.      
  description:
    type: str
    required: false
    description:
      - The description of the deployment share.
      - When O(state=absent), this is ignored.
      - When O(state=present), this is required.
  share_name:
    type: str
    required: false
    description:
      - The share name of the deployment share.
      - When O(state=absent), this is ignored.
      - When O(state=present), this is required.
  state:
    type: str
    required: false
    default: present
    choices:
      - present
      - absent
    description:
      - The expected state of the deployment share.
"""

EXAMPLES = r"""
- name: Create deployment share
  trippsc2.mdt.deployment_share:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    path: C:\\DeploymentShare
    description: My Deployment Share
    share_name: DeploymentShare
    state: present

- name: Remove deployment share by name
  trippsc2.mdt.deployment_share:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    name: DS001
    state: absent

- name: Remove deployment share by path
  trippsc2.mdt.deployment_share:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    path: C:\\DeploymentShare
    state: absent
"""

RETURN = r"""
name:
  type: str
  returned:
    - success
    - O(state=present)
  description:
    - The name of the deployment share.
path:
  type: str
  returned:
    - success
    - O(state=present)
  description:
    - The path to the deployment share.
directory_created:
  type: bool
  returned:
    - success
    - O(state=present)
  description:
    - Indicates if the deployment share directory was created and not just added as a persistent drive.
previous:
  type: dict
  returned:
    - O(state=absent)
    - RV(changed=true)
  description:
    - The previous state of the deployment share.
  options:
    name:
      type: str
      description:
        - The name of the deployment share.
    path:
      type: str
      description:
        - The path to the deployment share.
    description:
      type: str
      description:
        - The description of the deployment share.
"""
