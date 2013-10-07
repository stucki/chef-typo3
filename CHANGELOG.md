# CHANGELOG for typo3

This file is used to list changes made in each version of typo3.

## 0.5.0:

* [CLEANUP] Rename internal variables

## 0.4.3:

* [BUGFIX] Set the "fetch" refspec when updating the remote

## 0.4.2:

* [BUGFIX] Fix a typo
* [BUGFIX] Update the remote repository URL in case it was changed

## 0.4.1:

* [BUGFIX] Work around Dir::Tmpname.make_tmpname which is missing in Ruby 1.8.7

## 0.4.0:

* [CLEANUP] Make more use of variables
* [FEATURE] If the destination already exists, operate on a temporary folder
  In order to use this folder, the admin needs to rename the temporary folder to the real destination name.
* [FEATURE] Add attribute to define a reference / tag to be checked out


## 0.3.0:

* [BUGFIX] Fix permissions (make sure files are world-readable)
* [FEATURE] Only clone TYPO3core.git if requested
* [CLEANUP] More code cleanup
* [CLEANUP] Remove unused setting

## 0.2.0:

* [FEATURE] Major rewrite with lots of bugfixes

## 0.1.2:

* [FEATURE] Move git-new-workdir path into an attribute

## 0.1.1:

* [BUGFIX] Add dependency on Git

## 0.1.0:

* [FEATURE] Initial release of typo3

- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
