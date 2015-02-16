name 'local'
description 'localhost'
run_list(
  'recipe[docker]',
  'recipe[packer]',
  'recipe[vagrant]',
  'recipe[virtualbox]',
  'recipe[pdsh]'
)
