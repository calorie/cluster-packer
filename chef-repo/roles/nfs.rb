name 'nfs'
description 'nfs server'
run_list(
  'recipe[apt]',
  'recipe[nfs_server]'
)
