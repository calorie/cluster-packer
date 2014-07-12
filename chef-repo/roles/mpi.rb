name 'mpi'
description 'computing node'
run_list(
  'recipe[apt]',
  'recipe[timezone]',
  'recipe[ssh]',
  'recipe[git]',
  'recipe[gitconfig]',
  'recipe[openmpi]',
  'recipe[mpispec]',
  'recipe[nfs_client]'
)
