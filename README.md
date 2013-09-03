TYPO3 Cookbook
==============
This cookbook will create a Git clone of TYPO3 CMS and keep it up to date.

Requirements
------------

* Git

Usage
-----

This cookbook installs a shared TYPO3core.git folder in the base
directory. The folder contains nothing except a .git folder.
Define any number of branches that need to be installed & updated.

To install a new repository, create an empty file <branchname>.clone
inside the base directory. This is neccessary to avoid conflicts with
existing folders within the same base directory.
Once cloned, the cookbook will delete the *.clone file and keep the
project up to date.

Contributing
------------

License and Authors
-------------------

- Author:: Michael Stucki (<michael.stucki@typo3.org>)
- Copyright:: 2013, TYPO3 Association

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
