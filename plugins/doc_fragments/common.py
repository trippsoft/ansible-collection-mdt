# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type


class ModuleDocFragment(object):

    DOCUMENTATION = r"""
    options:
      installation_path:
        type: path
        required: false
        default: C:\Program Files\Microsoft Deployment Toolkit
        description:
          - The path to the MDT installation directory.
      mdt_share_path:
        type: path
        required: true
        description:
          - The path to the MDT directory.
    """
