name 'mpi'
description 'computing node'
run_list(
  'recipe[apt]',
  'recipe[chef-solo-search]',
  'recipe[users::sysadmins]',
  'recipe[sudo]',
  'recipe[timezone]',
  'recipe[ssh]',
  'recipe[git]',
  'recipe[gitconfig]',
  'recipe[openmpi]',
  'recipe[mpispec]',
  'recipe[nfs_client]'
)
