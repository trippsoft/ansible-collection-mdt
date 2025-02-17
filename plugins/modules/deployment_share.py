#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: deployment_share
version_added: 1.0.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Ensures an MDT deployment share is configured as expected
description:
  - Ensures an MDT deployment share is configured as expected.
  - This module will not delete the deployment share contents when O(state=absent).
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode
  - trippsc2.mdt.common
options:
  description:
    type: str
    required: false
    description:
      - The descriptive name of the deployment share.
      - When O(state=present), this is required.
      - When O(state=absent), this is ignored.
  unc_path:
    type: str
    required: false
    description:
      - The UNC share path of the deployment share.
      - This does B(not) share the deployment share folder.
      - When O(state=present), this is required.
      - When O(state=absent), this is ignored.
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
    mdt_share_path: C:\\DeploymentShare
    description: My Deployment Share
    unc_path: "\\\\{{ inventory_hostname | upper }}\\DeploymentShare"
    state: present

- name: Remove deployment share
  trippsc2.mdt.deployment_share:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    mdt_share_path: C:\\DeploymentShare
    state: absent
"""

RETURN = r"""
name:
  type: str
  returned: O(state=present)
  description:
    - The name of the deployment share.
path:
  type: str
  returned: O(state=present)
  description:
    - The path to the deployment share.
description:
  type: str
  returned: O(state=present)
  description:
    - The descriptive name of the deployment share.
unc_path:
  type: str
  returned: O(state=present)
  description:
    - The UNC share path of the deployment share.
"""
