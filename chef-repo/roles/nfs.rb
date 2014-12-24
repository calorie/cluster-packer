name 'nfs'
description 'nfs server'
run_list(
  'recipe[apt]',
  'recipe[chef-solo-search]',
  'recipe[users::sysadmins]',
  'recipe[sudo]',
  'recipe[nfs_server]'
)
