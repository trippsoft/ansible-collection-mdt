#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: application_dependency
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Creates, updates, or deletes an MDT application dependency
description:
  - Creates, updates, or deletes an MDT application dependency.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode
  - trippsc2.mdt.common
options:
  guid:
    type: str
    required: false
    description:
      - The GUID used to identify the application.
      - This is mutually exclusive with O(name).  One of the two must be provided.
  name:
    type: str
    required: false
    description:
      - The name used to identify the application.
      - This is mutually exclusive with O(guid).  One of the two must be provided.
  add:
    type: list
    required: false
    elements: dict
    description:
      - A list of applications to add as dependencies.
      - This is mutually exclusive with O(set).
      - Applications cannot be included in both O(add) and O(remove).
    suboptions:
      name:
        type: str
        required: false
        description:
          - The name used to identify the application to add as a dependency.
          - This is mutually exclusive with O(guid).  One of the two must be provided.
      guid:
        type: str
        required: false
        description:
          - The GUID used to identify the application to add as a dependency.
          - This is mutually exclusive with O(name).  One of the two must be provided.
  remove:
    type: list
    required: false
    elements: dict
    description:
      - A list of applications to remove as dependencies.
      - This is mutually exclusive with O(set).
      - Applications cannot be included in both O(add) and O(remove).
    suboptions:
      name:
        type: str
        required: false
        description:
          - The name used to identify the application to remove as a dependency.
          - This is mutually exclusive with O(guid).  One of the two must be provided.
      guid:
        type: str
        required: false
        description:
          - The GUID used to identify the application to remove as a dependency.
          - This is mutually exclusive with O(name).  One of the two must be provided.
  set:
    type: list
    required: false
    elements: dict
    description:
      - A list of applications to set as dependencies.
      - This is mutually exclusive with O(add) and O(remove).
    suboptions:
      name:
        type: str
        required: false
        description:
          - The name used to identify the application to set as a dependency.
          - This is mutually exclusive with O(guid).  One of the two must be provided.
      guid:
        type: str
        required: false
        description:
          - The GUID used to identify the application to set as a dependency.
          - This is mutually exclusive with O(name).  One of the two must be provided.
"""

EXAMPLES = r"""
- name: Set dependencies for an MDT application by name and path
  trippsc2.mdt.application_dependency:
    mdt_share_path: C:\\MDTShare
    name: Application 1
    set:
      - name: Dependency 1
        path: Dependencies
      - name: Dependency 2

- name: Set dependencies for an MDT application by GUID
  trippsc2.mdt.application_dependency:
    mdt_share_path: C:\\MDTShare
    name: Application 1
    set:
      - guid: {12345678-1234-1234-1234-123456789012}
      - guid: {12345678-1234-1234-1234-123456789013}

- name: Add and Remove dependencies for an MDT application by name and path
  trippsc2.mdt.application_dependency:
    mdt_share_path: C:\\MDTShare
    name: Application 1
    add:
      - name: Dependency 1
        path: Dependencies
    remove:
      - name: Dependency 2
"""

RETURN = r"""
application_dependencies:
  type: list
  elements: dict
  returned: success
  description:
    - The current state of the application's dependencies.
  contains:
    name:
      type: str
      description:
        - The full name of the application.
    guid:
      type: str
      description:
        - The GUID of the application.
"""
