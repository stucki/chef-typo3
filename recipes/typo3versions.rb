#
# Cookbook Name:: typo3
# Recipe:: typo3versions
#
# Copyright 2013, Michael Stucki / TYPO3 Association
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

base_directory       = node['typo3']['base_directory']
git_new_workdir      = node['typo3']['path_git-new-workdir']
shared_git_directory = node['typo3']['shared_git_directory'].gsub(/.git$/, '')

#####################################
# Maintain clones of TYPO3 versions
#####################################

node['typo3']['install_branches'].each do |v|

  # Read branch name and reference from attributes
  if v.kind_of?(Mash) and v.has_key?(:name)
    branch      = v[:name]
    reference   = v[:reference]
  elsif v.kind_of?(String)
    branch      = v
    reference   = v
  else
    Chef::Log.error("Error: Syntax error in node['typo3']['install_branches']:\n" +  node['typo3']['install_branches'].to_s + "\n")
    Chef::Application.fatal!("Cannot continue.")
  end

  source             = shared_git_directory + ".git"
  destination        = base_directory + "/" + branch + ".git"
  clone_file         = base_directory + "/" + branch + ".clone"
  marker_file        = base_directory + "/" + branch + ".cloned-by-chef"

  # Only clone the repository if explicitely requested
  if ::File.exists?(clone_file)

    if ::File.exists?(destination)
      # If the destination already exists, operate on a temporary folder and let the admin review the change
      # In order to use this folder, the admin needs to rename the temporary folder to the real destination name.
      prefix = branch + "_"

      # This fails on Ruby 1.8.7. Using an ugly workaround with Dir.mktmpdir instead
      #tempname       = Dir::Tmpname.make_tmpname(prefix, nil)

      path = Dir.mktmpdir(prefix, base_directory)
      tempname = File.basename(path)
      FileUtils.remove_entry_secure path

      destination    = base_directory + "/" + tempname + ".git"
      marker_file    = base_directory + "/" + tempname + ".cloned-by-chef"
    end

    # Create initial clone of TYPO3core
    # Use git-new-workdir share the main ".git" folder between all versions
    execute "Create new TYPO3 working directory for version #{branch}" do
      cwd base_directory
      umask 0022
      command <<-EOH
        sh #{git_new_workdir} #{source} #{destination}
        touch #{marker_file}
        rm #{clone_file}
      EOH
    end

    execute "Create new local branch #{branch}" do
      cwd destination
      umask 0022
      command "git checkout #{branch} || git checkout -b #{branch}; git reset --hard #{reference}"
    end

  elsif ::File.exists?(destination)

    # Only reset if managed by Chef
    if ::File.exists?(marker_file)

      # Update existing clone of TYPO3core (using git reset)
      execute "Update TYPO3core for version #{branch}" do
        cwd destination
        umask 0022
        command "git reset --hard #{reference}"
      end
    else
      Chef::Log.debug("Skipping update of #{destination}: The repository is not managed by Chef.")
    end
  else
    Chef::Log.debug("Skipping clone of #{destination}: Missing clone file.")
  end
end
