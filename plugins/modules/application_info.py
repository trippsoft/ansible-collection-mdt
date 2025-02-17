#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: application_info
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Gets information about an MDT application
description:
  - Gets information about an MDT application.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode_read_only
  - trippsc2.mdt.common
options:
  guid:
    type: str
    required: false
    description:
      - The GUID of the application.
      - This is mutually exclusive with O(name).  One of the two must be provided.
  name:
    type: str
    required: false
    description:
      - The full name of the application.
      - This is mutually exclusive with O(guid).  One of the two must be provided.
"""

EXAMPLES = r"""
- name: Get application info by name
  trippsc2.mdt.application_info:
    mdt_share_path: C:\\MDTShare
    name: Application 1

- name: Get application info by GUID
  trippsc2.mdt.application_info:
    mdt_share_path: C:\\MDTShare
    guid: "{12345678-1234-1234-1234-123456789012}"
"""

RETURN = r"""
exists:
  type: bool
  returned: success
  description:
    - Whether the application exists.
application:
  type: dict
  returned: RV(exists=true)
  description:
      - The application information.
  contains:
    guid:
      type: str
      description:
        - The application GUID.
    name:
      type: str
      description:
        - The full name of the application.
    paths:
      type: list
      elements: str
      description:
        - The list of paths relative to the V(Applications) folder where the application exists.
    type:
      type: str
      description:
        - The application type.
    publisher:
      type: str
      description:
        - The application publisher.
    short_name:
      type: str
      description:
        - The short name of the application.
    version:
      type: str
      description:
        - The application version.
    language:
      type: str
      description:
        - The application language.
    comments:
      type: str
      description:
        - The application comments.
    command_line:
      type: str
      returned: RV(application.type=source) or RV(application.type=no_source)
      description:
        - The application command line.
    working_directory:
      type: str
      returned: RV(application.type=source) or RV(application.type=no_source)
      description:
        - The application working directory.
    enabled:
      type: bool
      description:
        - Whether the application is enabled.
    hidden:
      type: bool
      description:
        - Whether the application is hidden.
    reboot:
      type: bool
      description:
        - Whether the application requires a reboot after installation.
    files_path:
      type: str
      returned: RV(application.type=source)
      description:
        - The path to the application files.
    dependencies:
      type: list
      elements: str
      description:
        - The application dependencies.
      contains:
        name:
          type: str
          description:
            - The full name of the dependency.
        guid:
          type: str
          description:
            - The GUID of the dependency.
"""
