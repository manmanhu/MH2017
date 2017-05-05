[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 10
  ny = 8
  xmax = 2
  zmax = 0.1
[]

[MeshModifiers]
  [./notch]
    type = ElementFileSubdomain
    subdomain_ids = 1
    file = notch_elements.txt
  [../]
[]

[Variables]
  active = 'disp_z disp_y disp_x'
  [./Temperature]
  [../]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
  [../]
  [./pore_pressure]
  [../]
[]

[Functions]
  [./top_bc]
    type = ParsedFunction
    value = 0.01*t
  [../]
[]

[BCs]
  [./ux_top]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = top
    function = top_bc
  [../]
  [./ux_bottom]
    type = DirichletBC
    variable = disp_x
    boundary = bottom
    value = 0
  [../]
  [./uy_top]
    type = DirichletBC
    variable = disp_y
    boundary = top
    value = 0
  [../]
  [./Periodic]
    [./periodic_x]
      secondary = right
      primary = left
      auto_direction = x
    [../]
  [../]
  [./uy_bottom]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  [../]
  [./uz_back]
    type = DirichletBC
    variable = disp_z
    boundary = back
    value = 0
  [../]
[]

[Materials]
  [./mech_material]
    type = RedbackMechMaterialJ2
    block = 0
    disp_z = disp_z
    disp_y = disp_y
    disp_x = disp_x
    outputs = all
    yield_stress = '0 1 0.1 0.1'
    poisson_ratio = 0.3
    youngs_modulus = 100
  [../]
  [./no_mech_material]
    type = RedbackMaterial
    block = '0 1'
  [../]
  [./mech_notch]
    type = RedbackMechMaterialJ2
    block = 1
    disp_z = disp_z
    disp_y = disp_y
    disp_x = disp_x
    outputs = all
    yield_stress = '0 1 0.1 0.1'
    poisson_ratio = 0.3
    youngs_modulus = 99
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
    solve_type = PJFNK
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -ksp_gmres_restart'
    petsc_options_value = 'gmres asm lu 201'
  [../]
[]

[Executioner]
  type = Transient
  num_steps = 50
  [./TimeStepper]
    type = ConstantDT
    dt = 1e-1
  [../]
[]

[Outputs]
  exodus = true
  file_base = simple_shear_elastoviscoplastic
  print_perf_log = true
[]

[RedbackMechAction]
  [./my_action]
    disp_z = disp_z
    disp_x = disp_x
    disp_y = disp_y
  [../]
[]

